from __future__ import annotations

import tomllib
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class RepositoryContractTests(unittest.TestCase):
    def test_legacy_pbo_prefixes_are_preserved(self) -> None:
        prefixes = {
            "addons/ArmaFPV/$PBOPREFIX$": "ArmaFPV",
            "optionals/ArmaFPV_Compat/$PBOPREFIX$": "ArmaFPV_Compat",
            "optionals/SDB_InteropTweaks/$PBOPREFIX$": "SDB_InteropTweaks",
        }
        for relative, expected in prefixes.items():
            with self.subTest(relative=relative):
                value = (ROOT / relative).read_text(encoding="utf-8").strip()
                self.assertEqual(value, expected)

    def test_public_cfgpatches_is_preserved(self) -> None:
        config = (ROOT / "addons" / "ArmaFPV" / "config.cpp").read_text(
            encoding="utf-8"
        )
        self.assertIn("class ArmaFPV_Data", config)
        self.assertIn("requiredVersion=2.22", config.replace(" ", ""))

    def test_release_version_starts_at_1_0_0(self) -> None:
        project = (ROOT / ".hemtt" / "project.toml").read_text(encoding="utf-8")
        self.assertIn("major = 1", project)
        self.assertIn("minor = 0", project)
        self.assertIn("patch = 0", project)

    def test_default_launch_loads_cba_and_binarizes(self) -> None:
        with (ROOT / ".hemtt" / "project.toml").open("rb") as project_file:
            project = tomllib.load(project_file)
        launch = project["hemtt"]["launch"]["default"]
        self.assertIn("450814997", launch["workshop"])
        self.assertTrue(launch["binarize"])
        self.assertFalse(launch["file_patching"])


if __name__ == "__main__":
    unittest.main()
