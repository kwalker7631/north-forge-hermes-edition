# Claude Code Session Audit

Timestamp: 2026-08-29 (full repository evaluation)

Requested task: Genuinely comprehensive repo evaluation ahead of Kenneth
personally testing this on his drive - 10 explicit checks: (1) zone coverage
of every file, (2) all 10 skill files read in full + self-lock line + stale
paths, (3) template <-> mode-blocks cross-check incl. /web//draft/hotline/
escalation router entries, (4) recompute FULL/SALES assembled sizes + marker
+ non-ASCII, (5) `.gitignore` via `git check-ignore -v` incl. legacy `skills/`,
(6) full git-history secret scan, (7) repo visibility, (8) README/NEXT_STEPS/
DEMO_PREP cross-check, (9) fresh read + live test of the just-rebuilt
toggle-mode scripts, (10) `hermes doctor` / `hermes skills list`. Zone B
read-only (report only); Zone A/C fix per standing authorization.

## Files inspected

Every tracked file (32):
- Zone A: `.env.example`, `.gitignore`, `launch-north-forge.bat`,
  `launch-north-forge.sh`, `toggle-mode.bat`, `toggle-mode.sh`,
  `setup-thumbdrive.ps1`, `provision-new-drive.ps1`, `skins/north-forge.yaml`,
  `audit/CLAUDE_CODE_LAST_AUDIT.md`.
- Zone B: `.hermes.template.md`, `mode-blocks/full-banner.md`,
  `mode-blocks/full-menu.md`, `mode-blocks/sales-banner.md`,
  `mode-blocks/sales-menu.md`, all 10 `skills-source/**/SKILL.md`
  (assist-intake, draft-writer, escalation-packet, fault-logging,
  forge-audit, hotline-ticket, kb-builder, training-guide; shared:
  sales-assist, web-navigator), `fallback/NORTH_FORGE_v21.8_PASTE_VERSION.md`
  (non-ASCII/structure scan), `KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html`,
  `README.md`, `ATTRIBUTION.md`, `CLAUDE.md`.
- Zone C: `NEXT_STEPS.md`, `DEMO_PREP_BACKLOG.md`.
- Engine source (installed, read-only): `hermes-agent/tools/skills_guard.py`,
  `hermes-agent/agent/skill_commands.py`, `hermes-agent/hermes_cli/skills_config.py`,
  `~/AppData/Local/hermes/cache/project_skill_scans/*.json`.

## Zone A changes made

1. **`.gitignore`** - added a root-anchored `/skills/` rule (+7 lines incl.
   comment).
   - Before: no `skills/` pattern anywhere (the word appears only inside two
     comments). `git check-ignore -v --no-index skills/kb-builder/SKILL.md`
     -> NOT IGNORED; `skills/old.md` -> NOT IGNORED. The earlier
     `git check-ignore -v "skills/"` -> `.gitignore:39:` was a false positive
     on the blank line 39.
   - After: `skills/`, `skills/old.md`, `skills/kb-builder/SKILL.md` ->
     ignored via `.gitignore:50:/skills/`. `skills-source/tsc-only/...` and
     `skills-source/shared/...` -> still NOT ignored (tracked source
     untouched). `.env`/`.forge-mode`/`.hermes.md`/`.hermes/`/`.claude/` ->
     still ignored.
   - Why: item 5 explicitly requires the legacy wrong folder name be
     excluded; an old build artifact named `skills/` could otherwise be
     committed by accident.
   - Commit: see "Commits" below.

2. **`provision-new-drive.ps1`** - repaired the placeholder-token STOP
   message (2 `Write-Host` lines).
   - Before (garbled by a word-drop in commit `aed82d7`):
     `"...Before handing this"` / `"the line that sets cloneUrl near the top
     of this file and replace YOUR_TOKEN_HERE"` / `"with the real read-only
     access token (see README.md...)."` - "Before handing this" has no
     object; the next line has no verb.
   - After: `"...Before handing this"` / `"drive to anyone, edit the line
     that sets cloneUrl near the top of this file"` / `"and replace
     YOUR_TOKEN_HERE with the real read-only access token (see README.md for
     how to generate one)."` - reads as one clean sentence; restores the
     "drive to anyone, edit" phrase that `aed82d7` dropped while swapping in
     the "line that sets cloneUrl" wording.
   - `Write-Host` strings only. Guard logic (`if ($cloneUrl -match
     "YOUR_TOKEN_HERE") { ... exit 1 }`) untouched. PowerShell
     `Parser::ParseFile` -> no syntax errors.

