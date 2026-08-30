from __future__ import annotations

import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class ModIconTests(unittest.TestCase):
    def test_mod_icons_exist_and_are_packaged(self) -> None:
        source = (ROOT / "mod.cpp").read_text(encoding="utf-8")
        references = set(
            re.findall(
                r'(?m)^\s*(?:picture|logo|logoOver|logoSmall|overviewPicture)'
                r'\s*=\s*"([^"]+)"\s*;',
                source,
            )
        )
        self.assertTrue(references)

        project = (ROOT / ".hemtt" / "project.toml").read_text(encoding="utf-8")
        for reference in references:
            with self.subTest(reference=reference):
                if reference.startswith("\\"):
                    relative = reference.lstrip("\\").replace("\\", "/")
                    self.assertTrue((ROOT / "addons" / relative).is_file())
                else:
                    self.assertTrue((ROOT / reference).is_file())
                    self.assertIn(f'"{reference}"', project)


if __name__ == "__main__":
    unittest.main()
