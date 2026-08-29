# Claude Code Session Audit

Timestamp: 2026-08-29 (full repo evaluation, then Zone B real-fix placement + live verification)

Requested task: (1) Comprehensive repository evaluation ahead of Kenneth
personally testing the drive - 10 explicit checks. (2) Then place a Zone B
handoff from the Claude Project chat
(`north-forge-hermes-audit-realfix.zip`, 4 files) fixing the three findings,
commit/push, and - since the first `audit/`->`forge-audit/` rename was
declared done without ever being checked against a live skill list - verify
against `hermes skills list` that `forge-audit` now appears.

## Files inspected

- Every tracked file (32): Zone A x10, Zone B x20 (template, 4 mode-blocks,
  10 skills, fallback, KYO HTML, README, ATTRIBUTION, CLAUDE.md), Zone C x2.
- Installed engine source (read-only): `hermes-agent/tools/skills_guard.py`,
  `agent/skill_commands.py`, `hermes_cli/skills_config.py`;
  `~/AppData/Local/hermes/cache/project_skill_scans/*.json`.

## Zone A changes made (commit `8e1eb69`)

1. **`.gitignore`** - added root-anchored `/skills/` (+7 lines incl. comment).
   Before: no `skills/` pattern anywhere; `git check-ignore --no-index
   skills/kb-builder/SKILL.md` -> NOT IGNORED. After: `skills/**` ignored via
   `.gitignore:50:/skills/`; `skills-source/**` still tracked; all other
   required patterns (`.env`, `.forge-mode`, `.hermes.md`, `.hermes/`,
   `.claude/`) still ignored. Why: item 5 requires the legacy wrong folder
   name be excluded so an old build artifact can't be committed by accident.

2. **`provision-new-drive.ps1`** - repaired the placeholder-token STOP
   message (2 `Write-Host` lines). Before (word-drop from commit `aed82d7`):
   `"...Before handing this"` / `"the line that sets cloneUrl near the top of
   this file and replace YOUR_TOKEN_HERE"` - "Before handing this" has no
   object, next line has no verb. After: `"...Before handing this"` / `"drive
   to anyone, edit the line that sets cloneUrl near the top of this file"` /
   `"and replace YOUR_TOKEN_HERE with the real read-only access token (see
   README.md for how to generate one)."` `Write-Host` strings only; guard
   logic unchanged; `Parser::ParseFile` clean.

3. **`toggle-mode.bat` L6-7** - fixed a malformed `else` branch. Before:
   `else (echo (none set - defaults to SALES)` + a lone `)` on the next line
   -> printed `(none set - defaults to SALES` (no close paren) on a first run
   with no `.forge-mode`. After (one line, escaped): `else (echo ^(none set -
   defaults to SALES^))`. Pre-existing defect (in the `c023a62` diff
   context, not introduced by the RESET rebuild). Re-tested the actual edited
   file, 7 cases via `cmd.exe` stdin-redirect - all exit 0, no parse errors,
   RESET still wipes exactly `.env` / `.forge-mode` / `.hermes.md` /
   `.hermes\skills` and leaves `.env.example` + `skills-source/` intact.

Also regenerated the git-ignored build artifacts `.hermes/skills/` and
`.hermes.md` for FULL (as the launcher does) so the drive is internally
consistent; `git status` stayed clean.

## Zone B placement (commit `a49580f`) - handoff from the Claude Project chat

`north-forge-hermes-audit-realfix.zip` (found in `~/Downloads`) contained
exactly 4 files at correct repo-relative paths - no absolute paths, no `..`,
nothing extra. Extracted with overwrite; `git status` showed exactly the 4
expected files modified. Placed byte-for-byte, not composed or edited by
Claude Code. Each diff matched the stated intent:

- `skills-source/tsc-only/forge-audit/SKILL.md` - line 3: "a code-maintenance
  file such as CLAUDE.md is specifically requested" -> "a code-maintenance or
  agent-configuration file is specifically requested". Self-lock line intact.
  One line changed.
- `skills-source/shared/sales-assist/SKILL.md` - adds the standard "Never
  rewrite this skill file on your own initiative..." self-lock line after the
  Trigger line (with a placeholder-applies-now clarification). One line
  added.
