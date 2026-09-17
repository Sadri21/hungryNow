#!/usr/bin/env python3
"""
build-radar-lottie.py — generates `radar-sweep.json`, the Lottie for screen 05.

WHY A GENERATOR AND NOT A HAND-DRAWN FILE
-----------------------------------------
The radar was authored as CSS keyframes in `output/mockups/screen-05-loading.html`,
and that file is the spec: every radius, delay, easing curve and alpha stop in here
is transcribed from it. A Lottie exported from After Effects would be a re-draw —
someone eyeballing the CSS — and would drift the first time a token changed. This
script is the translation instead, so the CSS stays the single source of truth and
regenerating is free.

Run:  python3 build-radar-lottie.py <out.json>

WHAT DOES NOT SURVIVE THE TRANSLATION, AND WHAT WAS DONE ABOUT IT
-----------------------------------------------------------------
1. CONIC GRADIENT. The sweeping arm is a `conic-gradient()` in CSS. Lottie has no
   conic gradient — the format carries linear and radial only, and lottie-ios
   implements exactly those. The arm is therefore a fan of 15 flat wedges of 6°
   each, whose fill opacities sample the CSS gradient's stops at their midpoints.
   Banding is bounded by the largest alpha step, 0.06 at the leading edge, on a
   fill that never exceeds 0.37 alpha. Do not "fix" this with a radial gradient;
   a radial fade runs the wrong way (outward, not angularly) and reads as a blob.

2. THE PULSE RINGS' MAXIMUM SIZE IS DELIBERATELY NOT THE CSS VALUE. In the mockup
   `.ring` is a 52px circle scaled .28 -> 1, so it tops out at 52px — INSIDE the
   46px `.me` badge that is painted over it. The rings are effectively invisible in
   the mockup, which is almost certainly why nobody caught it: screen 05 has never
   been rendered. Every comment in that file describes the opposite behaviour
   ("expanding search rings", "= the 1.5km radius the backend actually searches",
   and a reduced-motion rule that parks three rings at different radii to read as
   concentric). This file implements the documented intent: rings expand from
   14.56 to 197 diameter, i.e. out to the dashed edge ring.
   -> Logged as a mockup defect. Fix the CSS to match, do not fix this to match
      the CSS.

3. RING STROKE WEIGHT IS HELD CONSTANT. A CSS `transform: scale()` scales the
   border with the box, so the mockup's ring would thicken 3.6x as it grows. Here
   the ellipse SIZE is animated and the stroke stays 1.6. A radar ring is a thin
   line at every radius; a thickening one reads as a growing donut.

4. EASING AT A WRAP POINT IS APPROXIMATED. Elements with an `animation-delay`
   have their cycle split across the loop boundary. Where the split lands mid
   segment, the sub-segment reuses the full easing curve rather than the
   de Casteljau split of it. Worst case measured on the pulse rings: 0.5px of
   position error on a 197px circle. Everything else splits inside a constant
   segment, where the error is exactly zero.

COLOUR
------
Colours are baked from the hexes below, which are `shared.css` :root / `Theme.swift`
`Palette` values. They are ALSO overridden at runtime from `Palette` through Lottie
keypaths — see `RadarView.swift`. That is what keeps the "Rust & Mustard" palette
swap a one-file edit; the baked values only matter if the override ever fails, and
then they are at least correct today. Every layer is named for that reason: the
names below ARE the theming API. Renaming one silently breaks the override, which
fails soft (wrong colour, no crash), so keep them in sync with `RadarPalette`.
"""

import json
import math
import sys

# ---------------------------------------------------------------------------
# Composition
# ---------------------------------------------------------------------------

FPS = 60
T = 180                      # 3s loop — the period every CSS animation on 05 shares
W = H = 200                  # the mockup's `.radar` box, 1:1 in mockup px
CX = CY = 100.0
EPS = 0.001                  # sub-frame gap used to express an instantaneous jump

