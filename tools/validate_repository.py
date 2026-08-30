#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE_EXTENSIONS = {".cpp", ".h", ".hpp", ".inc", ".sqf"}
IGNORED_PARTS = {".git", ".hemttout", "releases", "__pycache__"}


def source_files() -> list[Path]:
    return sorted(
        path
        for path in ROOT.rglob("*")
        if path.is_file()
        and path.suffix.lower() in SOURCE_EXTENSIONS
        and not IGNORED_PARTS.intersection(path.relative_to(ROOT).parts)
    )


def main() -> int:
    files = source_files()
    if not files:
        print("ERROR: no SQF or Arma configuration files found", file=sys.stderr)
        return 1

    errors: list[str] = []
    for path in files:
        data = path.read_bytes()
        relative = path.relative_to(ROOT)
        if data.startswith((b"\xef\xbb\xbf", b"\xff\xfe", b"\xfe\xff")):
            errors.append(f"{relative}: byte-order mark is not allowed")

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1

    print(f"Validated {len(files)} SQF/config source file(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
