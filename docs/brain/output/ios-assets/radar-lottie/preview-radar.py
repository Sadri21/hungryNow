#!/usr/bin/env python3
"""
preview-radar.py — renders one frame of a Lottie shape animation to SVG.

Exists because of the lesson `checklist.md` has now logged six times: shape
decisions that are obviously wrong in a render are invisible in the arithmetic.
This covers only the subset `build-radar-lottie.py` emits (shape layers, ellipses,
bezier paths, solid fills and strokes, dashes, transform + opacity keyframes) —
it is a checking tool, not a Lottie player.

Usage: python3 preview-radar.py radar-sweep.json <frame> out.svg
"""

import json
import math
import sys


def cb(ez_o, ez_i, x):
    if ez_o is None or ez_i is None:
        return x
    x1, y1 = ez_o["x"][0], ez_o["y"][0]
    x2, y2 = ez_i["x"][0], ez_i["y"][0]
    t = x
    for _ in range(32):
        bx = 3 * (1 - t) ** 2 * t * x1 + 3 * (1 - t) * t * t * x2 + t ** 3
        d = 3 * (1 - t) ** 2 * x1 + 6 * (1 - t) * t * (x2 - x1) + 3 * t * t * (1 - x2)
        if abs(d) < 1e-12:
            break
        t = min(1.0, max(0.0, t - (bx - x) / d))
    return 3 * (1 - t) ** 2 * t * y1 + 3 * (1 - t) * t * t * y2 + t ** 3


def val(p, f):
    if p.get("a", 0) == 0:
        return p["k"]
    ks = p["k"]
    if f <= ks[0]["t"]:
        return ks[0]["s"]
    for i in range(len(ks) - 1):
        a, b = ks[i], ks[i + 1]
        if a["t"] <= f <= b["t"]:
            span = b["t"] - a["t"]
            u = 0.0 if span == 0 else (f - a["t"]) / span
            y = cb(a.get("o"), a.get("i"), u)
            return [a["s"][k] + (b["s"][k] - a["s"][k]) * y for k in range(len(a["s"]))]
    return ks[-1]["s"]


def sc(v):
    return v[0] if isinstance(v, list) else v


def path_d(k):
    v, i, o, closed = k["v"], k["i"], k["o"], k.get("c", False)
    if not v:
        return ""
    d = "M %.3f %.3f" % (v[0][0], v[0][1])
    n = len(v)
    for j in range(1, n):
        d += " C %.3f %.3f %.3f %.3f %.3f %.3f" % (
            v[j - 1][0] + o[j - 1][0], v[j - 1][1] + o[j - 1][1],
            v[j][0] + i[j][0], v[j][1] + i[j][1], v[j][0], v[j][1])
    if closed:
        d += " C %.3f %.3f %.3f %.3f %.3f %.3f Z" % (
            v[n - 1][0] + o[n - 1][0], v[n - 1][1] + o[n - 1][1],
            v[0][0] + i[0][0], v[0][1] + i[0][1], v[0][0], v[0][1])
    return d


def rgb(c):
    return "rgb(%d,%d,%d)" % (round(c[0] * 255), round(c[1] * 255), round(c[2] * 255))


def render_group(items, f, out):
    paths, fl, st = [], None, None
    for it in items:
        ty = it["ty"]
        if ty == "sh":
            paths.append(('p', path_d(val(it["ks"], f))))
        elif ty == "el":
            s = val(it["s"], f)
            p = val(it["p"], f)
            paths.append(('e', (p[0], p[1], s[0] / 2.0, s[1] / 2.0)))
        elif ty == "fl":
            fl = (rgb(val(it["c"], f)), sc(val(it["o"], f)) / 100.0)
        elif ty == "st":
            dash = ""
            if "d" in it:
                dl = sc(val(it["d"][0]["v"], f))
                gp = sc(val(it["d"][1]["v"], f))
                dash = ' stroke-dasharray="%.3f %.3f"' % (dl, gp)
            st = (rgb(val(it["c"], f)), sc(val(it["o"], f)) / 100.0,
                  sc(val(it["w"], f)), dash)
        elif ty == "gr":
            render_group(it["it"], f, out)
    for kind, g in paths:
        attrs = ""
        if fl:
            attrs += ' fill="%s" fill-opacity="%.4f"' % fl
        else:
            attrs += ' fill="none"'
        if st:
            attrs += (' stroke="%s" stroke-opacity="%.4f" stroke-width="%.4f"'
                      ' stroke-linecap="round" stroke-linejoin="round"%s' % st)
        if kind == 'p':
            out.append('<path d="%s"%s/>' % (g, attrs))
        else:
            out.append('<ellipse cx="%.3f" cy="%.3f" rx="%.3f" ry="%.3f"%s/>'
                       % (g[0], g[1], g[2], g[3], attrs))


def main():
    src, frame, dst = sys.argv[1], float(sys.argv[2]), sys.argv[3]
    doc = json.load(open(src))
    out = ['<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d">'
           % (doc["w"] * 2, doc["h"] * 2, doc["w"], doc["h"]),
           '<rect width="%d" height="%d" fill="#F7F1EF"/>' % (doc["w"], doc["h"])]
    for l in reversed(doc["layers"]):          # layers[0] is topmost
        ks = l["ks"]
        p = val(ks["p"], frame)
        s = val(ks["s"], frame)
        r = sc(val(ks["r"], frame))
        o = sc(val(ks["o"], frame)) / 100.0
        a = val(ks["a"], frame)
        out.append('<g opacity="%.4f" transform="translate(%.3f,%.3f) rotate(%.3f) '
                   'scale(%.5f,%.5f) translate(%.3f,%.3f)">'
                   % (o, p[0], p[1], r, s[0] / 100.0, s[1] / 100.0, -a[0], -a[1]))
        render_group(l["shapes"], frame, out)
        out.append('</g>')
    out.append('</svg>')
    open(dst, "w").write("\n".join(out))
    print("wrote", dst)


if __name__ == "__main__":
    main()
