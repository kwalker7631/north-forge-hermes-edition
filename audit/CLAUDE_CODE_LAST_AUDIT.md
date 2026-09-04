# Claude Code Session Audit

Timestamp: 2026-09-03, late evening EDT. Session-start HEAD `2f111dc`.
Two tasks this session, both from Kenneth in-session. Commits made:
`22ea569` (prior audit report), `5e2bc49` (improvements handoff placement),
and this report.

Requested task:
1. Extract `north-forge-improvements.zip` into the repo root - overwrite
   `.hermes.template.md`, `launch-north-forge.bat`, `launch-north-forge.sh`;
   add `skills-source/shared/daily-brief/` and `CHANGELOG.md` (new file,
   treated as Zone B per Kenneth's instruction, same category as
   README.md / ATTRIBUTION.md). Recompute assembled sizes, confirm
   `daily-brief` frontmatter, flag the margin, commit + push.
2. Separate task, same session: an optimization / redundancy audit of the
   whole repo (not correctness) - (a) redundant instructions across
   `.hermes.template.md` and the skill files that could reclaim character
   budget; (b) genuine logic duplication across the top-level scripts worth
   a shared include, or is one-script-per-purpose fine; (c) dead code,
   unused variables, stale comments. Fix Zone A in scope directly, report
   everything else.

## Session Start Protocol results

1. `git pull` -> "Already up to date." (run at session start; HEAD
   `2f111dc`). A later `git push` of `22ea569` and `5e2bc49` succeeded, so
   `origin/main` is now at `5e2bc49` + this report.
2. `audit/CLAUDE_CODE_LAST_AUDIT.md` read in full. Previous session: the
   palette-vs-Charizard question, no repo change, resolved the earlier
   "skills list shows 0" open item (a `.hermes/` build dir now exists in
   this checkout). Status was "Clean". No action items for this session.
3. `git status` at start -> clean working tree; only the expected
   gitignored artifacts (`.agent-name`, `.env`, `.forge-mode`,
   `.hermes.md`, `.hermes/`) present, none staged.
4. `.gitignore` re-verified - all four required excludes present and
   correct. No Zone A fix needed.
5. `hermes` installed. `hermes doctor` -> still hangs (timeout 20, exit
   124, no output) - fourth consecutive session; environment/network, not
   a repo defect. `hermes skills list --source local` -> **14 local, 14
   enabled** (the pre-existing build dir; this session's daily-brief
   addition brings the *source* count to 15 but the built `.hermes/skills/`
   in this checkout was not rebuilt - no launch run here).

```text
SESSION START CHECK
Pulled: Already up to date at start (origin now at 5e2bc49 + this report after this session's pushes)
Last audit read: Yes - prev session was the palette question, no change, "Clean"; skills-list-0 item resolved there
Uncommitted at start: None (only gitignored artifacts .agent-name/.env/.forge-mode/.hermes.md/.hermes/)
.gitignore: OK - excludes .env, .forge-mode, .hermes.md, .hermes/
hermes doctor: Could not run - hangs, exit 124 (4th session; network/update-check block, not a repo issue)
Project skills: hermes skills list --source local -> 14 built/enabled in this checkout; skills-source now has 15 (daily-brief added this session, not yet rebuilt here)
```

## Files inspected

