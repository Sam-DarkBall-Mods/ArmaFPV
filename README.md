# ArmaFPV

[![CI](https://github.com/Sam-DarkBall-Mods/ArmaFPV/actions/workflows/ci.yml/badge.svg)](https://github.com/Sam-DarkBall-Mods/ArmaFPV/actions/workflows/ci.yml)

ArmaFPV adds Crocus FPV drones for BLUFOR, OPFOR and Independent. AT and AP
versions are available with normal or thermal optics. Drones can be carried in
backpacks, assembled in the field and controlled through the UAV terminal.

The flight system handles battery time, radio signal, jammers, retranslators
and loss of control. It also owns the FPV display effects and the multiplayer
cleanup that runs when a drone is destroyed.

## Requirements

- Arma 3 2.22 or newer
- CBA_A3

`ArmaFPV_Compat` and `SDB_InteropTweaks` are included as optional mods.
`SDB_InteropTweaks` is only needed when using Drongo's Drone Tweaks.

## Building

```bash
python3 -B -m unittest discover -s tests -p "test_*.py" -v
hemtt check
hemtt build --no-bin
```

The prefixes `ArmaFPV`, `ArmaFPV_Compat` and `SDB_InteropTweaks` are
deliberately unchanged. Renaming them would break scripts and missions that use
the old paths.

## License

SQF, configs and tooling use GPL-2.0-or-later. Original models, textures,
materials, animations and audio use APL-SA. See [LICENSES.md](LICENSES.md).