# Easing, as CSS cubic-beziers. Lottie keyframe easing IS a cubic bezier over the
# same normalised space, so these transfer exactly rather than by approximation.
EASE_OUT = (0.0, 0.0, 0.58, 1.0)        # CSS `ease-out`
EASE_IN_OUT = (0.42, 0.0, 0.58, 1.0)    # CSS `ease-in-out`
LINEAR = None                            # omit i/o entirely


def hexc(h):
    return [((h >> 16) & 0xFF) / 255.0, ((h >> 8) & 0xFF) / 255.0, (h & 0xFF) / 255.0]


BG = hexc(0xF7F1EF)
HERO_SURFACE = hexc(0xA6243D)
HERO_TEXT = hexc(0x8A1E33)
SPEC_TEXT = hexc(0x4F6A38)
HAIRLINE = hexc(0xE7D9D4)
ON_HERO = hexc(0xFBF3EC)

# `--hero-fill` is hero-surface at 10% over the page ground. A Lottie fill carries
# its own opacity, so the colour stays hero-surface and the 10% goes on the fill's
# opacity — which is also what lets the runtime override set one colour and leave
# the alpha alone.
HERO_FILL_OPACITY = 10


# ---------------------------------------------------------------------------
# Easing evaluation and keyframe emission
# ---------------------------------------------------------------------------

def cb_eval(ez, x):
    """y at x on a CSS cubic-bezier(x1,y1,x2,y2). Newton, then clamp."""
    if ez is None:
        return x
    x1, y1, x2, y2 = ez
    t = x
    for _ in range(32):
        bx = 3 * (1 - t) ** 2 * t * x1 + 3 * (1 - t) * t * t * x2 + t ** 3
        d = 3 * (1 - t) ** 2 * x1 + 6 * (1 - t) * t * (x2 - x1) + 3 * t * t * (1 - x2)
        if abs(d) < 1e-12:
            break
        t = min(1.0, max(0.0, t - (bx - x) / d))
    return 3 * (1 - t) ** 2 * t * y1 + 3 * (1 - t) * t * t * y2 + t ** 3


def _clampx(v):
    # Lottie rejects an easing control point exactly on 0 or 1 in some renderers.
    return min(0.999, max(0.001, v))


def anim(keys):
    """keys: [(frame, [values], ease_of_the_segment_that_STARTS_here)].

    A Lottie keyframe's `o` is the out-control of the segment leaving it and `i`
    the in-control of the same segment — so one CSS timing function per segment
    maps onto one keyframe, not two.
    """
    out = []
    for idx, (t, vals, ez) in enumerate(keys):
        k = {"t": round(t, 4), "s": [round(v, 4) for v in vals]}
        if idx < len(keys) - 1 and ez is not None:
            x1, y1, x2, y2 = ez
            k["o"] = {"x": [_clampx(x1)], "y": [y1]}
            k["i"] = {"x": [_clampx(x2)], "y": [y2]}
        out.append(k)
    return {"a": 1, "k": out}


def prop(v):
    return {"a": 0, "k": v}


