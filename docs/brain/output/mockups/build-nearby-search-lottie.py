#!/usr/bin/env python3
"""Build a self-contained Screen 5 Lottie from the approved PNG and vector lens."""

import base64
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SOURCE = ROOT / "loading-nearby-food-search-900.png"
OUTPUT = ROOT / "hungrynow-nearby-search-v3.json"


def static(value):
    return {"a": 0, "k": value}


def transform(position, anchor=(0, 0, 0), scale=(100, 100, 100), rotation=0):
    return {
        "o": static(100),
        "r": static(rotation),
        "p": static(list(position)),
        "a": static(list(anchor)),
        "s": static(list(scale)),
    }


ease_in = {"x": [0.667], "y": [1]}
ease_out = {"x": [0.333], "y": [0]}
positions = [
    {"t": 0, "s": [160, 64, 0], "i": ease_in, "o": ease_out},
    {"t": 43, "s": [84, 134, 0], "i": ease_in, "o": ease_out},
    {"t": 96, "s": [146, 230, 0], "i": ease_in, "o": ease_out},
    {"t": 151, "s": [236, 166, 0], "i": ease_in, "o": ease_out},
    {"t": 190, "s": [205, 88, 0], "i": ease_in, "o": ease_out},
    {"t": 216, "s": [160, 64, 0]},
]
rotations = [
    {"t": 0, "s": [-18]},
    {"t": 43, "s": [-34]},
    {"t": 96, "s": [8]},
    {"t": 151, "s": [26]},
    {"t": 190, "s": [-10]},
    {"t": 216, "s": [-18]},
]

lens = {
    "ddd": 0,
    "ind": 1,
    "ty": 4,
    "nm": "Searching magnifying glass",
    "sr": 1,
    "ks": {
        "o": static(100),
        "r": {"a": 1, "k": rotations},
        "p": {"a": 1, "k": positions},
        "a": static([0, 0, 0]),
        "s": static([100, 100, 100]),
    },
    "shapes": [
        {
            "ty": "gr",
            "nm": "Lens",
            "it": [
                {"d": 1, "ty": "el", "s": static([52, 52]), "p": static([0, 0])},
                {"ty": "fl", "c": static([0.651, 0.141, 0.239, 1]), "o": static(16), "r": 1},
                {"ty": "st", "c": static([0.169, 0.082, 0.071, 1]), "o": static(100), "w": static(5), "lc": 2, "lj": 2},
                {"ty": "tr", "p": static([0, 0]), "a": static([0, 0]), "s": static([100, 100]), "r": static(0), "o": static(100)},
            ],
        },
        {
            "ty": "gr",
            "nm": "Handle",
            "it": [
                {
                    "ty": "sh",
                    "ks": static({
                        "i": [[0, 0], [0, 0]],
                        "o": [[0, 0], [0, 0]],
                        "v": [[18.5, 18.5], [45, 45]],
                        "c": False,
                    }),
                },
                {"ty": "st", "c": static([0.169, 0.082, 0.071, 1]), "o": static(100), "w": static(9), "lc": 2, "lj": 2},
                {"ty": "tr", "p": static([0, 0]), "a": static([0, 0]), "s": static([100, 100]), "r": static(0), "o": static(100)},
            ],
        },
    ],
    "ip": 0,
    "op": 216,
    "st": 0,
    "bm": 0,
}

encoded = base64.b64encode(SOURCE.read_bytes()).decode("ascii")
document = {
    "v": "5.7.4",
    "fr": 30,
    "ip": 0,
    "op": 216,
    "w": 320,
    "h": 320,
    "nm": "HungryNow nearby restaurant search v3",
    "ddd": 0,
    "assets": [{
        "id": "screen5_illustration",
        "w": 900,
        "h": 900,
        "u": "",
        "p": f"data:image/png;base64,{encoded}",
        "e": 1,
    }],
    "layers": [
        lens,
        {
            "ddd": 0,
            "ind": 2,
            "ty": 2,
            "nm": "Exact Screen 5 location illustration",
            "refId": "screen5_illustration",
            "sr": 1,
            "ks": transform([160, 160, 0], [450, 450, 0], [24.4444, 24.4444, 100]),
            "ao": 0,
            "ip": 0,
            "op": 216,
            "st": 0,
            "bm": 0,
        },
    ],
    "markers": [],
}

OUTPUT.write_text(json.dumps(document, separators=(",", ":")) + "\n")
print(OUTPUT)
