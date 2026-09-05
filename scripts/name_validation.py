#!/usr/bin/env python3
"""Shared, injection-safe name handling for both North Forge launchers.

Names are limited to 64 characters.  Unicode letters/numbers, spaces, and
apostrophe, hyphen, period, comma, and parentheses are accepted.  ASCII
control characters are removed, except that embedded newlines are rejected.
"""

from __future__ import annotations

import argparse
import datetime as dt
from pathlib import Path
import sys

MAX_NAME_LENGTH = 64
PUNCTUATION = "'-. ,()"  # The space is intentional.


def validate_name(raw: str) -> tuple[str | None, str | None]:
    """Return a normalized name and no error, or no name and a safe error."""
    if "\n" in raw:
        return None, "Names must be entered on one line."
    cleaned = "".join(ch for ch in raw if not (ord(ch) < 32 or ord(ch) == 127))
    if not cleaned.strip():
        return None, "Please enter a name."
    if len(cleaned) > MAX_NAME_LENGTH:
        return None, f"Names can be no longer than {MAX_NAME_LENGTH} characters."
    if any(not (ch.isalpha() or ch.isnumeric() or ch in PUNCTUATION) for ch in cleaned):
        return None, (
            "Use only letters, numbers, spaces, apostrophe, hyphen, period, "
            "comma, and parentheses."
        )
    return cleaned, None


def read_validated(path: Path, default: str) -> tuple[str, bool]:
    """Read old state safely, replacing invalid legacy content with default."""
    if not path.exists():
        return default, False
    try:
        raw = path.read_text(encoding="utf-8")
    except (OSError, UnicodeError):
        return default, False
    # State files may have a timestamp on line two; only names use one line.
    first, separator, remainder = raw.partition("\n")
    if path.name == ".drive-record.txt":
        raw_name = first
    else:
        raw_name = raw[:-1] if raw.endswith("\n") and "\n" not in raw[:-1] else raw
    name, _ = validate_name(raw_name)
    if name is None:
        return default, False
    # False also means the legacy value needed control-byte normalization; all
    # callers rewrite it before the value can be propagated anywhere else.
    return name, raw_name == name


def prompt_name(prompt: str, default: str, *, blank_keeps_default: bool) -> str:
    while True:
        try:
            raw = input(prompt)
        except (EOFError, KeyboardInterrupt):
            print()
            return default
        if raw == "" and blank_keeps_default:
            return default
        name, error = validate_name(raw)
        if name is not None:
            return name
        print(f"That name isn't safe to use. {error} Please try again.")


def write_drive(path: Path, name: str) -> None:
    path.write_text(f"{name}\n{dt.datetime.now():%Y-%m-%d %H:%M:%S}\n", encoding="utf-8")


def append_log(message: str) -> None:
    with Path("forge-events.log").open("a", encoding="utf-8") as log:
        log.write(f"[{dt.datetime.now():%Y-%m-%d %H:%M:%S}] [INFO] [drive-record]: {message}\n")


def manage_drive() -> None:
    path = Path(".drive-record.txt")
    if not path.exists():
        name = prompt_name("First launch: your name for this drive's record: ", "Unregistered", blank_keeps_default=True)
        write_drive(path, name)
        append_log(f"CREATE: registered to {name}")
        return
    current, was_valid = read_validated(path, "Unregistered")
    if not was_valid:
        write_drive(path, current)
        append_log(f"LEGACY INVALID NAME REPLACED: registered to {current}")
    new = prompt_name(
        f"Still {current}? [Enter to continue / type a new name to re-register]: ",
        current,
        blank_keeps_default=True,
    )
    if new != current:
        write_drive(path, new)
        append_log(f"RE-REGISTER: {current} -> {new}")


def manage_agent() -> None:
    path = Path(".agent-name")
    if path.exists():
        name, valid = read_validated(path, "North Forge")
        if not valid:
            path.write_text(name + "\n", encoding="utf-8")
        return
    print("\nFirst launch on this drive: you can give your assistant a personal")
    print("name if you'd like - it still runs as North Forge underneath.")
    name = prompt_name("Name your assistant (press Enter to keep 'North Forge'): ", "North Forge", blank_keeps_default=True)
    path.write_text(name + "\n", encoding="utf-8")
    print()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=("drive", "agent", "get", "validate"))
    parser.add_argument("--file", type=Path)
    parser.add_argument("--default", default="North Forge")
    args = parser.parse_args()
    if args.action == "drive":
        manage_drive()
    elif args.action == "agent":
        manage_agent()
    elif args.action == "get":
        if args.file is None:
            parser.error("get requires --file")
        name, valid = read_validated(args.file, args.default)
        if not valid:
            args.file.write_text(name + "\n", encoding="utf-8")
        print(name)
    else:
        name, error = validate_name(sys.stdin.read())
        if name is None:
            print(error, file=sys.stderr)
            return 1
        print(name)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
