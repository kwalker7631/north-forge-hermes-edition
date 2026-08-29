# Claude Code Session Audit

Timestamp: 2026-08-29 (provision-new-drive.ps1 enhancement: place, verify syntax, test for real)

Requested task: Extract the handed-over `provision-new-drive.ps1` into the
repo root, overwriting the current one (Zone A). New behavior: right before
the launcher hand-off, if `%LOCALAPPDATA%\hermes\config.yaml` already exists
on the machine, ask the operator whether it is their own Hermes setup (leave
alone) or leftover North Forge testing (clear it) instead of silently
assuming; only `config.yaml` and `.env` may be removed, and only on an
explicit "clear" answer; `skills`/`memory`/`sessions` in that same folder are
never touched. Verify the whole file is syntactically sound and test the new
behavior for real on Windows PowerShell (not available in the Claude Project
sandbox): existing-config prompt with the correct model line shown, answer
"1" deletes nothing, answer "2" removes exactly `config.yaml` + `.env` with
nothing else in the folder changed.

## Files inspected

- `provision-new-drive.ps1` (working tree, HEAD, and the handoff copy at
  `~/Downloads/provision-new-drive.ps1` dated 2026-08-29 01:21).
- `audit/CLAUDE_CODE_LAST_AUDIT.md` (previous session's report - continuity).
- `.gitignore` (session-start check).
- `~/AppData/Local/hermes/config.yaml` (first 8 lines + model/provider lines
  only, read-only, to model the sandbox realistically - no secrets read or
  echoed; `.env` never opened, only hashed).

## Zone A changes made

**`provision-new-drive.ps1`** - commit `7395761`. Net effect vs HEAD
(`46bcfe9`): +36 lines, purely additive - one new block appended between
`Write-Host "Starting North Forge..."` and `.\launch-north-forge.bat`.

1. New Hermes-config check block (the requested behavior), placed from the
   handoff:
   - Resolves `$hermesConfigDir` = `$env:HERMES_HOME` if set, else
     `"$env:LOCALAPPDATA\hermes"`; `$hermesConfigFile` / `$hermesEnvFile` =
     `config.yaml` / `.env` under it.
   - `if (Test-Path $hermesConfigFile)`: prints the path, prints the current
     model line, then asks "Is this: 1. your own existing Hermes setup -
     leave it alone / 2. leftover from earlier North Forge testing - clear
     it", `Read-Host "Type 1 or 2"`.
   - Only on `$hermesChoice -eq "2"`: `Remove-Item` `config.yaml` and `.env`
     (each guarded by its own `Test-Path`, `-Force`, no `-Recurse`). Any
     other answer (incl. empty / "3") -> "Leaving ... untouched", nothing
     removed. `skills`/`memories`/`sessions`/`SOUL.md` are never referenced.
   - `.\launch-north-forge.bat` still runs afterward regardless.

2. One deviation from the handoff bytes, made under Zone A authority as a
   confirmed defect against the stated acceptance criterion ("the correct
   current model line shown"):
   - Handoff line: `... | Select-String "model:" | Select-Object -First 1`.
     Reproduced against a config.yaml mirroring the real one (`model:` /
     `  default: claude-fable-5` / `  provider: anthropic`): the bare
     `model:` mapping key on line 1 is the first match, so the script printed
     `Current model setting: model:` - the section header, not the model.
   - Changed to
     `Select-String '^\s*(model|default|provider)\s*:\s*\S' | Select-Object -First 1`
     (requires a non-space value after the colon). Now prints
     `Current model setting: default: claude-fable-5`. Degrades the same as
     before (guard skips the line) if nothing matches.

3. STOP-message wording (lines 16-18) intentionally NOT taken from the
   handoff. The handoff copy was cut from a base older than commit `8e1eb69`
   and its lines 16-18 reintroduce that commit's fixed word-drop ("...Before
   handing this" with no object / "the line that sets cloneUrl..." with no
   verb). Kept at the `8e1eb69` form. The task was additive only; nothing
   asked to touch this message.

Final state: full-file AST parse clean on Windows PowerShell 5.1
(`Parser::ParseFile`, 0 errors, braces 31/31); 6637 bytes, LF-only, pure
ASCII.

## Live testing (Windows PowerShell 5.1, real execution)

The full script cannot run end-to-end here: `$cloneUrl` still contains
`YOUR_TOKEN_HERE`, so the real script `exit 1`s at its own guard well before
the new block. The new block is self-contained (depends only on `$env:*` and
its own locals), so it was extracted **verbatim** (byte-for-byte, sha256 of
file lines 99-132 == sha256 of the harness block) into a harness that sets
`$ErrorActionPreference = "Stop"` (matching the script) and runs it with
`Read-Host` fed from redirected stdin - real `Test-Path` / `Get-Content` /
`Select-String` / `Remove-Item` against a real on-disk sandbox Hermes dir
(`config.yaml` + `.env` + `skills/keep.txt` + `memories/MEMORY.md` +
`sessions/session1.json` + `SOUL.md`).

| Scenario | Answer | Result |
|---|---|---|
| Existing config | `1` | Prompt shown; `Current model setting: default: claude-fable-5`; all 6 sandbox files byte-identical before/after (0 changes). |
| Existing config | `2` | `config.yaml` + `.env` removed; `skills/keep.txt`, `memories/MEMORY.md`, `sessions/session1.json`, `SOUL.md` all byte-identical. Exactly the two files, nothing else. |
| Existing config | *(empty / Enter)* | "Leaving ... untouched"; 0 changes. |
| Existing config | `3` | "Leaving ... untouched"; 0 changes. Only the exact string `2` triggers removal. |
| No config present | `1` | Block is a complete no-op, no prompt (`Test-Path` false). |

Additional check against the **real** `%LOCALAPPDATA%\hermes` (else-branch,
answer `1` only - the delete branch is unreachable without an exact `2`):
resolved `C:\Users\kwalk\AppData\Local\hermes\config.yaml`, printed
`Current model setting: default: claude-fable-5` (matches `hermes doctor`),
and the real dir's top-level files were sha256-identical before and after.

All scenarios exit 0.

## Session-start check

```
SESSION START CHECK
Pulled: Already up to date
Last audit read: Yes - prior session placed the Zone B forge-audit real-fix
  handoff + 3 Zone A fixes; status "Clean / resolved"; open item is the
  pre-existing missing Anthropic key on this drive.
Uncommitted at start: provision-new-drive.ps1 (working tree already held a
  byte-for-byte copy of the ~/Downloads handoff; not yet committed)
.gitignore: OK (.env, .forge-mode, .hermes.md, .hermes/ all present; also
  config.yaml, /skills/, .claude/)
hermes doctor: Issues found - all environment-level and pre-existing: no
  Anthropic API key on this drive; SQLite 3.45.1 WAL-reset advisory;
  install behind; optional deps (telegram/discord) absent; Playwright
  Chromium not installed. No repo-content issues.
Project skills: 10 local, 10 enabled (assist-intake, draft-writer,
  escalation-packet, fault-logging, forge-audit, hotline-ticket, kb-builder,
  sales-assist, training-guide, web-navigator) - forge-audit still listing,
  matching last session's fix.
```

## Zone B findings (not fixed - reported only)

None. No Zone B file was read for change or touched this session.

## Commits made this session

- `7395761` - provision-new-drive.ps1: prompt before reusing/clearing an
  existing machine Hermes config (Zone A, pushed to origin/main).
- (this audit file) - Zone A operational record.

## Uncertain / flagged for primary GPT review

- **The handoff `provision-new-drive.ps1` in `~/Downloads` is stale at the
  top.** Its lines 16-18 revert commit `8e1eb69`'s STOP-message word-drop
  fix. This session kept the `8e1eb69` wording and took only the additive
  block. If the Claude Project chat regenerates this file, it should base it
  on current `main` (post-`8e1eb69`) so the fix is not lost again.
- **Model-line selector was changed, not placed verbatim.** Handoff used
  `Select-String "model:"`, which on a real Hermes `config.yaml` prints
  `Current model setting: model:` (the YAML section header). Changed to
  `^\s*(model|default|provider)\s*:\s*\S` so the real value shows. This is a
  Zone A file so the direct fix is within authority, but flagging because it
  is a logic change to handed-over content - confirm the new selector and
  the "default: ..." label read acceptably, or supply preferred wording.
- **`$env:HERMES_HOME` branch is assumed, not verified against Hermes.** The
  block prefers `$HERMES_HOME` over `%LOCALAPPDATA%\hermes`. That was the
  clean injection point for testing and matches the block's own comment, but
  whether the installed Hermes actually honors `HERMES_HOME` for its home
  dir was not confirmed here. The `%LOCALAPPDATA%\hermes` else-branch (the
  real-world path) was verified against the live dir.
- **Not exercised:** the block running inside a real full
  `provision-new-drive.ps1` invocation (blocked by the `YOUR_TOKEN_HERE`
  guard) and a real `launch-north-forge.bat` follow-on after a "2" clear
  (same missing-API-key block as prior sessions' QA parts 2/4). The new
  block's own behavior is fully covered by the verbatim-extract tests above.

## Status

Needs primary GPT review - routine Zone A enhancement, placed + model-line
selector fixed + tested for real on PowerShell 5.1, committed and pushed
(`7395761`). Two items for the Claude Project chat: (1) regenerate any
future `provision-new-drive.ps1` handoff from post-`8e1eb69` `main` so the
STOP-message fix is not dropped; (2) confirm the model-line selector change.
