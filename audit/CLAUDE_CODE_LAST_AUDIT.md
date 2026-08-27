# Claude Code Session Audit

Timestamp: 2026-08-26 (pre-flight audit, ahead of Kenneth's live end-to-end
test: wiped drive -> provision-new-drive.ps1 -> launch -> verify)

Requested task: Full pre-flight audit of `north-forge-hermes-edition` looking
for real bugs and gaps, not confirmation. Eight explicit checks: (1) trace
launcher ordering line by line in both .bat and .sh, (2) hunt for any other
hardcoded "line N" position references, (3) exhaustive bare `skills/` sweep,
(4) CLAUDE.md zone lists vs every actual file, (5) `.gitignore` coverage
tested with `git check-ignore -v`, (6) read both SKILL.md files for
self-authored drift, (7) safe dry-runs incl. both modes, (8) README /
NEXT_STEPS / DEMO_PREP_BACKLOG read end to end for internal + cross-file
contradictions.

## Files inspected
- `git pull` (up to date), `git status` / `git diff` (NOT clean at start -
  see below), `git log --oneline -8`, `git ls-files` (23 tracked), full
  `find` tree, `git status --porcelain --ignored`.
- Both launchers read in full and traced line by line:
  `launch-north-forge.bat`, `launch-north-forge.sh`.
- `toggle-mode.bat` / `toggle-mode.sh`, `provision-new-drive.ps1`,
  `setup-thumbdrive.ps1`, `.env.example`, `.gitignore` (with `cat -A`).
- `.hermes.template.md`, all four `mode-blocks/*.md`, `skins/north-forge.yaml`
  - full read + non-ASCII byte enumeration (only char outside ASCII anywhere
  in the generated-context inputs is one U+2014 EM DASH in the template).
- `skills-source/tsc-only/kb-builder/SKILL.md` and
  `skills-source/shared/sales-assist/SKILL.md` - full read.
- `README.md`, `NEXT_STEPS.md`, `DEMO_PREP_BACKLOG.md`, previous
  `audit/CLAUDE_CODE_LAST_AUDIT.md` - full read.
- `CLAUDE.md` zone lists cross-checked against every tracked file.
- Dry runs: `hermes doctor`, `hermes skills list --source local`,
  `hermes skills trust .` (exit-code check), simulated SALES-mode assembly
  then restored to FULL, `gh repo view` + unauth `curl` on the repo.
- Greps: position/line-number references, bare `skills/`, `step N` /
  `section N` / above/below ordering phrases.

## Uncommitted at session start (found, not caused by this session)
- `DEMO_PREP_BACKLOG.md` (Zone C) - externally revised (repo-visibility item
  resolved, new items 7-10 added). Legitimate project content authored via
  the Claude Project chat, just never committed. Committed this session (see
  Zone C changes).
- `README.md` (Zone B) - externally revised: `## First-time setup` retitled
  `## First-time setup (superseded - see above)` and its body rewritten to
  make `provision-new-drive.ps1` the one canonical path. **Left uncommitted.**
  Zone B is read-only for Claude Code and there was no in-session named
  handoff instructing it be placed/committed, so per CLAUDE.md it stays in
  the working tree for Kenneth to commit. It also has unresolved internal
  contradictions (see Zone B findings) that should be settled before it is
  committed.

## Check 1 - Launcher ordering (traced line by line)

**launch-north-forge.bat - PASS.** Order on disk:
1. L3 `cd /d "%~dp0"`
2. L6-13 mode resolve + validate (`set MODE`, read `.forge-mode`, default
   sales on anything unrecognized)
