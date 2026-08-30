#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
import sys
import tomllib
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("tag")
    args = parser.parse_args()

    match = re.fullmatch(r"v(\d+)\.(\d+)\.(\d+)", args.tag)
    if match is None:
        print(f"ERROR: invalid release tag {args.tag!r}", file=sys.stderr)
        return 1

    with (ROOT / ".hemtt" / "project.toml").open("rb") as project_file:
        project = tomllib.load(project_file)
    version = project["version"]
    expected = tuple(version[key] for key in ("major", "minor", "patch"))
    actual = tuple(int(value) for value in match.groups())
    if actual != expected:
        print(
            f"ERROR: tag version {actual} does not match HEMTT version {expected}",
            file=sys.stderr,
        )
        return 1

    meta = (ROOT / "meta.cpp").read_text(encoding="utf-8")
    item_match = re.search(r"publishedid\s*=\s*(\d+)\s*;", meta)
    if item_match is None or int(item_match.group(1)) == 0:
        print("ERROR: meta.cpp does not contain a production Workshop ID", file=sys.stderr)
        return 1

    print(f"Release contract valid for {args.tag}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
