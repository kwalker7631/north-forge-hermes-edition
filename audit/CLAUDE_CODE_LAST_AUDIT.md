# Claude Code Session Audit

Timestamp: 2026-09-04, ~02:20 EDT (relay task); ~02:50 EDT (Zone C append);
~03:15 EDT (README-fix.zip - HELD); ~03:30 EDT (README-fix re-cut PLACED
`da0249c`; official `README-fix2.zip` verified identical to it). Session-
start HEAD `df92049`; working tree clean at start. End HEAD `da0249c`
(+ this report).

Requested tasks (three, all from Kenneth in-session):
  (1) The primary GPT asked for a verbatim relay of specific current repo
      text so it can author corrected files off a known-good base rather
      than a stale sandbox copy. Three items:
    1a. `CLAUDE.md` `## Zone A` bulleted file list + the `Required first
        response` recital block, exact current text.
    1b. `README.md` file-tree block (the fenced block under `## What's in
        here`) + the two `setup-thumbdrive.ps1` prose references, exact
        current text.
    1c. A direct yes/no: does `README.md` currently contain an
        `## Updating Hermes itself` section documenting
        `machine-reset.bat`'s rotate-key / full-purge options?
  (2) Append (append-only, no edit/removal of existing entries) a logged
      future item to `NEXT_STEPS.md`: "## Future: North Forge Maker Studio
      (extracted from ABMS/Pine Barren Farms)" - given verbatim by
      Kenneth.
  (3) Zone B placement: "Extract README-fix.zip into this repo's root,
      overwriting README.md" - whole-file handoff from the Claude Project
      chat. Instructed to diff against HEAD per the STANDING RULE and
      confirm every change is accounted for. Handoff enumerates exactly
      three change groups: (3a) add "## Updating Hermes itself" section;
      (3b) fix both stale `setup-thumbdrive.ps1` refs -> `archive/`;
      (3c) add `machine-reset.bat` + `CHANGELOG.md` to the file-tree
      block. Handoff explicitly says "confirm no other line changed."

Task (1): no fix requested, none made - read / quote / report only.
Task (2): Zone C append performed and committed per standing Zone C
authorization (`CLAUDE.md` lines 127-147, 202-212). Pure append, 36
insertions, 0 deletions, existing entries byte-untouched - verified with
`git diff --stat` (`1 file changed, 36 insertions(+)`) and full
`git diff` review before commit. Text placed byte-for-byte as Kenneth
supplied it; Claude Code composed none of it.
Task (3): first cut **HELD** (undescribed `## Passcode system` section,
zero implementation - detail below). Kenneth then gave an explicit
in-session instruction to place the file minus that section and minus
the coupled "admin-password-gated - see \"Passcode system\" above"
clause. **PLACED as `da0249c`** - re-cut by hand from the held zip per
that instruction, diff verified to be exactly the five reviewed-correct
hunks and nothing else, CRLF preserved, zero residual `passcode`
references. Kenneth then also sent the Claude Project chat's own re-cut
`README-fix2.zip`; it is **content-identical** to `da0249c`
(sha256 `fb5f802...` after CR-normalisation, `git diff --no-index`
clean) and differs only by shipping LF instead of the repo's CRLF, so it
was **not** re-placed - doing so would be a pure line-ending churn commit
with no content change. Task (3) is closed.

## Files inspected

- `CLAUDE.md` (full, 316 lines) - read in full. Relevant spans quoted
  below verbatim: Zone A list lines 22-34, `Required first response`
  block lines 219-231.
- `README.md` (full, 190 lines) - read in full. Relevant spans: file-tree
  fenced block lines 35-79 (under `## What's in here`, line 33); the two
  `setup-thumbdrive.ps1` references at lines 66 and 123. All 16 `## `
  headings enumerated via `grep -n '^## ' README.md`.
- `audit/CLAUDE_CODE_LAST_AUDIT.md` (prior, 350 lines) - read in full as
  session-start continuity.
- `machine-reset.bat` (present at repo root, 6115 bytes, mtime
  2026-09-03 18:11) - grepped for its option labels only (lines 13-17
  rem header, 41-52 menu + dispatch, 58 `:rotate_key`, 94 `:full_purge`,
  107 `FULL PURGE - this will:`). Not read in full.