3. L15-21 skill assembly: `rmdir` legacy `skills\`, `rmdir` + `mkdir`
   `.hermes\skills`, `xcopy` shared, `xcopy` tsc-only only if `MODE==full`
4. L23-29 generate `.hermes.md` via inline PowerShell (Get-Content template
   + banner + menu, string Replace, Set-Content) - **no `hermes` call**
5. L34-42 **install check**: `where hermes` -> if `errorlevel 1`, run
   installer, message, `pause`, `exit /b`
6. L44-54 `.env` check: create from example, `notepad`, `pause`, `exit /b`
7. L56-63 skin dir resolve + `copy` skin file - no `hermes` call
8. L65-68 `hermes skin use north-forge` + `hermes skin list` - **first
   `hermes` invocations, after the install check**
9. L74 `hermes skills trust .`
10. L76 `hermes`
Nothing calls `hermes` before L34. The `9b43e75` fix holds.

**launch-north-forge.sh - PASS on ordering.** Same sequence, preceded by
L6-25 desktop-shortcut creation (no `hermes` call, macOS). `hermes` first
appears at L87, after the L61 install check. `hermes skills trust .` returns
exit 0 when the path is already trusted (verified this session), so the
`set -e` on L2 does not abort a repeat launch there.

## Check 2 - Hardcoded position references

Clean. The only position-style reference left anywhere in scripts, README,
or Write-Host text is `provision-new-drive.ps1:17` and `README.md:81`, both
in the **descriptive** form ("the line that sets `$cloneUrl` near the top of
this file"). The old "line 5" / "line 12" mismatch is fully corrected and
consistent across both files. No hardcoded line numbers, no "step N" / "the
Nth line" references that could rot.

## Check 3 - Bare `skills/` sweep

Clean. Every `skills/` occurrence is one of: (a) a correct `.hermes/skills/`
path, (b) a correct `skills-source/` path, (c) deliberate prose describing
the historical `skills/` -> `.hermes/skills/` bug (README, NEXT_STEPS,
template), or (d) the phrase "live skills/context" in the toggle scripts
where `/` is a word separator, not a path. No incorrect bare `skills/` path
references remain.
- Minor asymmetry (not a bug for the wiped-drive test): `launch-north-forge.bat`
  L15 deletes a stray legacy `skills\` dir; `launch-north-forge.sh` has no
  equivalent `rm -rf skills`. Only matters if a drive that once had the old
  bug is reused rather than wiped.

## Check 4 - CLAUDE.md zone coverage vs actual files

Four tracked files are in **no** zone list:
- **`provision-new-drive.ps1`** - the most significant. It is the canonical
  provisioning script for the exact test Kenneth is about to run, 99 lines of
  real PowerShell logic (drive detection, C:-drive refusal, FAT32 refusal,
  clone/pull, launch). It is precisely the "mechanical glue code" Zone A
  describes, but it is not listed there, so if this audit had found a bug in
  it, Claude Code would have had no authority to fix it. Arrived via "Claude
  Project chat handoff" per git log. Recommend adding it to Zone A.
- **`.env.example`** - not zoned. Contains substantive authored guidance (the
  plaintext-key-on-a-shared-drive warning). Recommend Zone A or Zone B.
- **`skins/north-forge.yaml`** - not zoned. Referenced by both launchers,
  copied into Hermes' skin dir. Recommend Zone A (it is config) or Zone B.
- **`audit/CLAUDE_CODE_LAST_AUDIT.md`** - covered by implication (the
  "Session audit report" section says commit it "as part of normal Zone A
  operation") but not in the explicit Zone A file list.
CLAUDE.md is Zone B - not edited. Same class of gap that surfaced
NEXT_STEPS/DEMO_PREP last time; the file list has grown and the zone lists
have not kept up.

## Check 5 - .gitignore

Correct and complete for the required set. `git check-ignore -v` confirms:
`.env` (line 2), `.forge-mode` (line 5), `.hermes.md` (line 8), `.hermes/`
(line 11), `skills/` (line 12, legacy name). `.env.example` correctly NOT
ignored (it is tracked). File is LF, no BOM.
- Minor: `.claude/` (Claude Code's own settings dir) is not in the repo
  `.gitignore`; it is currently ignored only via some machine-global git
  config on this box. It is irrelevant to the launcher / wiped-drive flow
  (Claude Code is not in that path), but adding `.claude/` to the repo
  `.gitignore` would make the repo self-contained. Zone A.

## Check 6 - SKILL.md files

Both read as legitimately **placed** Zone B content, not self-authored:
- `kb-builder/SKILL.md` - dense, specific field-support procedure (exact TSC
  phone/email/URLs, FRU terminology, hex color standard, ESD-strap safety
  correction, Template Compliance Check). Consistent with "ported from the
  v21.8 master." No TODOs, no hedging, no Claude-style phrasing.
- `sales-assist/SKILL.md` - explicitly headed "PLACEHOLDER - NOT YET
  AUTHORED", body is scope-boundary + "do not invent" discipline. Matches
  NEXT_STEPS. Honest placeholder, nothing snuck in.

## Check 7 - Dry runs

- `hermes doctor` - "All checks passed!" Unchanged warnings (SQLite 3.45.1
  WAL bug, Playwright Chromium absent, optional providers not logged in, no
  `GITHUB_TOKEN` in hermes `.env`, 117 commits behind upstream). None touch
  this repo.
- `hermes skills list --source local` - `kb-builder` + `sales-assist`, both
  `local` / `enabled`. Correct for the drive's current `.forge-mode` (full).
- **SALES-mode assembly simulated** (launcher logic only, no `hermes`
  launch): rebuilding `.hermes/skills/` for sales copies **only**
  `skills-source/shared/` -> `sales-assist/`; `kb-builder` is physically
  absent. PASS. Template substitution for the sales banner/menu leaves no
  unreplaced `{{...}}` markers; sales `.hermes.md` is ~13.7 KB (< 20 KB
  limit); "SALES ASSIST ONLY" banner present. Drive then restored to FULL;
  `.forge-mode` never touched; `git status` clean of generated files
  afterward (all correctly gitignored).
- Note (by design, not a defect): a sales-mode `.hermes.md` still contains
  the `/kb` etc. descriptions inside `<assistant_router_rule>` because the
  template body is shared across modes. The guardrails that make this safe
  are present and working: (a) the skill files are physically absent, (b)
  `sales-banner.md` + `sales-menu.md` explicitly instruct redirecting every
  TSC command to the normal channel and state the banner takes precedence.

## Check 8 - Doc contradictions (README / NEXT_STEPS / DEMO_PREP + disk)

Cross-file, on disk today:
1. **`/draft` mode is untracked.** Referenced in `.hermes.template.md`'s
   `assistant_router_rule` ("run Draft Writer") and listed in
   `mode-blocks/full-menu.md` (`/draft or /d`), but: not in NEXT_STEPS "Not
   yet built", no `skills-source/` folder or placeholder, and - unlike every
   other menu entry - no `(see .hermes/skills/...)` pointer. Either it is
   intentionally template-only (the router paragraph is fairly
   self-contained) or it is a missing placeholder nobody is tracking. Logged
   as a NEXT_STEPS "Also outstanding" line this session (Zone C). The
   template/menu side is Zone B - not changed.
2. **Default mode has no skill.** `.hermes.template.md` sets "DEFAULT MODE:
   /assist"; `assist-intake` is an unbuilt placeholder. Degrades gracefully
   (the template has an inline minimum-evidence prompt) but worth demo
   awareness. Logged in NEXT_STEPS this session.
3. **README internal contradictions, all introduced or exposed by the
   uncommitted README edit** (Zone B - reported, not touched):
   - "What's in here" inventory still lists `setup-thumbdrive.ps1` as "first-
     time Windows setup script" with no "superseded" note, and does **not**
     list `provision-new-drive.ps1` at all - directly against the edited
     "First-time setup (superseded)" section.
   - `## Prerequisites (check these before step 1)` - there is no "step 1"
     any more; the section it precedes is now titled "(superseded - see
     above)".
   - Line ~148 "move on to cloning the repo below" points into that
     superseded section.
   - The whole `gh` prerequisite ceremony (install `gh`, `gh auth login`,
     `gh auth status`, "before creating or cloning anything") is orphaned:
     `provision-new-drive.ps1`, now declared canonical, uses
     `git clone https://TOKEN@github.com/...` and never calls `gh`.
   Recommend the primary GPT reconcile the README as one pass before it is
   committed.
