#!/usr/bin/env python3
"""Validate and remove only a repository's own .hermes-home directory."""
import argparse
import shutil
import sys
from pathlib import Path


def fail(message: str) -> "NoReturn":
    print(f"Safety check failed: {message}", file=sys.stderr)
    raise SystemExit(2)


def canonical_target(repo_text: str, candidate_text: str) -> Path:
    if not repo_text or not candidate_text:
        fail("the repository and target paths are required.")
    repo_input = Path(repo_text).expanduser()
    candidate_input = Path(candidate_text).expanduser()
    if not repo_input.is_absolute() or not candidate_input.is_absolute():
        fail("use absolute paths.")
    if ".." in repo_input.parts or ".." in candidate_input.parts:
        fail("literal '..' path segments are not allowed.")

    repo = repo_input.resolve(strict=True)
    candidate = candidate_input.resolve(strict=True)
    expected = repo / ".hermes-home"
    if repo == Path(repo.anchor) or candidate == Path(candidate.anchor):
        fail("a filesystem or drive root is never allowed.")
    if candidate != expected:
        fail(f"target must be exactly '{expected}'.")

    # Resolve catches links that redirect the final result; this explicit walk
    # also rejects a link even when it happens to point back to the same place.
    current = Path(repo.anchor)
    for part in repo_input.parts[1:] + (".hermes-home",):
        current = current / part
        if current.is_symlink():
            fail(f"'{current}' is a symbolic link.")
    if not candidate.is_dir():
        fail("the drive-local Hermes home does not exist.")
    return candidate


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--action", choices=("validate", "purge"), required=True)
    parser.add_argument("--repo", required=True)
    parser.add_argument("--candidate", required=True)
    parser.add_argument("--confirmed")
    args = parser.parse_args()
    target = canonical_target(args.repo, args.candidate)
    canonical = str(target)
    if args.action == "validate":
        print(canonical)
        return 0
    if args.confirmed != canonical:
        fail("the confirmation does not exactly match the canonical target.")
    shutil.rmtree(target)
    if target.exists():
        fail("the target was only partly removed; close Hermes and try again.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
