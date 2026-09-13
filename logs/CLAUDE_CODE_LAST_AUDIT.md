# Claude Code Session Audit

Timestamp: 2026-09-12 (Pinokio validator reconciliation + deploy-console
repair-path and parse-bug fix)
Requested task: per `Downloads/CLAUDE_TASK_concern_check_and_excalibur_build.md`
Part 1 (confirm/fix the Pinokio same-drive-vs-separate-disk validator
conflict before building a real Excalibur drive), plus two follow-up asks
from the owner mid-session: build a standing drive-root "How To Start"
docs entry point (landed in `north-forge-agent`, see that repo's own
ledger), and fix the deploy console's repair path for a drive where
"someone messed where they shouldn't."

## Files inspected

- `scripts/pinokio_lab_target.py`, `tests/test_pinokio_lab_target.py`
- `logs/HANDOFF_PERPLEXITY_PINOKIO_2026-09-12.md` (the original conflict report)
- `Advanced/PINOKIO.md`, `PINOKIO-on-drive.md`, both `pinokio/SKILL.md` files
- `Advanced/deploy-console/Install-Pinokio-Lab.ps1` (confirmed it needed no
  change - passes no size override, gets the new default correctly)
- `Advanced/deploy-console/Zero-Touch-Deploy.ps1`
- `WELCOME.html`, `archive/legacy-standalone-launcher/launch-north-forge.sh`
  (checking what actually opens `WELCOME.html`)
- Every non-archived `.ps1` in this repo and `north-forge-agent` (static
  parse sweep, see below)

## Zone A changes made

1. **`scripts/pinokio_lab_target.py`** (+ `tests/test_pinokio_lab_target.py`):
   reconciled the hard-block rule with the documented Learning-class
   same-drive design. Before: any North Forge marker file hard-blocked the
   target volume unconditionally, regardless of size - silently
   contradicting `Advanced/PINOKIO.md` / `PINOKIO-on-drive.md`'s 256 GB
   "Learning stick" (North Forge + Pinokio sharing a drive on purpose).
   After: a marker only hard-blocks on a volume at/under a new
   `--excalibur-max-gb` (default 100 GB); above that, the marker no longer
   blocks by itself and the same free-space floor/warn/ok bands any
   candidate gets still apply. `Install-Pinokio-Lab.ps1` needed no change -
   it never passed a size override, so it gets the corrected default
   automatically. 14/15 tests pass (renamed two, added five); the one
   pre-existing failure (`test_blocks_missing_ancestor`) is unrelated,
   already flagged in a prior audit, not touched. Committed `87b513c`.

2. **`Advanced/deploy-console/Zero-Touch-Deploy.ps1`**, two fixes, one commit
   (`e9b6ae9`):
   - **Repair-path gap**: on `-SkipFormat` (repairing an already-deployed
     drive), the private Kyocera edition checkout used `git pull --ff-only`,
     which fails rather than repairs once local tampering or divergent
     history exists there - unlike the agent checkout a few lines above,
     which already force-checks-out `FETCH_HEAD`. Aligned both to the same
     fetch + force-checkout pattern. Only discards local changes inside
     `private-editions\kyocera\` itself; sibling venv/data (and the admin
     passcode inside them) untouched either way - and per that edition's own
     `CLAUDE.md`, only the Blacksmith commits there, so no legitimate
     uncommitted work should ever be at risk in a deployed drive's checkout.
   - **Parse-breaking BOM gap, found by actually running the script, not
     just reading it**: `powershell -File` on this script failed to parse
     at all - the file had no UTF-8 BOM, so Windows PowerShell 5.1 read it
     via the system ANSI codepage, misreading the pre-existing em-dash on
     line 170 (unrelated content, not touched otherwise) as invalid tokens.
     This broke the ENTIRE script, before any code could run - a real,
     previously-unknown blocker sitting directly in the path of the actual
     Excalibur build this task exists to do. Added the BOM; re-verified via
     a clean static parse (`[...Parser]::ParseFile`, no execution) since a
     second live invocation of the deploy engine was denied by the session's
     own auto-mode classifier as a repeated risky action - reasonable
     caution, and the static parse check is equally conclusive for "does
     this file parse now." Then swept every other non-archived `.ps1` in
     both `north-forge-hermes-edition` and `north-forge-agent` the same way:
     all clean - this was a one-off, not a systemic encoding problem across
     the codebase.

## Zone B findings (not fixed - reported only)

- Carried forward, unchanged: the dead `#gateway-service-requirements`
  anchor; `WELCOME.html`'s content still describes the retired
  `launch-north-forge.bat`/`.sh`, not the current `north-forge.cmd` flow
  (now more visible than before, since `north-forge-agent`'s new
  "How To Start.lnk" - see that repo's own ledger, `CHG-2026-09-12-007` -
  will faithfully open this stale page on every drive going forward until
  someone with Zone B authority corrects it).
- The `PINOKIO-on-drive.md` / `Advanced/PINOKIO.md` content-overlap flagged
  in the prior audit is unchanged - not addressed this session.

## Commits made this session

- `87b513c` - Reconcile pinokio_lab_target.py with the Learning-class same-drive design
- `e9b6ae9` - Fix Zero-Touch-Deploy.ps1: repair path for private edition + parse-breaking BOM gap
- `<pending - this file, immediately after this report is written>`

## Uncertain / flagged for primary GPT review

- Whether the owner wants a fully automated "detect existing correct-pattern
  label -> auto-choose repair vs fresh-format" rule built into the pipeline
  itself (discussed, not yet requested as a concrete build - flagged that a
  label match alone is spoofable/coincidental and should be corroborated
  with an actual North Forge marker file check, same evidence
  `pinokio_lab_target.py` already uses, before being trusted).
- The real Excalibur build (Part 2 of the owner's task) is still blocked on
  the admin passcode - not yet supplied. `E:\` (`GREG-NORTH`, 231 GB exFAT,
  empty) is the real candidate drive; owner has confirmed skip-format
  (build onto it as-is) but not yet the passcode text itself.
- `PINOKIO-on-drive.md` vs `Advanced/PINOKIO.md` overlap (prior audit,
  unresolved, not touched this session either).

## Status

Needs primary GPT review for the two items above; otherwise clean. Two real
bugs found and fixed this session by actually reproducing them (not
assumed from reading code): the Pinokio validator's docs-vs-code
contradiction, and a parse-breaking encoding gap in the exact deploy
script this project's stated near-term priority depends on. The real
Excalibur build itself has not started - blocked purely on the admin
passcode.

Handoff bundle: <pending - filled in with scripts/build-handoff-bundle.ps1>
