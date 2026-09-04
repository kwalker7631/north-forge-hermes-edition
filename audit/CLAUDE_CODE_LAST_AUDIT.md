# Claude Code Session Audit

Timestamp: 2026-09-03, night EDT. Session-start HEAD `6162663`.
One task this session, from Kenneth in-session: a named Zone B handoff.
Commits made: the placement commit (below) and this report.

Requested task:
Extract `north-forge-budget-trim.zip` into the repo root, overwriting five
files: `.hermes.template.md`, `mode-blocks/full-menu.md`,
`mode-blocks/sales-menu.md`, `launch-north-forge.bat`,
`launch-north-forge.sh`. This is the content-budget consolidation the
2026-09-03 audit (`6162663`) identified (Task 2(a) items 1-5, Task 2(c)
item 1) and correctly deferred to the Claude Project chat to author.
Five stated changes (verbatim from Kenneth):
1. `<how_this_package_is_organized>` trimmed - remove historical narrative
   (the "silently broke every slash command" story, the forge-audit
   naming-history framing) that isn't operationally necessary, while
   VERIFYING the SALES-mode-specific stricter fallback rule (stop
   entirely, don't route around with general knowledge) was preserved,
   not accidentally dropped. Kenneth flagged this as the one point where a
   content-loss would actually matter - check it specifically.
2. `<system_persona>` / `<human_voice_protocol>` deduplicated - remove the
   repeated "no fake polish / corporate filler / emojis" language that
   appeared in both blocks nearly verbatim.
3. `<decisive_assistant_rule>`'s redundant "applies in both modes"
   preamble removed, keeping only the non-redundant SALES-specific caveat.
4. Both menu files' `/switch` line no longer restates the full
   `/clear`-`/reset` danger explanation - `flush_clear_rule` (always part
   of the same assembled file) covers it; the menu line now just points
   there.
5. Stale "nightly research job" comment fixed in both launchers (now
   describes both scheduled jobs, not just one).
Recompute both assembled sizes (expected ~17,958 FULL / ~17,953 SALES,
margin ~2,045 on both, up from ~790). Confirm zero unreplaced markers.
Confirm nothing else changed via diff-vs-HEAD per the STANDING RULE.
Commit and push.

## Session Start Protocol results

1. `git pull` -> "Already up to date." HEAD `6162663`, branch `main`, up to
   date with `origin/main`. A `git push` at the end of this session moves
   `origin/main` to the placement commit + this report.
2. `audit/CLAUDE_CODE_LAST_AUDIT.md` read in full. Previous session
   (`6162663`): placed the `north-forge-improvements.zip` handoff
   (`5e2bc49` - daily-brief skill, cron self-scheduling launchers,
   CHANGELOG) and ran a repo optimization/redundancy audit. Status was
   "Needs primary GPT review". The optimization audit's Task 2(a) 1-5 and
   Task 2(c) 1 are exactly what this session's handoff acts on - the
   Claude Project chat has now authored the leaner wording and handed it
   back as a Zone B placement, which is the intended flow. Prior open
   flags (launcher self-heal string-match unverified against real
   `hermes cron list` output; `hermes doctor` hanging;
   `setup-thumbdrive.ps1` deletion recommendation; `f902285` flags;
   `CLAUDE.md` divergent Zone A enumerations) are untouched by this
   session and carried forward.
3. `git status` / `git diff` at start -> clean working tree. Only the
   expected gitignored artifacts present, none staged: `.agent-name`
   (7 B), `.env` (798 B), `.forge-mode` (6 B), `.hermes/` (dir),
   `.hermes.md` (19,264 B - the previously-assembled FULL file from
   Kenneth's last launch, pre-this-trim). Nothing uncommitted to act on.
4. `.gitignore` re-verified against the required four excludes, full file
   read:
   - `.env` -> line "`.env`" plus "`*.env`" (both present)
   - `.forge-mode` -> present (with the sync-hazard explanatory comment)
   - `.hermes.md` -> present
   - `.hermes/` -> present as "`/.hermes/`" (root-anchored, with comment
     distinguishing it from the global `~/.hermes` profile)
   Also present and correct: `/skills/` (root-anchored legacy
   wrong-folder-name guard, with its explanatory comment - the `/skills/`
   guard fix the STANDING RULE names as previously deliberate), `.claude/`,
   `.agent-name`, the runtime/state block (`state.db`, `sessions/`,
   `cron/`, `logs/`, etc.). No Zone A fix needed.
5. `hermes` installed at `C:\Users\kenw\AppData\Local\hermes\bin\hermes`.
   `hermes doctor` backgrounded with an 8-second wait -> no output
   returned in that window. This is the fifth consecutive session
   `hermes doctor` has failed to produce output (prior four: exit 124,
   hang). Assessed as the same offline/network block on its update-check,
   not a repo defect. `hermes skills list --source local` not separately
   re-run this session - the source tree is unchanged from `6162663`
   (15 skill sources: 8 tsc-only + 7 shared); this handoff touches no
   skill file.

```text
SESSION START CHECK
Pulled: Already up to date (HEAD 6162663; origin/main moves to the placement commit + this report after this session's push)
Last audit read: Yes - prev session placed the improvements handoff (5e2bc49) + ran the optimization audit; status "Needs primary GPT review"; this session's handoff acts on that audit's Task 2(a) 1-5 / 2(c) 1
Uncommitted at start: None (only gitignored artifacts: .agent-name, .env, .forge-mode, .hermes.md, .hermes/)
.gitignore: OK - excludes .env, .forge-mode, .hermes.md, .hermes/ (also /skills/, .claude/, runtime/state block)
hermes doctor: Could not run - no output in an 8s window (5th consecutive session; assessed network/update-check block, not a repo issue)
Project skills: 15 sources unchanged from 6162663 (8 tsc-only + 7 shared); this handoff touches no skill file
```

## Files inspected

- `north-forge-budget-trim.zip` (`C:\Users\kenw\Downloads\`) - extracted to
  a scratch dir. Archive listing: exactly 5 members, all repo-root-relative,
  no absolute paths, no `..` traversal, no `__MACOSX` payload members used.
  All 5 read in full.
- Incoming member raw sizes (as extracted, LF, bytes):
  - `.hermes.template.md` - 16,425
  - `mode-blocks/full-menu.md` - 1,369
  - `mode-blocks/sales-menu.md` - 758
  - `launch-north-forge.bat` - 5,499
  - `launch-north-forge.sh` - 6,358
- `git show HEAD:<path>` for all 5 overwritten files - CR-normalized
  `diff -u` incoming-vs-HEAD for each (full diffs quoted below).
- `mode-blocks/full-banner.md` (210 B LF) and `mode-blocks/sales-banner.md`
  (816 B LF) at HEAD - unchanged by this handoff, pulled in for the
  assembled-size recompute.
- The assembly substitution logic in both incoming launchers
  (`launch-north-forge.sh:69-82` Python block; `launch-north-forge.bat:43-48`
  inline PowerShell) - to replicate the exact marker substitution for the
  size recompute.
- Incoming launchers grepped for every prior-fix line the STANDING RULE
  requires be preserved (`.agent-name` writes, `CUSTOMNAME` prompt,
  `read -p ... || CUSTOMNAME=""`, `hermes model` echo).
- `.gitignore` (full read, session-start step 4).

## Zone A changes made

**None.** This session is a Zone B handoff placement only - five
byte-for-byte file overwrites from a named in-session handoff, plus this
report. No Zone A file was inspected for defects or modified. The two
launcher files are Zone A infrastructure but were placed as handoff
content, not fixed by Claude Code (the only change to them is a comment
reword the Claude Project chat authored - see below).

## Zone B handoff placement - `north-forge-budget-trim.zip`

### STANDING RULE diff-vs-HEAD (required, every handoff, every file)

Performed CR-normalized `diff -u` of each incoming file against its current
HEAD blob. Full results:

#### `.hermes.template.md` - 3 hunks, all within the 5 stated changes

Template LF size: HEAD had 17,598 chars (per `6162663` audit) -> incoming
**16,425** chars. Net -1,173 chars, entirely from the consolidation.

**Hunk 1 (`@@ -29,19 +29,15 @@`, `<how_this_package_is_organized>`)** -
stated changes 1. The block goes from 5 paragraphs to 3:
- OLD para 1 tail "It stays under Hermes's context-file size limit on
  purpose." -> dropped; the ".hermes/skills/ ... assembled fresh at launch"
  sentence (was para 2 opener) folded up into para 1.
- OLD para 2 (the long one) - the per-skill inventory is kept but
  compressed: "kb-builder, draft-writer, ... - all built" loses "- all
  built"; sales-assist keeps the "FAQ content still a placeholder"
  caveat; web-navigator loses "(built, with verified real links)"; the
  `menu`/`flush`/`switch` "(registers /X as a real command)" triplet is
  dropped; kyocera-research + daily-brief keep "cron-scheduled, not typed
  ... both self-schedule automatically at every launch if missing" but
  lose the "see launch-north-forge.bat/.sh" pointer and the "for the exact
  /cron add command" clause.
  - **REMOVED historical narrative (as instructed):** "...instead of
    falling back to the literal folder name, which is what silently broke
    every slash command before this was added." -> now just "- without it
    Hermes falls back to the folder name instead."
  - **REMOVED forge-audit naming-history framing (as instructed):** "The
    /audit skill's folder is named forge-audit for historical reasons (see
    NEXT_STEPS.md for why) but its registered command is /audit via its
    frontmatter, same mechanism as every other skill." -> compressed to a
    parenthetical on the inventory line: "forge-audit (registers /audit
    via its frontmatter, not its folder name)".
  - "see flush_clear_rule below for why /clear and /reset must never be
    used instead" -> dropped from this block (still stated in
    `flush_clear_rule` itself and `hermes_specific_addendum` item 3).
- OLD para 3 (the parenthetical "(All tsc-only skills ... are built and
  tracked in NEXT_STEPS.md ...)") - the "built and tracked in
  NEXT_STEPS.md" status note dropped; the operational content merged into
  the final paragraph.
- OLD para 5 "When a mode triggers, read and follow ... the same way the
  locked HTML template is the authority for KB structure." -> kept, minus
  the "same way the locked HTML template..." example clause and the
  "what a KB usually looks like" -> "what this usually looks like"
  generalization.

**VERIFICATION of the SALES-mode stricter-fallback rule (Kenneth's
explicit check - the one place content-loss would matter):** PRESERVED.

- OLD: "In Sales Assist mode specifically, a missing TSC skill is not a
  gap to route around with general knowledge - it means that capability is
  intentionally not part of this deployment. Say so plainly and stop,
  rather than attempting the task from general principles."
- NEW: "On a Sales-mode drive specifically, a missing TSC skill is
  stricter: it means that capability is intentionally not part of this
  deployment, not a gap to route around with general knowledge - say so
  plainly and stop."

Every semantic element survives: "a missing TSC skill", "intentionally not
part of this deployment", "not a gap to route around with general
knowledge", "say so plainly and stop", and it is explicitly labelled
"stricter" than the general fallback. The general fallback rule it is
stricter *than* also survives, in the same sentence group: "If a mode is
ever added to the menu before its skill file exists, say so plainly and
fall back to the general principles in this file rather than inventing
procedure" - with a new cross-reference "(see hermes_specific_addendum
item 5 for the persistence angle of this same rule)". Nothing about the
SALES stop-entirely behaviour was weakened, softened, or dropped in the
trim.

**Hunk 2 (`@@` at `<system_persona>` para 1)** - stated change 2.
- OLD: "You act like a seasoned field veteran: quiet expert, direct,
  practical, skeptical. No fake polish, no corporate filler, no decorative
  symbols, no emojis or emoticons, no unsupported certainty." + a separate
  "You do not talk down to technicians. You do not hand-hold unless
  training mode is requested. You give exact professional repair steps: ..."
- NEW: "You act like a seasoned field veteran: quiet expert, direct,
  practical, skeptical (see human_voice_protocol for the specific tone
  rules). Give exact professional repair steps: ... Do not talk down to
  technicians; do not hand-hold unless training mode is requested."
- The "no fake polish / corporate filler / decorative symbols / emojis /
  unsupported certainty" list is removed from `<system_persona>` and
  replaced with the pointer to `<human_voice_protocol>`. `<human_voice_protocol>`
  itself is **not in the diff** - it is byte-identical to HEAD, so the
  banned-style content it already carried (per the `6162663` audit's Task
  2(a) item 4: "both enumerate 'no emojis / no decorative symbols / no
  corporate filler / no unsupported certainty'") is intact and is now the
  single home for that language. "You separate: confirmed facts / ..." and
  the "You do not expose restricted service paths..." paragraph directly
  below are unchanged.

**Hunk 3 (`@@ -93,7 +89,7 @@`, `<decisive_assistant_rule>` last line)** -
stated change 3.
- OLD: "This applies in both FULL and SALES mode. On a SALES drive, "next
  step" still respects the mode's actual scope (e.g., point back to /sales
  or the normal TSC channel, never suggest a command this drive doesn't
  have)."
- NEW: "On a SALES drive, "next step" still respects the mode's actual
  scope - point back to /sales or the normal TSC channel, never suggest a
  command this drive doesn't have."
- Only the "This applies in both FULL and SALES mode." preamble sentence
  and the "(e.g., ...)" parenthetical wrapper are removed; the SALES-scope
  caveat itself is intact. The "NORTH FORGE TAKES THE RUDDER" paragraph
  above it is unchanged.

Every other line of the template is byte-identical to HEAD. Confirmed
untouched (not in any hunk): `<startup_sequence>`, `<assistant_router_rule>`
including the web-navigator entry (`a49580f`), `<personalization>`
(`cfd618d`), `<flush_clear_rule>` (`1fd6c1e`), `<hermes_specific_addendum>`
item 3 "/FLUSH AND /SWITCH ... Never /clear or /reset" (`1fd6c1e` Finding
4), the `{{MODE_BANNER_BLOCK}}` / `{{AGENT_NAME}}` / `{{COMMAND_MENU_BLOCK}}`
markers. **No previously-recorded deliberate fix is removed, reverted, or
contradicted.**

#### `mode-blocks/full-menu.md` - 1 hunk (`@@ -7,7 +7,7 @@`), the `/switch` line

- OLD: "/switch - reset working issue package AND mode, shows menu (see
  flush_clear_rule below). NEVER /clear or /reset for either - both are
  native Hermes commands that wipe the whole session with no warning."
- NEW: "/switch - reset working issue package AND mode, shows menu (see
  flush_clear_rule below - NEVER /clear or /reset for this)"
- Stated change 4. The standalone danger sentence ("both are native
  Hermes commands that wipe the whole session with no warning") is removed;
  the `/switch` line now mirrors the style of the `/flush` line directly
  above it ("(see flush_clear_rule below)"). `flush_clear_rule` is in
  `.hermes.template.md` and is always part of the assembled `.hermes.md`
  regardless of mode, so the full explanation is still present in every
  assembled file. Every other menu line (including the `/flush` line, the
  `/sales` and `/web` entries, the "Do not append a giant menu" footer) is
  byte-identical to HEAD.

#### `mode-blocks/sales-menu.md` - 1 hunk (`@@ -3,7 +3,7 @@`), the `/switch` line

- Identical edit to the same `/switch` line, same before/after text.
  Stated change 4. The "This drive has no other commands. If a technical
  support command is typed..." paragraph below is byte-identical to HEAD.

#### `launch-north-forge.bat` - 1 hunk (`@@ -113,9 +113,9 @@`), a comment only

- OLD: "rem Self-healing nightly research job - checks every launch,
  re-schedules / rem itself if missing (e.g. after an AppData flush wiped
  it). No manual / rem /cron add ever needed again." (3 lines)
- NEW: "rem Self-healing scheduled jobs - re-adds the research and
  daily-brief cron / rem entries if either is missing (e.g. after an
  AppData flush wiped them). / rem No manual /cron add ever needed again."
  (3 lines)
- Stated change 5. This is the exact reword the `6162663` audit's Task
  2(c) item 1 recommended ("e.g. 'Self-healing scheduled jobs - re-adds
  the research and daily-brief cron entries if either is missing'"),
  authored by the Claude Project chat and handed back here. **Comment
  text only** - the executable lines immediately below it
  (`hermes cron list ... findstr /C:"nightly-kyocera-research"`, the
  `if errorlevel 1` block, the `daily-kyocera-brief` block) are outside
  the hunk and byte-identical to HEAD.
- **Prior-fix preservation (STANDING RULE):** verified present and
  untouched in the incoming file:
  - line 34 `echo North Forge> ".agent-name"` (default branch, no
    trailing space - deliberate per `4b74503`)
  - line 36 `echo !CUSTOMNAME! > ".agent-name"` (**space before the
    redirect** - the `4b74503` fix preventing a digit-terminated name
    being parsed as an `N>` FD redirect)
  - lines 26-33 the `2dee2c1` first-launch name-prompt block
    (`if not exist ".agent-name"`, `set /p CUSTOMNAME=...`)
  - line 51 the `hermes model` advisory echo (`2dee2c1`)

#### `launch-north-forge.sh` - 1 hunk (`@@ -140,9 +140,9 @@`), a comment only

- Same three-line comment reword (`#` instead of `rem`), same before/after
  wording. Stated change 5. The `if ! hermes cron list ... | grep -q
  "nightly-kyocera-research"; then` block and the `daily-kyocera-brief`
  block below it are outside the hunk and byte-identical to HEAD.
- **Prior-fix preservation (STANDING RULE):** verified present and
  untouched:
  - line 57 `read -p "Name your assistant (press Enter to keep 'North
    Forge'): " CUSTOMNAME || CUSTOMNAME=""` (the `4b74503` fix -
    non-interactive stdin EOF degrades to the default name instead of
    aborting under `set -e`)
  - lines 51-61 the `2dee2c1` name-prompt block (`if [ ! -f ".agent-name"
    ]; then`)
  - line 87 the `hermes model` advisory echo

The diff-before-placement step passed cleanly for all 5 files. Nothing
outside the 5 stated changes moved.

### Marker integrity

Incoming template contains each assembly marker exactly once:
`{{MODE_BANNER_BLOCK}}` (line 9), `{{AGENT_NAME}}` (line 12,
"This drive's assigned display name is: {{AGENT_NAME}}"),
`{{COMMAND_MENU_BLOCK}}` (line 57). No other `{{...}}` occurrences. After
assembly (both modes) there are **zero** unreplaced `{{` sequences -
asserted programmatically in the recompute below.

### Encoding / line endings

All 5 incoming files: **0 non-ASCII bytes**, 0 CRLF pairs (pure LF in the
zip). Placed into the working tree where `core.autocrlf=true` is active -
git emits the expected "LF will be replaced by CRLF" advisory on all 5;
the committed blob is LF, so `git diff` shows only the intended content
changes (full diff quoted at the end of this report). `bash -n
launch-north-forge.sh` on the incoming file: clean.

### Assembled `.hermes.md` size recompute

Assembly = `.hermes.template.md` with `{{MODE_BANNER_BLOCK}}` ->
`mode-blocks/{mode}-banner.md`, `{{COMMAND_MENU_BLOCK}}` ->
`mode-blocks/{mode}-menu.md`, `{{AGENT_NAME}}` -> `North Forge` (default,
`.agent-name` treated as absent for the canonical measure). Skills are
separate on-disk files and do not count. Computed in Python on
LF-normalized inputs (`\r\n` -> `\n`), matching every prior audit's
method and the incoming `launch-north-forge.sh` Python assembler's own
`.replace()` calls:

| Mode  | template | + banner | + menu | assembled | margin to 20,000 |
|-------|----------|----------|--------|-----------|------------------|
| FULL  | 16,425   | 210      | 1,369  | **17,958**| **2,042**        |
| SALES | 16,425   | 816      | 758    | **17,953**| **2,047**        |

- **Assembled sizes match the handoff's stated `~17,958 FULL / ~17,953
  SALES` exactly.**
- Margin is now **2,042 (FULL) / 2,047 (SALES)** chars below the 20,000
  ceiling - the handoff said "~2,045 on both", and the mean of the two is
  2,044.5. Up from the `6162663` figure of **789 / 794**. Net margin
  gained: **+1,253 (FULL) / +1,253 (SALES)**.
- Zero unreplaced `{{...}}` markers in either assembled output
  (programmatic assert passed for both modes).

For continuity with the `6162663` table (which measured against a
17,598-char template): the template dropped 1,173 chars; `full-menu.md`
dropped 80 chars (1,449 -> 1,369); `sales-menu.md` dropped 80 chars
(838 -> 758); banners unchanged. 1,173 + 80 = 1,253 per mode. Consistent.

### Not exercised this session (no live key on this checkout)

- No launcher run, so `.hermes/skills/` was not rebuilt and `.hermes.md`
  in the working tree still holds Kenneth's last-launch FULL assembly
  (19,264 B, pre-trim). Kenneth's next launch regenerates it to the
  17,958 figure above.
- `hermes doctor` / `hermes cron list` not runnable (doctor hanging, 5th
  session). The launcher self-heal guard's string-match assumption
  against real `hermes cron list` output remains unverified - carried
  forward from `6162663` flag 1, unchanged by this handoff (the cron
  block's executable lines were not touched, only the comment above them).

## Zone B findings (not fixed - reported only)

**None new.** This session's entire purpose was to place the Claude
Project chat's authored fix for the findings the `6162663` audit already
recorded (Task 2(a) items 1-5, Task 2(c) item 1). The placement resolves,
in the assembled context file:
- the `<how_this_package_is_organized>` meta-narrative bloat (Task 2(a) 1)
  - template block trimmed ~1,173 chars;
- the menu-line restatement of the `/clear`/`/reset` danger already
  covered by `flush_clear_rule` (Task 2(a) 2) - both menu lines trimmed
  ~80 chars each;
- the `<system_persona>` / `<human_voice_protocol>` duplicated banned-style
  list (Task 2(a) 4) - consolidated into `<human_voice_protocol>`;
- the `<decisive_assistant_rule>` "applies in both modes" redundancy
  (Task 2(a) 5) - preamble removed;
- the stale "nightly research job" launcher comment (Task 2(c) 1) -
  reworded in both launchers.

Task 2(a) item 3 (`<assistant_router_rule>` verbose "or says something
like '...'" example clauses) was **not** part of this handoff - the
router rule block is byte-identical to HEAD. Still available as a future
lever if the margin needs more headroom; it was the lowest-priority,
highest-risk item in that list.

**Carried forward, unchanged (not touched by this handoff):**
- The launcher self-heal guard's string match is still unverified against
  real `hermes cron list` output (`6162663` flag 1). Needs a live check
  on Kenneth's next launch: run the launcher twice, then `hermes cron
  list`, confirm exactly one entry each for `nightly-kyocera-research`
  and `daily-kyocera-brief`.
- `hermes doctor` has now failed to produce output for 5 consecutive
  sessions. Assessed as an offline/update-check block, not a repo defect;
  the Session Start Protocol step-5 cross-check has effectively not run in
  over a month.
- `setup-thumbdrive.ps1` is superseded dead weight per `README.md:66`/`:123`
  - `6162663` recommended delete-or-archive; still holding for an explicit
  Blacksmith yes/no.
- `CLAUDE.md`'s bulleted "## Zone A" list omits `machine-reset.bat` while
  the "Required first response" recital includes it - cosmetic divergence
  in the authority document.
- The `f902285` flags (flag 1 `hermes model` echo intent - note it is in
  the current launchers and `2dee2c1` documents it; flag 4 name-prompt
  fires before the Hermes-install gate; flag 6 README `/cron` instructions
  not independently re-verified against this project's Hermes source).

## Commits made this session

- `0929a49` - "Place budget-trim handoff: consolidate always-loaded
  context (~1,253 chars/mode reclaimed)" - the 5 handoff files + this
  report. `git show --stat`: 6 files changed, 451 insertions(+), 509
  deletions(-) (the large line counts are the CRLF-vs-LF re-encoding git
  reports on first touch; the substantive content delta is the 5 stated
  changes only, as the CR-normalized diff below shows). Pushed to
  `origin/main` (`6162663..0929a49`).
- A follow-up commit filling this hash into the report (this line) may
  appear immediately after `0929a49`; it changes nothing but this file.

## Uncertain / flagged for primary GPT review

1. **The SALES stricter-fallback rule survives the trim** - documented in
   full above with the exact before/after. My read is that it is
   semantically complete (all four key phrases plus the explicit
   "stricter" framing) and that the new cross-reference to
   `hermes_specific_addendum item 5` is additive, not a substitution.
   Kenneth asked for this specific point to be checked; confirming it here
   for the primary GPT to sanity-check against intent. If the intent was
   to keep the literal phrase "rather than attempting the task from
   general principles" as well, note that clause specifically is gone -
   but "not a gap to route around with general knowledge - say so plainly
   and stop" carries the same instruction.
2. **`hermes_specific_addendum item 5` cross-reference** - the trimmed
   `<how_this_package_is_organized>` now points to "hermes_specific_addendum
   item 5 for the persistence angle of this same rule". I did not
   re-read `<hermes_specific_addendum>` this session to confirm its item 5
   is actually about rule persistence (the block is unchanged from HEAD
   and out of scope for a diff-only placement check). Worth the primary
   GPT confirming the item-5 reference lands on the right content, since
   it is a new pointer introduced by this trim.
3. **Assembled-size method** - I measure the canonical way (LF-normalized,
   `{{AGENT_NAME}}` -> literal "North Forge", markers replaced with no
   surrounding-newline manipulation). The incoming `.sh` assembler uses
   Python `f.read()` + `.replace()` (keeps whatever newlines are on disk);
   the `.bat` assembler uses `Get-Content -Raw` + `.Replace()` +
   `Set-Content -NoNewline`. On a CRLF working tree the real emitted
   `.hermes.md` will be larger by roughly one byte per line (~143 lines
   template + menu/banner lines => ~+160 bytes). The 20,000 ceiling is a
   character limit, not a byte limit, so the LF measure is the right one;
   flagging the method only so the primary GPT knows the 17,958 / 17,953
   figures are LF-char counts, consistent with every prior audit's table.
4. **No live exercise** - no launcher run, no model run against the new
   `.hermes.md`, no `hermes cron`/`doctor`. All deferred to Kenneth's next
   real launch, same as the prior two sessions.

## Status

Needs primary GPT review. The handoff placement is complete and verified:
diff-vs-HEAD is exactly the 5 stated changes and nothing else; the
SALES-mode stricter-fallback rule (the one flagged content-loss risk) is
preserved with all semantic elements intact; both assembled sizes recompute
to the handoff's exact figures (17,958 FULL / 17,953 SALES) with margin
restored to ~2,045 from ~790; zero unreplaced markers in either mode; all
prior launcher fixes (`4b74503`, `2dee2c1`) confirmed present and
untouched; encoding clean (0 non-ASCII). Repo integrity sound: working
tree clean after the commit, `.gitignore` correct, 15 skill sources
unchanged, both `.sh` launchers `bash -n`-clean.
