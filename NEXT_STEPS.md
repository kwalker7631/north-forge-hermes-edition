# Build Status

## Done
- `.hermes.template.md` - core template (identity, persona, startup routing, universal rules, Hermes-specific memory/skill-lock addendum, mode-aware banner/menu markers)
- `mode-blocks/` - FULL and SALES banner + menu content
- `skills-source/tsc-only/kb-builder/SKILL.md` - full /kb procedure, ported from the v21.8 master
- `skills-source/tsc-only/draft-writer/SKILL.md` - /draft (Draft Writer) procedure: trigger, output contract, context reuse, content scrubbing. Placed 2026-08-28 from a Claude Project chat handoff (byte-for-byte placement, not composed by Claude Code)
- `skills-source/tsc-only/hotline-ticket/SKILL.md` - /hl, /ticket: clipboard-ready HL/ServiceNow ticket-note block. Placed 2026-08-28 from the full-skillset-v3 (reissue) handoff (commit `d414f81`)
- `skills-source/tsc-only/assist-intake/SKILL.md` - /a, /assist (default mode): intake fact set, depth levels, minimum evidence packs, logs-first discipline, enterprise path discipline. Placed 2026-08-28 (`d414f81`)
- `skills-source/tsc-only/escalation-packet/SKILL.md` - /esc: structured engineering hand-off packet. Placed 2026-08-28 (`d414f81`)
- `skills-source/tsc-only/forge-audit/SKILL.md` - /audit, /chk: finding format + failure taxonomy (Router / Context Handoff / Template / Output Contract / Source Discipline / Hallucination Risk). Placed 2026-08-28 (`d414f81`); folder renamed from `audit/` to `forge-audit/` on 2026-08-28 (`8759d15`) - see QA Finding 1 below. User-facing command still `/audit` or `/chk`
- `skills-source/tsc-only/fault-logging/SKILL.md` - /log, /fault, /report: FORGE FAULT REPORT / EVENT LOG / change-log blocks, persistence-reality rules. Placed 2026-08-28 (`d414f81`)
- `skills-source/tsc-only/training-guide/SKILL.md` - /train, /t: slower guided-explanation mode, deliberate exception to the terse default. Placed 2026-08-28 (`d414f81`)
- `skills-source/shared/web-navigator/SKILL.md` - /web, /links (both modes): direct-link directory for kyoceradocumentsolutions.us (support/downloads, sales/product, proposal/dealer, industry material). Placed 2026-08-28 (`d414f81`). Link accuracy is the author's claim ("verified against the live site") - not re-checked by Claude Code; confirm during QA
- `skills-source/shared/sales-assist/SKILL.md` - scoped and boundary-defined, but NOT yet given real content (FAQ body still a placeholder pending real spec-sheet curation)
- `skills-source/shared/flush/SKILL.md` - thin routing skill that registers `/flush` (soft reset: clear working issue package, stay in mode). Placed 2026-09-01 from the north-forge-hermes-COMPLETE-fix handoff (Claude Project chat, byte-for-byte placement, not composed by Claude Code)
- `skills-source/shared/menu/SKILL.md` - thin routing skill that registers `/menu` (show the mode's command menu). Placed 2026-09-01 from the same handoff
- YAML frontmatter pass (2026-09-01, same handoff): all 14 skill files now open with a `name:` / `description:` frontmatter block so Hermes registers the intended slash command (`/hl`, `/kb`, `/esc`, `/audit`, `/log`, `/train`, `/draft`, `/web`, `/assist`, `/sales`, `/menu`, `/flush`, `/switch`, `/kyocera-research`) instead of the literal folder name. Previously only `switch` and `kyocera-research` carried frontmatter. See the 2026-09-01 section at the bottom of this file.
- Mode toggle system (`.forge-mode`, `toggle-mode.bat`/`.sh`, launcher assembly logic) - built AND exercised 2026-08-28 QA session: FULL assembles all 10 skills, SALES assembles only the 2 shared [now **14** skills FULL / **6** shared SALES as of 2026-09-01 - see section at bottom], `.hermes.md` banner/menu swap correct, `hermes skills trust` + skin activation work, all artifacts gitignored. See QA notes below.
- `toggle-mode.bat`/`.sh` RESET option - built 2026-08-28 (`c023a62`) to match the README (`0d6ef80`). Third choice alongside FULL/SALES; requires typing `YES` (exact); wipes `.env`, `.forge-mode`, `.hermes.md`, `.hermes/skills/` back to first-use state, leaves tracked content alone. This is the `.env`-scrub-before-handoff mechanism `DEMO_PREP_BACKLOG.md` item 9 asked for. Tested in an isolated dir (all four targets wiped on YES, nothing wiped on `yes`/blank/other, `.env.example` + `skills-source/` untouched).

## Not yet built (do not invent content for these - flag and wait)
- `skills-source/shared/sales-assist/SKILL.md` real content - needs actual spec sheets/datasheets, curated and Blacksmith-approved, not written from general knowledge
- (2026-08-28: the six tsc-only placeholders above - hotline-ticket, assist-intake, escalation-packet, forge-audit, fault-logging, training-guide - plus web-navigator are now all built and placed from the full-skillset-v3 reissue handoff, commit `d414f81`. All 8 tsc-only skills + both shared skills now have real SKILL.md files on disk. Remaining unbuilt item is sales-assist's real FAQ content only.)
- (2026-09-01: the shared set grew from 2 to 6 - `sales-assist`, `web-navigator`, `switch`, `kyocera-research`, `flush`, `menu`. Total skill count is now **14** (8 tsc-only + 6 shared). `sales-assist`'s real FAQ content is still the only unbuilt item.)

## QA session (2026-08-28) - first real run of the built skills + mode toggle

Ran `launch-north-forge.bat` headless in FULL and SALES (audit report at
`audit/CLAUDE_CODE_LAST_AUDIT.md` from that session has the full command
output). Results:

- PASS - FULL assembly: `.hermes/skills/` builds all 10 (8 tsc-only +
  sales-assist + web-navigator); `.hermes.md` ~16,170 chars, correct FULL
  banner/menu, no stray markers.
  [2026-09-01: now 14 skills FULL; `.hermes.md` assembles to 19,101 chars -
  see section at bottom of this file.]
- PASS - SALES assembly: only the 2 shared skills; SALES banner + reject
  list; `/web` present, FULL-only commands absent.
  [2026-09-01: now 6 shared skills SALES; `.hermes.md` assembles to 19,096.]
- PASS - web-navigator URLs: 7 spot-checked (one per section group), all
  HTTP 200, all land where the skill says.
- ~~FINDING 1: the `audit` skill collided with Hermes's reserved
  `hermes skills audit` sub-action and was dropped from `hermes skills list`
  though it assembled/loaded.~~ FIXED 2026-08-28 (`8759d15`): renamed
  `skills-source/tsc-only/audit/` -> `forge-audit/` (content byte-identical),
  updated `.hermes.template.md` (inventory + router) and
  `mode-blocks/full-menu.md` pointer. User-facing `/audit` / `/chk`
  unchanged. Zone B placement from the Claude Project chat.
  - **CORRECTION 2026-08-29 (full-repo evaluation): this diagnosis was wrong
    and the rename did NOT fix the list-drop.** `forge-audit` still does not
    appear in `hermes skills list --source local` after a clean FULL rebuild
    (verified this session). Real cause, confirmed against engine source
    (`hermes-agent/tools/skills_guard.py`): the `skills-guard-v1` scanner rule
    `agent_config_mod` (regex `AGENTS\.md|CLAUDE\.md|\.cursorrules|\.clinerules`)
    flags any project skill whose `SKILL.md` contains the literal string
    `CLAUDE.md`. `forge-audit/SKILL.md` line 3 says "...a code-maintenance file
    such as CLAUDE.md is specifically requested". That one token -> verdict
    `dangerous` -> withheld from the list (still counts in `hermes skills
    trust`'s "N will load" and, per this repo's own docs, still assembles into
    a session). Proven this session: a copy of the skill with the `CLAUDE.md`
    token reworded scans `safe` and lists normally. The folder name (`audit`
    vs `forge-audit`) is irrelevant to this. FIX IS ZONE B - not made by Claude
    Code: reword `forge-audit/SKILL.md` line 3 to not contain the literal
    `CLAUDE.md`, then correct the "reserved sub-action name" explanation in
    `.hermes.template.md` L26, `README.md` L42, and the FINDING 1 text above.
- ~~FINDING 2: the launchers only checked that `.env` EXISTS, not that
  `ANTHROPIC_API_KEY` was real - a placeholder passed and dropped the user
  into a session that couldn't call a model.~~ FIXED 2026-08-28 (`8759d15`):
  `launch-north-forge.bat` and `.sh` now also reject a missing or
  under-30-char key and reopen the editor with a clear message. Zone A fix.

STILL BLOCKED - QA parts 2 and 4 (exercise each mode live; observe
`decisive_assistant_rule` live): Finding 2 is the reason. This specific fresh
drive has no real Anthropic API key - the repo `.env` holds only the ~13-char
placeholder and Hermes's own `.env` is empty, so `hermes doctor` reports the
`anthropic` provider has no key and can't verify the API. **Kenneth needs to
put a real (spend-capped) Anthropic key on this drive** before the live
mode-exercise can run. After that: either run the 9 modes interactively and
paste transcripts, or (with an explicit spend go-ahead) drive them with
`hermes chat -q "..." -Q --max-turns 3 --run-budget 120` per mode.

Zone B follow-up flagged, not changed: `README.md` L37 still lists the
tsc-only skills as "placeholders" and now also carries the old `audit` name
- a Claude Project chat handoff should refresh that inventory line.

## Also outstanding
- ~~Upload `KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html` into this repo's root~~ - DONE: file is present at the repo root and tracked in git (commit `e7beb1f`). Confirmed 2026-08-26 audit.
- Decide whether `CLAUDE.md` (for Claude Code, same working directory) should mirror `.hermes.template.md`'s output or stay separate
- ~~Confirm `kwalker7631/north-forge-agent` is a registered GitHub fork of NousResearch/hermes-agent so `gh repo sync` works for engine updates~~ - DONE: verified via `gh repo view` on 2026-08-26 - `isFork: true`, parent `NousResearch/hermes-agent`, default branch `main`. `gh repo sync` path is valid.
- Live-test the /flush + memory-scrubbing interaction described in the Hermes addendum - this hasn't been run against Hermes's actual memory writes yet, only specified
- ~~Live-test the mode toggle end to end~~ - DONE: confirmed the launcher correctly builds separate FULL/SALES skill sets. Folder-name bug found and fixed (was `skills/`, corrected to `.hermes/skills/` after reading actual source); trust gate found and auto-approval added to the launcher.
- Decide how FULL-mode drives (TSC) vs. SALES-mode drives (reps) actually get distributed/built - e.g. does Kenneth set `.forge-mode` once per physical drive before handing it out, or is there a simpler batch process for provisioning many drives at once
- If/when local Llama (via Docker) gets wired in as a provider option: confirm the container's endpoint, port, and model name, and decide whether a large reference-docs folder for PDF research lives on the drive outside the git repo (large binaries don't belong in git)
- Confirm a real `/kb` draft actually renders correctly now that the locked HTML template has been added to the repo root
- `fallback/NORTH_FORGE_v21.8_PASTE_VERSION.md` added (2026-08-26) - complete standalone paste-in version for disaster recovery. Keep it manually in sync with `.hermes.template.md`/`skills-source/` when either changes; nothing auto-generates one from the other.
- ~~AUDIT 2026-08-26 (pre-flight): `/draft` ("Draft Writer") is referenced in `.hermes.template.md`'s `assistant_router_rule` and listed in `mode-blocks/full-menu.md`, but has no entry in "Not yet built" above, no `skills-source/` folder or placeholder.~~ - RESOLVED 2026-08-28: `skills-source/tsc-only/draft-writer/SKILL.md` placed from a Claude Project chat handoff (see "Done" above). The launcher's `skills-source/tsc-only/.` copy step picks it up in FULL mode alongside `kb-builder`; SALES drives already reject `/draft` via `mode-blocks/sales-menu.md`. FULLY RESOLVED 2026-08-28 by the full-skillset-v3 reissue handoff (commit `d414f81`), which carried the template/menu wiring alongside the six skill files: (A1) `full-menu.md` `/draft` line now has `(see .hermes/skills/draft-writer)`, and a `/web` entry was added to both `full-menu.md` and `sales-menu.md`; (A2) `.hermes.template.md` L26 inventory now lists all 8 tsc-only skills + `sales-assist` + `web-navigator` as built; (A3) L28 rewritten - no longer calls anything a placeholder, kept as a forward-looking safety net; (A4) L70 router line now reads "run Draft Writer (read .hermes/skills/draft-writer in full)"; (A5) new router entries added for hotline-ticket (L66) and escalation-packet (L68); (A6) CLOSED 2026-08-28 (commit `07b1343`): a follow-up `.hermes.template.md` handoff added `(read .hermes/skills/assist-intake in full)` to both Assistant router lines in `<assistant_router_rule>`, matching every other mode's citation pattern; (A7) all six "placeholder" skills now have real `SKILL.md` files on disk. Nothing from Finding A remains open.
- ~~AUDIT 2026-08-26 / 2026-08-28 (Finding B): the default mode is `/assist`, whose skill `assist-intake` was an unbuilt placeholder; and `.hermes.template.md` L7/L50 named `/assist` as the default unconditionally, even on SALES drives that reject it.~~ - FULLY RESOLVED 2026-08-28 (commit `d414f81`): `skills-source/tsc-only/assist-intake/SKILL.md` now exists with real content (intake set, depth levels, evidence packs); L7 is now "DEFAULT MODE: see mode banner below - /assist on FULL drives, /sales on SALES drives" and L50 is likewise mode-aware. Nothing from Finding B remains open. (Prioritization note now moot: all six skills were built together, not one-at-a-time.)

## Full repository evaluation (2026-08-29) - Claude Code

Comprehensive pass ahead of Kenneth's own drive test. Every tracked file
read; both launchers exercised in isolated dirs; git history re-scanned;
`hermes` state re-checked. Full detail in `audit/CLAUDE_CODE_LAST_AUDIT.md`.

### Zone A fixes made this session (committed)
- `.gitignore` - added `/skills/` (root-anchored). The legacy wrong folder
  name was NOT excluded before; `git check-ignore` confirmed `skills/old.md`
  would have been tracked. `skills-source/` is unaffected.
- `provision-new-drive.ps1` - the placeholder-token STOP message had a
  word-drop from commit `aed82d7` ("Before handing this" then "the line that
  sets cloneUrl..."). Restored to a readable sentence. `Write-Host` strings
  only; guard logic unchanged; PowerShell parse clean.
- `toggle-mode.bat` L6-7 - `else (echo (none set - defaults to SALES)` with a
  dangling `)` on the next line printed `(none set - defaults to SALES`
  (missing close paren) on a first run with no `.forge-mode`. Collapsed to
  one line with escaped parens. Re-tested 7 cases (FULL/SALES/bogus/RESET x4)
  - all exit 0, no parse errors, RESET still wipes exactly the 4 targets.

### Zone B / Zone C findings (all three RESOLVED 2026-08-29 - see below)
- **forge-audit list-drop misdiagnosis** - see the CORRECTION under QA
  FINDING 1 above. Headline item. Real cause is the literal `CLAUDE.md`
  token in `forge-audit/SKILL.md` line 3 tripping Hermes's `skills-guard`
  `agent_config_mod` rule; the `audit/`->`forge-audit/` rename did not fix
  it. Needed a Zone B reword of that one line + a docs correction in
  `.hermes.template.md` L26 and `README.md` L42. **RESOLVED - real-fix
  handoff placed and verified, see "Real-fix placement" below.**
- **`skills-source/shared/sales-assist/SKILL.md` has no "Never rewrite this
  skill file" self-lock line** - the other 9 skill files all do. It is a
  placeholder, but the line should be added when its real content is authored
  (Zone B). **RESOLVED - line added in the same handoff (`a49580f`).**
- **web-navigator has no `assistant_router_rule` entry** in
  `.hermes.template.md` - it is the only skill with a `full-menu.md` line
  (`/web or /links`, present and correct in both menu files) but no router
  paragraph. Per commit `d414f81` this was deliberate (menu-only), and the
  skill's own trigger covers it, so this is a consistency note, not a break.
  **RESOLVED - explicit web-navigator router entry added in `a49580f`.**
- DEMO_PREP_BACKLOG item numbering is out of sequence (1,2,3,7,4,5,6,8,11,9,10).
  Cosmetic; left as-is to avoid breaking cross-references.

### Re-verified clean
- Every tracked file maps to a Zone A/B/C list - nothing unzoned.
- Assembled context (recomputed): **FULL 16,526 chars, SALES 16,520** at the
  time of the evaluation - then **FULL 17,209 / SALES 17,203** after the
  2026-08-29 real-fix correction text (see "Real-fix placement" below); both
  well under the 20,000 limit; zero unreplaced `{{...}}`; zero non-ASCII in
  the template, the mode-blocks, or in fact any tracked file. (Supersedes the
  earlier "16,076 / ~16,170" QA numbers.)
- `.gitignore` (post-fix) excludes `.env`, `.forge-mode`, `.hermes.md`,
  `.hermes/`, `.claude/`, and now `skills/` - all confirmed with
  `git check-ignore -v`.
- Full-history secret scan (`sk-ant-`, `ghp_`, `github_pat_`, `AKIA`): clean;
  only textual mentions of the pattern names in these docs.
- Repo visibility: PRIVATE (`gh repo view`).
- KYO KB HTML locked contact block: portal URL, downloads URL, TSC phone
  `1-800-255-6482`, TSC email, authorized-login note, `SUPPORT & RESOURCES`
  markers, 128x64 logo slot - all present; no `<script>`; well-formed.
- toggle-mode RESET (both scripts) deletes exactly `.env`, `.forge-mode`,
  `.hermes.md`, `.hermes/skills/` - matches README; FULL/SALES behaviour is
  byte-identical to pre-`c023a62` (confirmed via `git show`).

### For Kenneth's first real launch to confirm
- The live `.hermes/skills/` and `.hermes.md` were regenerated this session
  (FULL) so the drive is consistent; before that, `.hermes.md` was stale
  (pre-`forge-audit` rename). A normal `launch-north-forge` run rebuilds
  both anyway.
- With a real Anthropic key in place: exercise each mode live (QA parts 2/4,
  still blocked on the key).

### Real-fix placement + live verification (2026-08-29, commit `a49580f`)

Zone B handoff from the Claude Project chat - 4 files placed byte-for-byte
(`forge-audit/SKILL.md`, `sales-assist/SKILL.md`, `.hermes.template.md`,
`README.md`), not composed by Claude Code. Addresses all three findings
above.

- **Finding 1 - THE REAL FIX, now VERIFIED against a live list** (the thing
  the first `audit/`->`forge-audit/` rename never did before being declared
  done):
  - `forge-audit/SKILL.md` line 3 no longer contains the literal string
    `CLAUDE.md` ("a code-maintenance file such as CLAUDE.md" -> "a
    code-maintenance or agent-configuration file"). `grep -rn "CLAUDE.md"
    skills-source/` -> **0 hits**.
  - Rebuilt `.hermes/skills/` for FULL, ran `hermes skills trust .`, ran
    `hermes skills list --source local` -> **10 local skills, all enabled,
    `forge-audit` now listed** (was 9, `forge-audit` hidden). `skills-guard`
    scan cache for `forge-audit`: verdict `safe`, `rules=[]` (was
    `dangerous` / `agent_config_mod`).
  - `.hermes.template.md` L26 and `README.md` L42 now carry a CORRECTION
    note describing the real `skills-guard` "CLAUDE.md" cause instead of the
    wrong "reserved sub-action name collision" story.
  - Still not observed: `/audit` loading in an actual live session (needs
    the API key, same block as QA parts 2/4). The list now shows it, which
    was the specific broken symptom.
- **Finding 2** - `sales-assist/SKILL.md` now has the standard "Never
  rewrite this skill file..." self-lock line (all 10 skill files now carry
  it).
- **Finding 3** - `.hermes.template.md` `<assistant_router_rule>` now has an
  explicit web-navigator entry after escalation-packet, matching every
  other mode's `(read .hermes/skills/X in full)` pattern.
- Assembled context after the correction text: **FULL 17,209 chars, SALES
  17,203** (matches the handoff's estimate; ~2,795 under the 20,000 limit).
  Zero unreplaced `{{...}}`; all 4 placed files pure ASCII.

## Blacksmith decisions (2026-08-29) - two open audit items closed

Kenneth relayed these in-session after reviewing the last two audit reports
(the `cfd618d` onboarding + custom-agent-name handoff, audit `59c6d13`; and
the `5911c7d` CLAUDE.md STANDING RULE placement, audit `a72c1df`). Status
update only - no code or content change was needed for either.

1. **`.gitignore` `/skills/` guard - INTENTIONALLY KEPT.** The
   onboarding-naming handoff's `.gitignore` was cut from a pre-`8e1eb69` base
   and dropped the root-anchored `/skills/` legacy-folder guard;
   Claude Code re-appended it verbatim when placing (commit `cfd618d`), so
   the net change there was `+.agent-name` only. Blacksmith decision: the
   re-append was correct, the `/skills/` guard stays. No further action;
   future `.gitignore` handoffs should carry it.
2. **`toggle-mode.sh` RESET-stripping working-tree edit - CLOSED as a
   one-time anomaly.** At the start of the `cfd618d` session `git status`
   showed `toggle-mode.sh` modified with the whole RESET branch deleted - not
   from any handoff zip or instruction. Claude Code reverted it
   (`git checkout -- toggle-mode.sh`, not committed); RESET is intact and
   consistent with `toggle-mode.bat` and the README. Blacksmith decision:
   correctly caught and reverted, no recurrence, not being investigated
   further. Closed.

Other carry-over flags from those two audits are unchanged by this update and
remain open: the `launch-north-forge.bat` vs `.sh` `.hermes.md` CRLF byte
divergence on `core.autocrlf=true` machines; `launch-north-forge.bat` not yet
run end-to-end; no live model session against the current
`.hermes.template.md` (blocked on a real Anthropic key on this drive, same as
QA parts 2/4).

## Drift audit vs v21.8 OneDrive source package (2026-08-29) - PASS WITH EXCEPTIONS

Kenneth supplied the 12-file v21.8 source package (OneDrive,
`KB_PROJECT_2026/FORGE SYSTEM - NORTH FORGE - KYOCERA EDITION - v21.8/`) and
asked for a repo drift audit. Full findings in
`audit/CLAUDE_CODE_LAST_AUDIT.md`. Nothing was changed - all four findings
target Zone B / locked skill files and await Blacksmith sign-off.

Passed: EDIT_9 flush/clear rule (incl. hard-reset clause + /log hook),
EDIT_10 (Mermaid mandatory, firmware unconditional, QA source-image
flagging), EDIT_11 writing standards (all five bullets), Contact Block Lock
byte-identical, fault-report block field-for-field, skills-source in sync
with live .hermes/skills, CLAUDE.md and command-menu deltas confirmed
by-design.

Open items awaiting Blacksmith approval:
1. [Medium/Template] Repo `KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html`
   header comments still say "v21.5" pairing (2 lines); source says v21.8.
   Body/contact block identical. Fix = update 2 header lines (Zone B).
2. [Medium/Context Handoff] EDIT_11's PRIMARY SOURCE FORMAT block (HL Case
   Details + Knowledge Details export pair as standard /kb input; QA/SB
   supplementary; note missing case export in Deep Search Notes) is in the
   source master (L928) and repo fallback paste version, but absent from
   kb-builder SKILL.md (live + skills-source). Fix = add block (locked
   skill, needs sign-off).
3. [Low/Output Contract] "Do not ask the user to select research, Mermaid,
   multimedia... separately" line in master + fallback, absent from
   kb-builder skill. Fold in with item 2.
4. [Note/Template, source-side] Both template copies' firmware-box
   placeholder still says "[ONE OR TWO SENTENCES...]" while EDIT_10 allows
   2-3 bullets. Not repo drift - source-package decision for a future
   v12.12 template rev.

## 14-skill completion + frontmatter pass (2026-09-01) - COMPLETE-fix handoff placed

Handoff `north-forge-hermes-COMPLETE-fix.zip` (Claude Project chat, via
Kenneth in-session) placed and committed. It replaces all of `skills-source/`
plus `.hermes.template.md`, `mode-blocks/full-menu.md`,
`mode-blocks/sales-menu.md`. Full detail in
`audit/CLAUDE_CODE_LAST_AUDIT.md`. This closes every open item from the
previous audit's Findings 1-5.

What changed:
- **Skill count 10 -> 14.** New shared skills `flush` (registers `/flush`,
  soft reset) and `menu` (registers `/menu`). Set is now 8 tsc-only + 6
  shared. This resolves prior Findings 1 (menu/flush referenced everywhere
  but absent) and 3 ("14 skills" was unreachable).
- **YAML frontmatter on all 14.** Every SKILL.md now opens with
  `name:` / `description:`. Registered commands: `/hl` `/kb` `/esc` `/audit`
  `/log` `/train` `/draft` `/web` `/assist` `/sales` `/menu` `/flush`
  `/switch` `/kyocera-research`. All 14 `name:` values are unique, parse
  clean under PyYAML, and match the folder's intended command. Resolves
  prior Finding 2 (only 2 of 12 had frontmatter).
- **`.hermes.template.md`** - one line changed: `<hermes_specific_addendum>`
  item 3 now reads "MEMORY MUST RESPECT /FLUSH AND /SWITCH ... Never /clear
  or /reset for this - see flush_clear_rule" (was "/flush or /clear").
  Resolves prior Finding 4 (the file contradicted its own `flush_clear_rule`
  ban on `/clear`).
- **`sales-assist/SKILL.md`** - frontmatter added above the existing body;
  its self-lock line (added in `a49580f`) is untouched. Prior Finding 5
  (no self-lock line) was already resolved; still true here.
- **`mode-blocks/full-menu.md` / `sales-menu.md`** - byte-identical to what
  was already committed at `1c66ab8`; re-bundled, no change.

STANDING RULE diff-vs-HEAD: clean. No previously-recorded deliberate fix is
reverted. Specifically preserved: `forge-audit/SKILL.md` has no literal
`CLAUDE.md` token (the real `a49580f` skills-guard fix); the web-navigator
`<assistant_router_rule>` entry and the `flush_clear_rule` /flush-vs-/switch
split both stay intact in the template.

Assembled `.hermes.md` (template + banner + menu; skills are separate files,
not concatenated): **FULL 19,101 chars / SALES 19,096 chars** (LF). Zero
unreplaced `{{...}}` markers, zero non-ASCII. On a native Windows launch the
Python writes CRLF: 19,271 / 19,258 bytes.

**MARGIN WARNING (flag for the next content change):** headroom against the
20,000-char context-file ceiling is now only ~900 chars (899 FULL / 904
SALES on LF; 729 / 742 on CRLF). Any further template, banner, or menu
growth needs to budget against this - the assembled file is close to the
limit and there is no automated guard on it.

Not exercised this session (deferred, per Kenneth's instruction to commit
before the AppData flush + fresh repull): a live `hermes skills list`
re-registration against the 14-skill set, and any live model run. Kenneth's
post-commit fresh launch is what exercises those.