- `git ls-files | grep -i 'archive\|setup-thumb'` -> `archive/setup-thumbdrive.ps1`
  (single hit). `ls setup-thumbdrive.ps1` -> `No such file or directory`.
  `ls archive/` -> `setup-thumbdrive.ps1` (4502 bytes, mtime
  2026-09-03 18:11). Confirms the `88953a7` `git mv` is in effect.
- `grep -rn 'setup-thumbdrive'` across `*.md *.ps1 *.bat *.sh` - hits in
  `README.md:66`, `README.md:123`, `CLAUDE.md:29`, and this audit file
  only. No functional / script reference anywhere.

## Session-start protocol results

- **`git pull`**: `Already up to date.` Session-start HEAD `df92049`
  ("Audit: fix remaining <HASH> placeholder (final push hash 72be258)").
- **`git status` / `git diff`**: working tree clean, nothing staged,
  nothing modified, branch even with `origin/main`.
- **`.gitignore`**: not re-modified this session. Prior audits confirmed
  it excludes `.env`, `.forge-mode`, `.hermes.md`, `.hermes/`, plus the
  `/skills/` guard at line 51 and `logs/` at line 29. Not re-diffed this
  session (no task touched it); assumed intact per `df92049` state.
- **`hermes doctor`**: run in a chained background command that exceeded
  the 120 s foreground timeout and was moved to background; I initially
  reported it as hung and killed. **Correction: it completed with exit
  code 0 and produced full clean output** (task `bzgfco3qm`, notified
  after my first response). This BREAKS the "6+ consecutive sessions
  with no `hermes doctor` output" streak the prior audits recorded - the
  command works, it is just slow (>120 s) on this machine. Verbatim
  result:
  ```
  ◆ Security Advisories      ✓ No active security advisories
  ◆ MCP Server Security      ✓ No suspicious MCP stdio commands
  ◆ Python Environment       ✓ Python 3.11.16   ✓ SQLite 3.53.1
                             ✓ Virtual environment active
                             ✓ Version files consistent (0.21.0)
    state.db WAL 1.0 MB; cron/executions.db WAL 20.0 KB;
    verification_evidence.db WAL 32.0 KB; kanban.db WAL 116.0 KB
  ◆ SSL / CA Certificates    ✓ SSL CA certificate bundle is valid
  ◆ Required Packages        ✓ OpenAI SDK  ✓ Rich  ✓ python-dotenv  ✓ PyYAML
  ```
  Hermes version 0.21.0. No issues reported in any section.
- **`hermes skills list --source local`**: also completed (same
  background task). **14 local skills, all `local` source, all `local`
  trust, all `enabled`, 0 disabled** - "0 hub-installed, 0 builtin, 14
  local". Names as registered:
  `assist, audit, draft, esc, flush, hl, kb, kyocera-research, log,
  menu, sales, switch, train, web`.
  Note: `daily-brief` is NOT in this list - consistent with the prior
  audit's record that the `daily-brief/SKILL.md` handoff file was HELD,
  not placed. This live list reflects the last launcher build into
  `~/.hermes`, not necessarily current `skills-source/`; a fresh launch
  would rebuild it. `Category` column is blank for every row (no skill
  sets a `category:` field). Prior audits' "15 skill sources" figure vs.
  this "14 registered" - flagged below for the primary GPT to reconcile
  against `skills-source/**`.

## Task (3) - README-fix.zip placement - HELD

### How the handoff arrived (worth noting - matches the export-mishap pattern)

There is no `README-fix.zip` at the repo root or anywhere on disk under
that name. The only new download is `~/Downloads/files.zip` (20,919 B,
mtime 2026-09-04 02:15). `unzip -l files.zip`:

```
    25522  2026-09-04 06:15   README.md
    10436  2026-09-04 06:15   README-fix.zip
```

`files.zip` contains BOTH a top-level `README.md` AND a nested
`README-fix.zip`. Extracted the nested zip:
`unzip -l README-fix.zip` -> single entry `README.md`, 25522 B,
mtime 2026-09-04 02:14. `sha256sum` of the top-level `README.md` and the
nested-zip `README.md` are **identical**
(`550795f4385905a982502119d9293986cbdf4710eb443c97f99d15f68aef9d00`), so
there is exactly one candidate file regardless of which layer it is
pulled from. The double-wrap (a zip inside a zip inside a differently
named zip) is itself a small signal that the export was assembled
loosely.

### Incoming file vs. current HEAD

