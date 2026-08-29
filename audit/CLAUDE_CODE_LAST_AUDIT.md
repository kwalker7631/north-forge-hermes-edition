# Claude Code Session Audit

Timestamp: 2026-08-28 (eighth task this session - QA-fixes placement)

Requested task: Place `north-forge-hermes-qa-fixes.zip` - overwrite
`.hermes.template.md`, `mode-blocks/full-menu.md`, `launch-north-forge.bat`,
`launch-north-forge.sh`; add `skills-source/tsc-only/forge-audit/` and delete
the old `skills-source/tsc-only/audit/` (rename, not duplicate). Fixes the
two QA-session findings: (1) `audit` skill name collided with Hermes's
reserved `hermes skills audit` sub-action; renamed to `forge-audit`.
(2) launchers only checked `.env` existence, not key validity; now also
length-check `ANTHROPIC_API_KEY`. Zone A = both launchers (standing
authorization, bug reproduced in QA). Zone B = template, full-menu,
forge-audit skill (Claude Project chat handoff). After placing: delete old
`audit/`, confirm `forge-audit` is the only one, recompute assembled sizes
(~16,526 FULL / ~16,520 SALES), commit, push, update `NEXT_STEPS.md`.

## STATUS: DONE. Placed, verified, committed (`8759d15`), pushed. NEXT_STEPS updated (`d925539`).

## Zip not available - verification method

`north-forge-hermes-qa-fixes.zip` was not in `Downloads/` or anywhere under
`C:\Users\kwalk` / `E:\` (searched by name and by today's mtime). The working
tree already held the extraction (4 modified files + untracked `forge-audit/`,
`audit/` still present). With no archive to hash against, verification was:
(a) `git diff` every modified file vs `HEAD` and confirm each hunk is exactly
what the task description specifies and nothing else; (b) confirm
`forge-audit/SKILL.md` is byte-identical to the outgoing `audit/SKILL.md`
("renamed not duplicated"); (c) confirm no other file changed and no missed
skill-path references; (d) recompute assembled sizes and match the expected
figures. All four held.

## Verification detail

### `.hermes.template.md` (Zone B) - PASS
Two hunks, both matching the description:
- L26 skill inventory: `... escalation-packet, audit, fault-logging ...` ->
  `... escalation-packet, forge-audit, fault-logging ...`, plus an added
  sentence: "The audit skill is named forge-audit, not audit - "audit"
  collides with a reserved sub-action name in Hermes's own `hermes skills
  audit` command and silently gets dropped from `hermes skills list` if used,
  even though it still assembles and loads. The user-facing command is still
  /audit or /chk; only the underlying folder/skill name changed."
- L72 router: `run Auditor (read .hermes/skills/audit)` ->
  `run Auditor (read .hermes/skills/forge-audit)`.
No other bytes changed. Template grew 14,686 -> 15,042 B (+356), all in the
L26 sentence.

### `mode-blocks/full-menu.md` (Zone B) - PASS
One hunk: L6 `/audit or /chk - review existing output for drift/failure (see
.hermes/skills/audit)` -> `(see .hermes/skills/forge-audit)`. The `/audit or
/chk` command name is unchanged.

### `launch-north-forge.bat` (Zone A) - PASS, fix is correct
New 20-line block inserted after the `if not exist ".env"` block, before the
skin copy. Reads the `ANTHROPIC_API_KEY=` line from `.env` via an inline
PowerShell call, emits `MISSING` / `SHORT` (value length < 30) / `OK`; if not
`OK`, prints a clear message, opens `notepad ".env"`, `pause`, `exit /b`.
Threshold 30 is sound - real Anthropic keys are ~100+ chars, the template
placeholder is ~13. Flow is correct: first run creates `.env` from example
and exits; second run with the placeholder now stops here instead of
launching a dead session; third run with a real key proceeds.

### `launch-north-forge.sh` (Zone A) - PASS, fix is correct
Bash mirror of the same guard: `KEYVAL="$(grep '^ANTHROPIC_API_KEY=' .env |
head -1 | cut -d'=' -f2- | tr -d '[:space:]')"`; if empty or
`${#KEYVAL} -lt 30`, print the message, open `${EDITOR:-nano} ".env"`,
`exit 0`. Same threshold, same placement (after the `.env`-exists block).

### `forge-audit/SKILL.md` (Zone B) - PASS
`diff` and `sha256` both show it is byte-identical to the outgoing
`skills-source/tsc-only/audit/SKILL.md`
(`a503a27cf6344fee3823d05c280b87cfbd54e9871251eebe19d477a2ec286503`). Git
recorded the commit as a 100% rename. The file's internal `# Audit Skill`
H1 and "Auditor" persona wording are unchanged and fine - the skill is about
auditing; only the folder/registration name needed to change.

