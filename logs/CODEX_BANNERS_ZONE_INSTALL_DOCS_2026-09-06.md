# Codex Banners, Zone Classification, and Install Documentation Report

Timestamp: 2026-09-06 UTC
Requested task: place the approved banner markup in `README.md` and
`WELCOME.html`, classify `WELCOME.html` explicitly as Zone B in `CLAUDE.md`,
and add the supplied any-drive installation note to `README.md`.

## Files inspected

- `AGENTS.md` (Codex session and reporting rules)
- `CLAUDE.md` (repository authority rules and Zone B list)
- `README.md` (opening artwork and Windows setup section)
- `WELCOME.html` (header markup)
- `assets/north-forge-banner-etched.png`
- `assets/north-forge-banner-mono.png`
- `tests/test_static_html_assets.py`
- `logs/CODEX_PUSH_LOG.md`

## Changes and findings

### BANNER-01 — RESOLVED — README banner was absent

Placed the supplied `assets/north-forge-banner-etched.png` image tag directly
after the opening centered container. The existing fenced ASCII artwork was
not modified, removed, or duplicated.

### BANNER-02 — RESOLVED — Welcome header banner was absent

Placed the supplied `assets/north-forge-banner-mono.png` image tag directly
inside the header, above the existing North Forge icon and Kyocera logo. Its
inline style caps the banner at 280 pixels and keeps it responsive.

### ZONE-01 — RESOLVED — WELCOME.html required an explicit classification

Added `WELCOME.html` to the Zone B file list in `CLAUDE.md`. This was a named,
pre-approved Zone B handoff, so the exact requested list entry was placed
without changing the surrounding authority rules.

### INSTALL-01 — RESOLVED — Root-drive support needed clarification

Placed the supplied paragraph immediately below the Windows new-drive setup
heading. It explains that North Forge may run from USB, internal, network, or
other storage while retaining the recommendation to install at a drive root.

### TEST-01 — LOW — Header asset coverage did not name the new banner

Extended the existing static HTML asset test with one assertion for the new
welcome banner path. No runtime behavior or portable Python architecture was
changed.

## Verification performed

- Ran `python -m pytest -q tests/test_static_html_assets.py`: 2 tests passed.
- Ran `python -m compileall -q tests`: completed successfully with no output.
- Parsed `WELCOME.html` with Python's standard-library `HTMLParser`: parsing
  completed successfully.
- Ran `git diff --check`: completed successfully with no whitespace errors.
- Inspected the focused diff and confirmed the README ASCII block and the two
  existing welcome-header image tags are unchanged.
- Confirmed both referenced banner PNG files exist in `assets/`.
- Confirmed `.env` is not staged.
- A browser screenshot could not be produced because no browser or browser
  automation runtime is installed in this environment; static markup and
  asset-path checks were used instead.

## Potential edge cases / regressions

- Network shares and internal-drive roots can have permissions controlled by
  the host or administrator. The new paragraph documents supported placement,
  but it does not override operating-system access restrictions.
- The README banner uses a fixed requested width of 820 pixels; narrow Markdown
  renderers may scale it according to their own image rules.
- No additional issues were detected in the requested scope.

## Status

Complete — all four approved documentation placements were made, targeted
tests and static checks passed, and no bundled-Python work was attempted.
