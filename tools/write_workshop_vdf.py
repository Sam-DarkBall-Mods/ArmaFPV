#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def vdf_escape(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"')


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--content", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--change-note", required=True)
    args = parser.parse_args()

    meta = (ROOT / "meta.cpp").read_text(encoding="utf-8")
    match = re.search(r"publishedid\s*=\s*(\d+)\s*;", meta)
    if match is None or int(match.group(1)) == 0:
        raise SystemExit("meta.cpp does not contain a production Workshop ID")

    content = args.content.resolve()
    if not content.is_dir():
        raise SystemExit(f"Workshop content directory does not exist: {content}")

    args.output.write_text(
        "\n".join(
            [
                '"workshopitem"',
                "{",
                '    "appid" "107410"',
                f'    "publishedfileid" "{match.group(1)}"',
                f'    "contentfolder" "{vdf_escape(str(content))}"',
                f'    "changenote" "{vdf_escape(args.change_note)}"',
                "}",
                "",
            ]
        ),
        encoding="utf-8",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
