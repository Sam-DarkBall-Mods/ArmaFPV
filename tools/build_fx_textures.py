#!/usr/bin/env python3
"""Build the analog video overlay textures in addons/ArmaFPV/pictures/fx.

snow_N_co: opaque grey line noise, the picture of a lost analog link. Every
texture row is one PAL line, noise runs along the line (FM clicks smear
horizontally), each line has its own brightness.
spark_N_ca: sparse one-line white and black streaks on transparency, the
"sparkles" of a link near its threshold. Layers of them add density.
vignette_ca: the dark corners of a wide FPV camera lens.

Usage: python tools/build_fx_textures.py   (needs numpy, scipy, Pillow and hemtt on PATH)
"""
import subprocess
import tempfile
from pathlib import Path

import numpy as np
from PIL import Image
from scipy.ndimage import uniform_filter1d

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "addons" / "ArmaFPV" / "pictures" / "fx"
SIZE = 512
FRAMES = 8


def streaks(rng, count, length, img, value):
    for y, x, n in zip(rng.integers(0, SIZE, count), rng.integers(0, SIZE, count), rng.integers(*length, count)):
        img[y, x:x + n] = value


def snow(rng):
    n = uniform_filter1d(rng.standard_normal((SIZE, SIZE)), 3, axis=1)
    n = n / n.std() * 0.2 + 0.5 + rng.normal(0, 0.05, (SIZE, 1))
    streaks(rng, 900, (3, 14), n, 0.95)
    streaks(rng, 300, (3, 10), n, 0.08)
    return Image.fromarray((np.clip(n, 0, 1) * 255).astype(np.uint8)).convert("RGB")


def spark(rng):
    rgba = np.zeros((SIZE, SIZE, 4), np.uint8)
    white = np.zeros((SIZE, SIZE))
    black = np.zeros((SIZE, SIZE))
    streaks(rng, 260, (3, 14), white, 1)
    streaks(rng, 80, (3, 9), black, 1)
    rgba[white > 0] = (255, 255, 255, 235)
    rgba[black > 0] = (0, 0, 0, 180)
    return Image.fromarray(rgba, "RGBA")


def vignette():
    yy, xx = np.mgrid[0:256, 0:256] / 127.5 - 1
    a = 0.55 * np.clip(np.hypot(xx, yy) - 0.6, 0, 1) ** 1.4
    rgba = np.zeros((256, 256, 4), np.uint8)
    rgba[..., 3] = (np.clip(a, 0, 1) * 255).astype(np.uint8)
    return Image.fromarray(rgba, "RGBA")


def main():
    rng = np.random.default_rng(11)
    images = {f"snow_{i}_co": snow(rng) for i in range(FRAMES)}
    images |= {f"spark_{i}_ca": spark(rng) for i in range(FRAMES)}
    images["vignette_ca"] = vignette()
    OUT.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        for name, img in images.items():
            png = Path(tmp) / f"{name}.png"
            img.save(png)
            subprocess.run(["hemtt", "utils", "paa", "convert", str(png), str(OUT / f"{name}.paa")],
                           check=True, capture_output=True)
            print(f"{name}.paa")


if __name__ == "__main__":
    main()
