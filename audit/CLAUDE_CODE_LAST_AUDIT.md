# Claude Code Session Audit

Timestamp: 2026-09-01 (evening session)
Requested task: Extract `north-forge-hermes-pending-tonight.zip` into the repo
root, overwriting `.hermes.template.md`, `mode-blocks/full-menu.md`,
`mode-blocks/sales-menu.md` and adding `skills-source/shared/switch/` and
`skills-source/shared/kyocera-research/`. Kenneth described it as "everything
from tonight's session in one consolidated handoff - verify each piece,
commit, push," then run the full pre-flush verification (all 14 skills'
frontmatter, both assembled sizes, `flush_clear_rule` correctness, git
log/status clean).

OUTCOME: Files extracted and byte-verified onto disk (they already matched
the working tree). NOT committed / NOT pushed. The handoff is internally
inconsistent and incomplete against its own content and against Kenneth's
stated expectation of 14 skills - details below. Held for Blacksmith / Claude
Project chat decision. Only this audit file is committed this session.

## Files inspected

- `audit/CLAUDE_CODE_LAST_AUDIT.md` - prior session's record (111 lines,
  timestamp 2026-08-29, "session-start check only", status Clean). Note: its
  prose refers to the repo being "at 095a111" but HEAD is now `75cfa19`
  ("Audit: session-start check only, no task given"), whose sole change was
  replacing that audit file (172 lines changed, +82/-90). The 2026-08-29
  audit file content and the 75cfa19 commit that carries it are one and the
  same session; the "095a111" in the prose is a stale internal reference.
