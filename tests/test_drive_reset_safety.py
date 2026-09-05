import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

HELPER = Path(__file__).parents[1] / "scripts" / "drive-reset-safety.py"

class DriveResetSafetyTests(unittest.TestCase):
    def run_helper(self, action, repo, candidate, confirmed=None):
        command = [sys.executable, str(HELPER), "--action", action,
                   "--repo", str(repo), "--candidate", str(candidate)]
        if confirmed is not None:
            command += ["--confirmed", str(confirmed)]
        return subprocess.run(command, text=True, capture_output=True)

    def test_rejects_parent_root_and_shared_home(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            repo = root / "repo"
            home = repo / ".hermes-home"
            shared = root / "shared-home"
            home.mkdir(parents=True)
            shared.mkdir()
            (home / "state.db").write_text("keep", encoding="utf-8")
            for candidate in (repo, Path(repo.anchor), shared):
                result = self.run_helper("purge", repo, candidate, candidate)
                self.assertNotEqual(result.returncode, 0)
                self.assertTrue(home.exists())

    def test_confirmed_purge_removes_only_exact_scratch_home(self):
        with tempfile.TemporaryDirectory() as temporary:
            repo = Path(temporary) / "repo"
            home = repo / ".hermes-home"
            home.mkdir(parents=True)
            (home / "state.db").write_text("state", encoding="utf-8")
            sentinel = repo / "repo-content.txt"
            sentinel.write_text("keep", encoding="utf-8")
            canonical = self.run_helper("validate", repo, home)
            self.assertEqual(canonical.returncode, 0, canonical.stderr)
            target = canonical.stdout.strip()
            result = self.run_helper("purge", repo, home, target)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertFalse(home.exists())
            self.assertEqual(sentinel.read_text(encoding="utf-8"), "keep")

if __name__ == "__main__":
    unittest.main()
