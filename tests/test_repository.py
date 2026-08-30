from __future__ import annotations

import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class RepositoryContractTests(unittest.TestCase):
    def test_project_version_starts_at_1_0_0(self) -> None:
        project = (ROOT / ".hemtt" / "project.toml").read_text(encoding="utf-8")
        self.assertIn("major = 1", project)
        self.assertIn("minor = 0", project)
        self.assertIn("patch = 0", project)

    def test_addon_has_pboprefix(self) -> None:
        self.assertTrue((ROOT / "addons" / "main" / "$PBOPREFIX$").is_file())


if __name__ == "__main__":
    unittest.main()