- `.gitignore` (52 lines) - Session Start Protocol step 4. Correct.
- `north-forge-hermes-pending-tonight.zip` (`C:\Users\kwalk\Downloads\`) -
  extracted to a scratch dir first, then into the repo. Archive contains
  exactly 5 files, no more:
  - `.hermes.template.md`
  - `mode-blocks/full-menu.md`
  - `mode-blocks/sales-menu.md`
  - `skills-source/shared/switch/SKILL.md`
  - `skills-source/shared/kyocera-research/SKILL.md`
- `.hermes.template.md` - full read, working tree (147 lines, 17424 bytes)
  and HEAD blob (16731 bytes).
- `mode-blocks/full-menu.md` (1449 B WT / 1317 B HEAD),
  `mode-blocks/sales-menu.md` (838 B WT / 705 B HEAD),
  `mode-blocks/full-banner.md` (214 B), `mode-blocks/sales-banner.md`
  (822 B) - all read.
- `skills-source/shared/switch/SKILL.md` (2361 B, new) - full read.
- `skills-source/shared/kyocera-research/SKILL.md` (3809 B, new) - full read.
- Every `SKILL.md` under `skills-source/` (12 files total) - frontmatter and
  first line inspected.
- `NEXT_STEPS.md` - working tree vs HEAD diff, plus targeted content reads
  (skill inventory, forge-audit rename explanation, QA session notes).
- `launch-north-forge.sh` - full read, to reproduce the assembly step.
- `.hermes.md` (18373 B, on-disk build artifact, git-ignored) - header +
  `flush_clear_rule` region only; confirmed stale (pre-handoff content).
- Read-only git: `git pull` (already up to date), `git status`, `git diff`,
  `git diff HEAD`, `git diff --ignore-cr-at-eol`, `git log`, `git show`,
  `git check-ignore`, `git ls-files`.
- `command -v hermes` - not installed on this drive (unchanged from every
  prior audit).

## State of the working tree at session start

`git status` already showed the five target paths modified/untracked before
this session touched anything:

```
 M .hermes.template.md
 M NEXT_STEPS.md
 M mode-blocks/full-menu.md
 M mode-blocks/sales-menu.md
?? skills-source/shared/kyocera-research/
?? skills-source/shared/switch/
```

The three tracked files on disk were already byte-for-byte identical to the
zip's copies (verified with `cmp -s` against a separate extraction, and again
after re-extracting into the repo). So "tonight's session" had already
written these to the working tree in an earlier, uncommitted pass; the zip is
the same content re-bundled. Re-extraction changed nothing.

`NEXT_STEPS.md` also carries an **unrelated** uncommitted change (a 33-line
append, "Drift audit vs v21.8 OneDrive source package (2026-08-29) - PASS
WITH EXCEPTIONS") that is not part of tonight's switch/kyocera handoff and
was not authored this session. It references "Full findings in
`audit/CLAUDE_CODE_LAST_AUDIT.md`" and "all four findings" - but the
currently committed audit file (75cfa19) contains no such findings, so that
append points at an audit report that was overwritten. Left untouched and
uncommitted this session; flagged below.

## File integrity of the 5 handoff files (all pass)

- Line endings: pure LF, zero CR bytes in all 5 (perl `/\r/` count = 0;
  `cat -A` shows `$` line-ends, no `^M`; `od -c` on line 1 of the template
  shows `] \n`). The `git` "LF will be replaced by CRLF the next time Git
  touches it" warning is the pre-existing `core.autocrlf=true` on this
  Windows drive (already on record as carry-over flag (a)); it does not
  affect committed blobs and `git diff --ignore-cr-at-eol` is identical to
  plain `git diff` (16 changed lines both ways for the template).
- No BOM (`.hermes.template.md` first 3 bytes `5b 53 59` = `[SY`; the two new
  SKILL.md files first 3 bytes `2d 2d 2d` = `---`).
- `git diff HEAD` for the 3 tracked files is small and content-only:
  `.hermes.template.md` +10/-4, `mode-blocks/full-menu.md` +16/-13,
  `mode-blocks/sales-menu.md` +5/-4. No unintended collateral edits.
- sha256 (on disk, this session):
  - `.hermes.template.md` `6271a577a59eb3ffaa2663c9f5be108287403994f136967b5facef55df780b04`
  - `mode-blocks/full-menu.md` `c599171cbef6ccf7e8abdc737c6d9038b844ad96e0dc30246d61132b19d9f961`
  - `mode-blocks/sales-menu.md` `7a83e9ab56d015e552162f4ff2f800a27c729f6b60edcb6a2b4cb9deb0099d92`
  - `skills-source/shared/switch/SKILL.md` `4848a56962aee5a577ddaf25ca93e7fe4ef2417ff3225f1131ed68a911fe1c57`
  - `skills-source/shared/kyocera-research/SKILL.md` `d71b3468a9e373a6509692c1f5f39fbf5fd1404674c2722e9c5c22dd8b10d30d`

## STANDING RULE diff-vs-HEAD check (2026-08-29 rule)

Diffed each incoming tracked file against current HEAD, not just against the
handoff's self-description.

- **`.hermes.template.md` - `how_this_package_is_organized` paragraph.**
  HEAD carries a long inline "CORRECTION (2026-08-29)" about the `forge-audit`
  list-drop (real cause = the literal string `CLAUDE.md` in a skill tripping
  Hermes's `skills-guard-v1` scanner, not a reserved-name collision). The
  handoff removes that inline paragraph and replaces it with "The /audit
  skill's folder is named forge-audit for historical reasons (see
  NEXT_STEPS.md for why)." This is NOT a lost fix: the full explanation
  already lives in `NEXT_STEPS.md` (working tree lines ~36-58 and ~171-184,
  the "QA FINDING 1" correction and the verification notes), which the new
  template text now points to. Cross-reference is satisfied. Recorded here
  per the STANDING RULE so the primary GPT can confirm the relocation was
  intentional.
- **`.hermes.template.md` - `flush_clear_rule` block.** HEAD said "/flush and
  /clear are the same command." The handoff replaces that with the
  /flush-vs-/switch split plus a "CRITICAL SAFETY CORRECTION (2026-08-29)"
  that `/clear` and `/reset` are destructive native Hermes commands a
  technician must never be told to type. This CONTRADICTS the old HEAD text
  by design - it is the safety correction, and it is consistent with the
  "NEVER /clear or /reset" line the handoff also adds to both menu blocks and
  with the security-hardening direction already recorded in NEXT_STEPS.md. Not
  a reverted fix - a deliberate supersede. See Zone B finding 4 for the spot
  the handoff missed while making this change.
- **`mode-blocks/full-menu.md` / `sales-menu.md`.** Full rewrite of the
  command list into "one real slash form + plain-word alternates" style, adds
  a `/switch` line, points `/menu` at `.hermes/skills/menu`. No prior audit
  recorded a deliberate fix in these two files that the rewrite reverts. See
  Zone B findings 1-3.

No previously-recorded deliberate fix is silently reverted by this handoff.

## Pre-flush verification results (as requested)

### 1. "All 14 skills' frontmatter" - FAILS

Only **12** skill folders exist under `skills-source/` after this handoff,
and only **2** of the 12 carry YAML frontmatter:

```
YAML-FM  skills-source/shared/kyocera-research/SKILL.md   name: kyocera-research
YAML-FM  skills-source/shared/switch/SKILL.md             name: switch
NO-FM    skills-source/shared/sales-assist/SKILL.md       (# Sales Assist Skill (PLACEHOLDER...))
NO-FM    skills-source/shared/web-navigator/SKILL.md      (# Web Navigator Skill)
NO-FM    skills-source/tsc-only/assist-intake/SKILL.md    (# Assist Intake Skill)
NO-FM    skills-source/tsc-only/draft-writer/SKILL.md     (# Draft Writer Skill)
NO-FM    skills-source/tsc-only/escalation-packet/SKILL.md
NO-FM    skills-source/tsc-only/fault-logging/SKILL.md
NO-FM    skills-source/tsc-only/forge-audit/SKILL.md      (# Audit Skill)
NO-FM    skills-source/tsc-only/hotline-ticket/SKILL.md   (# Hotline Ticket Skill)
NO-FM    skills-source/tsc-only/kb-builder/SKILL.md       (# KB Builder Skill)
NO-FM    skills-source/tsc-only/training-guide/SKILL.md   (# Training Guide Skill)
```

Both new-skill frontmatter blocks are well-formed: `---` on line 1, `name:`
line 2, `description:` line 3, `---` line 4, `name:` value matches the folder
name in both cases.

- `switch`: `name: switch`, `description: Hard reset the working issue package
  AND reset to default mode, then show the command menu`
- `kyocera-research`: `name: kyocera-research`, `description: Targeted
  research pass over public Kyocera resources - firmware notes, known issues,
  forums - logging only genuinely new findings`

Why this fails the "14" bar and why it matters - see Zone B findings 1 and 2.

### 2. Both assembled `.hermes.md` sizes

Reproduced the launcher's Python assembly (`{{MODE_BANNER_BLOCK}}` ->
`mode-blocks/<mode>-banner.md`, `{{COMMAND_MENU_BLOCK}}` ->
`mode-blocks/<mode>-menu.md`, `{{AGENT_NAME}}` -> `North Forge` because no
`.agent-name` file is present). `.forge-mode` on this drive = `full`.

```
mode    HEAD assembled    HANDOFF assembled    delta
full        18212 B           19037 B          +825 B     (171 lines)
sales       18206 B           19032 B          +826 B     (163 lines)
```

All three placeholder tokens resolve to zero leftovers in both modes. No
size-limit concern (well under any Hermes context-file cap; template itself
notes it "stays under Hermes's context-file size limit on purpose" and the
delta is small).

Note: skills are copied as separate files into `.hermes/skills/`; they are
NOT concatenated into `.hermes.md`, so the assembled size reflects template +
banner + menu only.

### 3. `flush_clear_rule` correctness - MOSTLY CORRECT, one internal contradiction

The new `<flush_clear_rule>` block (WT lines 107-121) is internally coherent
with `switch/SKILL.md` and with both rewritten menu blocks:

- /flush = soft (reset issue package, stay in mode); /switch = hard (reset
  package + reset to default mode + show menu). Matches `switch/SKILL.md`
  sections "What to do when this triggers" and "The two-command pair".
- "CRITICAL SAFETY CORRECTION (2026-08-29): neither of these is '/clear' or
  '/reset'... Never tell a technician to type '/clear' or '/reset'." Matches
  the "NEVER /clear or /reset for either" line added to `full-menu.md` and
  `sales-menu.md`.
- Anti-leak "HARD RESET, NOT A SOFT SUMMARY" clause retained; memory-write
  coverage retained; "There is no /initialize command" retained.

Defect: see Zone B finding 4 - `<hermes_specific_addendum>` item 3 (WT line
142) still reads "MEMORY MUST RESPECT /FLUSH. Treat a /flush or /clear the
same way..." The handoff updated the `flush_clear_rule` block to ban `/clear`
but left this second reference in the same file untouched, so the file now
contradicts itself on whether `/clear` is a thing North Forge acknowledges.

### 4. git log / status clean - NOT CLEAN (expected, mid-handoff)

Working tree at session end:

```
 M .hermes.template.md
 M NEXT_STEPS.md
 M mode-blocks/full-menu.md
 M mode-blocks/sales-menu.md
?? skills-source/shared/kyocera-research/
?? skills-source/shared/switch/
(+ audit/CLAUDE_CODE_LAST_AUDIT.md staged/committed by this session)
```

HEAD before this session: `75cfa19`. `git pull` = already up to date,
`origin/main` = local `main`.

## Zone A changes made

None. `.gitignore` inspected under Session Start Protocol step 4 and found
correct (all four required entries present: `.env` L2, `.forge-mode` L10,
`/.hermes/` L18, `.hermes.md` L19; plus `.agent-name` L11 and the
root-anchored `/skills/` legacy guard L51, both consistent with prior
audits). No fix required. The only file this session writes is this audit
report (Zone A operational record).

## Zone B findings (not fixed - reported only)

### Finding 1 - `menu` and `flush` skill folders are referenced everywhere but do not exist

`skills-source/shared/menu/` and `skills-source/shared/flush/` are not in the
handoff zip, not in the working tree, and never appeared in git history
(`git log --all -- 'skills-source/shared/menu/*' 'skills-source/shared/flush/*'`
is empty). Yet tonight's content references them as built, registered skills:

- `.hermes.template.md` L34: "skills-source/shared/ holds ... **menu**
  (registers /menu as a real command), **flush** (registers /flush as a real
  command), switch (...), and kyocera-research (...)".
- `.hermes.template.md` L110: "/flush (**read .hermes/skills/flush in full
  when triggered**)".
- `mode-blocks/full-menu.md` L4 and `mode-blocks/sales-menu.md` L2: "/menu -
  command menu (**.hermes/skills/menu**)".
- `skills-source/shared/switch/SKILL.md` references
  "**skills-source/shared/flush**" three times (lines 9, 21) and "the menu
  skill" once (line 17).

Impact if committed and a FULL drive is launched: the assembled `.hermes.md`
instructs the model to "read .hermes/skills/flush in full" and cites
`.hermes/skills/menu`, but the launcher's `cp -r skills-source/shared/.`
step will not create either folder, so both citations dangle. `<hermes_
specific_addendum>` item 5 ("IF A SKILL FILE IS MISSING OR EMPTY... say so
plainly and fall back") would be the only thing catching it at runtime.

### Finding 2 - the "every skill registers its slash command via `name:` frontmatter" claim is true for only 2 of 12 skills

`.hermes.template.md` L34 now asserts: "Each skill's SKILL.md declares its
own slash-command name via YAML frontmatter (name: field) - this is what
makes Hermes register e.g. **/hl or /kb** as real commands instead of falling
back to the literal folder name, **which is what silently broke every slash
command before this was added**."

But `hotline-ticket/SKILL.md` (`/hl`), `kb-builder/SKILL.md` (`/kb`),
`forge-audit/SKILL.md` (`/audit`), `escalation-packet/SKILL.md` (`/esc`),
`fault-logging/SKILL.md` (`/log`), `assist-intake/SKILL.md` (`/assist`),
`draft-writer/SKILL.md` (`/draft`), `training-guide/SKILL.md` (`/train`),
`web-navigator/SKILL.md` (`/web`), and `sales-assist/SKILL.md` (`/sales`)
have **no frontmatter at all** - they still open with a `#` heading. Their
folder names do not match their documented slash commands (folder
`hotline-ticket` vs command `/hl`, folder `kb-builder` vs `/kb`, folder
`forge-audit` vs `/audit`, etc.). So by the template's own stated mechanism,
the handoff documents a fix ("added" `name:` frontmatter that "makes Hermes
register /hl or /kb") that has only been applied to the two brand-new shared
skills. If the mechanism description is accurate, /hl /kb /audit /esc /log
/assist /draft /train /web /sales would all still be "silently broke" after
this handoff.

Either the other 10 SKILL.md files were meant to gain `name:` (and
`description:`) frontmatter in this same handoff and were left out, or the
template paragraph is describing a target state that is not yet real. Cannot
tell from the zip which. NEXT_STEPS.md has no "add frontmatter to skills"
work item, and its skill inventory still says "all 10 skills" / "the other 9
skill files" (working-tree lines 16, 29, ~122).

### Finding 3 - "14 skills" is not reachable from this handoff

Prior baseline, per NEXT_STEPS.md repeatedly ("FULL assembles all 10
skills", "All 8 tsc-only skills + both shared skills", "the other 9 skill
files all do"): **10 skills** (8 tsc-only + sales-assist + web-navigator).
This handoff adds `switch` and `kyocera-research` -> **12**. Kenneth's task
text expects **14** to verify. The gap is exactly `menu` + `flush` from
Finding 1. The handoff as delivered cannot satisfy its own verification
target.

### Finding 4 - `.hermes.template.md` now contradicts itself on `/clear`

`<flush_clear_rule>` L114 (new): "Never tell a technician to type '/clear' or
'/reset'... if asked, correct them plainly."
`<hermes_specific_addendum>` item 3, L142 (unchanged from HEAD L136):
"MEMORY MUST RESPECT /FLUSH. Treat a /flush or /clear the same way for memory
writes as for conversation..."
The second reference treats `/clear` as a normal sibling of `/flush`, which
the first reference now explicitly forbids. The handoff edited the block 30
lines above but not this line. Small, but it is a genuine inconsistency
introduced by an incomplete edit within a single locked file.

### Finding 5 - `sales-assist/SKILL.md` still has no self-lock line and no frontmatter

Pre-existing (already on NEXT_STEPS.md's flagged list, working-tree
lines ~121-122): `sales-assist/SKILL.md` opens "# Sales Assist Skill
(PLACEHOLDER - NOT YET AUTHORED)" and lacks the "Never rewrite this skill
file on your own initiative" line every other skill carries. This handoff
does not touch it. Noted for completeness since a frontmatter pass (Finding
2) would be the natural time to fix it.

### Not a finding - the two new skill files themselves

`switch/SKILL.md` and `kyocera-research/SKILL.md` are internally well-formed:
correct frontmatter, folder name matches `name:`, both carry the "Never
rewrite this skill file on your own initiative. Flag it to the Blacksmith
(Kenneth Walker Jr.)" self-lock line, both use the project's `field_claim_
rule` vocabulary, `kyocera-research` includes a concrete `/cron add` setup
line and a dedup-against-log-file discipline. Their only problem is the
outbound reference to the missing `flush` skill (Finding 1). If `menu` +
`flush` are added and the frontmatter pass is done, these two look ready.

## Why nothing was committed

CLAUDE.md Zone B: "if something there looks wrong, describe why in the report
and stop. Flag it back to the Blacksmith or to the Claude Project chat where
this content is authored." The placement exception authorises placing and
committing a specific pre-approved file, but Kenneth's own instruction was
"verify each piece" - and verification shows the pieces do not cohere: two
referenced skills are absent (Finding 1), the frontmatter mechanism the
template now describes is 2/12 done (Finding 2), the stated "14 skills" bar
is unreachable (Finding 3), and the template contradicts itself on `/clear`
(Finding 4). Committing would publish, to `main`, documentation describing
skills and a registration mechanism that are not present, on a demo-prep
branch.

The 5 files ARE placed on disk (byte-verified, LF, no BOM, clean content-only
diff) so no work is lost and a follow-up bundle can be diffed against them.
Awaiting a decision: (a) hold the whole handoff until `menu` + `flush` skill
folders and the 10 missing frontmatter blocks are supplied, then commit the
complete set; (b) commit `switch` + `kyocera-research` skill folders only
(complete and correct on their own, apart from `switch`'s reference to the
absent `flush`), hold the 3 doc files; (c) Blacksmith directs commit as-is
with the gaps recorded.

## Commits made this session

- `audit/CLAUDE_CODE_LAST_AUDIT.md` - this report (Zone A operational record),
  committed and pushed per standing authorization. Hash in the session-ending
  chat response.

No other commit. The 5 handoff files remain uncommitted in the working tree,
as does the unrelated `NEXT_STEPS.md` v21.8-drift append.

## Uncertain / flagged for primary GPT review

1. **Is the zip simply missing files?** Kenneth's "14 skills" expectation
   plus the template/menu/switch references to `menu` and `flush` strongly
   suggest `skills-source/shared/menu/SKILL.md` and
   `skills-source/shared/flush/SKILL.md` were meant to be in tonight's bundle
   (and possibly `name:` frontmatter added to the other 10 skills). If the
   Claude Project chat authored those tonight, the bundle needs rebuilding to
   include them. If it did not, the 3 doc files overshot and should be
   revised down to current reality (12 skills, folder-name registration, no
   `menu`/`flush` skill). Claude Code cannot compose either the missing skill
   files or the frontmatter - Zone B.
2. **`forge-audit` explanation relocation.** The handoff moves the
   `skills-guard-v1` / literal-`CLAUDE.md` correction out of the template and
   into a "see NEXT_STEPS.md" pointer. NEXT_STEPS.md does currently carry the
   full explanation, so the pointer resolves - but confirm this relocation
   was intended and that NEXT_STEPS.md is considered a durable enough home
   for it (NEXT_STEPS.md is Zone C, which Claude Code may rewrite freely).
3. **Unrelated uncommitted `NEXT_STEPS.md` append** ("Drift audit vs v21.8
   OneDrive source package (2026-08-29) - PASS WITH EXCEPTIONS", 33 lines).
   Not from this session, not part of tonight's handoff. It says "Full
   findings in `audit/CLAUDE_CODE_LAST_AUDIT.md`" but the audit file that
   held those findings was overwritten by commit `75cfa19`. This session did
   not commit or revert it. Decide whether that append should stay (its four
   listed open items - CONTACT_BLOCK header v21.5/v21.8, kb-builder PRIMARY
   SOURCE FORMAT block, kb-builder "do not ask to select research/Mermaid"
   line, firmware-box placeholder wording - may still be live), and whether
   the v21.8 drift findings need to be re-captured somewhere durable.
4. **Three carry-over flags from prior audits** remain open and unchanged:
   (a) `.bat` vs `.sh` `.hermes.md` CRLF divergence on `core.autocrlf=true`
   machines - directly relevant now that `.hermes.template.md` changed;
   (b) `launch-north-forge.bat` never exercised end-to-end;
   (c) no live model session has been run against the current
   `.hermes.template.md` (blocked on an Anthropic key on this drive). Flag
   (c) is now more pointed: the flush/switch split and the missing skill
   references have never been exercised against a running model.

## Status

Needs primary GPT review. Handoff extracted and byte-verified onto disk but
NOT committed - it is internally inconsistent (Findings 1-4) and cannot meet
its own "14 skills" verification target. Repo HEAD unchanged at `75cfa19`
plus this audit commit. Working tree holds the 5 handoff files and one
unrelated `NEXT_STEPS.md` append, all uncommitted. Recommended next step:
Claude Project chat supplies `menu` + `flush` skill folders and `name:`/
`description:` frontmatter for the other 10 skills (or revises the 3 doc
files down to current reality), then a clean single commit of the complete
set.
