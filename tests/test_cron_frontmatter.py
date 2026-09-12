"""Cron scheduling for this edition's skills is declared in SKILL.md frontmatter
and picked up automatically by north-forge-agent's scripts/nf_sync_cron.py at
every launch (see CHANGELOG.md, 2026-09-12). These tests guard the contract
between the two repos: the frontmatter must exist, must parse, and must keep
matching the prose "Setup note" fallback documented in the same file, so the
two never drift out of sync again the way the retired launcher's cron
self-heal silently did.

This intentionally does not import nf_sync_cron.py (that lives in a sibling
repo, not a dependency of this one) - it only asserts this repo's half of the
contract: well-formed, correctly-scheduled frontmatter.
"""
import re
import unittest
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]

EXPECTED = {
    "kyocera-research": {
        "job_name": "nightly-kyocera-research",
        "schedule": "0 6 * * *",
    },
    "daily-brief": {
        "job_name": "daily-kyocera-brief",
        "schedule": "0 8 * * *",
    },
}


def _read_frontmatter(skill_md_path: Path) -> dict:
    text = skill_md_path.read_text(encoding="utf-8")
    match = re.match(r"^---\s*\n(.*?)\n---\s*\n", text, re.DOTALL)
    assert match, f"{skill_md_path} has no --- frontmatter block"
    return yaml.safe_load(match.group(1)) or {}


class CronFrontmatterTest(unittest.TestCase):
    def test_every_scheduled_skill_declares_matching_cron_frontmatter(self):
        for skill_dir, expected in EXPECTED.items():
            skill_md = ROOT / "skills" / skill_dir / "SKILL.md"
            self.assertTrue(skill_md.exists(), f"missing {skill_md}")
            frontmatter = _read_frontmatter(skill_md)
            cron_jobs = frontmatter.get("cron")
            self.assertIsInstance(
                cron_jobs, list,
                f"{skill_dir}: frontmatter 'cron' must be a list, got {cron_jobs!r}")
            self.assertEqual(
                len(cron_jobs), 1,
                f"{skill_dir}: expected exactly one declared cron job")
            job = cron_jobs[0]
            self.assertEqual(job.get("name"), expected["job_name"])
            self.assertEqual(job.get("schedule"), expected["schedule"])
            self.assertTrue(
                job.get("prompt"),
                f"{skill_dir}: cron job needs a non-empty 'prompt'")
            # No model/provider pin: unattended jobs must inherit the drive's
            # own default so they behave identically on Basic and Full tier.
            self.assertNotIn("model", job)
            self.assertNotIn("provider", job)

    def test_frontmatter_schedule_matches_prose_setup_note(self):
        # The manual /cron add fallback documented in each file must never
        # silently drift from the machine-readable schedule above it.
        for skill_dir, expected in EXPECTED.items():
            skill_md = ROOT / "skills" / skill_dir / "SKILL.md"
            text = skill_md.read_text(encoding="utf-8")
            self.assertIn(
                f'/cron add "{expected["schedule"]}"', text,
                f"{skill_dir}: prose Setup note schedule no longer matches frontmatter")
            self.assertIn(
                f'--name {expected["job_name"]}', text,
                f"{skill_dir}: prose Setup note job name no longer matches frontmatter")


if __name__ == "__main__":
    unittest.main()