4. **Resolved / verified consistent this session:**
   - README line 20 "This repo is private and not published" is now
     **accurate** - independently re-verified: `gh repo view` ->
     `visibility: PRIVATE`, unauth `curl` of both the repo page and raw
     README -> 404. DEMO_PREP item 10's account holds.
   - README "Engine ... kept current with `gh repo sync`" - the fork
     `kwalker7631/north-forge-agent` exists (`isFork: true`, parent
     `NousResearch/hermes-agent`); NEXT_STEPS already marks this DONE.
   - `KYO_KB_TITAN_..._LOCKED.html` present and tracked; NEXT_STEPS DONE
     line is correct.

## Zone A changes made
None. No Zone A file had a reproduced bug. Everything traced correct on the
Windows demo path.

## Zone A findings NOT fixed (could not reproduce in this environment; all
off the Windows demo path, so none block the test)
- `launch-north-forge.sh` L2 `set -e` + L13 `cat > "$HOME/Desktop/North
  Forge.command"`: on any machine where `$HOME/Desktop` does not exist
  (headless Linux, XDG-localized desktop dir), the `cat >` fails and `set -e`
  aborts the launcher **before** it assembles skills or starts Hermes. macOS
  effectively always has `~/Desktop`, so this is a Linux-path risk. One-line
  fix: `mkdir -p "$HOME/Desktop"` or guard with `[ -d "$HOME/Desktop" ]`.
  Reported not fixed because it can't be reproduced here and is not on the
  demo path (aligns with DEMO_PREP item 8).
- `launch-north-forge.sh` L44-56 depends on `python3` being on PATH, with no
  check and no mention in README prerequisites; under `set -e` a missing
  `python3` aborts with a raw error. The `.bat` uses PowerShell for the same
  step and carries no extra runtime dependency. Linux/Mac-path only.
- `launch-north-forge.sh` L82 skin dir `${HERMES_HOME:-$HOME/.hermes}/skins`
  vs `.bat` L60 `%LOCALAPPDATA%\hermes\skins`. Only the Windows path is
  confirmed by `hermes doctor` output. If `~/.hermes/skins` is not where
  Hermes looks on macOS/Linux, `hermes skin use north-forge` (L87) fails and
  `set -e` aborts before launch. Verify against Hermes' actual macOS/Linux
  skin path.
