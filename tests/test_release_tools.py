from __future__ import annotations

import importlib.util
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def load_tool(name: str):
    path = ROOT / "tools" / f"{name}.py"
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Unable to load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


package_release = load_tool("package_release")
write_workshop_vdf = load_tool("write_workshop_vdf")


class ReleaseToolTests(unittest.TestCase):
    def test_release_archive_uses_flat_legal_files(self) -> None:
        destinations = [
            destination.as_posix()
            for _, destination in package_release.LEGAL_FILES
        ]
        self.assertEqual(
            destinations,
            ["LICENSE", "ASSET_LICENSE.txt", "THIRD_PARTY_NOTICES.txt"],
        )
        for source, _ in package_release.LEGAL_FILES:
            with self.subTest(source=source):
                self.assertTrue(source.is_file())

    def test_release_archive_excludes_markdown_and_licenses_directory(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / "addons").mkdir()
            (root / "LICENSES").mkdir()
            (root / "addons" / "mod.pbo").write_bytes(b"pbo")
            (root / "meta.cpp").write_text("meta", encoding="utf-8")
            (root / "LICENSE").write_text("license", encoding="utf-8")
            (root / "README.md").write_text("readme", encoding="utf-8")
            (root / "LICENSES" / "APL-SA.txt").write_text(
                "asset license", encoding="utf-8"
            )

            files = package_release.collect_release_files(root)
            relative = {path.relative_to(root).as_posix() for path in files}

        self.assertEqual(relative, {"addons/mod.pbo", "meta.cpp"})

    def test_vdf_escape_handles_multiline_release_notes(self) -> None:
        escaped = write_workshop_vdf.vdf_escape(
            'First line\r\n"Second line" C:\\Mods'
        )
        self.assertEqual(escaped, 'First line\\n\\"Second line\\" C:\\\\Mods')

    def test_workshop_vdf_reads_change_note_file(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            content = root / "content"
            content.mkdir()
            note = root / "changenote.txt"
            note.write_text("First line\nSecond line\n", encoding="utf-8")
            output = root / "workshop.vdf"

            result = subprocess.run(
                [
                    sys.executable,
                    str(ROOT / "tools" / "write_workshop_vdf.py"),
                    "--content",
                    str(content),
                    "--output",
                    str(output),
                    "--change-note-file",
                    str(note),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
            )

            self.assertEqual(result.returncode, 0, result.stderr)
            vdf = output.read_text(encoding="utf-8")
            self.assertIn('"changenote" "First line\\nSecond line"', vdf)

    def test_release_workflow_publishes_files_and_supports_steam_retry(self) -> None:
        release = (ROOT / ".github" / "workflows" / "release.yml").read_text(
            encoding="utf-8"
        )
        steam = (
            ROOT / ".github" / "workflows" / "publish-steam.yml"
        ).read_text(encoding="utf-8")

        self.assertIn(
            "release-payload/releases/*.zip release-payload/SHA256SUMS", release
        )
        self.assertNotIn("release-payload/* --repo", release)
        self.assertIn("uses: ./.github/workflows/publish-steam.yml", release)
        self.assertIn("workflow_dispatch:", steam)
        self.assertIn("runs-on: windows-latest", steam)
        self.assertIn("Get-FileHash", steam)
        self.assertIn("steamcmd.zip", steam)
        self.assertIn('steamcmd\\config\\config.vdf', steam)
        self.assertNotIn("steamcmd_linux", steam)


if __name__ == "__main__":
    unittest.main()
