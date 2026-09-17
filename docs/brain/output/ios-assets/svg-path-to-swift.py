#!/usr/bin/env python3
"""
svg-path-to-swift.py — turns a mockup glyph's SVG `d` attribute into SwiftUI `Path` code.

Exists because every glyph ported so far has needed this by hand, and two of them got it
wrong. `LocationPinShape` carries the note: SwiftUI's `addArc` is CENTRE-parameterised and
its `clockwise` flag is measured in SwiftUI's flipped coordinate space, so it reads
backwards from what an SVG `A` command says — which is why that shape ended up as hand
written kappa Béziers. This does the endpoint->centre conversion (SVG spec F.6.5) and emits
cubics, so the arc geometry is derived rather than eyeballed.

Emitted code is in GRID UNITS through a local `p(x, y)` helper, matching how
`AppGlyphs.swift` already writes its shapes: `let s = min(w, h) / grid`.

Usage:
  python3 svg-path-to-swift.py "M6 11a6 6 0 0 0 12 0"
  python3 svg-path-to-swift.py --grid 16 "M11 11L14.5 14.5"

Reuses the parser in radar-lottie/build-radar-lottie.py — one implementation of the SVG
path subset, not two.
"""

import importlib.util
import os
import sys

_here = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location(
    "radarbuild", os.path.join(_here, "radar-lottie", "build-radar-lottie.py"))
_rb = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_rb)


def fmt(v):
    r = round(v, 4)
    return str(int(r)) if r == int(r) else str(r)


def to_swift(d):
    lines = []
    for sub in _rb.parse_path(d):
        nodes = sub["nodes"]
        v0 = nodes[0]["v"]
        lines.append("path.move(to: p(%s, %s))" % (fmt(v0[0]), fmt(v0[1])))
        for i in range(1, len(nodes)):
            prev, cur = nodes[i - 1], nodes[i]
            o, ci, v = prev["o"], cur["i"], cur["v"]
            straight = (abs(o[0]) < 1e-9 and abs(o[1]) < 1e-9
                        and abs(ci[0]) < 1e-9 and abs(ci[1]) < 1e-9)
            if straight:
                lines.append("path.addLine(to: p(%s, %s))" % (fmt(v[0]), fmt(v[1])))
            else:
                lines.append(
                    "path.addCurve(to: p(%s, %s), control1: p(%s, %s), control2: p(%s, %s))"
                    % (fmt(v[0]), fmt(v[1]),
                       fmt(prev["v"][0] + o[0]), fmt(prev["v"][1] + o[1]),
                       fmt(v[0] + ci[0]), fmt(v[1] + ci[1])))
        if sub["closed"]:
            lines.append("path.closeSubpath()")
    return lines


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if a != "--grid"]
    for d in args:
        if d.replace(".", "").isdigit():
            continue
        print("// " + d)
        for line in to_swift(d):
            print(line)
        print()