def shift_cycle(cycle, delay):
    """Express a CSS keyframe cycle with an `animation-delay` as one loop of keys.

    `cycle` is [(cycle_frame, [values], ease_after)] with the first at 0 and the
    last at T. `delay` is the CSS animation-delay in frames. The returned key list
    starts at frame 0 and ends at frame T with the same value, so the Lottie loops
    seamlessly — which is the whole reason this can't be a naive time offset.
    """
    ndim = len(cycle[0][1])
    q0 = (0.0 - delay) % T          # cycle time at composition frame 0

    def seg_of(q):
        for i in range(len(cycle) - 1):
            if cycle[i][0] <= q < cycle[i + 1][0]:
                return i
        return len(cycle) - 2

    def value_at(q):
        i = seg_of(q)
        cfa, va, ez = cycle[i]
        cfb, vb, _ = cycle[i + 1]
        if cfb == cfa:
            return list(va)
        y = cb_eval(ez, (q - cfa) / (cfb - cfa))
        return [va[k] + (vb[k] - va[k]) * y for k in range(ndim)]

    keys = [(0.0, value_at(q0), cycle[seg_of(q0)][2])]
    for cf, vals, ez in cycle[1:-1]:
        if cf > q0:
            keys.append((cf - q0, list(vals), ez))

    wrap = T - q0                    # composition frame at which the cycle ends
    if wrap >= T - EPS:
        # Cycle ends exactly on the loop boundary; jump back inside the last frame.
        keys.append((T - EPS, value_at(T - 1e-9), None))
        keys.append((T, list(cycle[0][1]), None))
    else:
        keys.append((wrap, list(cycle[-1][1]), None))
        keys.append((wrap + EPS, list(cycle[0][1]), cycle[0][2]))
        for cf, vals, ez in cycle[1:-1]:
            if wrap + cf < T - EPS:
                keys.append((wrap + cf, list(vals), ez))
        keys.append((T, value_at(q0), None))

    keys.sort(key=lambda k: k[0])
    return keys


# ---------------------------------------------------------------------------
# SVG path subset -> Lottie bezier
# ---------------------------------------------------------------------------

def _tokens(d):
    out, num, i = [], "", 0
    while i < len(d):
        c = d[i]
        if c.isalpha():
            if num:
                out.append(float(num)); num = ""
            out.append(c)
        elif c in "+-":
            # A sign starts a new number unless it is an exponent sign.
            if num and num[-1] not in "eE":
                out.append(float(num)); num = ""
            num += c
        elif c in ", \t\n\r":
            if num:
                out.append(float(num)); num = ""
        elif c == ".":
            if "." in num and "e" not in num.lower():
                out.append(float(num)); num = ""
            num += c
        else:
            num += c
        i += 1
    if num:
        out.append(float(num))
    return out


def arc_to_cubics(x0, y0, rx, ry, phi_deg, laf, sf, x1, y1):
    """SVG elliptical arc -> cubic segments (endpoint parameterisation, F.6.5)."""
    if rx == 0 or ry == 0 or (x0 == x1 and y0 == y1):
        return [((x0, y0), (x1, y1), (x1, y1))]
    phi = math.radians(phi_deg)
    cosp, sinp = math.cos(phi), math.sin(phi)
    dx2, dy2 = (x0 - x1) / 2.0, (y0 - y1) / 2.0
    x1p = cosp * dx2 + sinp * dy2
    y1p = -sinp * dx2 + cosp * dy2
    rx, ry = abs(rx), abs(ry)
    lam = (x1p * x1p) / (rx * rx) + (y1p * y1p) / (ry * ry)
    if lam > 1:
        s = math.sqrt(lam)
        rx, ry = rx * s, ry * s
    num = rx * rx * ry * ry - rx * rx * y1p * y1p - ry * ry * x1p * x1p
    den = rx * rx * y1p * y1p + ry * ry * x1p * x1p
    co = math.sqrt(max(0.0, num / den))
    if laf == sf:
        co = -co
    cxp = co * rx * y1p / ry
    cyp = -co * ry * x1p / rx
    cx = cosp * cxp - sinp * cyp + (x0 + x1) / 2.0
    cy = sinp * cxp + cosp * cyp + (y0 + y1) / 2.0

    def ang(ux, uy, vx, vy):
        dot = ux * vx + uy * vy
        n = math.hypot(ux, uy) * math.hypot(vx, vy)
        a = math.acos(max(-1.0, min(1.0, dot / n)))
        return -a if (ux * vy - uy * vx) < 0 else a

    ux, uy = (x1p - cxp) / rx, (y1p - cyp) / ry
    vx, vy = (-x1p - cxp) / rx, (-y1p - cyp) / ry
    th1 = ang(1, 0, ux, uy)
    dth = ang(ux, uy, vx, vy)
    if sf == 0 and dth > 0:
        dth -= 2 * math.pi
    if sf == 1 and dth < 0:
        dth += 2 * math.pi

    n_seg = max(1, int(math.ceil(abs(dth) / (math.pi / 2) - 1e-9)))
    step = dth / n_seg
    k = 4.0 / 3.0 * math.tan(step / 4.0)
    segs, px, py, th = [], x0, y0, th1
    for _ in range(n_seg):
        th2 = th + step
        ex = cx + cosp * (rx * math.cos(th2)) - sinp * (ry * math.sin(th2))
        ey = cy + sinp * (rx * math.cos(th2)) + cosp * (ry * math.sin(th2))
        d1x = cosp * (-rx * math.sin(th)) - sinp * (ry * math.cos(th))
        d1y = sinp * (-rx * math.sin(th)) + cosp * (ry * math.cos(th))
        d2x = cosp * (-rx * math.sin(th2)) - sinp * (ry * math.cos(th2))
        d2y = sinp * (-rx * math.sin(th2)) + cosp * (ry * math.cos(th2))
        segs.append(((px + k * d1x, py + k * d1y), (ex - k * d2x, ey - k * d2y), (ex, ey)))
        px, py, th = ex, ey, th2
    return segs


