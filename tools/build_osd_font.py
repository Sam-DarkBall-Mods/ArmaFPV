#!/usr/bin/env python3
"""Build the ArmaFPV_OSD font family from the Betaflight analog OSD font.

Source: tools/osd_font/betaflight.mcm from betaflight-configurator
(resources/osd/2/betaflight.mcm, GPL-3.0). MAX7456 glyphs are 12 x 18 px,
two bits per pixel: 00 black, 10 white, 01/11 transparent.

ASCII 0x20-0x5F keeps its codes, a-z draws as A-Z (the OSD has no lower case),
OSD symbols are mapped to U+E000 + their Betaflight code.

Usage: python tools/build_osd_font.py   (needs Pillow and hemtt on PATH)
"""
import struct
import subprocess
import tempfile
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
MCM = ROOT / "tools" / "osd_font" / "betaflight.mcm"
OUT = ROOT / "addons" / "ArmaFPV" / "font" / "osd"
HPP = ROOT / "addons" / "ArmaFPV" / "includes" / "OSDFont.hpp"
NAME = "ArmaFPV_OSD"
GAME_DIR = "\\ArmaFPV\\font\\osd\\"
HEIGHTS = [30, 33, 36, 39, 42, 46, 50, 54, 59, 64, 70, 76, 83, 90, 98, 107, 117, 128, 140]
PAL_ASPECT = 16 / 15
SYMBOLS = [0x01, 0x06, 0x07, 0x0C, 0x72, 0x73, 0x74, 0x7B, 0x7F,
           0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x9A, 0x9B, 0x9C]
GAP = 4
MARGIN = 2


def load_mcm():
    lines = [l.strip() for l in MCM.read_text().splitlines()[1:] if l.strip()]
    glyphs = []
    for c in range(256):
        bits = "".join(lines[c * 64:c * 64 + 54])
        img = Image.new("RGBA", (12, 18), (0, 0, 0, 0))
        for i in range(216):
            p = bits[i * 2:i * 2 + 2]
            if p == "00":
                img.putpixel((i % 12, i // 12), (0, 0, 0, 255))
            elif p == "10":
                img.putpixel((i % 12, i // 12), (255, 255, 255, 255))
        glyphs.append(img)
    return glyphs


def charmap():
    m = {c: c for c in range(0x20, 0x60)}
    m.update({c: c - 0x20 for c in range(0x61, 0x7B)})
    m.update({0xE000 + s: s for s in SYMBOLS})
    return m


def scaled(img, h):
    w = round(12 * PAL_ASPECT * h / 18)
    k = -(-h // 18)
    big = img.resize((12 * k, 18 * k), Image.NEAREST)
    return big.resize((w, h), Image.BOX)


def pot(n):
    p = 1
    while p < n:
        p *= 2
    return p


def build_size(glyphs, cmap, h, tmp):
    w = round(12 * PAL_ASPECT * h / 18)
    codes = sorted(cmap)
    per_row = max(1, (2048 - 2 * MARGIN) // (w + GAP))
    rows = -(-len(codes) // per_row)
    pw = pot(min(len(codes), per_row) * (w + GAP) + 2 * MARGIN)
    ph = pot(rows * (h + GAP) + 2 * MARGIN)
    page = Image.new("RGBA", (pw, ph), (255, 255, 255, 0))
    records = []
    cache = {}
    for i, code in enumerate(codes):
        src = cmap[code]
        if src == 0x20:
            records.append((code, 2, 2, 0, 0, 0, 0, w))
            continue
        if src not in cache:
            cache[src] = scaled(glyphs[src], h)
        x = MARGIN + (i % per_row) * (w + GAP)
        y = MARGIN + (i // per_row) * (h + GAP)
        page.alpha_composite(cache[src], (x, y))
        records.append((code, x, y, w, h, 0, 0, w))
    base = f"{NAME}{h}"
    png = Path(tmp) / f"{base}-01.png"
    page.save(png)
    subprocess.run(["hemtt", "utils", "paa", "convert", str(png), str(OUT / f"{base}-01.paa")],
                   check=True, capture_output=True)
    fxy = bytearray(b"BIFo" + struct.pack("<I", 258))
    fxy += struct.pack("<HIII", 1, h, h, 0)
    fxy += struct.pack("<I", len(records))
    for r in records:
        fxy += struct.pack("<HHHHHiii", *r)
    (OUT / f"{base}.fxy").write_bytes(bytes(fxy))
    return base


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for old in OUT.glob(f"{NAME}*"):
        old.unlink()
    glyphs = load_mcm()
    cmap = charmap()
    with tempfile.TemporaryDirectory() as tmp:
        names = [build_size(glyphs, cmap, h, tmp) for h in HEIGHTS]
    fonts = ",\n".join(f'            "{GAME_DIR}{n}"' for n in names)
    HPP.write_text(f"class {NAME}\n{{\n    fonts[] =\n    {{\n{fonts}\n    }};\n}};\n", encoding="utf-8", newline="\n")
    print(f"{len(names)} sizes -> {OUT}")


if __name__ == "__main__":
    main()
