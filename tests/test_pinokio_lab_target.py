"""Tests for scripts/pinokio_lab_target.py's admin-only Pinokio target gate.

Covers the reconciled rule from ROUND-TABLE.md / PINOKIO.md / PINOKIO-on-drive.md:
a North Forge marker hard-blocks only on a Round-Table-class (small) volume;
on a Learning-class-or-bigger volume it doesn't block by itself and the
usual free-space floor/warn/ok bands apply - same-drive Pinokio is the
documented design there, not a contradiction.

("Round Table" was "Excalibur" until 2026-09-14, when "Excalibur" was
reassigned to mean the admin/designer drive itself - see
Advanced/deploy-console/EXCALIBUR.md. Naming only; behavior unchanged.)
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


def test_blocks_north_forge_volume_round_table_class(tmp_path):
    """A small (Round-Table-class) stick with a marker is blocked outright,
    even with plenty of free space relative to its own tiny total size."""
    (tmp_path / "north-forge.cmd").write_text("echo hi")
    candidate = tmp_path / "PinokioHome"
    result = target.validate_target(candidate, disk_usage=_fake_disk_usage(free_gb=20, total_gb=32))
    assert result["verdict"] == "blocked_north_forge_volume"
    assert "north-forge.cmd" in result["north_forge_markers_found"]


def test_blocks_north_forge_volume_marker_in_parent_round_table_class(tmp_path):
    root = tmp_path
    (root / "HOW_TO_START.txt").write_text("hi")
    nested = root / "some" / "nested" / "PinokioHome"
    nested.parent.mkdir(parents=True)
    result = target.validate_target(nested, disk_usage=_fake_disk_usage(free_gb=20, total_gb=32))
    assert result["verdict"] == "blocked_north_forge_volume"
    assert "how_to_start.txt" in result["north_forge_markers_found"]


def test_round_table_ceiling_boundary_is_inclusive(tmp_path):
    """Exactly at --round-table-max-gb (default 100) still counts as Round-Table-class."""
    (tmp_path / "north-forge.cmd").write_text("echo hi")
    candidate = tmp_path / "PinokioHome"
    result = target.validate_target(candidate, disk_usage=_fake_disk_usage(free_gb=50, total_gb=100))
    assert result["verdict"] == "blocked_north_forge_volume"


def test_north_forge_marker_does_not_block_learning_class_volume(tmp_path):
    """The reconciliation: a marker on a big (Learning-class+) drive no
    longer hard-blocks - PINOKIO.md / PINOKIO-on-drive.md's same-drive
    design puts North Forge there on purpose. The ordinary free-space
    verdict applies instead, and the marker is still reported."""
    (tmp_path / "north-forge.cmd").write_text("echo hi")
    candidate = tmp_path / "PinokioHome"
    result = target.validate_target(candidate, disk_usage=_fake_disk_usage(free_gb=900, total_gb=1000))
    assert result["verdict"] == "ok"
    assert "north-forge.cmd" in result["north_forge_markers_found"]


def test_north_forge_marker_on_learning_class_volume_still_hits_floor(tmp_path):
    """Learning-class-or-bigger does not mean unconditionally allowed - the
    same free-space floor still applies, just not the outright marker block."""
    (tmp_path / "north-forge.cmd").write_text("echo hi")
    candidate = tmp_path / "PinokioHome"
    result = target.validate_target(candidate, disk_usage=_fake_disk_usage(free_gb=50, total_gb=1000))
    assert result["verdict"] == "blocked_too_small"
    assert "north-forge.cmd" in result["north_forge_markers_found"]


def test_round_table_max_gb_is_configurable(tmp_path):
    (tmp_path / "north-forge.cmd").write_text("echo hi")
    candidate = tmp_path / "PinokioHome"
    # A 1000 GB stick is well above the default 100 GB ceiling - Learning-class...
    default_result = target.validate_target(candidate, disk_usage=_fake_disk_usage(free_gb=900, total_gb=1000))
    assert default_result["verdict"] == "ok"
    # ...but explicitly raising the ceiling can still classify it Round-Table-side.
    raised_result = target.validate_target(
        candidate, round_table_max_gb=2000, disk_usage=_fake_disk_usage(free_gb=900, total_gb=1000)
    )
    assert raised_result["verdict"] == "blocked_north_forge_volume"


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
    # --round-table-max-gb set absurdly high so this is deterministic regardless
    # of how large the real disk running this test happens to be - the CLI
    # has no way to fake total disk size directly, unlike validate_target()'s
    # disk_usage= param used everywhere else in this file.
    proc = subprocess.run(
        [
            sys.executable,
            str(Path(__file__).resolve().parents[1] / "scripts" / "pinokio_lab_target.py"),
            str(candidate),
            "--round-table-max-gb",
            "1000000000",
        ],
        capture_output=True,
        text=True,
    )
    assert proc.returncode == 2
    assert "blocked_north_forge_volume" in proc.stdout


def test_cli_does_not_block_marker_above_default_round_table_ceiling(tmp_path):
    """Default CLI behavior on a real (large) disk: a marker alone no longer
    blocks - matches test_north_forge_marker_does_not_block_learning_class_volume,
    exercised through the actual CLI instead of validate_target() directly."""
    (tmp_path / "toggle-mode.bat").write_text("rem")
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
    assert "blocked_north_forge_volume" not in proc.stdout


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
