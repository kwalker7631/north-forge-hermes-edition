import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class CronRegistrationWarningsTest(unittest.TestCase):
    def run_cron_block(self, failed_jobs):
        launcher = (ROOT / "launch-north-forge.sh").read_text(encoding="utf-8")
        block = "CRON_DEGRADED=" + launcher.split("CRON_DEGRADED=", 1)[1]
        block = block.split("# Plain call instead of exec", 1)[0]

        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            fake_bin = work / "bin"
            fake_bin.mkdir()
            fake_hermes = fake_bin / "hermes"
            fake_hermes.write_text(
                """#!/usr/bin/env bash
if [ "$1 $2" = "cron list" ]; then exit 0; fi
if [ "$1 $2" = "cron add" ]; then
  for arg in "$@"; do
    if [[ ",$FAIL_JOBS," == *",$arg,"* ]]; then
      printf 'fake diagnostic for %s\\033[31m\\n' "$arg" >&2
      exit 23
    fi
  done
fi
exit 0
""",
                encoding="utf-8",
            )
            fake_hermes.chmod(0o755)
            script = work / "cron-under-test.sh"
            script.write_text(
                "#!/usr/bin/env bash\nset -e\n"
                "log_event() { printf '[INFO] [%s]: %s\\n' \"$1\" \"$2\" >> forge-events.log; }\n"
                + f'HERMES_EXE="{fake_hermes}"\n'
                + block,
                encoding="utf-8",
            )
            env = os.environ.copy()
            env["PATH"] = f"{fake_bin}:{env['PATH']}"
            env["FAIL_JOBS"] = ",".join(failed_jobs)
            result = subprocess.run(
                ["bash", str(script)], cwd=work, env=env, text=True,
                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=False,
            )
            return result, (work / "forge-events.log").read_text(encoding="utf-8")

    def test_each_job_and_both_failures_are_visible_and_logged(self):
        jobs = ("nightly-kyocera-research", "daily-kyocera-brief")
        for failed_jobs in ((jobs[0],), (jobs[1],), jobs):
            with self.subTest(failed_jobs=failed_jobs):
                result, event_log = self.run_cron_block(failed_jobs)
                self.assertEqual(result.returncode, 0)
                for job in failed_jobs:
                    expected = f"WARNING: Could not schedule {job} (exit 23; diagnostic: fake diagnostic for {job}?"
                    self.assertIn(expected, result.stdout)
                    self.assertIn(expected, event_log)
                    self.assertIn(job, result.stdout.split("WARNING SUMMARY:", 1)[1])
                self.assertIn("Interactive North Forge can continue", result.stdout)
                self.assertIn("hermes cron list", result.stdout)

    def test_windows_launcher_has_equivalent_failure_handling(self):
        launcher = (ROOT / "launch-north-forge.bat").read_text(encoding="utf-8")
        for job in ("nightly-kyocera-research", "daily-kyocera-brief"):
            self.assertIn(f"WARNING: Could not schedule {job} (exit ", launcher)
        self.assertGreaterEqual(launcher.count("Add-Content -LiteralPath 'forge-events.log'"), 2)
        self.assertEqual(launcher.count("automated nightly research will not run"), 1)
        self.assertEqual(launcher.count("automated daily brief will not run"), 1)
        self.assertIn("WARNING SUMMARY: North Forge is starting in degraded mode", launcher)


if __name__ == "__main__":
    unittest.main()