3. **`toggle-mode.bat` lines 6-7** - fixed a malformed `else` branch.
   - Before:
     `if exist ".forge-mode" (type ".forge-mode") else (echo (none set - defaults to SALES)`
     then a lone `)` on the next line. On a first run (no `.forge-mode`) cmd
     consumed the `)` inside the echo text as the block terminator and
     printed `(none set - defaults to SALES` with no closing paren; the lone
     `)` was an orphan.
   - After (one line, escaped parens):
     `if exist ".forge-mode" (type ".forge-mode") else (echo ^(none set - defaults to SALES^))`
   - Pre-existing defect (present in the `c023a62` diff context, not
     introduced by the RESET rebuild).
   - Re-tested the ACTUAL edited file, 7 cases via `cmd.exe` with stdin
     redirected from a file: FULL -> `.forge-mode`=full; SALES (no
     `.forge-mode`) -> prints `(none set - defaults to SALES)` WITH close
     paren, sets `.forge-mode`=sales; bogus -> "Didn't recognize that..."
     unchanged; RESET+`YES` -> `.env` / `.forge-mode` / `.hermes.md` /
     `.hermes\skills` all deleted, `.env.example` + `skills-source/` intact;
     RESET+`yes` and RESET+blank -> "Cancelled - nothing was deleted.";
     RESET+`YES` on an already-clean dir -> no-op. All exit 0, zero stderr.

Also regenerated the git-ignored build artifacts `.hermes/skills/` and
`.hermes.md` for FULL (exactly as `launch-north-forge.sh` does) so the drive
is left internally consistent - before this session `.hermes.md` was stale
(pre-`forge-audit` rename, 16,164 chars, still said `/audit` not
`forge-audit`). Not a tracked change; `git status` stayed clean.

## Zone B findings (not fixed - reported only)

### 1. HEADLINE: the `forge-audit` list-drop is misdiagnosed in three files, and the 2026-08-28 fix did not work

- `hermes skills list --source local` shows 9 of the 10 built project
  skills. `forge-audit` is the one missing - **still**, after the
  `audit/` -> `forge-audit/` rename (commit `8759d15`). Verified this
  session against a clean FULL rebuild of `.hermes/skills/`.
- `hermes skills trust .` reports "10 project skill(s) will load", so the
  skill is seen and (per the package's own docs) still assembles into a
  session - it is only hidden from the *list*.
- Root cause, confirmed by reading engine source
  `hermes-agent/tools/skills_guard.py` (~line 462) and the scan cache
  `~/AppData/Local/hermes/cache/project_skill_scans/*.json`:
  the `skills-guard-v1` rule `agent_config_mod`
  (`r'AGENTS\.md|CLAUDE\.md|\.cursorrules|\.clinerules'`, severity critical,
  category persistence, "references agent config files") fires on the
  literal string `CLAUDE.md`. `forge-audit/SKILL.md` line 3 reads
  "...Use this skill unless a code-maintenance file such as CLAUDE.md is
  specifically requested...". That single token -> scan verdict
  `dangerous` -> withheld from `hermes skills list`.
- Proven this session: a byte-copy of the skill with only that phrase
  reworded (no `CLAUDE.md` token) scans `safe` and appears in the list
  normally (10 local). Copies that kept the token but changed the folder
  name (`forge-review`, `zzz-probe`) still scanned `dangerous` and still
  did not list - so the folder/skill NAME is irrelevant to this behaviour.
- Therefore these statements in the repo are WRONG:
  - `.hermes.template.md` L26 - "'audit' collides with a reserved
    sub-action name in Hermes's own `hermes skills audit` command and
    silently gets dropped from `hermes skills list`".
  - `README.md` L42 - same "reserved sub-action name" claim.
  - `NEXT_STEPS.md` QA FINDING 1 - "collided with Hermes's reserved
    `hermes skills audit` sub-action ... FIXED 2026-08-28 (`8759d15`):
    renamed ...". (A CORRECTION note was added under it this session -
    Zone C.)
