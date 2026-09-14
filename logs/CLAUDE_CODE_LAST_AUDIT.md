# Claude Code Session Audit

Timestamp: 2026-09-14, local
Requested task: Kenneth reported "no scripts work" after elevating this checkout to
`F:\`, relabeled `MAIN-NORTH` (Get-Volume confirms: exFAT, ~2TB, DriveType Fixed - the
intended permanent drive, not a rotating test letter), and separately testing a USB
drive as an "Excalibur" build (per this repo's `Advanced/deploy-console/EXCALIBUR.md`).
Follow-up instruction: repair script errors found, keep F: as the working drive going
forward, push all changes, keep an accurate job-log handoff for Claude Code, and explain
root cause + fix.

## Files inspected

- `F:\` volume info (`Get-Volume`) - confirmed `MAIN-NORTH` label, exFAT, Fixed type.
- `north-forge-agent` repo (sibling checkout, no `CLAUDE.md` - has `AGENTS.md`, the
  upstream Hermes Agent OSS contribution guide, no zone-restriction system): `pyproject.toml`,
  `hermes_cli/setup.py`, `scripts/nf-preflight.ps1`, `scripts/lib/nf-readiness.ps1`
  (referenced, not opened in full), `scripts/bootstrap-north-forge.ps1` (partial), git log
  for hardcoded-drive-letter hits (all confirmed to be doc/example text, not logic bugs).
- `C:\Users\kwalk\.local\bin\hermes.exe` - extracted embedded strings; confirmed it's a
  uv-trampoline launcher pointing at `C:\Users\kwalk\.hermes\venvs\hermes-dev\Scripts\python.exe`.
- `C:\Users\kwalk\.hermes\venvs\hermes-dev\Lib\site-packages\__editable___hermes_agent_0_21_0_finder.py`
  - the actual defect: every package path hardcoded to `D:\north-forge-agent\...`.
- `C:\Users\kwalk\.hermes\venvs\hermes-dev\Lib\site-packages\__editable__.hermes_agent-0.21.0.pth`.
- This repo's `CLAUDE.md` (Zone A/B/C lists) - confirmed drift: several Zone A files it
  names (`launch-north-forge.bat/.sh`, `toggle-mode.bat/.sh`, `machine-reset.bat`,
  `provision-new-drive.ps1`, `full-drive-reset.bat/.sh`) don't exist at those (root) paths.
- Prior audit (`logs/CLAUDE_CODE_LAST_AUDIT.md`, 2026-09-13 entry, now overwritten by
  this file) and `git log --oneline` for `launch-north-forge.bat`, `provision-new-drive.ps1`,
  `toggle-mode.bat`, `machine-reset.bat` (all-history) - found commit `d4b0abc`
  ("Retire standalone launcher/installer; adopt as a Hermes profile distribution",
  2026-09-11) as the actual explanation for the missing root scripts: an intentional
  architecture change, not accidental loss.
- `archive/legacy-standalone-launcher/README.md` (the quarantine's own explanation,
  written by that 2026-09-11 session) - read in full; used to distinguish "intentionally
  retired" from "collateral damage."
- `Advanced/toggle-mode.bat`, `Advanced/machine-reset.bat`, `Advanced/full-drive-reset.bat`
  - read in full; checked each for calls into now-archived files.
- `Advanced/deploy-console/*.ps1` (`Zero-Touch-Deploy.ps1`, `exclude-profile-skills.ps1`)
  - confirmed this is the *current*, non-stale deployment path (clones `north-forge-agent`
  fresh, installs this repo as a profile) - not affected by the 2026-09-11 retirement.
- `Advanced/deploy-console/README.md` - confirms independently: "The old FULL / SALES
  toggle is retired. Do not use `toggle-mode.bat`." (validates the toggle-mode.bat
  archival decision below).
- `archive/legacy-standalone-launcher/scripts/machine-reset-safety.ps1` (full read) -
  confirmed it's a generic path-safety validator with zero dependency on the retired
  launcher/mode system.
- `archive/legacy-standalone-launcher/tests/machine-reset-safety.Tests.ps1` (full read)
  - confirmed it exclusively exercises the `.ps1` above.
- `scripts/pinokio_lab_target.py` lines 55-92 (`NORTH_FORGE_MARKERS` set) - checked for
  fallout from today's archival, found a pre-existing (3-day-old) partial staleness, not
  something today's session caused outright.
- `.env.example` (this repo) - no hardcoded drive letters found.
- Windows User `PATH` (`[Environment]::GetEnvironmentVariable('Path','User')`) - found
  two dead `north-forge-hermes-edition` entries under `D:\` and `E:\`.
- `CHANGELOG.md` line ~196 - found a prior, already-standing Zone B flag (README.md /
  USER_MANUAL.md drift) that this session's `toggle-mode.bat` archival makes worse
  (path-stale -> fully-dead reference); did not touch either doc (Zone B).

## Zone A changes made

1. **Restored `scripts/machine-reset-safety.ps1`** (via `git mv` from
   `archive/legacy-standalone-launcher/scripts/machine-reset-safety.ps1`) - it had been
   swept into the 2026-09-11 launcher-retirement archive despite being the sole
   dependency of the still-live `Advanced/machine-reset.bat`, which called it
   unconditionally via `"%~dp0..\scripts\machine-reset-safety.ps1"` (3 call sites) and
   would therefore fail on every invocation ("cannot find the file" from PowerShell).
   Root-caused as collateral damage from an overly-broad file sweep, not an intended
   retirement (the `.ps1` has no logic tied to the drive launcher or FULL/SALES mode).
2. **Fixed a real, independent bug inside `scripts/machine-reset-safety.ps1`** (found by
   re-running its restored test suite): the `Validate` action's success path used
   `[Console]::Out.WriteLine($validated)`, which writes straight to the OS console
   handle. `Advanced/machine-reset.bat`'s `cmd.exe "> file"` redirect (its actual caller)
   captures that fine, but PowerShell's own `$x = & script` variable-capture mechanism
   (used by `tests/machine-reset-safety.Tests.ps1`'s "valid Hermes fixture" positive-path
   case) never sees it - `$canonical` came back `$null`, so the subsequent `Purge` call's
   exact-match check against `$ExpectedCanonical` always failed. Before: 7/8 tests passed
   (only the positive case failed). Changed to `Write-Output $validated`. After: 8/8
   pass. Verified `machine-reset.bat`'s actual cmd-redirect capture path still works
   identically post-fix (ran the same `Validate` invocation through `>` redirection
   manually, correct output captured). This bug predates today's session - it was simply
   never exercised while the file sat archived and untested.
3. **Restored `tests/machine-reset-safety.Tests.ps1`** (via `git mv` from its archive
   location) alongside the `.ps1` it tests.
4. **Archived `Advanced/toggle-mode.bat`** (via `git mv` to
   `archive/legacy-standalone-launcher/Advanced/toggle-mode.bat`) - its `.sh` twin and the
   FULL/SALES mode system it operated (`assemble-skills.ps1`, `mode-blocks/`) were already
   archived in the 2026-09-11 pass; the `.bat` was left behind live but functionally inert
   (nothing has consumed `.forge-mode` since `assemble-skills.ps1` moved). Independently
   confirmed correct by `Advanced/deploy-console/README.md`, which already instructs
   "Do not use `toggle-mode.bat`."
5. **Updated `archive/legacy-standalone-launcher/README.md`**: added the `toggle-mode.bat`
   entry to its contents table (matching its `.sh` twin's row) and added a new paragraph
   explaining the `machine-reset-safety.ps1` restoration and why it was collateral damage
   rather than an intended retirement, including the `Write-Output` fix.
6. **Cleared two dead Windows User `PATH` entries**:
   `D:\north-forge-hermes-edition\.hermes-install-staging\bin` and
   `E:\north-forge-hermes-edition\.hermes-install-staging\bin`. Confirmed via
   `[Environment]::GetEnvironmentVariable('Path','User')` that both lived in the User
   scope only (no admin needed, Machine scope had no matches), removed via
   `[Environment]::SetEnvironmentVariable` (not `setx`, to avoid its ~1024-char PATH
   truncation risk), and confirmed the resulting PATH string no longer matches
   `north-forge`. This only affects new processes going forward, as expected.
7. **Updated `CHANGELOG.md`** and **`NEXT_STEPS.md`** (Zone C, freely editable) with a
   full account of the above, plus an explicit "Known, not fixed this session" list of
   everything found but deliberately left alone (see below).

## Zone B findings (not fixed - reported only)

1. **`CLAUDE.md`'s own Zone A file list is stale** and has been since the 2026-09-11
   retirement: it lists `launch-north-forge.bat`, `launch-north-forge.sh`,
   `toggle-mode.bat`, `toggle-mode.sh`, `machine-reset.bat`, `provision-new-drive.ps1`,
   `full-drive-reset.sh`, `full-drive-reset.bat` as root-level files "Claude Code MAY fix
   directly." None of these exist at the repo root any more (`toggle-mode.bat` and
   `machine-reset.bat` now live in `Advanced/`, and as of this session `toggle-mode.bat`
   is further archived; the rest were archived entirely on 2026-09-11). This is the same
   category of drift already caught once before (the `skills-source/**` vs
   `skills/*/SKILL.md` correction in the 2026-09-13 audit) - worth a dedicated pass over
   the whole Zone A/B/C list rather than one-off corrections each time something's
   noticed. Not edited - Zone B, no named handoff for this specific correction yet.
2. **`README.md` and `USER_MANUAL.md`** - already flagged stale in the standing
   `CHANGELOG.md` 2026-09-12 entry (old root paths for `provision-new-drive.ps1`,
   `toggle-mode.bat`, `full-drive-reset.bat`, `machine-reset.bat`). This session's
   `toggle-mode.bat` archival makes `USER_MANUAL.md`'s reference to it fully dead (not
   just one folder off) - noted in `CHANGELOG.md`'s new entry for visibility, doc itself
   not touched.
3. **`Advanced/deploy-console/DEPLOY.md` / `ADMIN_FIRST_TIME.txt` / `EXCALIBUR.md`** -
   not confirmed stale (didn't find a concrete broken reference), but not fully audited
   line-by-line against the current architecture either given session scope; worth a
   dedicated read-through given how much else in this area had drifted.

## Zone A items found but deliberately NOT changed (flagged for review)

- **`Advanced/full-drive-reset.bat`** - still operates on this drive's own (now-retired)
  `.hermes-home` concept (drive-root install model). Its dependency
  (`scripts/drive-reset-safety.py`) is intact, so unlike `machine-reset.bat` it isn't
  concretely broken - it would just find nothing to purge under the new architecture.
  Left as-is rather than guessing whether Kenneth wants it archived alongside its `.sh`
  twin or kept as a defensive tool.
- **`scripts/pinokio_lab_target.py`'s `NORTH_FORGE_MARKERS`** (drive-detection safety
  heuristic gating lab installs/wipes) - still lists 3 now-archived filenames among its 9
  match-any markers (`launch-north-forge.bat`/`.sh` from 2026-09-11, and now
  `toggle-mode.bat` from this session). Not touched: this backs a safety check, the other
  6 markers (`north-forge.cmd`, `HOW_TO_START.txt`, `ASSIGNED_TO.txt`,
  `machine-reset.bat`, etc.) still resolve correctly on a real Excalibur drive per
  `EXCALIBUR.md`'s own build checklist, so it isn't believed to be a live false-negative
  - but editing a drive-wipe safety gate without more explicit sign-off felt like the
  wrong call to make unilaterally.

## The actual root cause of "no scripts work" (not this repo's bug)

`hermes` (the CLI everything in both repos ultimately calls) was completely broken
system-wide: `ModuleNotFoundError: No module named 'hermes_cli'` on every invocation,
regardless of which repo or what was plugged in as another drive. Root cause: in the
sibling `north-forge-agent` checkout, the package is installed editable
(`uv pip install -e .`) into a dedicated venv (`C:\Users\kwalk\.hermes\venvs\hermes-dev`).
Editable installs work by writing a generated Python import-finder
(`__editable___hermes_agent_0_21_0_finder.py`) containing a hardcoded absolute-path
`MAPPING` dict, one entry per top-level package - and every single entry pointed at
`D:\north-forge-agent\...`, left over from before this checkout moved to `F:\` and was
relabeled `MAIN-NORTH`. `D:` is now a completely different, unrelated volume
(`APPS-AppData`), so the import silently failed to resolve. `hermes.exe`'s own launcher
is a uv-trampoline binary that runs the venv's `python.exe` in isolated mode (`-I`),
which does not fall back to the current working directory the way a normal interactive
`python -c "import hermes_cli"` does - that CWD fallback is what made an ad hoc manual
test of the venv appear to work correctly while the real `hermes.exe` entry point still
failed, and is why this bug was non-obvious to spot by hand.

Fix: `uv pip install -e . --no-deps --python "C:\Users\kwalk\.hermes\venvs\hermes-dev\Scripts\python.exe"`
run from `F:\north-forge-agent`, regenerating the finder with correct `F:\` paths.
Confirmed via `hermes doctor` running clean end-to-end afterward. This is a venv-local
fix, not a repo file change in either checkout - `north-forge-agent`'s own self-healing
`scripts/nf-preflight.ps1` (run automatically by `north-forge.cmd` before every launch)
is explicitly designed to detect and auto-repair exactly this class of failure
(`module_in_checkout` / `marker_repo_matches` checks -> `bootstrap-north-forge.ps1
-Force`), but it only runs through that launcher entry point - a direct `hermes ...`
invocation (as this session used for diagnosis, and as any script directly calling
`hermes` would) bypasses it entirely. Worth flagging to Kenneth: this self-heal exists
and is well-designed, but only protects the `north-forge.cmd` entry point, not direct
`hermes` calls.

## Commits made this session

- One commit, `north-forge-hermes-edition`, `main`, pushed to `origin/main`: restores
  `scripts/machine-reset-safety.ps1` (+ `Write-Output` fix) and
  `tests/machine-reset-safety.Tests.ps1` from archive, archives `Advanced/toggle-mode.bat`,
  updates `archive/legacy-standalone-launcher/README.md`, `CHANGELOG.md`, `NEXT_STEPS.md`.
  (Commit hash recorded in `git log` immediately following this write - this file is
  written and committed together with the rest per standing Zone A authorization.)
- `north-forge-agent`: no repo-file commit needed for the actual fix (venv-local `uv pip
  install -e .` re-point, not a tracked file). Checked for uncommitted drift separately;
  see that repo's own state noted below.

## Uncertain / flagged for primary GPT review

- The `machine-reset-safety.ps1` restoration is the one judgment call in this session
  with real weight: it reverses part of a 2026-09-11 commit that was explicitly "per
  Kenneth's direct instruction." I'm confident it's correct (the file's own content has
  no coupling to the retired system, and `machine-reset.bat` - which the same commit
  deliberately left live - cannot function at all without it), but it's still overriding
  part of a named, intentional prior change rather than fixing an obviously-accidental
  bug, so it deserves a second look rather than being taken as unquestionably settled.
- The three "found but not touched" items above (Zone B doc drift, `full-drive-reset.bat`,
  the Pinokio marker set) are exactly that - flagged, not resolved. None are believed to
  be actively causing harm right now, but none should be assumed closed either.
- Prior sessions' `D:\logs\...` and `D:\HANDOFF_...zip` references (see
  `NEXT_STEPS.md`'s 2026-09-13 entry) point at a drive letter that is now a different,
  unrelated volume on this machine. That content was not recovered or searched for
  elsewhere this session (out of scope) - flagging in case it matters for continuity.

## Status

Needs primary GPT review - real Zone A fixes made and verified (tests re-run, both
callers of the restored script checked), but one of them (machine-reset-safety.ps1
restoration) partially reverses a named prior decision and should get a second look
before being treated as fully settled.
