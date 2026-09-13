#!/usr/bin/env python3
"""Validate a candidate target directory for an optional Pinokio lab install.

Pinokio (https://github.com/pinokiocomputer/pinokio) is deliberately kept
OFF the North Forge teammate/handoff drive - see
`Advanced/deploy-console/EXCALIBUR.md` ("Do not put on this stick: Pinokio,
local model zoos, AppData installs, the research archive. Those bury the
sale.") and `Advanced/PINOKIO.md` ("Same 32 GB Excalibur stick as North
Forge: No.  PINOKIO_HOME on a data SSD (500 GB-2 TB): the real design.").

This module is the mechanical half of enforcing that decision: given a
candidate directory, it reports whether the drive it lives on (a) looks like
a North Forge volume (any teammate-path marker file found from the nearest
existing ancestor up to the filesystem/drive root) and (b) has enough free
space to be a plausible Pinokio lab disk. It makes no changes to the
filesystem and installs nothing - `Advanced/deploy-console/Install-Pinokio-Lab.ps1`
and `Remove-Pinokio-Lab.ps1` are the admin-only scripts that act on this
verdict, and neither is wired into any teammate-path launch script.

Verdicts:
- "blocked_missing_path"        - no existing ancestor directory at all.
- "blocked_north_forge_volume"  - a North Forge marker file was found on the
                                   same drive; refuse regardless of size.
- "blocked_too_small"           - free space is below --min-free-gb (default
                                   200 GB - well above any teammate stick,
                                   still short of a real lab disk).
- "warn_marginal"               - free space is between --min-free-gb and
                                   --warn-free-gb (default 500 GB): allowed,
                                   but PINOKIO.md's "real design" floor.
- "ok"                          - free space is at or above --warn-free-gb.
"""

from __future__ import annotations

import argparse
import json
import shutil
import sys
from pathlib import Path
from typing import Callable, List, Optional

# Case-insensitive filenames whose presence anywhere from the nearest existing
# ancestor up to the drive root marks a volume as a North Forge teammate
# drive. Sourced from EXCALIBUR.md's own description of what a prepared
# stick looks like ("Start North Forge at the root", "HOW_TO_START.txt and
# ASSIGNED_TO.txt on the root") plus the launcher/toggle scripts every North
# Forge checkout carries.
NORTH_FORGE_MARKERS = {
    "start north forge.lnk",
    "how_to_start.txt",
    "assigned_to.txt",
    "north-forge.cmd",
    "launch-north-forge.bat",
    "launch-north-forge.sh",
    "toggle-mode.bat",
    "toggle-mode.sh",
    "machine-reset.bat",
}

DEFAULT_MIN_FREE_GB = 200.0
DEFAULT_WARN_FREE_GB = 500.0
GB = 1024 ** 3

DiskUsageFn = Callable[[str], "shutil._ntuple_diskusage"]


def _existing_ancestor(path: Path) -> Optional[Path]:
    candidates = [path] + list(path.parents)
    for candidate in candidates:
        if candidate.exists():
            return candidate
    return None


def _find_markers(start: Path) -> List[str]:
    """Walk from `start` up to the filesystem/drive root, collecting hits."""
    found: List[str] = []
    current = start if start.is_dir() else start.parent
    seen = set()
    while True:
        try:
            entries = {entry.name.lower() for entry in current.iterdir()}
        except (PermissionError, OSError):
            entries = set()
        hits = sorted(entries & NORTH_FORGE_MARKERS)
        for hit in hits:
            if hit not in seen:
                found.append(hit)
                seen.add(hit)
        parent = current.parent
        if parent == current:
            break
        current = parent
    return found


def validate_target(
    path: Path,
    min_free_gb: float = DEFAULT_MIN_FREE_GB,
    warn_free_gb: float = DEFAULT_WARN_FREE_GB,
    disk_usage: DiskUsageFn = shutil.disk_usage,
) -> dict:
    path = Path(path)
    ancestor = _existing_ancestor(path)
    if ancestor is None:
        return {
            "path": str(path),
            "verdict": "blocked_missing_path",
            "message": "No existing ancestor directory - cannot inspect this target at all.",
        }

    markers = _find_markers(ancestor)
    if markers:
        return {
            "path": str(path),
            "checked_from": str(ancestor),
            "verdict": "blocked_north_forge_volume",
            "north_forge_markers_found": markers,
            "message": (
                "This looks like a North Forge volume (found: "
                f"{', '.join(markers)}). Pinokio is deliberately kept off the "
                "teammate/handoff drive - see EXCALIBUR.md and PINOKIO.md. "
                "Choose a separate lab/admin disk instead."
            ),
        }

    usage = disk_usage(str(ancestor))
    free_gb = usage.free / GB
    total_gb = usage.total / GB

    if free_gb < min_free_gb:
        verdict = "blocked_too_small"
        message = (
            f"Only {free_gb:.1f} GB free - below the {min_free_gb:.0f} GB floor. "
            "This is not a plausible Pinokio lab disk (PINOKIO.md: a serious "
            "local zoo is 100 GB minimum; this floor adds headroom above that)."
        )
    elif free_gb < warn_free_gb:
        verdict = "warn_marginal"
        message = (
            f"{free_gb:.1f} GB free - allowed, but below the {warn_free_gb:.0f} GB "
            "PINOKIO.md calls \"the real design\" (500 GB-2 TB). Fine for a small "
            "trial; expect to run out of room fast with more than a couple of apps."
        )
    else:
        verdict = "ok"
        message = f"{free_gb:.1f} GB free - a reasonable Pinokio lab disk."

    return {
        "path": str(path),
        "checked_from": str(ancestor),
        "verdict": verdict,
        "free_gb": round(free_gb, 1),
        "total_gb": round(total_gb, 1),
        "message": message,
    }


BLOCKED_VERDICTS = {"blocked_missing_path", "blocked_north_forge_volume", "blocked_too_small"}


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(
        description="Validate a candidate directory for an optional Pinokio lab install."
    )
    parser.add_argument("path", help="Candidate target directory (need not exist yet).")
    parser.add_argument("--min-free-gb", type=float, default=DEFAULT_MIN_FREE_GB)
    parser.add_argument("--warn-free-gb", type=float, default=DEFAULT_WARN_FREE_GB)
    args = parser.parse_args(argv)

    result = validate_target(
        Path(args.path), min_free_gb=args.min_free_gb, warn_free_gb=args.warn_free_gb
    )
    print(json.dumps(result, indent=2))
    return 2 if result["verdict"] in BLOCKED_VERDICTS else 0


if __name__ == "__main__":
    raise SystemExit(main())