def parse_path(d):
    """-> list of subpaths, each {"nodes": [{"v","i","o"}], "closed": bool}."""
    tk = _tokens(d)
    subs, nodes = [], []
    cx = cy = sx = sy = 0.0
    prev_c2 = None
    cmd = None
    i = 0

    def flush(closed=False):
        nonlocal nodes
        if len(nodes) > 1:
            subs.append({"nodes": nodes, "closed": closed})
        nodes = []

    def add_cubic(c1, c2, end):
        nodes[-1]["o"] = (c1[0] - nodes[-1]["v"][0], c1[1] - nodes[-1]["v"][1])
        nodes.append({"v": end, "i": (c2[0] - end[0], c2[1] - end[1]), "o": (0.0, 0.0)})

    def add_line(end):
        nodes[-1]["o"] = (0.0, 0.0)
        nodes.append({"v": end, "i": (0.0, 0.0), "o": (0.0, 0.0)})

    while i < len(tk):
        if isinstance(tk[i], str):
            cmd = tk[i]
            i += 1
            if cmd in "Zz":
                flush(closed=True)
                cx, cy = sx, sy
                prev_c2 = None
                continue
        rel = cmd.islower()
        c = cmd.upper()
        if c == "M":
            x, y = tk[i], tk[i + 1]; i += 2
            if rel:
                x, y = cx + x, cy + y
            flush()
            nodes = [{"v": (x, y), "i": (0.0, 0.0), "o": (0.0, 0.0)}]
            cx, cy = sx, sy = x, y
            prev_c2 = None
            cmd = "l" if rel else "L"
        elif c == "L":
            x, y = tk[i], tk[i + 1]; i += 2
            if rel:
                x, y = cx + x, cy + y
            add_line((x, y)); cx, cy = x, y; prev_c2 = None
        elif c == "H":
            x = tk[i]; i += 1
            if rel:
                x = cx + x
            add_line((x, cy)); cx = x; prev_c2 = None
        elif c == "V":
            y = tk[i]; i += 1
            if rel:
                y = cy + y
            add_line((cx, y)); cy = y; prev_c2 = None
        elif c == "C":
            x1, y1, x2, y2, x, y = tk[i:i + 6]; i += 6
            if rel:
                x1, y1, x2, y2, x, y = cx + x1, cy + y1, cx + x2, cy + y2, cx + x, cy + y
            add_cubic((x1, y1), (x2, y2), (x, y))
            prev_c2 = (x2, y2); cx, cy = x, y
        elif c == "S":
            x2, y2, x, y = tk[i:i + 4]; i += 4
            if rel:
                x2, y2, x, y = cx + x2, cy + y2, cx + x, cy + y
            # Reflection of the previous second control; the current point when there
            # was no previous curve — which is the case for screen 05's pin glyph.
            x1, y1 = (2 * cx - prev_c2[0], 2 * cy - prev_c2[1]) if prev_c2 else (cx, cy)
            add_cubic((x1, y1), (x2, y2), (x, y))
            prev_c2 = (x2, y2); cx, cy = x, y
        elif c == "A":
            rx, ry, rot, laf, sf, x, y = tk[i:i + 7]; i += 7
            if rel:
                x, y = cx + x, cy + y
            for c1, c2, end in arc_to_cubics(cx, cy, rx, ry, rot, int(laf), int(sf), x, y):
                add_cubic(c1, c2, end)
            prev_c2 = None; cx, cy = x, y
        else:
            raise ValueError("unsupported path command %r" % cmd)
    flush()
    return subs