- Current `README.md` (HEAD `df92049`): 190 lines, 21,699 bytes,
  **CRLF** line endings (`xxd` shows `0d0a`), sha256
  `ed9ef922bf2f91fdb3210e42a21f6c28a9a2ac653fe051488b3e8d23b6098da1`.
- Incoming `README.md`: 221 lines, 25,522 bytes, **LF only**
  (`file` -> "ASCII text, with very long lines"; `xxd | grep -c 0d0a`
  on the head -> 0).
- **Line-ending flip is a whole-file change.** Placing the incoming file
  as-is converts the entire README from CRLF to LF. Git on this repo has
  `core.autocrlf` behavior active (every `audit/` commit this session
  emitted `warning: ... LF will be replaced by CRLF the next time Git
  touches it`), so the committed blob may normalize back to CRLF on
  checkout - but the placement should be done from a CRLF copy to keep
  the diff to real content lines only, not 221 phantom EOL changes.

### `diff <(git show HEAD:README.md) <incoming>` - six hunks

```
60a61
> machine-reset.bat               <- Kenneth-only: manages THIS MACHINE's Hermes state (separate from the drive) - rotate just the API key, or fully purge everything
66c67,68
< setup-thumbdrive.ps1           <- SUPERSEDED - kept only because Kenneth's own personal drive was set up with it early on. Do not use for new drives.
---
> archive/
>   setup-thumbdrive.ps1          <- SUPERSEDED, moved here from repo root - kept only because Kenneth's own personal drive was set up with it early on. Do not use for new drives.
76a79
> CHANGELOG.md                     <- plain-language running history of what changed and why, distinct from git log and from the audit report below
96a100,112
> ## Passcode system - handoff activation and admin lock
> [ ... 13 lines ... ]
123c139
< `setup-thumbdrive.ps1` is superseded by this script and kept only for historical reasons - don't use it for new drives.
---
> `archive/setup-thumbdrive.ps1` is superseded by this script and kept only for historical reasons - don't use it for new drives.
154a171,185
> ## Updating Hermes itself (not this repo)
> [ ... 15 lines ... ]
```

**Accounted for against the handoff's three stated change groups:**

