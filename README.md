# ArmaFPV

[![CI](https://github.com/Sam-DarkBall-Mods/ArmaFPV/actions/workflows/ci.yml/badge.svg)](https://github.com/Sam-DarkBall-Mods/ArmaFPV/actions/workflows/ci.yml)

FPV drone systems for Arma 3, including signal degradation, jamming,
retransmission, battery simulation, UI effects, and multiplayer-safe drone
destruction.

## Requirements

- Arma 3 2.22 or newer
- CBA_A3

`ArmaFPV_Compat` and `SDB_InteropTweaks` are shipped as optional addons.
`SDB_InteropTweaks` additionally requires Drongo's Drone Tweaks.

## Development

```bash
hemtt check
hemtt build --no-bin
python3 -B -m unittest discover -s tests -p "test_*.py" -v
```

The legacy `\ArmaFPV`, `\ArmaFPV_Compat`, and `\SDB_InteropTweaks` PBO
prefixes are intentionally preserved for mission and mod compatibility.

## License

SQF, Arma configuration, and tooling are GPL-2.0-or-later. Original Arma
models, textures, materials, animations, and audio are APL-SA. See
[LICENSES.md](LICENSES.md) and closer notices.