### Old `audit/` folder - DELETED
`git rm -r skills-source/tsc-only/audit`. `skills-source/tsc-only/` now holds
8 dirs: assist-intake, draft-writer, escalation-packet, fault-logging,
forge-audit, hotline-ticket, kb-builder, training-guide. No `audit`.

### No missed references
`grep -i audit` across the repo: every remaining hit is either the
`audit/CLAUDE_CODE_LAST_AUDIT.md` report path / read-only-audit governance in
`CLAUDE.md` (unrelated), the user-facing `/audit` command in
`mode-blocks/sales-menu.md` reject list and `full-banner.md` /
`sales-banner.md` capability prose (correctly unchanged - the command name
did not change), or `fallback/NORTH_FORGE_v21.8_PASTE_VERSION.md` which uses
`/audit` / "Auditor" as concepts with no skill-file paths (nothing to sync).
The one stale spot is `README.md` L37 - see Zone B findings.

### Assembled `.hermes.md` sizes - PASS (match the expected figures exactly)
Recomputed by mirroring the launcher substitution (not by running it):
- FULL  = 16,526 chars (LF) / 16,677 worst-case CRLF / 16,526 bytes UTF-8
- SALES = 16,520 chars (LF) / 16,665 worst-case CRLF / 16,520 bytes UTF-8
Expected ~16,526 / ~16,520 - exact. Far under the 20,000 limit. No
unreplaced `{{...}}` markers.

## Zone A changes made
- `launch-north-forge.bat`, `launch-north-forge.sh` - the API-key-length
  guard described above. Before: launched into a broken session on a
  placeholder key. After: refuses and reopens the editor with a clear
  message. Committed in `8759d15`.
- This audit file.

## Zone B changes made (placement exception - not authoring)
- `.hermes.template.md`, `mode-blocks/full-menu.md`, and the
  `audit/` -> `forge-audit/` rename. In-session named handoff from Kenneth,
  identified as from the Claude Project chat, with an instruction to commit.
  Content placed as-is; the rename is a 100% git rename (no content edit).
  Committed in `8759d15`.

## Zone B findings (not fixed - reported only)
- `README.md` L37: "(placeholders for hotline-ticket, assist-intake,
  escalation-packet, audit, fault-logging, training-guide)" - stale twice
  over: those skills are built (not placeholders) since `d414f81`, and
  `audit` is now `forge-audit`. `README.md` is Zone B and was not in this
  handoff. A future Claude Project chat handoff should refresh that line.

## Zone C changes made
- `NEXT_STEPS.md` (commit `d925539`): new "QA session (2026-08-28)" section
  recording the assembly/toggle/URL PASSes, both findings now FIXED
  (`8759d15`), and that QA parts 2/4 stay blocked until a real Anthropic key
  is on this fresh drive. Updated the `audit` -> `forge-audit` references and
  the mode-toggle "tested" status. Flagged the `README.md` L37 staleness.

## Commits made this session
- Tasks 1-7: `bd8969c` `3f28184` `7e4d55d` `3a44994` `cfa18a7` `df6a328`
  `187cd5e` `0b179f0` `d414f81` `3c2b7f3` `1898d33` `07b1343` `971ac01`
  `05e92aa`.
- `8759d15` - QA fixes: forge-audit rename + launcher key guard (task 8).
- `d925539` - NEXT_STEPS QA section (task 8).
- This report (task 8) - hash in `git log`.

## Uncertain / flagged for the North Forge GPT / Blacksmith
- The qa-fixes zip was not on disk, so this placement was verified by
  diff-against-description + content-identity checks, not a byte-for-byte
  hash match against an archive. The change set is small and every hunk
  matched the stated intent exactly, so confidence is high, but noting the
  method.
- `README.md` L37 needs a Claude Project chat refresh (Zone B).
- QA parts 2 and 4 remain owed. Precondition: a real, spend-capped Anthropic
  API key on this specific drive (`hermes doctor` must go green on the
  `anthropic` provider). Then run the 9 modes - interactively with pasted
  transcripts, or via `hermes chat -q` with an explicit spend go-ahead and
  `--max-turns` / `--run-budget` caps.
- Not launched or tested this task - no `.hermes.md` / `.hermes/skills/`
  rebuild, no `hermes` invocation.

## Status
Clean / done. Both QA findings fixed and verified; assembled sizes match the
expected figures exactly; old `audit/` folder gone, `forge-audit` is the sole
audit-skill folder. Repo at `origin/main` (`d925539`), working tree clean.
One Zone B staleness (`README.md` L37) flagged. QA parts 2/4 still blocked on
a real API key.