def to_shapes(subs, k, ox=12.0, oy=12.0):
    """Map grid units to layer-local points: the glyph's grid centre becomes (0,0)."""
    out = []
    for sub in subs:
        vs, ins, os_ = [], [], []
        for n in sub["nodes"]:
            vs.append([round((n["v"][0] - ox) * k, 4), round((n["v"][1] - oy) * k, 4)])
            ins.append([round(n["i"][0] * k, 4), round(n["i"][1] * k, 4)])
            os_.append([round(n["o"][0] * k, 4), round(n["o"][1] * k, 4)])
        out.append({
            "ty": "sh", "d": 1, "hd": False, "nm": "path",
            "ks": prop({"i": ins, "o": os_, "v": vs, "c": sub["closed"]}),
        })
    return out


# ---------------------------------------------------------------------------
# Lottie primitives
# ---------------------------------------------------------------------------

def tr():
    return {"ty": "tr", "nm": "Transform", "p": prop([0, 0]), "a": prop([0, 0]),
            "s": prop([100, 100]), "r": prop(0), "o": prop(100),
            "sk": prop(0), "sa": prop(0)}


def group(name, items):
    items = list(items) + [tr()]
    return {"ty": "gr", "nm": name, "np": len(items), "cix": 2, "ix": 1,
            "bm": 0, "hd": False, "it": items}


def stroke(color, width, dash=None, opacity=100):
    s = {"ty": "st", "nm": "stroke", "hd": False, "bm": 0,
         "c": prop(color + [1]), "o": prop(opacity), "w": prop(width),
         "lc": 2, "lj": 2, "ml": 1}
    if dash:
        s["d"] = [{"n": "d", "nm": "dash", "v": prop(dash[0])},
                  {"n": "g", "nm": "gap", "v": prop(dash[1])}]
    return s


def fill(color, opacity=100):
    return {"ty": "fl", "nm": "fill", "hd": False, "bm": 0, "r": 1,
            "c": prop(color + [1]), "o": prop(opacity)}


def ellipse(diameter, pos=(0, 0)):
    return {"ty": "el", "d": 1, "hd": False, "nm": "ellipse",
            "s": prop([diameter, diameter]), "p": prop(list(pos))}


def ellipse_animated(size_keys, pos=(0, 0)):
    return {"ty": "el", "d": 1, "hd": False, "nm": "ellipse",
            "s": anim(size_keys), "p": prop(list(pos))}


def layer(ind, name, shapes, pos=(CX, CY), scale=None, opacity=None, rotation=None):
    return {
        "ddd": 0, "ind": ind, "ty": 4, "nm": name, "sr": 1, "ao": 0, "bm": 0,
        "ks": {
            "o": opacity if opacity is not None else prop(100),
            "r": rotation if rotation is not None else prop(0),
            "p": prop([pos[0], pos[1], 0]),
            # Anchor at the layer origin, so `s` scales about the element's own
            # centre — this is what makes the pop and the heartbeat land correctly
            # without any parenting.
            "a": prop([0, 0, 0]),
            "s": scale if scale is not None else prop([100, 100, 100]),
        },
        "shapes": shapes, "ip": 0, "op": T, "st": 0,
    }


# ---------------------------------------------------------------------------
# Elements
# ---------------------------------------------------------------------------

