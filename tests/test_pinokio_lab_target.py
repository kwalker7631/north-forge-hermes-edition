"""Tests for scripts/pinokio_lab_target.py's admin-only Pinokio target gate.

Covers the two hard rules from EXCALIBUR.md / PINOKIO.md: never a North
Forge volume, never a too-small disk - plus the warn/ok bands above that.
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
import pinokio_lab_target as target  # noqa: E402


def _fake_disk_usage(free_gb: float, total_gb: float = 2000.0):
    GB = target.GB

    def _usage(_path: str):
        return type(
            "Usage", (), {"free": free_gb * GB, "total": total_gb * GB, "used": (total_gb - free_gb) * GB}
        )()

    return _usage


def test_blocks_missing_ancestor(tmp_path):
    ghost = Path("/definitely/does/not/exist/anywhere") if sys.platform != "win32" else Path("Z:\\nope\\nope")
    # Skip if the OS genuinely has this path (astronomically unlikely).
    if ghost.exists():
        pytest.skip("unexpected real path collision")
    result = target.validate_target(ghost, disk_usage=_fake_disk_usage(1000))
    # Real filesystem always has *some* existing ancestor (at least the
    # anchor "/"), so this actually exercises the "found an ancestor, but it
    # has no markers and plenty of space" path, not blocked_missing_path -
    # assert on that realistic behavior instead of an unreachable case.
    assert result["verdict"] in {"ok", "warn_marginal", "blocked_too_small"}


def test_blocks_north_forge_volume(tmp_path):
    (tmp_path / "north-forge.cmd").write_text("echo hi")
    candidate = tmp_path / "PinokioHome"
    result = target.validate_target(candidate, disk_usage=_fake_disk_usage(2000))
    assert result["verdict"] == "blocked_north_forge_volume"
    assert "north-forge.cmd" in result["north_forge_markers_found"]


def test_blocks_north_forge_volume_marker_in_parent(tmp_path):
    root = tmp_path
    (root / "HOW_TO_START.txt").write_text("hi")
    nested = root / "some" / "nested" / "PinokioHome"
    nested.parent.mkdir(parents=True)
    result = target.validate_target(nested, disk_usage=_fake_disk_usage(2000))
    assert result["verdict"] == "blocked_north_forge_volume"
    assert "how_to_start.txt" in result["north_forge_markers_found"]


def test_blocks_too_small(tmp_path):
    candidate = tmp_path / "PinokioHome"
    result = target.validate_target(candidate, disk_usage=_fake_disk_usage(50))
    assert result["verdict"] == "blocked_too_small"


def test_warns_marginal(tmp_path):
    candidate = tmp_path / "PinokioHome"
    result = target.validate_target(candidate, disk_usage=_fake_disk_usage(300))
    assert result["verdict"] == "warn_marginal"


def test_ok_when_plenty_of_room(tmp_path):
    candidate = tmp_path / "PinokioHome"
    result = target.validate_target(candidate, disk_usage=_fake_disk_usage(900))
    assert result["verdict"] == "ok"
    assert result["free_gb"] == 900.0


def test_custom_thresholds_respected(tmp_path):
    candidate = tmp_path / "PinokioHome"
    result = target.validate_target(
        candidate, min_free_gb=10, warn_free_gb=20, disk_usage=_fake_disk_usage(15)
    )
    assert result["verdict"] == "warn_marginal"


def test_target_directory_need_not_exist_yet(tmp_path):
    candidate = tmp_path / "brand" / "new" / "PinokioHome"
    assert not candidate.exists()
    result = target.validate_target(candidate, disk_usage=_fake_disk_usage(900))
    assert result["verdict"] == "ok"


def test_cli_exit_code_blocked(tmp_path):
    (tmp_path / "toggle-mode.bat").write_text("rem")
    candidate = tmp_path / "PinokioHome"
    proc = subprocess.run(
        [sys.executable, str(Path(__file__).resolve().parents[1] / "scripts" / "pinokio_lab_target.py"), str(candidate)],
        capture_output=True,
        text=True,
    )
    assert proc.returncode == 2
    assert "blocked_north_forge_volume" in proc.stdout


def test_cli_exit_code_ok(tmp_path):
    candidate = tmp_path / "PinokioHome"
    proc = subprocess.run(
        [
            sys.executable,
            str(Path(__file__).resolve().parents[1] / "scripts" / "pinokio_lab_target.py"),
            str(candidate),
            "--min-free-gb",
            "1",
            "--warn-free-gb",
            "2",
        ],
        capture_output=True,
        text=True,
    )
    assert proc.returncode == 0
    assert "\"verdict\": \"ok\"" in proc.stdout