| Hunk | What it is | Handoff group | Verdict |
|------|-----------|---------------|---------|
| `60a61` | add `machine-reset.bat` to file-tree | 3c | matches - `machine-reset.bat` really exists at root (6115 B), really was undocumented |
| `66c67,68` | file-tree `setup-thumbdrive.ps1` -> `archive/` subtree, "moved here from repo root" | 3b | matches the real `88953a7` `git mv` |
| `76a79` | add `CHANGELOG.md` to file-tree | 3c | matches - `CHANGELOG.md` really exists (3122 B), really was unlisted |
| `123c139` | prose `setup-thumbdrive.ps1` -> `archive/setup-thumbdrive.ps1` | 3b | matches the real move |
| `154a171,185` | new `## Updating Hermes itself (not this repo)` section, 15 lines | 3a | content is accurate on its face (`%LOCALAPPDATA%\hermes`, `$HERMES_HOME`, `hermes gateway stop`/`uninstall`, `state.db`/`cron/`/`logs/` - the `state.db`/`cron/` names match this session's live `hermes doctor` output) - BUT its closing line cross-references the undescribed section: "Both are admin-password-gated - see \"Passcode system\" above." |
| `96a100,112` | new `## Passcode system - handoff activation and admin lock` section, 13 lines | **NONE** | **undescribed; documents a feature that does not exist** |

### The blocker: hunk `96a100,112` - `## Passcode system`

The incoming file inserts a full 13-line section (incoming lines
100-112) describing:
- a per-drive **user-activation flow**: Kenneth runs the launcher on a
  virgin drive, it prompts for the recipient's **name** and a
  **passcode** (entered twice), writes both + a timestamp to
  **`.user-record.txt`**, then requires the passcode once to unlock,
  creating **`.user-unlocked`**; wrong passcode never locks out, just
  re-prompts with "Incorrect passcode. Forgot it? Check with the USB
  admin.";
- an **admin lock**: a fixed administrator password gating FULL/SALES
  toggle, RESET, API-key rotation, and full purge, in
  `toggle-mode.bat`/`.sh` and `machine-reset.bat`, "every single time";
- RESET also wiping `.user-record.txt` + `.user-unlocked`.

**None of this exists in the repo.** Verified:
- `git grep -n -i "passcode\|password\|\.user-record\|\.user-unlocked\|unlock"`
  over all tracked files except `README.md` and `audit/`: only hits are
  `fallback/NORTH_FORGE_v21.8_PASTE_VERSION.md:603` and
  `skills-source/tsc-only/assist-intake/SKILL.md:79`, both the unrelated
  field-support phrase "recent password/MFA/tenant/security change".
- `launch-north-forge.bat` `set /p` prompts: only `MODE` (line 8) and
  `CUSTOMNAME` for `.agent-name` (line 32). No name-record, no passcode.
- `launch-north-forge.sh:57`: only the `.agent-name` prompt
  ("Name your assistant ...").
- `toggle-mode.bat`: the only gate is `set /p CONFIRM="Type YES (all caps)
  to confirm: "` (line 45) for RESET. No admin password.
- `machine-reset.bat`: `set /p CHOICE` 1/2/3 then `set /p CONFIRM` Y or
  `YES`. No admin password.
- `.gitignore`: no entry for `.user-record.txt` or `.user-unlocked`
  (the section claims `.user-record.txt` is "per-drive, never committed"
  - nothing enforces that).
- `git log --all --oneline`: no commit message mentions passcode /
  activation / user-record / lock, ever.
- No mention in `NEXT_STEPS.md`, `DEMO_PREP_BACKLOG.md`, `CHANGELOG.md`,
  or any prior audit report.

So placing the incoming file verbatim would publish, into
Blacksmith-reviewed user-facing documentation, a detailed description of
a name+passcode activation gate and an admin-password lock that a team
member would then expect to encounter and never will - and it would tell
them a file (`.user-record.txt`) is "never committed" without anything in
`.gitignore` actually preventing that.

### Why HELD rather than partial-placed

The STANDING RULE's established remedy ("apply only the genuinely new
part of the handoff") was previously used for Zone A / `.gitignore`
mechanical fixes where the safe subset was unambiguous. Here:
- Deciding the `## Passcode system` section is unwanted vs. deliberately
  ahead of its scripts is a judgment about the primary GPT's intent, and
  that is exactly the kind of call the Zone B rule reserves to the
  Blacksmith / Claude Project chat, not Claude Code.
- The two new sections are coupled - `## Updating Hermes itself` ends
  with "see \"Passcode system\" above" - so hand-assembling a partial
  file means either also editing that cross-reference out (composing
  Zone B prose) or shipping a dangling reference. Both are worse than
  holding.
- This is the fourth Zone B handoff tonight (`daily-brief`,
  `kyocera-research`, and now this) to arrive with content beyond its
  stated scope. The pattern itself is worth the primary GPT's attention.

### Resolution (path a - taken)

Kenneth confirmed in-session that `## Passcode system` was an accidental
inclusion and instructed: place the file minus that section (incoming
lines 100-112) and minus the "see \"Passcode system\" above" clause in
`## Updating Hermes itself`, "since that feature doesn't exist in the
repo yet."

What was done (`da0249c`):
- Removed the 13-line `## Passcode system` section in full (heading
  through the "Neither passcode lives anywhere..." paragraph and its
  trailing blank). Verified the line before it was already blank, so the
  single blank separator before `## Custom agent name` is preserved -
  structure matches the pre-handoff file.
- In `## Updating Hermes itself`, removed the **entire** trailing clause
  " Both are admin-password-gated - see \"Passcode system\" above." from
  the machine-reset paragraph, not just the "see..." cross-reference
  fragment. Rationale: "admin-password-gated" is itself a description of
  the same unimplemented gate - `machine-reset.bat` currently uses only
  a `Y`/`YES` confirm (verified last commit), so leaving that phrase
  would be a fresh factual inaccuracy and would contradict the stated
  purpose of the re-cut. **Flagged here for the primary GPT** in case a
  literal-minimal cut (fragment only, phrase kept) was actually wanted -
  trivial to adjust, but the accurate reading is the phrase goes too.
  The sentence now ends cleanly at "...deletes the entire folder
  above)."
- Output written with CRLF to match the repo's existing `README.md`
  line endings, so `git diff` shows only real content lines.

