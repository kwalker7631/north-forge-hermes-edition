"""Tests for Advanced/deploy-console/exclude-profile-skills.ps1 - the tool
for stopping a specific skill (e.g. `pinokio`) from leaking onto a specific
build (e.g. a Round-Table-class drive) without a manual rm -rf after the
fact. See the script's own header for the incident this fixes.
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

import pytest

_SCRIPT = Path(__file__).resolve().parents[1] / "Advanced" / "deploy-console" / "exclude-profile-skills.ps1"
_WINDOWS_ONLY = pytest.mark.skipif(sys.platform != "win32", reason="drives a real .ps1")


def _run(profile_dir: Path, skill_names: list[str]):
    # powershell.exe -File hands everything after it to the process as flat
    # argv tokens - a [string[]] parameter only receives multiple elements
    # from *that* boundary if each is its own token AND no other named
    # parameter follows, which real callers can't rely on; a comma-joined
    # single token also binds as one single-element string, not a split
    # array (both tried and confirmed wrong while writing this test). The
    # reliable way to pass a real array across a process boundary is
    # -Command with actual PowerShell array-literal syntax, which is what
    # every real caller of this script (Zero-Touch-Deploy.ps1's own `&`
    # invocation, in-session) already does natively - only an external
    # `-File` subprocess call hits this at all.
    names_literal = "@(" + ",".join(f"'{n}'" for n in skill_names) + ")"
    command = (
        f'& "{_SCRIPT}" -ProfileDir "{profile_dir}" -SkillNames {names_literal}'
    )
    args = ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", command]
    return subprocess.run(args, capture_output=True, text=True)


@_WINDOWS_ONLY
def test_removes_skill_from_both_locations(tmp_path):
    profile = tmp_path / "profiles" / "kyocera"
    (profile / "skills" / "pinokio").mkdir(parents=True)
    (profile / "skills" / "pinokio" / "SKILL.md").write_text("x", encoding="utf-8")
    (profile / "skills-source" / "shared" / "pinokio").mkdir(parents=True)
    (profile / "skills-source" / "shared" / "pinokio" / "SKILL.md").write_text("x", encoding="utf-8")
    (profile / "skills" / "assist").mkdir(parents=True)
    (profile / "skills" / "assist" / "SKILL.md").write_text("x", encoding="utf-8")

    r = _run(profile, ["pinokio"])
    assert r.returncode == 0, r.stdout + r.stderr

    assert not (profile / "skills" / "pinokio").exists()
    assert not (profile / "skills-source" / "shared" / "pinokio").exists()
    # Untouched: not in the exclude list.
    assert (profile / "skills" / "assist").exists()


@_WINDOWS_ONLY
def test_missing_skill_is_reported_not_an_error(tmp_path):
    profile = tmp_path / "profiles" / "kyocera"
    (profile / "skills").mkdir(parents=True)

    r = _run(profile, ["pinokio"])
    assert r.returncode == 0, r.stdout + r.stderr
    assert "not found" in (r.stdout + r.stderr).lower()


@_WINDOWS_ONLY
def test_multiple_skill_names_all_removed(tmp_path):
    profile = tmp_path / "profiles" / "kyocera"
    for name in ("pinokio", "sales"):
        (profile / "skills" / name).mkdir(parents=True)
        (profile / "skills" / name / "SKILL.md").write_text("x", encoding="utf-8")

    r = _run(profile, ["pinokio", "sales"])
    assert r.returncode == 0, r.stdout + r.stderr

    assert not (profile / "skills" / "pinokio").exists()
    assert not (profile / "skills" / "sales").exists()


@_WINDOWS_ONLY
def test_only_named_skill_removed_from_skills_source(tmp_path):
    """Only skills-source\\shared\\<name> is touched, not sibling skills there."""
    profile = tmp_path / "profiles" / "kyocera"
    (profile / "skills-source" / "shared" / "pinokio").mkdir(parents=True)
    (profile / "skills-source" / "shared" / "menu").mkdir(parents=True)

    r = _run(profile, ["pinokio"])
    assert r.returncode == 0, r.stdout + r.stderr

    assert not (profile / "skills-source" / "shared" / "pinokio").exists()
    assert (profile / "skills-source" / "shared" / "menu").exists()