def dashed(radius, stroke_w, segments):
    """Dash length that divides the circumference evenly, so there is no visible
    seam where the dash pattern wraps — the one thing a hand-set dash always gets
    wrong on a circle."""
    step = (2 * math.pi * radius) / segments
    return (round(step / 2, 4), round(step / 2, 4))


def build_layers():
    layers = []
    ind = [0]

    def add(name, shapes, **kw):
        ind[0] += 1
        layers.append(layer(ind[0], name, shapes, **kw))

    # --- front to back. layers[0] is the topmost, matching the mockup's DOM order
    #     read bottom-up: ring-edge, ring-mid, sweep, pulses, pins, me.

    # `.me` — you, at the centre. 46px disc, `mebeat` scale pulse.
    mebeat = [(0.0, [100, 100, 100], EASE_IN_OUT),
              (0.08 * T, [108, 108, 100], EASE_IN_OUT),
              (0.20 * T, [100, 100, 100], EASE_IN_OUT),
              (float(T), [100, 100, 100], None)]
    k_me = 20.0 / 24.0
    add("me-glyph",
        [group("g", to_shapes(parse_path("M15.5 15.5L21 21"), k_me)
                            + [ellipse(2 * 6 * k_me, ((11 - 12) * k_me, (11 - 12) * k_me))]
                            + [stroke(ON_HERO, 1.9 * k_me)])],
        scale=anim(mebeat))
    add("me-face", [group("g", [ellipse(46), fill(HERO_SURFACE)])], scale=anim(mebeat))

    # --- `.pin` — places being found. Each pops in as the arm crosses it, then holds.
    #
    # Positions are the mockup's percentages of the 200px box, and the delays are
    # its delays. The two are coupled: the arm starts at 12 o'clock and turns
    # 120 deg/s, so a pin's angle IS its delay x 120. Change one and the causal
    # illusion — "it appeared because the beam found it" — breaks. Do not nudge a
    # position for composition without recomputing the delay.
    pop_scale = [(0.0, [0, 0, 100], EASE_OUT),
                 (0.09 * T, [118, 118, 100], EASE_OUT),
                 (0.16 * T, [100, 100, 100], EASE_OUT),
                 (0.88 * T, [100, 100, 100], EASE_OUT),
                 (float(T), [100, 100, 100], None)]
    pop_opacity = [(0.0, [0], EASE_OUT),
                   (0.09 * T, [100], EASE_OUT),
                   (0.16 * T, [100], EASE_OUT),
                   (0.88 * T, [100], EASE_OUT),
                   (float(T), [0], None)]

    NOODLE = ["M4 11h16", "M6 11a6 6 0 0 0 12 0", "M3 20h18"]
    SKEWER = ["M6 18L18 6"]
    CUP = ["M6 7h11v6a5.5 5.5 0 0 1-11 0z", "M17 8h2.5a2 2 0 0 1 0 4H17"]
    PINGLYPH = ["M12 21s7-7.2 7-12a7 7 0 1 0-14 0c0 4.8 7 12 7 12z"]
    RICE = ["M4 12h16a8 8 0 0 1-16 0z", "M8.5 9.5c.8-1.2 2-1.8 3.5-1.8s2.7.6 3.5 1.8"]

    k_pin = 15.0 / 24.0
    pins = [
        # (index, left%, top%, delay_s, hero, stroked_paths, stroked_circles, filled_circles)
        (1, 0.791, 0.288, 0.45, False, NOODLE, [], []),
        (2, 0.774, 0.622, 0.95, False, SKEWER, [(10.5, 13.5, 2.1), (14.5, 9.5, 2.1)], []),
        (3, 0.536, 0.838, 1.45, False, CUP, [], []),
        (4, 0.241, 0.688, 1.95, True, PINGLYPH, [], [(12, 9, 2.4)]),
        (5, 0.167, 0.429, 2.35, False, RICE, [], []),
    ]

    for n, lx, ty_, delay_s, hero, paths, scirc, fcirc in pins:
        d = delay_s * FPS
        pos = (round(lx * W, 3), round(ty_ * H, 3))
        s_keys = anim(shift_cycle(pop_scale, d))
        o_keys = anim(shift_cycle(pop_opacity, d))

        glyph_items = []
        for p in paths:
            glyph_items += to_shapes(parse_path(p), k_pin)
        for cxg, cyg, r in scirc:
            glyph_items.append(ellipse(2 * r * k_pin, ((cxg - 12) * k_pin, (cyg - 12) * k_pin)))
        glyph_items.append(stroke(HERO_TEXT if hero else SPEC_TEXT, 1.9 * k_pin))
        add("pin-%d-glyph" % n, [group("g", glyph_items)],
            pos=pos, scale=s_keys, opacity=o_keys)

        if fcirc:
            # The hero pin's centre dot: `fill=currentColor stroke=none`, so it is a
            # second shape group with a fill, not part of the stroked outline.
            dot_items = [ellipse(2 * r * k_pin, ((cxg - 12) * k_pin, (cyg - 12) * k_pin))
                         for cxg, cyg, r in fcirc]
            dot_items.append(fill(HERO_TEXT if hero else SPEC_TEXT))
            add("pin-%d-dot" % n, [group("g", dot_items)],
                pos=pos, scale=s_keys, opacity=o_keys)

        # CSS paints a border inside the box, so a 30px circle with a 1.6px border
        # has its stroke centreline at r = 15 - 0.8. The background still fills the
        # whole 30px. Two layers, because the fill and the stroke are separately
        # themed (`--bg` vs `--spec-text`, `--hero-fill` vs `--hero-surface`).
        add("pin-%d-ring" % n,
            [group("g", [ellipse(30 - 1.6), stroke(HERO_SURFACE if hero else SPEC_TEXT, 1.6)])],
            pos=pos, scale=s_keys, opacity=o_keys)
        add("pin-%d-face" % n,
            [group("g", [ellipse(30), fill(HERO_SURFACE if hero else BG,
                                           HERO_FILL_OPACITY if hero else 100)])],
            pos=pos, scale=s_keys, opacity=o_keys)

    # --- Expanding search rings. See note 2 in the header: these reach the dashed
    #     edge ring, which is what the mockup describes and not what its CSS does.
    RING_MIN = 52 * 0.28        # 14.56 — the mockup's own start size
    RING_MAX = 197.0            # dashed edge ring, less half a stroke, less 1px of
                                # bleed so nothing touches the composition bounds
    ring_size = [(0.0, [RING_MIN, RING_MIN], EASE_OUT), (float(T), [RING_MAX, RING_MAX], None)]
    ring_opacity = [(0.0, [0], EASE_OUT), (0.12 * T, [55], EASE_OUT), (float(T), [0], None)]
    for n, delay_s in ((3, 2.0), (2, 1.0), (1, 0.0)):
        d = delay_s * FPS
        add("pulse-%d" % n,
            [group("g", [ellipse_animated(shift_cycle(ring_size, d)),
                         stroke(HERO_SURFACE, 1.6)])],
            opacity=anim(shift_cycle(ring_opacity, d)))

    # --- The sweeping arm, as a fan of 30 NESTED sectors. See note 1 in the header.
    #
    # The CSS conic gradient runs `from -90deg` (angle 0 at 12 o'clock) and ramps up
    # to the leading edge at 360deg, so the tail sits BEHIND the arm as it turns
    # clockwise. Written the other way round the radar reads as spinning backwards,
    # which is the bug the mockup comment warns about.
    #
    # NESTED, not abutting — and this is the whole trick. The obvious build is 30
    # slices side by side, each at its own alpha. Rendered, that shows 30 light
    # radial seams: every slice antialiases its two radial edges against the
    # BACKGROUND, so each shared edge loses a fraction of a pixel of coverage from
    # both sides. (Caught in a render; completely invisible in the numbers.)
    # Instead every sector runs from the leading edge back to its own angle, so they
    # stack, and an edge antialiases against the sector underneath rather than
    # against nothing. Incremental alphas are solved so the accumulated
    # `1 - prod(1 - a_j)` lands exactly on the gradient's value — the product
    # telescopes, so this is exact, not fitted.
    STOPS = [(0.0, 0.40), (12.0, 0.28), (30.0, 0.14), (60.0, 0.04), (90.0, 0.0)]

    def alpha_behind(deg):
        for i in range(len(STOPS) - 1):
            a, va = STOPS[i]
            b, vb = STOPS[i + 1]
            if a <= deg <= b:
                return va + (vb - va) * ((deg - a) / (b - a))
        return 0.0

    R_ARM = 100.0
    N_SEG = 30
    WEDGE = 90.0 / N_SEG

    # Target alpha per angular band, then the incremental alpha each nested sector
    # contributes. A[N_SEG] = 0 closes the recurrence at the tail.
    A = [alpha_behind(WEDGE * k + WEDGE / 2.0) for k in range(N_SEG)] + [0.0]
    inc = [1.0 - (1.0 - A[k]) / (1.0 - A[k + 1]) for k in range(N_SEG)]

    def sector_path(r, deg_from, deg_to, max_seg=30.0):
        """Pie sector, angles clockwise from 12 o'clock. Arc split so no cubic
        spans more than `max_seg` degrees — a single cubic over 90 deg is visibly
        flat at this radius."""
        a1, a2 = math.radians(deg_from), math.radians(deg_to)
        n = max(1, int(math.ceil(abs(deg_to - deg_from) / max_seg - 1e-9)))
        step = (a2 - a1) / n
        k = 4.0 / 3.0 * math.tan(step / 4.0) * r
        v, ins, outs = [[0.0, 0.0]], [[0.0, 0.0]], [[0.0, 0.0]]
        for j in range(n + 1):
            a = a1 + step * j
            v.append([r * math.sin(a), -r * math.cos(a)])
            tan = (k * math.cos(a), k * math.sin(a))
            ins.append([0.0, 0.0] if j == 0 else [-tan[0], -tan[1]])
            outs.append([0.0, 0.0] if j == n else [tan[0], tan[1]])
        rnd = lambda pts: [[round(x, 4), round(y, 4)] for x, y in pts]
        return {"v": rnd(v), "i": rnd(ins), "o": rnd(outs), "c": True}

    wedge_groups = []
    for j in range(N_SEG):
        wedge_groups.append(group("w%02d" % j, [
            {"ty": "sh", "d": 1, "hd": False, "nm": "path",
             "ks": prop(sector_path(R_ARM, -(WEDGE * (j + 1)), 0.0))},
            fill(HERO_SURFACE, round(inc[j] * 100, 4)),
        ]))
    add("sweep", wedge_groups,
        rotation=anim([(0.0, [0], LINEAR), (float(T), [360], None)]))

    # --- Static faint rings, so the space reads as a searched area between sweeps.
    R_MID = 70 - 0.65
    add("ring-mid",
        [group("g", [ellipse(2 * R_MID), stroke(HAIRLINE, 1.3, dash=dashed(R_MID, 1.3, 49))])],
        opacity=prop(70))
    R_EDGE = 99.0
    add("ring-edge",
        [group("g", [ellipse(2 * R_EDGE), stroke(HAIRLINE, 1.3, dash=dashed(R_EDGE, 1.3, 70))])])

    return layers


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else "radar-sweep.json"
    doc = {
        "v": "5.9.0", "fr": FPS, "ip": 0, "op": T, "w": W, "h": H,
        "nm": "radar-sweep", "ddd": 0, "assets": [], "markers": [],
        "layers": build_layers(),
    }
    with open(out, "w") as f:
        json.dump(doc, f, separators=(",", ":"))
    print("wrote %s (%d layers)" % (out, len(doc["layers"])))


if __name__ == "__main__":
    main()