`git diff HEAD~1 -- README.md` = **exactly five hunks**, 20 insertions /
2 deletions:
`60a61` machine-reset.bat file-tree line; `66c67,68` setup-thumbdrive.ps1
-> archive/ subtree; `76a79` CHANGELOG.md file-tree line; `123c139`
prose archive/setup-thumbdrive.ps1; `156a159,175` `## Updating Hermes
itself (not this repo)` section (without the passcode clause). No
`## Passcode system`. `grep -ic passcode README.md` -> 0.

### Cross-check against the Claude Project chat's own re-cut

Kenneth subsequently supplied `~/Downloads/README-fix2.zip` (single
`README.md`, 23,501 B, LF, mtime 2026-09-04 02:23) - the primary GPT's
independent re-cut of the same file. Compared to `da0249c`:
- `git show HEAD:README.md | tr -d '\r' | sha256sum` ->
  `fb5f80243fc4bcfeda6766c11d095212aedfccbf9d8afc487904de680ba1c201`
- `tr -d '\r' < README-fix2/README.md | sha256sum` -> **same hash**.
- `git diff --no-index` (both CR-stripped) -> no differences.
- Only real difference: `README-fix2.zip` ships LF; the committed repo
  file is CRLF like the rest of the tree.
Therefore `README-fix2.zip` was **not** placed - it would produce a
whole-file CRLF->LF churn commit with zero content change. The hand
re-cut and the primary GPT's re-cut agree byte-for-byte on content.

## Zone A changes made

None. No Zone A file was modified, staged, or committed for a fix. The
only Zone A writes are this report and the Zone B/C placements below.

## Zone B placements made this session

- **`README.md` <- `da0249c`** (whole-file handoff, re-cut per Kenneth's
  explicit in-session instruction). Five reviewed-correct hunks placed;
  `## Passcode system` section + "admin-password-gated - see \"Passcode
  system\" above" clause omitted per instruction (feature has no
  implementation in the repo). Verified byte-identical in content to the
  primary GPT's own `README-fix2.zip` re-cut. Detail in Task (3) above.
  **One judgment call flagged**: removed the whole "admin-password-gated"
  clause, not just the cross-reference fragment - see Task (3)
  resolution.

## Zone B findings (not fixed - reported only)

**Finding 0 - RESOLVED this session.** The first `README-fix.zip` carried
an undescribed `## Passcode system` section (name+passcode activation
gate, admin-password lock) with zero implementation in any tracked file.
Held, then placed without that section per Kenneth's instruction
(`da0249c`). Underlying open item for the primary GPT: **the
passcode/admin-lock feature is now referenced nowhere in the repo again -
if it is still intended, it needs a real Zone A implementation
(launcher name+passcode+`.user-record.txt`/`.user-unlocked` flow,
admin-password gate on `toggle-mode.*` + `machine-reset.bat`, `.gitignore`
entries) AND the README section back, together.**

Findings 1-5 below re-confirm items already open in the prior audit.
NOTE: `da0249c` resolves the `README.md` side of findings 1, 2 and 5
(the stale `setup-thumbdrive.ps1` path refs, and the missing
`## Updating Hermes itself` section / missing `machine-reset.bat` +
`CHANGELOG.md` file-tree entries). Findings 3 and 4 are `CLAUDE.md`-side
and still need their own Zone B handoff - unchanged.

1. **`README.md:66` (inside the file-tree fenced block) - stale path.**
   Exact current line:
   ```
   setup-thumbdrive.ps1           <- SUPERSEDED - kept only because Kenneth's own personal drive was set up with it early on. Do not use for new drives.
   ```
   The file is now at `archive/setup-thumbdrive.ps1` (committed
   `88953a7`, verified this session - no copy at repo root). The tree
   block lists it at root indentation with no `archive/` parent entry,
   and the block has no `archive/` line at all. `machine-reset.bat` and
   `CHANGELOG.md` are also both absent from this tree block (added
   `5e2bc49`; `machine-reset.bat` has zero mentions anywhere in
   `README.md`).

2. **`README.md:123` - stale prose.** Exact current line:
   ```
   `setup-thumbdrive.ps1` is superseded by this script and kept only for historical reasons - don't use it for new drives.
   ```
   Reads as though the file sits at repo root alongside
   `provision-new-drive.ps1`. Path now `archive/`.

