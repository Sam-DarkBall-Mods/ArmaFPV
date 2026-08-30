# DB Example Mod

[![CI](https://github.com/Sam-DarkBall-Mods/mod-template/actions/workflows/ci.yml/badge.svg)](https://github.com/Sam-DarkBall-Mods/mod-template/actions/workflows/ci.yml)

Working template for Sam-DarkBall-Mods Arma 3 projects.

## Requirements

- Arma 3 2.22 or newer
- [HEMTT](https://hemtt.dev/) 1.21 or newer

## Development

```bash
hemtt check
hemtt build --no-bin
python3 -B tools/validate_repository.py
```

## License

SQF, Arma configuration, and tooling are GPL-2.0-or-later. Original Arma
models, textures, materials, animations, and audio are APL-SA. See
[LICENSES.md](LICENSES.md) and closer notices for details.