- `.hermes.template.md` - L26: the "reserved sub-action name collision"
  explanation replaced with a "CORRECTION (2026-08-29)" paragraph describing
  the real `skills-guard-v1` "CLAUDE.md" cause. Router: new web-navigator
  entry added after the escalation-packet line, matching every other mode's
  `(read .hermes/skills/X in full)` pattern.
- `README.md` - L42: the same "reserved sub-action name" text replaced with a
  matching CORRECTION note.

Post-placement verification:
- `grep -rn "CLAUDE.md" skills-source/` -> **0 hits**. No other
  scanner-tripping token (`AGENTS.md`, `.cursorrules`, `.clinerules`,
  `.hermes/config.yaml`, `.hermes/SOUL.md`, `.claude/settings`,
  `.codex/config`) anywhere in `skills-source/`.
- All 4 placed files pure ASCII.
- Assembled context recomputed: **FULL 17,209 chars, SALES 17,203** (matches
  the handoff's ~17,209 / ~17,203 estimate; ~2,795 under the 20,000 limit).
  Zero unreplaced `{{...}}`. Template still has exactly the two markers, once
  each.

## Live verification of the real fix (the step the first rename skipped)

No real Anthropic key on this drive, so a full `launch-north-forge` run
stops at the key guard before starting a session. The skills-list check does
not need a session or a key - ran exactly the launcher's pre-guard steps:

1. Rebuilt `.hermes/skills/` for FULL (`cp -r skills-source/shared/. ` +
   `skills-source/tsc-only/. `) -> 10 skill folders incl. `forge-audit`.
2. `hermes skills trust .` -> "10 project skill(s) will load".
3. `hermes skills list --source local` ->

```
0 hub-installed, 0 builtin, 10 local - 10 enabled, 0 disabled
```

   with `forge-audit` present as a listed row (assist-intake, draft-writer,
   escalation-packet, fault-logging, **forge-audit**, hotline-ticket,
   kb-builder, sales-assist, training-guide, web-navigator). Before the fix
   this list showed 9 and `forge-audit` was absent.
4. `skills-guard` scan cache for `forge-audit`: **verdict `safe`, `rules=[]`**
   (scanned 2026-08-29T04:39:55). Before: `dangerous` / `agent_config_mod`.
   A reworded probe copy during the evaluation had already shown the token
   removal flips the verdict; this confirms it on the real file.

Not yet observed: `/audit` loading in an actual live model session (blocked
on the API key, same as QA parts 2/4). The broken symptom was the list
hiding it; that is fixed and verified.

## Original finding 1 diagnosis (kept for continuity - now RESOLVED)

`hermes skills list` withheld `forge-audit` because Hermes's `skills-guard-v1`
scanner rule `agent_config_mod`
(`r'AGENTS\.md|CLAUDE\.md|\.cursorrules|\.clinerules'`, critical, persistence,
in `hermes-agent/tools/skills_guard.py`) fires on the literal string
`CLAUDE.md` anywhere in a skill's text -> verdict `dangerous` -> hidden from
the list (still counted by `hermes skills trust`, still assembles/loads).
`forge-audit/SKILL.md` line 3 named `CLAUDE.md` as an example. The
`audit/`->`forge-audit/` folder rename (`8759d15`) never addressed this - a
folder-name change has no effect on the scanner. Reproduced both ways during
the evaluation (token present -> dangerous -> hidden; token removed -> safe
-> listed). The repo's "reserved `hermes skills audit` sub-action name
collision" explanation in `.hermes.template.md` L26, `README.md` L42, and
`NEXT_STEPS.md` QA FINDING 1 was wrong; all now corrected.

## Cross-check results (item by item - no change needed unless noted)

- **(1) Zone coverage:** all 32 tracked files map to a Zone A/B/C list.
  Nothing unzoned. No untracked files. On-disk `.env` / `.forge-mode` /
  `.hermes.md` / `.hermes/skills/*` are git-ignored artifacts/secrets by
  design.
- **(2) Skill files:** all 10 read in full. Self-lock line: was 9/10
  (sales-assist missing) - now 10/10 after the handoff. No stale `skills/`
  paths. `forge-audit` H1 is still `# Audit Skill` and `fault-logging` says
  "the audit skill" - both use the intentional user-facing `/audit` name.
- **(3) Template <-> menus:** `/draft`, hotline-ticket, escalation-packet
  router entries present and correct. `/web` present in both menu files;
  web-navigator router entry was missing, now added by the handoff. Every
  mode has a menu line and vice versa.
- **(4) Assembled sizes:** FULL 16,526 / SALES 16,520 at evaluation time;
  FULL 17,209 / SALES 17,203 after the real-fix text. Both well under
  20,000. Zero `{{...}}`. Zero non-ASCII in the template, all mode-blocks,
  and in fact every tracked file.
- **(5) `.gitignore`:** post-fix, `git check-ignore -v` confirms `.env`,
  `.forge-mode`, `.hermes.md`, `.hermes/`, `.claude/`, and `skills/` all
  ignored; `skills-source/**` not ignored.
- **(6) Secret scan:** `git rev-list --all` + `git grep` for `sk-ant-`,
  `ghp_`, `github_pat_`, `AKIA` - only textual mentions of the pattern names
  in these docs. `.env.example` = `your-key-here`; `provision-new-drive.ps1`
  = `YOUR_TOKEN_HERE`. Clean.
- **(7) Visibility:** `gh repo view` -> `"isPrivate": true`,
  `"visibility": "PRIVATE"`.
- **(8) Docs cross-check:** README / NEXT_STEPS / DEMO_PREP consistent on
  skills built, RESET + its 4 targets, superseded setup script, private
  repo. Corrected this cycle: the "reserved sub-action" story (finding 1).
  Cosmetic-only: DEMO_PREP item numbering out of order (1,2,3,7,4,5,6,8,11,
  9,10) - left alone.
- **(9) toggle-mode scripts:** fresh read of both. `.sh` - `case` dispatch,
  6/6 isolated-dir tests, `bash -n` clean, unchanged. `.bat` - `goto`-label
  dispatch, 7/7 tests after the L6-7 fix. `git show c023a62` confirms the
  RESET rebuild left FULL/SALES logic identical. RESET (both) deletes exactly
  `.env` / `.forge-mode` / `.hermes.md` / `.hermes/skills/` - matches README
  L80.
- **(10) hermes doctor / skills list:** doctor issues are all
  environment-level and pre-existing - no anthropic API key on this drive
  (Kenneth's next step, untouched), SQLite WAL advisory, install behind,
  optional deps absent. `hermes skills list --source local` - now 10/10 incl.
  `forge-audit` (see live verification).
- **KYO KB HTML:** locked contact-block values all present - portal
  `https://kyocera.service-now.com`, downloads
  `https://mykyocera.kyoceradocumentsolutions.us`, TSC phone
  `1-800-255-6482`, TSC email `customer.service@da.kyocera.com`,
  authorized-login note, `<!-- SUPPORT & RESOURCES -->`, 128x64 logo slot.
  No `<script>`. Well-formed.

## Commits made this session

- `4207e6f` - routine session-start check audit (earlier, before the task).
- `8e1eb69` - full-repo evaluation: 3 Zone A fixes + Zone C findings.
- `a49580f` - Zone B placement of the real-fix handoff (4 files).
- Zone C follow-up (`NEXT_STEPS.md`) + this audit file - see `git log`.

## Uncertain / flagged for primary GPT review

- Finding 1's mechanism, fix, and live verification are all now closed: the
  literal `CLAUDE.md` token was the cause; removing it flips the
  `skills-guard` verdict to `safe`; `hermes skills list --source local` now
  shows `forge-audit` as the 10th skill. Worth the primary GPT confirming
  the CORRECTION wording in `.hermes.template.md` L26 and `README.md` L42
  reads correctly, since those were placed as authored content.
- `/audit` loading in a live session (not just listing) is still unproven -
  needs the API key, same block as QA parts 2/4.
- The `.hermes.template.md` CORRECTION text itself contains the string
  `CLAUDE.md` (explaining the rule). That is the always-loaded context file,
  not a skill file - `skills-guard` scans `skills-source/` / `.hermes/skills/`
  only, so it does not trip the scanner. Noted in case a future change moves
  that text into a skill.
- The three Zone A fixes (message strings + one ignore rule) were each
  re-tested; a second look at the `toggle-mode.bat` `^(...^)` escaping is
  reasonable since that file was already restructured once this cycle.

## Status

Clean / resolved. All three evaluation findings fixed via the Zone B
handoff; finding 1 (the headline) verified against a live `hermes skills
list`. Zone A fixes made and tested. Working tree clean after commits. Repo
private. Remaining open item is unrelated and pre-existing: no Anthropic key
on this drive (blocks live mode exercise, QA parts 2/4).
