#!/usr/bin/env python3
"""Build the Crocus drone sounds from the CC0 recordings in tools/sound_src.

Sources (Freesound, qubodup, CC0; audio of public-domain US DoD footage):
854353 and 854354 quadcopter hover heard from the ground, 854646 arming tones
and take-off of a 10" quad. The drone camera has no motor sound: an FPV
operator does not hear the drone in the goggles, only the receiver's hiss and
its crackle on a weak link, which are generated here from noise.

Loops are cut from steady parts and closed with an equal-power crossfade, so the
engine can pitch them freely. The spin-down is synthesised from the hover loop.
Output: mono 44.1 kHz OGG Vorbis in addons/ArmaFPV/sounds.

Usage: python tools/build_sounds.py   (needs numpy, scipy, soundfile)
"""
from pathlib import Path

import numpy as np
import soundfile as sf
from scipy.signal import butter, resample_poly, sosfiltfilt

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "tools" / "sound_src"
OUT = ROOT / "addons" / "ArmaFPV" / "sounds"
SR = 44100


def load(prefix):
    path = next(SRC.glob(f"{prefix}__*.wav"))
    x, sr = sf.read(path, always_2d=True)
    return resample_poly(x.mean(axis=1), SR // 100, sr // 100)


def band(x, lo=None, hi=None):
    if lo and hi:
        sos = butter(4, [lo, hi], "bandpass", fs=SR, output="sos")
    elif lo:
        sos = butter(4, lo, "highpass", fs=SR, output="sos")
    else:
        sos = butter(4, hi, "lowpass", fs=SR, output="sos")
    return sosfiltfilt(sos, x)


def loop(x, start, length, fade=0.25):
    a, n, f = int(start * SR), int(length * SR), int(fade * SR)
    seg = x[a:a + n + f]
    t = np.linspace(0, np.pi / 2, f)
    y = seg[:n].copy()
    y[:f] = seg[:f] * np.sin(t) + seg[n:n + f] * np.cos(t)
    return y


def level(x, rms_db, peak=0.95):
    x = x * 10 ** (rms_db / 20) / np.sqrt(np.mean(x ** 2))
    return x * min(1.0, peak / np.abs(x).max())


def spin_down(x, seconds=1.4, end_rate=0.3):
    n = int(seconds * SR)
    k = np.linspace(0, 1, n)
    rate = end_rate + (1 - end_rate) * (1 - k) ** 2
    pos = np.cumsum(rate)
    y = np.interp(pos % len(x), np.arange(len(x)), x)
    return y * (1 - k) ** 1.5


def fades(x, fin=0.02, fout=0.3):
    a, b = int(fin * SR), int(fout * SR)
    x = x.copy()
    x[:a] *= np.linspace(0, 1, a)
    x[-b:] *= np.linspace(1, 0, b) ** 2
    return x


def rx_hiss(rng, seconds=4.0):
    n = int((seconds + 0.25) * SR)
    x = band(rng.standard_normal(n), 250, 7000)
    flutter = 1 + 0.06 * band(rng.standard_normal(n), hi=6)
    return loop(x * flutter, 0, seconds)


def rx_crackle(rng, seconds=4.0):
    n = int((seconds + 0.25) * SR)
    x = np.zeros(n)
    for at in rng.uniform(0, n - SR // 10, int(seconds * 9)).astype(int):
        k = int(rng.uniform(0.004, 0.045) * SR)
        x[at:at + k] += rng.standard_normal(k) * np.exp(-np.linspace(0, 5, k)) * rng.uniform(0.3, 1)
        x[at] += rng.choice([-1, 1]) * rng.uniform(1, 3)
    return loop(band(x, 400, 5000), 0, seconds)


def main():
    hover, far, arm = load("854353"), load("854354"), load("854646")
    rng = np.random.default_rng(7)
    engine_ext = level(loop(band(hover, lo=120), 0.3, 5.6), -18)
    sounds = {
        "fpv_rx_hiss": level(rx_hiss(rng), -22),
        "fpv_rx_crackle": level(rx_crackle(rng), -22),
        "fpv_engine_ext": engine_ext,
        "fpv_punch_ext": level(loop(band(hover, lo=1200), 0.3, 5.6), -20),
        "fpv_far_ext": level(loop(band(far, 300, 2500), 0.3, 4.4), -20),
        "fpv_start": level(fades(arm[int(1.0 * SR):int(2.75 * SR)], fout=0.25), -20),
        "fpv_stop_ext": level(spin_down(engine_ext), -20),
    }
    OUT.mkdir(parents=True, exist_ok=True)
    for name, data in sounds.items():
        sf.write(OUT / f"{name}.ogg", data.astype(np.float32), SR, format="OGG", subtype="VORBIS")
        print(f"{name}.ogg {len(data) / SR:.2f}s")


if __name__ == "__main__":
    main()
