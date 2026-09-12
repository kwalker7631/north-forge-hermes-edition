from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]


class LauncherHermesHomeStaticTests(unittest.TestCase):
    def test_windows_home_precedes_every_hermes_operation(self):
        launcher = (ROOT / "launch-north-forge.bat").read_text(encoding="utf-8")
        assignment = 'set "HERMES_HOME=%CD%\\.hermes-home"'
        self.assertEqual(launcher.count(assignment), 1)
        self.assertRegex(launcher, r'cd /d "%~dp0"\r?\nset "HERMES_HOME=')
        assignment_offset = launcher.index(assignment)
        operations = [
            match.start()
            for match in re.finditer(
                r"(?im)^\s*(?:hermes\b|call\s+:CONFIGURE_FREE_PROVIDER\b|"
                r"powershell\b.*hermes-agent\.nousresearch\.com)",
                launcher,
            )
        ]
        self.assertTrue(operations)
        self.assertTrue(all(assignment_offset < operation for operation in operations))
        self.assertNotIn("%LOCALAPPDATA%\\hermes", launcher)

    def test_posix_home_precedes_every_hermes_operation(self):
        launcher = (ROOT / "launch-north-forge.sh").read_text(encoding="utf-8")
        assignment = 'export HERMES_HOME="$(pwd -P)/.hermes-home"'
        self.assertEqual(launcher.count(assignment), 1)
        self.assertRegex(launcher, r'cd "\$\(dirname "\$0"\)"\r?\nexport HERMES_HOME=')
        assignment_offset = launcher.index(assignment)
        operations = [
            match.start()
            for match in re.finditer(
                r"(?m)^\s*(?:hermes\b|curl\b.*hermes-agent\.nousresearch\.com)",
                launcher,
            )
        ]
        self.assertTrue(operations)
        self.assertTrue(all(assignment_offset < operation for operation in operations))
        self.assertNotIn("$HOME/.hermes", launcher)
        self.assertNotIn("${HERMES_HOME:-", launcher)

    def test_runtime_home_is_ignored_at_repository_root(self):
        ignore = (ROOT / ".gitignore").read_text(encoding="utf-8").splitlines()
        self.assertIn("/.hermes-home/", ignore)

    def test_posix_welcome_is_marked_shown_only_after_success(self):
        launcher = (ROOT / "launch-north-forge.sh").read_text(encoding="utf-8")
        self.assertIn('[ "$WELOPEN" != "ok" ] || : > ".readme-shown"', launcher)
        welcome_block = launcher.split('# --- first run on this drive:', 1)[1].split('# Names are capped', 1)[0]
        self.assertEqual(welcome_block.count('> ".readme-shown"'), 1)


if __name__ == "__main__":
    unittest.main()