Task 1 (placement):
- `north-forge-improvements.zip` (`C:\Users\kenw\Downloads\`, 16,405 bytes)
  - extracted to a scratch dir, all 5 members read in full.
- `.hermes.template.md` - full read, old and incoming, CR-normalized diff.
- `launch-north-forge.bat` / `.sh` - full read, old and incoming,
  CR-normalized diff; incoming grepped for the prior-fix lines.
- `skills-source/shared/kyocera-research/SKILL.md` - full read (cron
  name/schedule cross-check against the new launcher block).
- `mode-blocks/full-banner.md`, `full-menu.md`, `sales-banner.md`,
  `sales-menu.md` - full read (assembly size recompute).
- Git history: `git log --oneline --` for the three overwritten files;
  `git show` of `4b74503` and `2dee2c1` in full (the launcher fixes the
  STANDING RULE requires be preserved).

Task 2 (optimization audit):
- `.hermes.template.md` - full read, every block.
- All 15 `skills-source/**/SKILL.md` - char counts for all; full read of
  `flush`, `switch`, `menu`, `daily-brief`, `kyocera-research`; grep sweep
  across all 15 for shared instruction blocks ("Never rewrite this skill
  file", `flush_clear_rule`/`/clear`/`/reset`, scrubbing language, the
  Confirmed-Fact/Strong-Clue classification, research-log continuity).
- All 7 top-level scripts (`launch-north-forge.bat`/`.sh`,
  `toggle-mode.bat`/`.sh`, `machine-reset.bat`, `provision-new-drive.ps1`,
  `setup-thumbdrive.ps1`) - full read.
- Repo-wide grep for references to each script name (which docs/scripts
  invoke or describe each).

## Zone A changes made

**None this session.** Task 1's launcher changes were a byte-for-byte
handoff placement, not a Claude Code fix (detail below). Task 2 surfaced no
Zone A defect meeting the "confirmed real bug, reproduced first" bar - every
Task 2 item is a Zone B content-consolidation decision, a just-placed
handoff file not to be self-edited the same session, or defensible-as-is
defensive code. Full reasoning in the Task 2 section.

## Task 1 - improvements handoff placement (commit `5e2bc49`)

### What the zip contained (5 files)

```
skills-source/shared/daily-brief/SKILL.md   (LF, 2,651 chars)   NEW
.hermes.template.md                          (LF, 17,598 chars)  overwrite
launch-north-forge.bat                       (LF, 5,479 chars)   overwrite
launch-north-forge.sh                        (LF, 6,343 chars)   overwrite
CHANGELOG.md                                 (LF, 3,048 chars)   NEW
```

All members are repo-root-relative, no absolute paths, no `..` traversal.
Placed with CRLF line endings to match the repo's existing working-tree
convention (`core.autocrlf=true` is active here - confirmed by the "LF will
be replaced by CRLF" warning git emits on every write; the committed blob
is LF either way, so `git diff` shows only the intended additions).

### STANDING RULE diff-vs-HEAD (required, every handoff)

**`.hermes.template.md`** - CR-normalized `diff -u` against HEAD is exactly
**one hunk**, at line 34, inside `<how_this_package_is_organized>`:

- OLD: "...switch (registers /switch as a real command), and
  kyocera-research (invoked by a scheduled /cron job, not typed directly -
  see the skill file's setup note for the exact /cron add command) - see
  flush_clear_rule below..."
- NEW: "...switch (registers /switch as a real command), kyocera-research
  and daily-brief (both invoked by scheduled /cron jobs, not typed
  directly - see each skill file's setup note for the exact /cron add
  command; both self-schedule automatically at every launch if missing,
  see launch-north-forge.bat/.sh) - see flush_clear_rule below..."

Every other line of the 148-line template is byte-identical. All prior
Zone B fixes verified still present: `<personalization>` block (`cfd618d`),
`<hermes_specific_addendum>` item 3 "/FLUSH AND /SWITCH ... Never /clear or
/reset" (`1fd6c1e` Finding 4), `<assistant_router_rule>` web-navigator
entry (`a49580f`), the forge-audit "named for historical reasons" note, the
`.hermes/skills` folder name. Nothing reverted or contradicted.

**`launch-north-forge.bat`** - one hunk, `@@ -113,4 +113,18 @@`, purely
additive: +14 lines after `hermes skills trust .` and before the final
`hermes`. Lines 1-115 unchanged. Verified present and untouched in the
incoming file:
- line 34 `echo North Forge> ".agent-name"` (default branch, no trailing
  space - deliberate per `4b74503`)
- line 36 `echo !CUSTOMNAME! > ".agent-name"` (**space before the
  redirect** - the `4b74503` fix so a name ending in a digit can't be
  parsed as an `N>` FD redirect)
- lines 26-39 the `2dee2c1` first-launch name-prompt block
- line 51 the `hermes model` echo line (`2dee2c1`)

**`launch-north-forge.sh`** - one hunk, `@@ -140,4 +140,16 @@`, purely
additive: +12 lines after `hermes skills trust .` and before
`exec hermes`. Lines 1-141 unchanged. Verified present and untouched:
- line 57 `read -p "..." CUSTOMNAME || CUSTOMNAME=""` (the `4b74503` fix -
  non-interactive stdin EOF degrades to the default name instead of
  aborting under `set -e`)
- lines 51-64 the `2dee2c1` name-prompt block
- line 87 the `hermes model` echo line

No previously-recorded deliberate fix is removed, reverted, or contradicted
by any of the three overwrites. The diff-before-placement step passed
cleanly for all three.

### The added launcher block (both scripts, same logic)

`.bat`:
```
hermes cron list 2>nul | findstr /C:"nightly-kyocera-research" >nul
if errorlevel 1 (
    echo Scheduling the nightly Kyocera research job...
    hermes cron add "every 24h" "Run the kyocera-research pass" --skill kyocera-research --name nightly-kyocera-research >nul 2>nul
)
hermes cron list 2>nul | findstr /C:"daily-kyocera-brief" >nul
if errorlevel 1 (
    echo Scheduling the daily Kyocera brief job...
    hermes cron add "0 8 * * *" "Run the daily-brief pass" --skill daily-brief --name daily-kyocera-brief >nul 2>nul
)
```
`.sh` is the `if ! ... | grep -q ...; then` equivalent. Cross-checked the
`--name` values against the skill files' own setup notes:
- `kyocera-research/SKILL.md` setup note: `--name nightly-kyocera-research`,
  `"every 24h"` -> **matches** the launcher.
- `daily-brief/SKILL.md` setup note: `--name daily-kyocera-brief`,
  `"0 8 * * *"` -> **matches** the launcher.
So the `findstr`/`grep -q` guard keys on the same `--name` string a manual
`/cron add` would have registered - the self-heal check will correctly
detect "already scheduled" vs "missing". Whether `hermes cron list`'s
output actually contains the `--name` value verbatim was **not** verifiable
this session (no live Hermes session against a real key on this checkout);
the assumption is reasonable and matches how `hermes cron` is documented,
but it is Kenneth's fresh launch that truly exercises it. Flagged below.

### daily-brief skill

Frontmatter (bytes 0-98 of the file):
```
---
name: daily-brief
description: A short daily digest of Kyocera and document-solutions industry news - lighter and faster than kyocera-research
---
```
`name: daily-brief` confirmed. It carries the standard "Never rewrite this
skill file..." self-lock line. It lives in `skills-source/shared/`, so both
`launch-north-forge.bat` (`xcopy skills-source\shared`) and `.sh`
(`cp -r skills-source/shared/.`) copy it into `.hermes/skills/` in **both**
FULL and SALES modes - simulated the shared-copy locally, `daily-brief`
appears in the result alongside the other 6 shared skills. Skill source
count 14 -> 15 (8 tsc-only + 7 shared).

### Assembled `.hermes.md` size recompute

Assembly = `.hermes.template.md` with `{{MODE_BANNER_BLOCK}}` ->
`mode-blocks/{mode}-banner.md`, `{{COMMAND_MENU_BLOCK}}` ->
`mode-blocks/{mode}-menu.md`, `{{AGENT_NAME}}` -> `North Forge` (default,
`.agent-name` absent). Skills are **separate on-disk files, not
concatenated into `.hermes.md`** - they do not count toward the size.
Computed in PowerShell on LF-normalized inputs (the canonical assembly
measure, matching every prior audit):

| Mode  | template | + banner | + menu | assembled | vs 2026-09-01 | margin to 20,000 |
|-------|----------|----------|--------|-----------|---------------|------------------|
| FULL  | 17,598   | 210      | 1,449  | **19,211**| +110          | **789**          |
| SALES | 17,598   | 816      | 838    | **19,206**| +110          | **794**          |

Matches the handoff's stated `~19,211 FULL / ~19,206 SALES` exactly. Zero
unreplaced `{{...}}` markers in either assembled output (each of the three
markers appears exactly once in the template). Zero non-ASCII in any of the
5 placed files. `bash -n launch-north-forge.sh` clean; `.bat` running paren
depth balanced (final 0).

### MARGIN - FLAGGED PLAINLY, PER THE HANDOFF INSTRUCTION

**The assembled `.hermes.md` is now 789 chars (FULL) / 794 chars (SALES)
below the 20,000-character ceiling at which Hermes silently truncates the
middle of a context file** (README.md:150; also stated in
`fallback/NORTH_FORGE_v21.8_PASTE_VERSION.md:20`). This is no longer a
"budget against it on the next change" note - it is close enough that the
next Zone B addition of any real size (a new `<...>` rule block, another
menu line with description, a banner expansion) can push the assembled file
over the limit, at which point rule blocks in the middle of `.hermes.md`
are dropped with **no error**. There is still no automated size guard
anywhere in the launch path. Recorded in `NEXT_STEPS.md` under a new
2026-09-03 section with the same emphasis, and see Task 2(a) below for
where the character budget could be reclaimed if content needs to keep
growing.

### Commit

`5e2bc49` - "Place improvements handoff: daily-brief skill + cron
self-scheduling launchers + CHANGELOG". 6 files (the 5 placed +
`NEXT_STEPS.md` Zone C update), +155 / -1. Pushed to `origin/main`
(`22ea569..5e2bc49`).

### Not exercised this session (deferred - no live key on this checkout)

- A live `hermes cron list` / `hermes cron add` run - so the self-heal
  guard's string-match assumption against real `hermes cron list` output
  is unverified.
- A live model run against the new `.hermes.md`.
- A launcher rebuild of `.hermes/skills/` in this checkout (still shows the
  pre-daily-brief 14-skill build).
Kenneth's next real launch exercises all three.

## Task 2 - optimization / redundancy audit

### Framing correction that changes part (a)

**Skill files do NOT count toward the 20,000-char `.hermes.md` ceiling.**
Only `.hermes.template.md` + the active mode's `banner.md` + `menu.md` are
assembled into `.hermes.md`. Every `skills-source/**/SKILL.md` is loaded by
Hermes *on demand* when its mode triggers, from `.hermes/skills/`.
Consolidating skill-file text reduces on-disk size and per-skill load cost,
but it does **not** move the margin. The only margin levers are the
template (17,598) and the four mode-blocks (210 / 1,449 / 816 / 838). Part
(a) below is split accordingly.

### (a) Redundant / overlapping instructions

**Budget-relevant (template + mode-blocks) - these actually reclaim margin:**

1. **`<how_this_package_is_organized>` (template lines 32-38, ~2,700 chars)
   is the single highest-yield consolidation target in the whole assembled
   file.** Lines 34 and 36 are almost entirely meta-narrative for a *human*
   reading the template: which skills exist, that they're "all built and
   tracked in NEXT_STEPS.md", why the audit folder is called `forge-audit`,
   the YAML-`name:`-frontmatter mechanism and what it "silently broke"
   before, the physical FULL-vs-SALES copy behavior. None of that is an
   instruction the model needs on every turn. The genuinely operational
   content is: line 38 ("When a mode triggers, read and follow the matching
   skill file in full ... the skill file is the authority") and the Sales
   half of line 36 ("a missing TSC skill ... means that capability is
   intentionally not part of this deployment. Say so plainly and stop").
   Moving the repo-layout narrative to `README.md` / `NEXT_STEPS.md` and
   keeping only those two operational pieces would reclaim an estimated
   **1,500-2,000 chars** - roughly tripling the current margin in one edit.
   Zone B, so the Claude Project chat / Blacksmith must make the call, but
   it is by far the best lever available.

2. **The "never /clear or /reset" safety point is stated 4x in the
   assembled `.hermes.md`:** (i) the full `<flush_clear_rule>` block
   (template lines 107-121, ~1,450 chars); (ii) `<hermes_specific_addendum>`
   item 3 "Never /clear or /reset for this - see flush_clear_rule"; (iii)
   `<how_this_package_is_organized>` "see flush_clear_rule below for why
   /clear and /reset must never be used instead"; (iv) **the menu line** in
   both `full-menu.md:10` and `sales-menu.md:6` - "NEVER /clear or /reset
   for either - both are native Hermes commands that wipe the whole session
   with no warning" (~95 chars/mode). The menu-line clause duplicates a
   point already made at length two sections down in the same file.
   Trimming it to "(see flush_clear_rule below)" - matching the style of
   the `/flush` line immediately above it - reclaims ~70-80 chars per mode
   with zero loss of information.

3. **`<assistant_router_rule>` (template lines 63-89) vs each skill's own
   "Trigger:" line.** Some overlap is by design (template routes, skill
   executes). But 5 of the router entries have grown a verbose "or says
   something like '...'" example clause (hotline-ticket, escalation-packet,
   web-navigator, draft-writer, forge-audit). Tightening those to the bare
   routing condition would reclaim ~400-600 chars. Medium risk - the
   examples do help disambiguation - so lower priority than #1.

4. **`<system_persona>` para 1 (lines 42-44) and `<human_voice_protocol>`
   "Avoid:" list (line 102) are ~60% the same content** - both enumerate
   "no emojis / no decorative symbols / no corporate filler / no
   unsupported certainty / direct plain language". Merging the two blocks
   (keep the "seasoned field veteran" framing, keep the banned-phrases
   list, drop the duplicated adjective pile) - est. ~300-400 chars.

5. **`<decisive_assistant_rule>` (lines 91-97, ~1,500 chars) makes one
   point** ("end every substantive response with a specific next step, not
   a dead end") three times: the rule, a paragraph of worked examples, then
   the SALES caveat. Could be ~40% shorter without losing the rule.

Rough combined reclaimable budget from (a) items 1-5 without removing any
actual rule: **~2,800-3,600 chars**, i.e. the margin could go from ~790
back to ~3,500-4,400 if the Blacksmith wants the headroom.

**Skill-file redundancy (NOT budget-relevant - on-demand load):**

6. "Never rewrite this skill file on your own initiative. Flag it to the
   Blacksmith..." appears verbatim in **all 15** skill files (~110 chars
   each, ~1,650 total on disk), and is also stated more forcefully in the
   template's `<hermes_specific_addendum>` item 1. Because a skill file is
   only in context when its own mode is active, this isn't runtime bloat,
   and the per-file copy is a deliberate safety property (a skill read in
   isolation still carries its own lock). Consolidation possible but low
   value and arguably weakens the guarantee.
7. `flush` (1,592 chars), `menu` (1,227), `switch` (2,361) are "thin
   routing skills" that each spend 3-5 paragraphs restating that they are
   thin routing skills and deferring to `.hermes.md`. `flush` and `menu`
   could each be ~4 lines. No margin impact; minor on-disk / load saving.
8. `daily-brief` and `kyocera-research` share a "check the log before
   writing, don't repeat entries" continuity idea and a
   `research-log/*.md` output-format block, worded differently in each.
   This is deliberate - the new skill explicitly contrasts its "light
   morning scan" against kyocera-research's "deep investigation" - and the
   two logs are separate files. Fine as-is.

### (b) Script logic duplication - shared include?

Note: the task's script list named **`quick-drive-setup`**, which **does
not exist in this repo and never has** (`git log` and a working-tree search
both find nothing). Most likely a conflation with `provision-new-drive.ps1`
(the canonical new-drive path) or `setup-thumbdrive.ps1`. The seven scripts
that do exist: `launch-north-forge.bat`/`.sh`, `toggle-mode.bat`/`.sh`,
`machine-reset.bat`, `provision-new-drive.ps1`, `setup-thumbdrive.ps1`.

Genuine duplication:

1. **Per-machine Hermes-dir resolution** (`HERMES_HOME` else a per-OS
   default) appears in 4 places: `launch-north-forge.bat:97-101`,
   `machine-reset.bat:22-26`, `provision-new-drive.ps1:106`,
   `launch-north-forge.sh:128`. It is only ~3 lines each, the default is
   **intentionally OS-divergent** (`%LOCALAPPDATA%\hermes` on Windows,
   `$HOME/.hermes` on Mac/Linux), and a shared include would need three
   language-specific copies (`.bat` `call`, `.sh` `source`, `.ps1`
   dot-source) plus a new "include not found" failure mode. **Not worth
   extracting** - the cure is bigger than the disease.

2. **First-run `.env`-from-`.env.example`** logic is in
   `launch-north-forge.bat`/`.sh` *and* `setup-thumbdrive.ps1`. See #3.

3. **`setup-thumbdrive.ps1` is wholesale redundant.** `README.md:66` and
   `:123` both mark it **SUPERSEDED** - "Do not use for new drives", "kept
   only because Kenneth's own personal drive was set up with it early on".
   It re-implements Hermes-install-check + `.env` setup + `.forge-mode`
   init that `provision-new-drive.ps1` and `launch-north-forge.bat` now
   own. It is ~4,500 chars of unmaintained parallel setup logic that a team
   member could run by mistake (nothing stops them - it's in the repo root
   next to the real launchers). **Recommendation: delete it, or move it to
   an `archive/` subfolder.** Deleting a file the README explicitly says is
   deliberately retained is a Blacksmith decision, not a Zone A
   "confirmed-bug" fix - so flagged here, not done.

Everything else: the **one-script-per-purpose structure is correct as-is.**
`toggle-mode` (drive mode file) and `machine-reset` (per-machine Hermes
state) are genuinely different jobs with near-zero shared logic. `launch`
and `provision` are sequential, not parallel - `provision-new-drive.ps1`
ends by calling `.\launch-north-forge.bat`. The system's stated design
philosophy (CLAUDE.md Zone A: "mechanical glue code ... testable, low-risk";
README: a team member should "double-click ... rather than type commands or
think about mode at all") argues against adding an include indirection
layer for a few lines of savings.

### (c) Dead code / unused variables / stale comments

1. **`launch-north-forge.bat` / `.sh` - the new cron block's header comment
   is now stale/narrow.** It reads "Self-healing **nightly research job** -
   checks every launch, re-schedules itself if missing". The block it heads
   now schedules **two** jobs (the `every 24h` research pass *and* the
   `0 8 * * *` daily brief). The singular "nightly research job" label
   under-describes it. This text arrived byte-for-byte in the
   `north-forge-improvements.zip` handoff placed this same session
   (`5e2bc49`), so per the Zone B placement discipline I did **not**
   self-edit it. Flagging for the Claude Project chat to reword on the next
   launcher revision - e.g. "Self-healing scheduled jobs - re-adds the
   research and daily-brief cron entries if either is missing".
2. **`provision-new-drive.ps1:124`** - `if (Test-Path $hermesConfigFile) {
   Remove-Item $hermesConfigFile -Force }` sits inside an outer
   `if (Test-Path $hermesConfigFile)` (line 110) with nothing deleting the
   file in between: a redundant re-check. It is harmless (defensive against
   the file vanishing mid-run under `$ErrorActionPreference = "Stop"`).
   Leaving as-is - removing it trades a robustness margin for one line, and
   the task is "leaner where it's a real win", which this isn't.
3. **`launch-north-forge.bat:18`** `if exist "skills" rmdir /s /q "skills"`
   - cleans up the legacy wrong-folder-name artifact from an early build.
   Still-relevant defensive code, matches the `.gitignore` `/skills/` guard
   and its explanatory comment. Not dead - keep.
4. **No unused variables** in any script. `SCRIPT_PATH` (`sh:4`) used at
   `sh:16`; `$hermesEnvFile` (`ps1:108`) used at `ps1:125`; `KEYCHECK`
   (`bat:82`), `KEYVAL` (`sh:115`), `$volumeArray` (`ps1:41`), `$vol`,
   `$target`, `$modelLine` all used. No unreachable branches. `bash -n`
   clean on both `.sh` scripts; `.bat` label/paren structure sound in all
   three `.bat` files.
5. **Stale doc entries (Zone C, left per the file's append-only
   convention):** `NEXT_STEPS.md:114` still lists a `toggle-mode.bat` L6-7
   cosmetic item as open; several "Not yet built" / skill-count lines
   pre-date the 15-skill reality. The 2026-09-03 section I appended this
   session carries the current counts and margin, so the historical
   entries are superseded in place rather than rewritten.

### Task 2 - net actions

**No Zone A code changes.** Every finding is one of: (i) a Zone B
character-budget consolidation that only the Claude Project chat /
Blacksmith may make (a-items 1-5); (ii) a file placed byte-for-byte from a
handoff this same session, not to be self-edited (c-item 1); (iii)
defensible-as-is defensive code where a "fix" is a net negative (c-items
2-3); or (iv) a whole-file deletion recommendation that exceeds the
"confirmed bug" Zone A bar (b-item 3, `setup-thumbdrive.ps1`).

## Zone B findings (not fixed - reported only)

New this session (Task 2):
- **`.hermes.template.md` margin is ~790 chars from the 20,000 truncation
  ceiling** and the largest reclaimable block is
  `<how_this_package_is_organized>` (~1,500-2,000 chars of human-facing
  meta-narrative that isn't a per-turn instruction). See Task 2(a) item 1.
- **4x restatement of the "/clear or /reset" safety point** in assembled
  `.hermes.md`; the two menu-line copies (`full-menu.md:10`,
  `sales-menu.md:6`) are the trimmable ones. Task 2(a) item 2.
- **`<system_persona>` / `<human_voice_protocol>` ~60% content overlap**;
  **`<decisive_assistant_rule>` says one thing three times.** Task 2(a) 4-5.
- **`setup-thumbdrive.ps1` is superseded dead weight** (README says so) -
  recommend delete or move to `archive/`. Task 2(b) item 3.
- **New cron-block comment in both launchers says "nightly research job"
  but the block schedules two jobs** - reword on the next launcher
  revision. Task 2(c) item 1.

Carried forward, unchanged:
- `CLAUDE.md`'s bulleted "## Zone A" list omits `machine-reset.bat` while
  the "Required first response" recital includes it. Cosmetic divergence in
  the authority document.

## Commits made this session

- `22ea569` - "Audit: palette-vs-Charizard question, no repo change -
  skills-list count resolved (build dir now exists)" - the previous
  session's audit report, committed at the start of this one.
- `5e2bc49` - "Place improvements handoff: daily-brief skill + cron
  self-scheduling launchers + CHANGELOG" - Task 1. 6 files, +155 / -1.
- This report - committed + pushed as routine Zone A operation.

## Uncertain / flagged for primary GPT review

1. **The launcher self-heal guard's string match is unverified against
   real `hermes cron list` output.** The block greps `hermes cron list` for
   the literal `--name` value (`nightly-kyocera-research` /
   `daily-kyocera-brief`). If `hermes cron list` renders the job name
   differently (truncated, in a table column, without the raw `--name`
   string), the guard would never match and every launch would re-run
   `hermes cron add`, potentially stacking duplicate cron entries. Needs a
   live check on Kenneth's next launch: run the launcher twice, then
   `hermes cron list`, confirm exactly one entry per job. Cannot be tested
   on this checkout (no key, `hermes doctor` also hanging).
2. **`hermes doctor` has hung for 4 consecutive sessions.** Consistent
   behavior, assessed as an offline/network block on its update-check, not
   a repo defect - but the Session Start Protocol's step-5 "confirm last
   known-good state" cross-check has now not run in a month of sessions. If
   `doctor` is meant to work offline, that's a Hermes issue outside this
   repo.
3. **Task 2(a) is a set of recommendations, not applied changes.** The
   character-budget consolidations (especially trimming
   `<how_this_package_is_organized>`) need the Claude Project chat to
   author the actual replacement text and hand it back as a Zone B
   placement. This audit only identifies where the budget is and estimates
   the yield; it has not drafted the leaner wording (that would itself be
   composing Zone B content, which Claude Code must not do).
4. **`setup-thumbdrive.ps1` deletion recommendation** - wanted a second
   opinion before anything is removed. It's in CLAUDE.md's Zone A list, so
   Claude Code technically could delete it under standing authorization,
   but "delete a file the README deliberately keeps for historical
   reasons" is not the kind of change the Zone A auto-commit authorization
   was written for. Holding for an explicit Blacksmith yes/no.
5. **Still open from earlier reports, untouched:** the `f902285` flags
   (flag 1 `hermes model` echo line intent - note it IS in the current
   launchers and the `2dee2c1` commit message documents it; flag 4
   name-prompt fires before the Hermes-install gate; flag 6 README `/cron`
   instructions not independently re-verified against this project's Hermes
   source), and the `CLAUDE.md` divergent Zone A enumerations.

## Status

Needs primary GPT review. Task 1 (the handoff placement, `5e2bc49`) is
complete and verified - diff-vs-HEAD clean and additive, all prior launcher
fixes preserved, assembled sizes recomputed to the handoff's exact
estimate, `daily-brief` frontmatter confirmed, margin flagged prominently
in three places. Task 2 (optimization audit) is complete as a report:
no Zone A defect found that meets the fix bar, and the highest-value
finding - that the always-loaded context file is ~790 chars from silent
truncation and `<how_this_package_is_organized>` is the block to trim -
needs the Claude Project chat to act on it before the next content
addition, as the handoff itself instructed. Repo integrity sound: working
tree clean after the two commits + this report, `HEAD` will be at this
report on `origin/main`, `.gitignore` correct, 15 skill sources present,
all 7 scripts syntax-clean.