- Suggested Zone B fix (Blacksmith / Claude Project chat, NOT Claude Code):
  reword `forge-audit/SKILL.md` line 3 so it does not contain the literal
  `CLAUDE.md` (e.g. "a code-maintenance / agent-configuration file"), then
  re-scan to confirm `safe` + listed; and correct the explanation text in
  `.hermes.template.md` L26 and `README.md` L42. The folder name (`audit`
  vs `forge-audit`) can be decided separately - it does not affect this.

### 2. `skills-source/shared/sales-assist/SKILL.md` has no self-lock line

The other 9 skill files all carry "Never rewrite this skill file on your own
initiative..." `sales-assist/SKILL.md` does not. It is explicitly a
placeholder ("PLACEHOLDER - NOT YET AUTHORED"), but the line should be added
when its real content is authored, so the lock is present from day one.
Zone B.

### 3. web-navigator has a menu line but no router paragraph

`.hermes.template.md`'s `<assistant_router_rule>` gives every mode an
explicit "User asks X: run Y (read .hermes/skills/Z in full)" line - except
web-navigator. `/web or /links` IS present and correct in both
`mode-blocks/full-menu.md` (L13) and `mode-blocks/sales-menu.md` (L4), with
the natural-language trigger note, and the skill's own SKILL.md has a clear
trigger. Per commit `d414f81` the `/web` entry was deliberately added to the
menus only. So this is a consistency observation, not a functional break -
noted for the Blacksmith to decide whether the router should also name it.

### 4. Minor / cosmetic (Zone B, no action expected)

- `forge-audit/SKILL.md` H1 is still `# Audit Skill` (folder is
  `forge-audit`); `fault-logging/SKILL.md` refers to "the audit skill".
  Both use the user-facing `/audit` name, which the template says is
  intentional - so this is naming drift, not an error.
- `.hermes.template.md` + `mode-blocks/*` are LF; `README.md`, `CLAUDE.md`,
  the skill files are CRLF. `core.autocrlf=true`, no `.gitattributes`, so
  committed blobs are normalised - harmless.
- `setup-thumbdrive.ps1` (SUPERSEDED per README L54) still points at
  `kb-builder` only in its closing hint - fine, kb-builder still exists;
  not worth touching a superseded file.

## Zone C changes made

- `NEXT_STEPS.md` - added a "CORRECTION 2026-08-29" note under QA FINDING 1
  (the forge-audit misdiagnosis), and a new "Full repository evaluation
  (2026-08-29)" section recording the three Zone A fixes, the Zone B
  findings, the recomputed assembled sizes, and what is left for Kenneth's
  first launch to confirm.
- `DEMO_PREP_BACKLOG.md` - added item 12 (`/audit` skill missing from
  `hermes skills list`), demo-impact framed, pointing at the Zone B reword.

## Cross-check results (no change needed)

- **Zone coverage (item 1):** all 32 tracked files map to a Zone A/B/C list
  in `CLAUDE.md`. Nothing unzoned. No untracked files. `.env` /
  `.forge-mode` / `.hermes.md` / `.hermes/skills/*` present on disk are
  git-ignored build artifacts/secrets by design, not zoned.
- **Assembled context (item 4), recomputed by replaying the launcher's
  substitution in-memory:** FULL = **16,526 chars**, SALES = **16,520
  chars** - both ~3,480 under the 20,000 truncation limit. Zero unreplaced
  `{{...}}` in either. Template has exactly the two markers, once each.
  Zero non-ASCII in `.hermes.template.md`, all four `mode-blocks/*`, and in
  fact every one of the 32 tracked files (full scan). Supersedes the
  "16,076 / ~16,170" numbers in NEXT_STEPS.
- **`.gitignore` (item 5), post-fix, via `git check-ignore -v`:** `.env`
  (`*.env`), `.forge-mode`, `.hermes.md`, `.hermes/` (`/.hermes/`),
  `.claude/`, and now `skills/` (`/skills/`) - all ignored;
  `skills-source/**` correctly NOT ignored.