- `launch-north-forge.bat` mode parse has no whitespace tolerance: if
  `.forge-mode` ever contained `full ` (trailing space) or a BOM, L10 would
  not match and it would silently fall back to sales. `.sh` strips whitespace
  (`tr -d '[:space:]'`); `.bat` does not. No current writer produces
  whitespace (`.forge-mode` on disk is a clean `full\r\n`), so this is latent
  only. Hardening the `.bat` to trim `%MODE%` would remove the asymmetry.
- `launch-north-forge.bat` L23-29 generates `.hermes.md` with PS 5.1
  `Get-Content`/`Set-Content` at their default (ANSI/Windows-1252) encoding.
  Today this round-trips the template's single non-ASCII char (U+2014 em
  dash) losslessly because its UTF-8 bytes are all defined in 1252, and the
  current `.hermes.md` on disk is valid UTF-8 with the dash intact. It is
  latent fragility: any future non-ASCII added to the (Zone B) template whose
  UTF-8 bytes hit an undefined 1252 slot would be silently corrupted on
  Windows while the `.sh` (Python, explicit UTF-8) stays clean. Options:
  pin `-Encoding UTF8` in the `.bat` (note PS 5.1 would add a BOM), or keep
  the template pure ASCII.

## Zone B findings (reported only - not fixed)
- `README.md` internal contradictions from the uncommitted edit - see Check 8
  item 3. Recommend one reconciling pass before it is committed.
- `.hermes.template.md` mode lists are inconsistent with each other: the
  `startup_sequence` parenthetical lists "(/assist, /kb, /draft, /audit, or
  /train)", the `flush_clear_rule` lists "(/hl, /esc, /a, /kb, /draft,
  /audit, /train)", neither matches the authoritative 11-command set in
  `mode-blocks/full-menu.md` (missing `/log`, `/sales`, `/menu` in various
  combinations). Reads as "e.g." style rather than exhaustive, so not a hard
  bug, but a reader can't tell which list is definitive.
- `mode-blocks/sales-menu.md` lists the TSC commands to reject as "(/kb,
  /hl, /esc, /audit, /log, /train, /assist)" - omits `/draft`. A sales-drive
  user typing `/draft` is not explicitly covered by that redirect list.
- `/draft` and default-mode-has-no-skill items - see Check 8 items 1-2.

## Zone C changes made
- `DEMO_PREP_BACKLOG.md` - committed the externally-authored uncommitted
  content, and relocated the "## 7. Third proof case" block (it was
  physically sitting between items 3 and 4) to after item 6, so heading order
  now reads 1-10 sequentially. No wording changed; both cross-references
  ("item 6's framing", "item 3 above") remain valid.
- `NEXT_STEPS.md` - added two factual "Also outstanding" lines from this
  audit: the untracked `/draft` mode, and the default mode (`/assist`)
  having only a placeholder skill.

## Commits made this session
- One commit: the two Zone C files above + this audit report. Hash recorded
  in the session-ending chat response. `README.md` deliberately left
  uncommitted.

## Uncertain / flagged for primary GPT review
- **README reconciliation (do before the demo).** The uncommitted README
  edit makes `provision-new-drive.ps1` canonical but leaves the inventory,
  the "Prerequisites / step 1" framing, the "clone the repo below" pointer,
  and the entire `gh` prerequisite block pointing at the old manual path.
  Needs one coherent pass. Claude Code did not touch it (Zone B, no handoff).
- **`/draft`**: is it intentionally template-only, or a missing placeholder?
- **Zone list drift**: `provision-new-drive.ps1` (especially), `.env.example`,
  `skins/north-forge.yaml` are unzoned. `provision-new-drive.ps1` being
  outside Zone A means the canonical provisioning script has no defined
  fix-authority path.
- **`launch-north-forge.sh` `set -e` fragilities** (`~/Desktop`, `python3`,
  skin-dir path): none block the Windows demo, but they undercut "the
  Mac/Linux launchers are built the same way and should work" in DEMO_PREP
  item 8 - at least the `~/Desktop`-under-`set -e` abort is a concrete
  predicted failure, not a maybe.
- Working tree is intentionally not 100% clean at session end: `README.md`
  (Zone B, externally edited, no handoff) remains uncommitted by design.

## Status
Needs primary GPT review. No bug found on the Windows demo path - the
launcher ordering fix holds and mode assembly is correct in both modes. The
substantive items are the README edit's internal contradictions (settle
before committing), the unzoned `provision-new-drive.ps1`, and the untracked
`/draft` mode. The `launch-north-forge.sh` `set -e` issues are real but
off-path for this test.
