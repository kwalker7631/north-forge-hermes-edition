# Claude Code Session Audit

Timestamp: 2026-08-28 (ninth/tenth task this session - git recheck + build toggle-mode RESET)

Requested task: (1) "Recheck GIT I updated the README" - pull Kenneth's
out-of-session change and report. (2) Then, on his go-ahead, implement the
`toggle-mode` RESET option in `toggle-mode.bat` / `.sh` "to the README spec",
commit and push.

## STATUS: DONE. Pulled `0d6ef80`; built + tested RESET, committed (`c023a62`); Zone C recorded (`b15507b`).

## Part 1 - pulled Kenneth's README change

`git pull --ff-only` -> `8285433..0d6ef80` ("Add files via upload" / "Updated
README", GitHub web upload by Kenneth). One file, `README.md`, +14 / -4:
- RESOLVED the Zone B staleness the previous audit flagged: the skill
  inventory now lists all 8 tsc-only skills + `web-navigator` as built, with
  a `forge-audit` line carrying the name-collision note; `sales-assist` now
  "built, FAQ still a placeholder".
- NEW: documented a third `toggle-mode` action, RESET, that wipes a drive's
  personal setup (`.env`, `.forge-mode`, `.hermes.md`, `.hermes/skills/`)
  back to first-use state with a `YES` confirm - before this task, neither
  `toggle-mode.bat` nor `.sh` implemented it.

## Part 2 - built RESET (commit `c023a62`, Zone A)

Kenneth confirmed "Yes - build it to the README spec."

### `toggle-mode.sh`
Added a `reset)` case to the existing `case` dispatch. Prints what it
clears, `read -p "Type YES (all caps) to confirm: " CONFIRM`, and only on
`[ "$CONFIRM" = "YES" ]` (exact, case-sensitive) runs
`rm -f ".env" ".forge-mode" ".hermes.md"` + `rm -rf ".hermes/skills"`, then
a first-use confirmation. Any other input -> "Cancelled - nothing was
deleted." Prompt text and the `*)` fallback updated to name RESET.

### `toggle-mode.bat`
Restructured from the `if / else if / else` chain to `goto`-label dispatch
(`:do_full` / `:do_sales` / `:do_reset` / `:end`). This was necessary, not
cosmetic: the RESET help text needs characters (originally parentheses) that
cmd mis-parses inside a parenthesised `if` block - the first attempt failed
with "is was unexpected at this time." The label form prints cleanly.
FULL and SALES behaviour is byte-for-byte the same as before (verified).
RESET branch: `set /p CONFIRM=`, `if not "%CONFIRM%"=="YES"` (plain `if`,
case-sensitive) -> echo Cancelled + `goto :end`; otherwise
`del /q` the three files + `rmdir /s /q ".hermes\skills"`, then the
first-use confirmation.

### What RESET deletes / does not delete
Deletes: `.env`, `.forge-mode`, `.hermes.md`, `.hermes/skills/` - exactly
the four the README names (per-drive key + toggle + two launch-generated
artifacts, all gitignored). Never touches `.env.example`, `skills-source/`,
`mode-blocks/`, the scripts, or anything else tracked.

### Testing (isolated scratch dirs, real fixtures, not the repo)
`toggle-mode.sh` (bash, piped input) - 6/6:
- FULL -> `.forge-mode` = full; SALES -> sales; garbage -> new 3-option
  message, `.forge-mode` unchanged.
- RESET + `yes` (lowercase) -> CANCEL, all 4 targets still present.
- RESET + empty -> CANCEL.
- RESET + `YES` -> all 4 targets GONE; `.env.example` and
  `skills-source/tsc-only/keep.txt` still PRESENT.
`toggle-mode.bat` (cmd, stdin from a file for reliable `set /p`):
- FULL / SALES set `.forge-mode` correctly; garbage -> new message.
- RESET + `YES` -> `.env` / `.forge-mode` / `.hermes.md` / `.hermes\skills`
  all deleted; `.env.example` + `skills-source/` intact.
- RESET + `yes` (lowercase) -> "Cancelled - nothing was deleted."
- RESET + `YES` on an already-clean dir -> no-op, no errors (all four
  `if exist` guards).
`bash -n toggle-mode.sh` clean.

Note: when `toggle-mode.bat`'s two `set /p` prompts are fed by a *pipe*
(rather than a file or a real keyboard), cmd's `set /p` can drop the second
line and the RESET confirm reads empty -> cancels. That is a known cmd
pipe/`set /p` quirk in the test harness, not a script defect - a human
typing at the prompt, or `< file` redirection, works correctly (verified).

## Zone A changes made
- `toggle-mode.bat`, `toggle-mode.sh` - RESET action added as described.
  Before: FULL / SALES only; a placeholder-key `.env` or a departing
  owner's key just stayed on the drive. After: `toggle-mode` RESET is the
  one-command scrub-before-handoff. Commit `c023a62`.
- This audit file.

## Zone B changes made
None. (`README.md` change was Kenneth's own commit `0d6ef80`, pulled not
authored.)

## Zone C changes made (commit `b15507b`)
- `NEXT_STEPS.md`: new line under "Done" recording the RESET option, its
  contract, and its test results; ties it to `DEMO_PREP_BACKLOG.md` item 9.
- `DEMO_PREP_BACKLOG.md` item 9: "UPDATE 2026-08-28" - option (a) now has a
  concrete mechanism (`toggle-mode` RESET); still recommends a console spend
  cap as enforced backup since RESET is honour-system.

## Zone B findings (not fixed - reported only)
- None new. `README.md` L37 staleness from the last audit: resolved by
  `0d6ef80`.

## Commits made this session
- Tasks 1-8: `bd8969c` `3f28184` `7e4d55d` `3a44994` `cfa18a7` `df6a328`
  `187cd5e` `0b179f0` `d414f81` `3c2b7f3` `1898d33` `07b1343` `971ac01`
  `05e92aa` `8759d15` `d925539` `8285433`.
- `ca6f610` - audit: pulled `0d6ef80`, flagged RESET-not-built (task 9).
- `c023a62` - toggle-mode RESET (task 10, Zone A).
- `b15507b` - Zone C: NEXT_STEPS + DEMO_PREP item 9 (task 10).
- This report (task 10) - hash in `git log`.

## Uncertain / flagged for the North Forge GPT / Blacksmith
- `toggle-mode.bat` structure changed (if/else -> goto). Low risk, FULL /
  SALES paths tested identical, but a second set of eyes on the batch
  restructure is reasonable.
- RESET is deliberately honour-system (a `YES` prompt, no OS-level
  enforcement). If a stronger guarantee is wanted (e.g. refuse to `git push`
  or refuse to build a drive while a real-looking key is in `.env`), that is
  a separate ask.
- QA parts 2/4 still blocked on a real Anthropic key on this drive
  (unchanged). Ironically, RESET + then adding a real key is now the clean
  path to get this drive into a testable state.

## Status
Clean / done. README pulled; RESET built to spec in both launchers and
tested in isolation (FULL/SALES unchanged; RESET wipes exactly the 4 targets
only on an exact `YES`); NEXT_STEPS and DEMO_PREP item 9 updated. Repo at
`origin/main` (`b15507b` + this report), working tree clean.
