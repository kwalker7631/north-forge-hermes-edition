# Claude Code Session Audit

Timestamp: 2026-09-01, late session (work and commit ran past local midnight
into 2026-09-02; the handoff zip and all inline NEXT_STEPS markers use
2026-09-01, kept consistent here).
Requested task: Extract `north-forge-hermes-COMPLETE-fix.zip` into the repo
root. It replaces ALL of `skills-source/` (14 skill folders), plus
`.hermes.template.md`, `mode-blocks/full-menu.md`, `mode-blocks/sales-menu.md`.
Kenneth stated it "resolves every finding from the last audit" (Findings 1-5)
and asked, explicitly: read every skill's frontmatter directly and confirm
all 14 register correctly (hl, kb, esc, audit, log, train, draft, web,
assist, sales, menu, flush, switch, kyocera-research); recompute both
assembled sizes (expected ~19,101 FULL / ~19,096 SALES) and flag the sub-900
margin plainly; confirm zero unreplaced markers; update `NEXT_STEPS.md` to
say 14 skills not 10; then commit and push. Kenneth's own AppData flush +
fresh repull happens AFTER this commit, not before - so no live rebuild of
`.hermes/` or AppData was performed this session.

## Files inspected

- `audit/CLAUDE_CODE_LAST_AUDIT.md` - prior session's report (443 lines,
  timestamp "2026-09-01 (evening session)", status "Needs primary GPT
  review"). Recorded the `pending-tonight` handoff committed as-is
  (`1c66ab8`) per Kenneth's direction with Findings 1-5 left open. That
  report's "Required follow-up" list is exactly what this handoff claims to
  deliver.
- `.gitignore` (52 lines) - Session Start Protocol step 4. Unchanged,
  correct: `.env` L2, `.forge-mode` L10, `.agent-name` L11, `/.hermes/` L18,
  `.hermes.md` L19, root-anchored `/skills/` legacy guard L51. No fix
  required.
- `NEXT_STEPS.md` - full read (260 lines incl. the still-uncommitted
  2026-08-29 v21.8-drift append). Working tree vs HEAD diff at session start.