3. **`CLAUDE.md:29` - Zone A list entry.** Exact current line (bullet):
   ```
   - `setup-thumbdrive.ps1`
   ```
   Bare basename, no path. After the `88953a7` move this names a file
   that no longer exists at that location. Related open question (carried
   from prior audit, still unanswered): **`archive/` has no zone
   assignment anywhere in `CLAUDE.md`.**

4. **`CLAUDE.md` internal inconsistency (carried forward, still open).**
   The `## Zone A` bulleted list (lines 24-34) does NOT include
   `machine-reset.bat`. The `Required first response` recital (lines
   225-230) DOES: line 226 reads
   `...may fix + commit + push automatically): launch scripts, toggle scripts, machine-reset.bat, setup script, provision-new-drive.ps1, .env.example, skins/north-forge.yaml, this audit report, .gitignore`.
   So the recital already treats `machine-reset.bat` as Zone A and
   already abbreviates `setup-thumbdrive.ps1` to "setup script"; the
   bulleted list still names `setup-thumbdrive.ps1` explicitly and omits
   `machine-reset.bat`. The two need reconciling, and the `archive/`
   zone question resolved, in the same edit.

5. **`README.md` has NO `## Updating Hermes itself` section.** Direct
   check performed at the primary GPT's request. `grep -n '^## '
   README.md` returns exactly 16 headings (listed in full in the chat
   response); none is "Updating Hermes itself" or any near variant.
   `grep -n 'machine-reset\|Updating Hermes\|rotate-key\|full-purge\|purge'
   README.md` returns **zero lines**. `machine-reset.bat` is entirely
   undocumented for users - it exists at repo root (6115 bytes) with a
   two-option interactive menu (`1` Rotate the API key - delete only
   `.env`; `2` Full purge - stop + uninstall the messaging gateway
   service then remove the Hermes folder; `3` cancel), and its only
   textual references in the repo are `CHANGELOG.md` and `CLAUDE.md`.
   **Conclusion for the primary GPT: if it believes it authored an
   "## Updating Hermes itself" section for `README.md` in an earlier
   round, that handoff did not land in this repo.** Same pattern the
   prior audit noted for other zips. Current `README.md` HEAD is
   `df92049`; no commit in the visible log
   (`df92049 72be258 88953a7 084d67b e869b82 decef9a 0929a49 6162663`)
   has a message suggesting a README Hermes-update section was added.

## Commits made this session

- `d9981b3` - "Audit: verbatim relay of Zone A list / recital / README
  file-tree to primary GPT; confirm README has no 'Updating Hermes
  itself' section" - `audit/CLAUDE_CODE_LAST_AUDIT.md` only. Pushed
  `df92049..d9981b3` to `origin/main`.
- `2f65aaa` - "Audit: fill commit hash d9981b3 into report" - same file.
- `074b57a` - "Audit: correct hermes doctor/skills-list result (completed
  clean, not hung)" - same file. The chained background `hermes` command
  finished with exit 0 after my first response; session-start section and
  flag 3 corrected accordingly.
- `a145b88` - "NEXT_STEPS: log future item - North Forge Maker Studio
  (ABMS extraction)" - **Zone C**, `NEXT_STEPS.md`, append-only, +36
  lines / -0. Pushed `074b57a..a145b88`.
- `1d26cd0` - "Audit: record Zone C append to NEXT_STEPS (Maker Studio
  future item)" - `audit/` file only.
- `dc41386` - "Audit: README-fix.zip HELD - undescribed '## Passcode
  system' section, no implementation in repo" - `audit/` file only.
- `da0249c` - "Place README-fix per Blacksmith re-cut: archive/ path
  fixes, machine-reset.bat + CHANGELOG.md in file-tree, new '## Updating
  Hermes itself' section" - **Zone B placement**, `README.md`, +20 / -2,
  five hunks, passcode section + clause omitted per instruction. Pushed
  `dc41386..da0249c`.
- (final commit) - this report update: task (3) resolved, README placed,
  `README-fix2.zip` verified identical and not re-placed. `audit/` file
  only.

## Uncertain / flagged for primary GPT review

1. **Judgment call inside the `da0249c` placement: I removed the whole
   clause " Both are admin-password-gated - see \"Passcode system\"
   above."**, not just the "see \"Passcode system\" above" fragment
   Kenneth named. Reason: `machine-reset.bat` is not actually
   password-gated today (only a `Y`/`YES` confirm), so "admin-password-
   gated" would be a fresh inaccuracy and defeats the point of the
   re-cut ("README should not describe [the feature] until it's actually
   implemented"). The primary GPT's own `README-fix2.zip` made the exact
   same removal (verified byte-identical), so this reads as the intended
   cut - but if a literal-minimal edit was wanted, it is a one-line
   adjustment.

2. **The passcode / admin-lock feature is now undocumented again** (as it
   was before tonight). If it is still a real roadmap item, it needs a
   proper Zone A implementation handoff (launcher name+passcode flow
   writing `.user-record.txt` / `.user-unlocked`; admin-password gate in
   `toggle-mode.bat`/`.sh` + `machine-reset.bat`; `.gitignore` entries
   for the two dotfiles) delivered together with the README section, so
   docs and behaviour match. Nothing tracks this yet - not in
   `NEXT_STEPS.md`, `DEMO_PREP_BACKLOG.md`, or `CHANGELOG.md`.

3. **STANDING-RULE prior-fix check on the README handoff (clean).** The
   placed file does not revert any previously-recorded fix. The
   `88953a7` `setup-thumbdrive.ps1 -> archive/` move is correctly
   reflected in the file-tree subtree change and the prose line; no
   other prior audit fix touches `README.md`. The only issue with the
   original handoff was additive (the extra section), now removed.

4. **`README-fix2.zip` not placed** - it is content-identical to
   `da0249c` and differs only by LF-vs-CRLF line endings. Placing it
   would be a no-content churn commit flipping the whole file's endings.
   If the primary GPT specifically wants the repo `README.md` on LF, say
   so explicitly - that is a deliberate repo-wide line-ending decision,
   not something to fold in silently under a content handoff.

5. **`archive/` zone assignment still unanswered.** Blocking clean
   authoring of the `CLAUDE.md` Zone A list fix. Prior audit's default
   assumption, unchanged: treat `archive/` as read-only "kept for
   history," Claude Code does not modify its contents and does not move
   new files in without an explicit instruction.

6. **`hermes doctor` / `hermes skills list` DID run clean this session**
   (background task `bzgfco3qm`, exit 0) - I had wrongly reported them as
   hung/killed in my first pass and have corrected the session-start
   section above. `hermes doctor` is fully clean at 0.21.0; 14 local
   skills all enabled + locally trusted. Still no launcher run / no live
   `.hermes.md` assembly exercise this session. **Reconcile "15 skill
   sources" (prior audits) vs. "14 registered local skills" (this
   session's live list) against `skills-source/**`** - likely just
   `daily-brief` (held, not placed) accounting for the difference, but
   worth a direct check.

7. **`.gitignore` not re-diffed this session** - no task touched it and
   the working tree was clean, so it was taken as intact at `df92049`.
   If the primary GPT wants an explicit re-verification of the four
   required excludes + the `/skills/` and `logs/` guards, that is a
   one-command check next session.

## Status

Needs primary GPT review - flags 1 and 2 above (the "admin-password-
gated" clause removal, and the now-undocumented passcode feature).

Session end state:
- Task (1): verbatim relay delivered in chat + quoted in this report.
  `README.md` confirmed to have had no `## Updating Hermes itself`
  section and no `machine-reset.bat` reference at HEAD `df92049`.
- Task (2): `NEXT_STEPS.md` Maker Studio future item appended and pushed
  (`a145b88`). Pure append, existing entries untouched.
- Task (3): **RESOLVED.** First `README-fix.zip` held (undescribed
  `## Passcode system` section, no implementation). Re-cut per Kenneth's
  in-session instruction and placed as `da0249c` - five reviewed-correct
  hunks, passcode section + clause removed, CRLF preserved, `grep -ic
  passcode README.md` = 0. Primary GPT's `README-fix2.zip` re-cut
  arrived next and is byte-identical in content (sha256 `fb5f802...`,
  LF-vs-CRLF only) - not re-placed, would be pure churn.
- Still open, `CLAUDE.md`-side, needs its own Zone B handoff: findings 3
  and 4 (Zone A list still names `setup-thumbdrive.ps1` / omits
  `machine-reset.bat`; `archive/` has no zone assignment).
- Repo integrity: working tree clean apart from this `audit/` file.
  End HEAD `da0249c` + this report. `hermes doctor` clean at 0.21.0 this
  session; 14 local skills enabled + trusted. No launcher / live
  `.hermes.md` assembly run this session.