- **Secret scan (item 6):** `git rev-list --all` + `git grep` for `sk-ant-`,
  `ghp_`, `github_pat_`, `AKIA` across every revision - only hits are
  textual mentions of the pattern names themselves in `DEMO_PREP_BACKLOG.md`
  / `audit/CLAUDE_CODE_LAST_AUDIT.md` (rev `589ed0f`). `.env.example` =
  `your-key-here`; `provision-new-drive.ps1` = `YOUR_TOKEN_HERE`. Clean.
- **Visibility (item 7):** `gh repo view` -> `"isPrivate": true`,
  `"visibility": "PRIVATE"`.
- **Docs cross-check (item 8):** README / NEXT_STEPS / DEMO_PREP agree with
  each other and the tree on: 8 tsc-only + 2 shared skills all built;
  sales-assist FAQ still a placeholder; RESET mechanism + its 4 targets;
  `setup-thumbdrive.ps1` superseded; repo private. Stale/incorrect bits
  found: the "reserved sub-action" explanation (finding 1); NEXT_STEPS
  L59-61's "README L37 still says placeholders" note (resolved by `0d6ef80`);
  NEXT_STEPS QA sizes (superseded above); DEMO_PREP item numbering out of
  order (1,2,3,7,4,5,6,8,11,9,10 - cosmetic, left alone).
- **toggle-mode scripts (item 9):** fresh read of both. `.sh` - `case`
  dispatch, 6/6 isolated-dir tests pass, `bash -n` clean, unchanged this
  session. `.bat` - `goto`-label dispatch, 7/7 tests pass after the L6-7
  fix. `git show c023a62` confirms the RESET rebuild left FULL/SALES logic
  identical (same commands, moved to labels). RESET in both deletes exactly
  `.env`, `.forge-mode`, `.hermes.md`, `.hermes/skills/` - matches README
  L80.
- **KYO KB HTML:** locked contact-block values all present - portal
  `https://kyocera.service-now.com`, downloads
  `https://mykyocera.kyoceradocumentsolutions.us`, TSC phone
  `1-800-255-6482`, TSC email `customer.service@da.kyocera.com`,
  authorized-login note, `<!-- SUPPORT & RESOURCES -->` / "Support &
  Resources", 128x64 logo slot. No `<script>`. One `<html>`/`</html>`.
- **`hermes doctor` (item 10):** the only issues are environment-level and
  pre-existing - `model.provider 'anthropic'` set but no API key on this
  drive (Kenneth's own next step, NOT touched); SQLite 3.45.1 WAL-reset
  advisory; hermes install 582 commits behind; optional Telegram/Discord/
  Playwright deps absent. No repo or content problem.
- **`hermes skills list --source local`:** 9 shown, all enabled -
  assist-intake, draft-writer, escalation-packet, fault-logging,
  hotline-ticket, kb-builder, sales-assist, training-guide, web-navigator.
  `forge-audit` withheld - see finding 1.

## Commits made this session

See `git log`. One commit for the three Zone A fixes + the two Zone C doc
updates + this audit file (all auto-authorised: Zone A fixes, Zone C
updates, Zone A audit record).

## Uncertain / flagged for primary GPT review

- **Finding 1 is the one to scrutinise.** The mechanism is verified against
  engine source and reproduced both ways (token present -> dangerous ->
  hidden; token removed -> safe -> listed), but the fix is Zone B and needs
  the Blacksmith / Claude Project chat to reword `forge-audit/SKILL.md`
  line 3 and correct `.hermes.template.md` L26 + `README.md` L42. Until
  then, anyone running `hermes skills list` will see `/audit` as missing.
- Whether `/audit` still *loads* in a live session despite being hidden
  from the list is asserted by the package's own docs and by the "10 will
  load" trust count, but has not been observed live (blocked on the API
  key, same as QA parts 2/4).
- The three Zone A fixes are message-string / ignore-rule only, each
  re-tested, but a second look at the `toggle-mode.bat` L6-7 change
  (`^(...^)` escaping) is reasonable since that file was already
  restructured once this cycle.
- web-navigator router-vs-menu asymmetry (finding 3) - judgement call for
  the Blacksmith, not obviously a defect.

## Status

Needs primary GPT review - Zone B finding 1 (forge-audit misdiagnosis +
non-working fix) needs a Blacksmith reword; finding 2 (sales-assist
self-lock) and finding 3 (web-navigator router entry) are lower priority.
Zone A fixes made and tested; Zone C updated; working tree clean after
commit; repo private.