- `north-forge-hermes-COMPLETE-fix.zip` (`C:\Users\kwalk\Downloads\`, 42,187
  bytes, mtime 2026-09-01 23:52). Extracted to a scratch dir
  (`...\scratchpad\zipextract\`) first, inspected in full there, then placed
  into the repo. Archive contains exactly 17 files:
  - `.hermes.template.md`
  - `mode-blocks/full-menu.md`, `mode-blocks/sales-menu.md`
  - `skills-source/` - 14 `SKILL.md` files (6 shared, 8 tsc-only), listed
    below. No other files, no banners, no READMEs.
- Every one of the 14 zip `SKILL.md` files - full read of `flush`, `menu`,
  `switch`; frontmatter + first body lines + self-lock-line grep on all 14;
  full-file diff (CR-insensitive) of each against its repo counterpart.
- `.hermes.template.md` - full read of the repo copy (147 lines) and a
  line-level diff repo-vs-zip.
- `mode-blocks/full-menu.md`, `mode-blocks/sales-menu.md`,
  `mode-blocks/full-banner.md`, `mode-blocks/sales-banner.md` - all read.
- `launch-north-forge.sh` - full read, to reproduce the `.hermes.md`
  assembly (template + `{{MODE_BANNER_BLOCK}}` + `{{COMMAND_MENU_BLOCK}}` +
  `{{AGENT_NAME}}` -> `North Forge`, skills copied as separate files, NOT
  concatenated).
- Read-only git: `git pull` (already up to date), `git status`, `git diff`,
  `git diff --cached`, `git diff --cached --ignore-cr-at-eol`, `git log
  --all -- skills-source/shared/menu skills-source/shared/flush` (empty),
  `git ls-tree -r HEAD`, `git ls-files --eol`, `git cat-file blob`,
  `git show`, `git diff c6d6dee HEAD`.
- `hermes doctor` and `hermes skills list --source local` - hermes IS
  installed on this drive at
  `C:\Users\kwalk\AppData\Local\hermes\bin\hermes` (v0.21.0). Doctor: no
  security advisories, venv OK, API key configured, config v39, one
  pre-existing unrelated warning (SQLite 3.45.1 WAL-reset-bug advisory,
  not introduced by anything in this repo).
- PyYAML parse of all 14 frontmatter blocks via the hermes venv
  (`C:\Users\kwalk\AppData\Local\hermes\hermes-agent\.venv\Scripts\python.exe`).

## State of the working tree at session start

```
On branch main, up to date with origin/main (HEAD c6d6dee)
 M NEXT_STEPS.md
```

The only uncommitted change was the 2026-08-29 "Drift audit vs v21.8 OneDrive
source package" append (36 added lines), which the prior two audits recorded
as deliberately left uncommitted and flagged for a primary-GPT decision on
whether it should stay. See "Disposition of the v21.8-drift append" below.
No other file was modified, no skill folder was missing or extra beyond the
known 12.

## What the zip contains vs. what was on disk

ZIP `skills-source/` (14 folders):

```
shared/flush/SKILL.md              NEW  (1592 B in zip, CRLF)
shared/menu/SKILL.md               NEW  (1227 B in zip, CRLF)
shared/kyocera-research/SKILL.md   unchanged vs repo (CR-insensitive diff empty)
shared/switch/SKILL.md             unchanged vs repo (CR-insensitive diff empty)
shared/sales-assist/SKILL.md       +4 lines (frontmatter only)
shared/web-navigator/SKILL.md      +4 lines (frontmatter only)
tsc-only/assist-intake/SKILL.md    +4 lines (frontmatter only)
tsc-only/draft-writer/SKILL.md     +4 lines (frontmatter only)
tsc-only/escalation-packet/SKILL.md +4 lines (frontmatter only)
tsc-only/fault-logging/SKILL.md    +4 lines (frontmatter only)
tsc-only/forge-audit/SKILL.md      +4 lines (frontmatter only)
tsc-only/hotline-ticket/SKILL.md   +4 lines (frontmatter only)
tsc-only/kb-builder/SKILL.md       +4 lines (frontmatter only)
tsc-only/training-guide/SKILL.md   +4 lines (frontmatter only)
```

The "+4 lines (frontmatter only)" was verified by
`diff --strip-trailing-cr -u repo zip` on every file: in each case the ONLY
hunk is a leading `@@ -1,3 +1,7 @@` inserting

```
---
name: <cmd>
description: <one line>
---
```

above the existing `# <Name> Skill` heading. Zero changes to any body line
of any of the 10 files. `switch` and `kyocera-research` produced no diff at
all (they already carried frontmatter from `1c66ab8`).

ZIP doc files:

- `.hermes.template.md` - exactly one changed line (hunk `@@ -139,7 +139,7 @@`),
  `<hermes_specific_addendum>` item 3:
  - OLD: `3. MEMORY MUST RESPECT /FLUSH. Treat a /flush or /clear the same
    way for memory writes as for conversation: do not let specifics from
    before the flush leak into memory entries written after it, and do not
    let old memory entries surface facts into a new working issue package
    unless the technician restates them.`
  - NEW: `3. MEMORY MUST RESPECT /FLUSH AND /SWITCH. Treat either command
    the same way for memory writes as for conversation: do not let specifics
    from before the reset leak into memory entries written after it, and do
    not let old memory entries surface facts into a new working issue
    package unless the technician restates them. Never /clear or /reset for
    this - see flush_clear_rule.`
  No other line of the 147-line file differs (`git diff c6d6dee HEAD --
  .hermes.template.md` = one hunk, +1/-1).
- `mode-blocks/full-menu.md` - `diff --strip-trailing-cr` against the repo
  copy is EMPTY. Byte-identical (CR-insensitive) to the version committed at
  `1c66ab8`. Re-bundled, no change.
- `mode-blocks/sales-menu.md` - same, `diff` EMPTY. No change.

## STANDING RULE (2026-08-29) diff-vs-HEAD check

Ran for every incoming file against current HEAD (`c6d6dee`), not just
against the handoff's self-description. Result: CLEAN - no previously
recorded deliberate fix is removed, reverted, or contradicted.

Specific prior fixes checked and confirmed still present after placement:

1. **`forge-audit/SKILL.md` - no literal `CLAUDE.md` token** (the REAL
   `skills-guard` `agent_config_mod` fix, commit `a49580f`, after the
   `audit/`->`forge-audit/` rename was found not to have fixed it).
   - `grep -rn "CLAUDE\.md" <zip>/skills-source/` -> 0 hits.
   - `git cat-file blob HEAD:skills-source/tsc-only/forge-audit/SKILL.md |
     grep -c "CLAUDE\.md"` -> 0.
   - The zip's frontmatter is inserted ABOVE line 1; the trigger sentence
     that used to contain the token still reads "...unless a code-maintenance
     or agent-configuration file is specifically requested..." - the
     reworded form from `a49580f`, intact.
2. **`sales-assist/SKILL.md` self-lock line** ("Never rewrite this skill
   file on your own initiative. Flag it to the Blacksmith (Kenneth Walker
   Jr.)...", added `a49580f`). Diff shows frontmatter added above the body
   only; the self-lock line is untouched. Grep for the self-lock phrase
   passes on all 14 files.
3. **`.hermes.template.md` `<assistant_router_rule>` web-navigator entry**
   (L78, added `a49580f`). The template diff touches only L142; L78 is
   unchanged.
4. **`.hermes.template.md` `<flush_clear_rule>` /flush-vs-/switch split +
   "CRITICAL SAFETY CORRECTION (2026-08-29)"** (L107-121, placed `1c66ab8`).
   Unchanged - the L142 edit is the follow-through that the prior audit's
   "Required follow-up" list explicitly asked for ("Fix `.hermes.template.md`
   L142 ('/flush or /clear') to match the L114 ban"), not a reversion.
5. **`.hermes.template.md` forge-audit explanation relocation to "see
   NEXT_STEPS.md"** (L34, placed `1c66ab8`). Unchanged.
6. **`mode-blocks/*-menu.md` "NEVER /clear or /reset for either" lines**
   (placed `1c66ab8`). Menu files are byte-identical to HEAD, lines intact.
7. **`.gitignore` root-anchored `/skills/` guard**, **`provision-new-drive.ps1`
   STOP message**, **`toggle-mode.bat`/`.sh` RESET branch** - none of these
   files are in the handoff; untouched.

`git log --all --oneline -- skills-source/shared/menu skills-source/shared/flush`
is empty - the two new folders have no prior history to conflict with.

## Pre-flush verification results

### 1. All 14 skills' frontmatter - PASS

Read directly from every committed blob (`git show HEAD:<path>`, line 2) and
cross-checked with a PyYAML `safe_load` of each `---...---` block via the
hermes venv python. All 14 parsed with no error; every block is a mapping
with non-empty `name` and `description`.

```
skills-source/shared/flush/SKILL.md              name: flush
skills-source/shared/kyocera-research/SKILL.md   name: kyocera-research
skills-source/shared/menu/SKILL.md               name: menu
skills-source/shared/sales-assist/SKILL.md       name: sales
skills-source/shared/switch/SKILL.md             name: switch
skills-source/shared/web-navigator/SKILL.md      name: web
skills-source/tsc-only/assist-intake/SKILL.md    name: assist
skills-source/tsc-only/draft-writer/SKILL.md     name: draft
skills-source/tsc-only/escalation-packet/SKILL.md name: esc
skills-source/tsc-only/fault-logging/SKILL.md    name: log
skills-source/tsc-only/forge-audit/SKILL.md      name: audit
skills-source/tsc-only/hotline-ticket/SKILL.md   name: hl
skills-source/tsc-only/kb-builder/SKILL.md       name: kb
skills-source/tsc-only/training-guide/SKILL.md   name: train
```

- 14 distinct `name:` values, no duplicates
  (`{assist, audit, draft, esc, flush, hl, kb, kyocera-research, log, menu,
  sales, switch, train, web}`).
- Set equals the task's expected set EXACTLY: missing = none, extra = none.
- Every `name:` matches the skill's intended slash command; folder name and
  `name:` diverge on purpose for the 12 that use a short command
  (`hotline-ticket`->`hl`, `kb-builder`->`kb`, `escalation-packet`->`esc`,
  `forge-audit`->`audit`, `fault-logging`->`log`, `training-guide`->`train`,
  `draft-writer`->`draft`, `web-navigator`->`web`, `assist-intake`->`assist`,
  `sales-assist`->`sales`) and match for `menu`, `flush`, `switch`,
  `kyocera-research`.
- All 14 frontmatter blocks are well-formed: `---` line 1, `name:` line 2,
  `description:` line 3, `---` line 4, no BOM, no embedded `": "` in any
  `description:` value (would risk a nested-map parse), zero non-ASCII.
- All 14 carry the "Never rewrite this skill file on your own initiative"
  self-lock line.

NOT done this session (deferred per Kenneth): a live `hermes skills list
--source local` after rebuilding `.hermes/skills/` from the new 14-set. The
current live list still reflects the pre-handoff 12-set, registered by
FOLDER name (all 12 show `enabled`). Re-registration under the new `name:`
values will happen on Kenneth's post-commit fresh launch. The two skills
that already had frontmatter (`switch`, `kyocera-research`) currently list
under their `name:` value with no problem, which is direct evidence the
frontmatter format Hermes expects is the one used here.

### 2. Both assembled `.hermes.md` sizes - MATCH the task's targets

Reproduced the launcher's Python assembly from the COMMITTED HEAD blobs
(`.hermes.template.md` + `mode-blocks/<mode>-banner.md` +
`mode-blocks/<mode>-menu.md`, `{{AGENT_NAME}}` -> `North Forge`, no
`.agent-name` present):

```
mode    chars (LF)    bytes (LF)    bytes (CRLF, native Win launch)
FULL      19,101        19,101        19,271
SALES     19,096        19,096        19,258
```

- FULL 19,101 vs task's "~19,101" - exact.
- SALES 19,096 vs task's "~19,096" - exact.
- Delta from the prior handoff's assembled numbers (`1c66ab8`: 19,037 /
  19,032 per the last audit): +64 each, all of it the L142 line-length
  increase. Menus/banners unchanged, so nothing else moved.
- Skills are copied as separate files into `.hermes/skills/`, NOT
  concatenated into `.hermes.md`, so the 14-vs-12 skill count does not
  change the assembled size - only template + banner + menu do.

### 3. Zero unreplaced markers - PASS

Post-assembly scan for `{{MODE_BANNER_BLOCK}}`, `{{COMMAND_MENU_BLOCK}}`,
`{{AGENT_NAME}}`, and a bare `{{` in both modes: NONE found. Non-ASCII char
count in both assembled outputs: 0.

### 4. Margin to the 20,000-char ceiling - FLAGGED, as requested

```
mode    margin (LF)    margin (CRLF, native Windows launch)
FULL       899               729
SALES      904               742
```

Plainly: headroom is now about 900 characters on a Linux/Mac LF assembly
and about 730-740 bytes on a native Windows launch (the `.bat`/`.sh` Python
writes CRLF - carry-over flag (a)). This is tight. There is no automated
guard on the assembled size anywhere in the launcher or the repo. Any
further growth of `.hermes.template.md`, either `*-banner.md`, or either
`*-menu.md` needs to be budgeted against this ceiling before it is written.
The template's own line 32 still asserts it "stays under Hermes's
context-file size limit on purpose" - that is still true, but the phrase now
has very little slack behind it.

### 5. git log / status clean - CLEAN

After the commit, `git status` = "nothing to commit, working tree clean".
`git push` succeeded; `origin/main` == local `main` == `1fd6c1e`.
HEAD before session: `c6d6dee`. `git pull` at start: already up to date.
Commit chain this session: `c6d6dee` -> `1fd6c1e` (handoff placement) ->
(this audit commit, hash in the chat response).

### 6. Line endings of the committed blobs - LF, correct

`git ls-files --eol` reports `i/lf w/lf` for every placed file.
`git cat-file blob HEAD:<path> | tr -cd '\r' | wc -c` = 0 for the sampled
files (`.hermes.template.md`, `flush`, `menu`, `forge-audit`, `kb-builder`,
`full-menu.md`). The zip's files are CRLF on disk; `git add` under this
drive's `core.autocrlf=true` normalized them to LF in the blob (the
"LF will be replaced by CRLF the next time Git touches it" warnings on
`git add` are that normalization, expected, on record as carry-over flag
(a)). Note: `git show HEAD:<path>` on this Git-for-Windows build re-applies
the working-tree eol filter to its stdout and shows CR bytes - that is a
display artifact of `git show`, NOT the blob; `git cat-file blob` is the
authoritative raw view and shows pure LF.

## Zone A changes made

None. `.gitignore` inspected (Session Start Protocol step 4), found correct,
not modified. The only files this session writes are (a) the Zone B/Zone C
handoff placement, under the placement exception, and (b) this audit report.

## Zone B findings (not fixed - reported only)

None outstanding from this handoff. All five findings the prior audit left
open are resolved by the placed content:

- **Prior Finding 1** (`menu` and `flush` skill folders referenced by the
  template, both menu blocks, and `switch/SKILL.md` but absent from the
  repo) - RESOLVED. Both folders now exist with well-formed skills.
  `switch/SKILL.md`'s three outbound references
  (`skills-source/shared/flush` x2, "the menu skill" x1) now resolve.
  `.hermes.template.md` L34 ("menu (registers /menu...)", "flush (registers
  /flush...)") and L110 ("/flush (read .hermes/skills/flush in full when
  triggered)") now point at real files.
- **Prior Finding 2** (the template's "each skill registers its slash
  command via `name:` frontmatter" claim was true for only 2 of 12) -
  RESOLVED. True for all 14 now. Verified by direct blob read + PyYAML
  parse.
- **Prior Finding 3** ("14 skills" unreachable from the `pending-tonight`
  handoff, which topped out at 12) - RESOLVED. 14 folders, 14 `SKILL.md`,
  14 unique `name:` values matching the task's list.
- **Prior Finding 4** (`.hermes.template.md` contradicted itself: L114
  `flush_clear_rule` banned `/clear`, L142 addendum item 3 treated `/clear`
  as a normal sibling of `/flush`) - RESOLVED. L142 now says "MEMORY MUST
  RESPECT /FLUSH AND /SWITCH ... Never /clear or /reset for this - see
  flush_clear_rule". Consistent with L114 and with L34.
- **Prior Finding 5** (`sales-assist/SKILL.md` had no self-lock line, no
  frontmatter) - RESOLVED. Self-lock line was already added in `a49580f`;
  this handoff adds `name: sales` / `description:` frontmatter above it.
  The file still opens (after the frontmatter) with "# Sales Assist Skill
  (PLACEHOLDER - NOT YET AUTHORED)" and its FAQ body is still an
  intentional placeholder pending real spec-sheet curation - that is a
  known, tracked non-issue, not a regression.

Minor pre-existing observation, NOT introduced or changed by this handoff
and NOT a finding against it: `skills-source/shared/switch/SKILL.md` line 9
refers to "the original (non-Hermes) North Forge v21.9" while the template
header says v21.8. That file is byte-identical to what was committed at
`1c66ab8`; the version-number wording is a Blacksmith/Claude-Project-chat
content question, unchanged this session.

## Disposition of the v21.8-drift append (NEXT_STEPS.md)

The 2026-08-29 "Drift audit vs v21.8 OneDrive source package - PASS WITH
EXCEPTIONS" append (36 lines) had sat uncommitted across the last two
sessions, flagged for a primary-GPT decision. It is `NEXT_STEPS.md` content
(Zone C), it records real findings from the 2026-08-29 drift-audit session,
and leaving it as a floating working-tree diff across Kenneth's imminent
AppData flush + fresh repull risked losing it. This session committed it as
part of `NEXT_STEPS.md` (Zone C, freely committable) so the working tree is
clean before the flush. Its four open sub-items (CONTACT_BLOCK header
v21.5/v21.8; kb-builder PRIMARY SOURCE FORMAT block; kb-builder "do not ask
to select research/Mermaid" line; firmware-box placeholder wording) are
unchanged and still await Blacksmith sign-off - committing the text does not
resolve them, it just stops the record from floating.

## Zone C changes made (NEXT_STEPS.md)

1. "## Done": added bullets for `skills-source/shared/flush/SKILL.md` and
   `skills-source/shared/menu/SKILL.md` (placed 2026-09-01, byte-for-byte,
   not composed by Claude Code); added a "YAML frontmatter pass" bullet
   listing all 14 registered commands.
2. "## Done" mode-toggle line: annotated "FULL assembles all 10 skills,
   SALES ... 2 shared" with "[now **14** skills FULL / **6** shared SALES as
   of 2026-09-01 - see section at bottom]". The 2026-08-28 dated wording
   itself is left intact as a historical record.
3. "## Not yet built": added a 2026-09-01 note that the shared set grew 2 ->
   6 and the total is now 14 (8 tsc-only + 6 shared), `sales-assist` FAQ
   content still the only unbuilt item.
4. "## QA session (2026-08-28)" FULL/SALES assembly bullets: added bracketed
   2026-09-01 updates (14 skills / 19,101 chars; 6 shared / 19,096).
5. New section "## 14-skill completion + frontmatter pass (2026-09-01) -
   COMPLETE-fix handoff placed": full breakdown of what changed, the
   STANDING RULE result, assembled sizes, and an explicit MARGIN WARNING
   about the ~900-char headroom.
6. (Carried in the same commit) the previously-deferred v21.8-drift append,
   as described above.

No Zone C edit describes or implies a Zone B content change that did not
actually happen this session - the 14-skill placement and the L142 template
edit are both really in commit `1fd6c1e`.

## Commits made this session

- `1fd6c1e` - "Place COMPLETE-fix handoff: 14 skills + name: frontmatter on
  all of them". 14 files changed, +167/-2.
  - `.hermes.template.md` (+1/-1, the L142 Finding-4 fix)
  - `skills-source/shared/flush/SKILL.md` (new, 17 lines)
  - `skills-source/shared/menu/SKILL.md` (new, 15 lines)
  - `skills-source/shared/sales-assist/SKILL.md` (+4, frontmatter)
  - `skills-source/shared/web-navigator/SKILL.md` (+4, frontmatter)
  - `skills-source/tsc-only/{assist-intake,draft-writer,escalation-packet,
    fault-logging,forge-audit,hotline-ticket,kb-builder,training-guide}/SKILL.md`
    (+4 each, frontmatter)
  - `NEXT_STEPS.md` (+95/-1: 14-skill updates, new 2026-09-01 section, plus
    the previously-deferred v21.8-drift append)
  - `skills-source/shared/switch/SKILL.md` and
    `skills-source/shared/kyocera-research/SKILL.md` are NOT in the commit -
    git saw the incoming copies as byte-identical to HEAD.
  Placed under the Zone B placement exception (in-session named handoff from
  Kenneth, content originating from the Claude Project chat, with an
  instruction to commit). Pushed to `origin/main`.
- (this audit report) - `audit/CLAUDE_CODE_LAST_AUDIT.md`, Zone A
  operational record, committed and pushed as normal Zone A operation. Hash
  in the chat response.

## Uncertain / flagged for primary GPT review

1. **Live registration not yet observed.** All 14 `name:` values are
   verified structurally correct and PyYAML-parseable, and the two
   pre-existing frontmatter skills already register fine under their
   `name:`, so there is strong indirect evidence the other 12 will too - but
   `hermes skills list --source local` against a rebuilt 14-set has NOT been
   run this session (deferred per Kenneth's "commit before the flush"
   instruction). Kenneth's post-commit fresh launch is the real test. If any
   of the 12 newly-frontmattered skills fails to appear in that list, the
   most likely causes to check first are (a) a `name:` value colliding with
   a Hermes reserved word, and (b) the `skills-guard` scanner flagging a
   body - a full `grep -rn "CLAUDE\.md\|AGENTS\.md\|\.cursorrules\|\.clinerules"
   skills-source/` this session returned 0 hits, so (b) looks clear.
2. **Assembled-size margin (~900 chars / ~730 bytes CRLF).** Recorded in
   NEXT_STEPS.md with a MARGIN WARNING. Flagging here too because it is a
   real constraint on the next content revision and there is no automated
   check. If the primary GPT plans any further template/menu/banner growth,
   it needs a size budget, or the 20,000 ceiling needs to be re-confirmed as
   the actual Hermes limit (it is treated as such in this repo's docs but I
   did not re-verify it against Hermes source this session).
3. **`switch/SKILL.md` "v21.9" vs template "v21.8".** Pre-existing, not
   touched by this handoff. Content question for the Claude Project chat -
   is the `switch` skill's reference to porting from "North Forge v21.9"
   correct, or should it say v21.8 to match the template header?
4. **v21.8-drift append now committed** (see its own section above). If the
   primary GPT wants that text shaped differently or moved to a durable
   location other than `NEXT_STEPS.md`, it is Zone C and freely editable -
   this session committed it only to clear the working tree before the
   flush, not to finalize its wording.
5. **Three carry-over flags from prior audits, unchanged:**
   (a) `.bat` vs `.sh` `.hermes.md` CRLF byte divergence on
   `core.autocrlf=true` machines - still live, and now more pointed since
   the CRLF assembled size (19,271 FULL) eats into the 20,000 ceiling
   harder than the LF figure the docs quote;
   (b) `launch-north-forge.bat` never exercised end-to-end;
   (c) no live model session has been run against the current
   `.hermes.template.md` - now includes the flush/switch split, the 14-skill
   set, and the L142 memory rule, none of which have faced a running model.

## Status

Needs primary GPT review. Handoff placed and committed clean (`1fd6c1e`,
pushed). All five prior-audit findings resolved and verified. Working tree
clean. The one substantive item for Kenneth's next action is the fresh
launch + `hermes skills list` to confirm all 14 register live; the one
substantive item for the primary GPT is the ~900-char assembled-size margin
before any further content is added.
