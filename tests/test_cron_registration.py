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
        block = block.replace("scripts/hermes-drive.sh", "hermes")

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
        cron_log_writes = [
            line for line in launcher.splitlines()
            if "Add-Content -LiteralPath 'forge-events.log'" in line
            and "[WARNING] [cron]" in line
        ]
        self.assertEqual(len(cron_log_writes), 2)
        self.assertEqual(launcher.count("automated nightly research will not run"), 1)
        self.assertEqual(launcher.count("automated daily brief will not run"), 1)
        self.assertIn("WARNING SUMMARY: North Forge is starting in degraded mode", launcher)
        self.assertIn('set "HERMES_HOME=%~dp0.hermes-home"', launcher)
        self.assertEqual(launcher.count('"scripts\\hermes-drive.ps1" cron add'), 2)


class DriveLocalCronIsolationTest(unittest.TestCase):
    def make_drive(self, parent, name):
        repo = parent / name
        (repo / "scripts").mkdir(parents=True)
        (repo / ".hermes-home/bin").mkdir(parents=True)
        (repo / ".hermes-home/logs").mkdir()
        (repo / ".hermes.template.md").write_text("fixture", encoding="utf-8")
        wrapper = repo / "scripts/hermes-drive.sh"
        wrapper.write_text((ROOT / "scripts/hermes-drive.sh").read_text(encoding="utf-8"), encoding="utf-8")
        wrapper.chmod(0o755)
        fake = repo / ".hermes-home/bin/hermes"
        fake.write_text(
            """#!/usr/bin/env bash
set -eu
if [ "$1 $2" = "cron add" ]; then
  printf '%s\\n' "$*" >> "$HERMES_HOME/cron-jobs"
  printf '#!/usr/bin/env bash\\nexec %q cron run\\n' "$PWD/scripts/hermes-drive.sh" > "$HERMES_HOME/service"
  chmod +x "$HERMES_HOME/service"
elif [ "$1 $2" = "cron run" ]; then
  cat "$HERMES_HOME/config.yaml" > "$PWD/execution-result"
fi
""",
            encoding="utf-8",
        )
        fake.chmod(0o755)
        (repo / ".hermes-home/config.yaml").write_text(name, encoding="utf-8")
        return repo

    def test_clean_scheduler_keeps_each_drive_cron_and_config_isolated(self):
        with tempfile.TemporaryDirectory() as directory:
            parent = Path(directory)
            drives = [self.make_drive(parent, name) for name in ("drive-a", "drive-b")]
            for repo in drives:
                subprocess.run(
                    [str(repo / "scripts/hermes-drive.sh"), "cron", "add", "daily", repo.name],
                    cwd="/", env={"PATH": "/usr/bin:/bin"}, check=True,
                )
            for repo in drives:
                service = (repo / ".hermes-home/service").read_text(encoding="utf-8")
                self.assertIn(str(repo / "scripts/hermes-drive.sh"), service)
                subprocess.run([str(repo / ".hermes-home/service")], cwd="/", env={"PATH": "/usr/bin:/bin"}, check=True)
                self.assertEqual((repo / "execution-result").read_text(encoding="utf-8"), repo.name)
                self.assertIn(repo.name, (repo / ".hermes-home/cron-jobs").read_text(encoding="utf-8"))
                other = drives[1] if repo == drives[0] else drives[0]
                self.assertNotIn(other.name, (repo / ".hermes-home/cron-jobs").read_text(encoding="utf-8"))

    def test_missing_home_fails_without_recreating_it(self):
        with tempfile.TemporaryDirectory() as directory:
            repo = self.make_drive(Path(directory), "removed-drive")
            home = repo / ".hermes-home"
            subprocess.run(["rm", "-rf", str(home)], check=True)
            result = subprocess.run(
                [str(repo / "scripts/hermes-drive.sh"), "cron", "run"],
                cwd="/", env={"PATH": "/usr/bin:/bin"}, text=True, capture_output=True,
            )
            self.assertEqual(result.returncode, 72)
            self.assertIn("drive-local .hermes-home is unavailable", result.stderr)
            self.assertFalse(home.exists())


if __name__ == "__main__":
    unittest.main()
