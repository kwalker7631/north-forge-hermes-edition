# Handoff: Claude Code session 2026-09-04 (Hermes/DIRK drive session)

Audience: the Claude AI running Kenneth's GPT (Claude Project chat). This is
a complete change log of what Claude Code committed this session, why, and
what it means for Zone B bookkeeping on your side. Everything here was done
at Kenneth's explicit direction in-session ("Fix it all"), including two
locked-skill edits he authorized as Blacksmith.

## Context: what happened before the fixes

1. The two cron jobs (nightly-kyocera-research, daily-kyocera-brief) were
   inspected live for the first time. Neither had ever fired.
2. Kenneth approved rescheduling nightly-kyocera-research from "every 1440m"
   (anchored to creation time -> drifted to ~2 PM runs) to cron "0 6 * * *"
   (fixed 6:00 AM, two hours before the 8 AM brief so the brief reads fresh
   findings). Applied to the LIVE cron store via cronjob update.
3. The research job was manually fired as a shakedown. Result: SUCCESS.
   First run created and committed research-log/kyocera-research-log.md
   (commit a801cb8) with 5 properly classified findings. The classification
   discipline (Confirmed/Strong Clue/Unverified Field Note) held.
4. The run reported two Reddit sources it could not retrieve (bot-walled,
   no browser fallback). Fixed: `npx agent-browser install --with-deps`
   run on this machine - Chrome 152 was already present, now registered.
   Future research passes can corroborate bot-walled forum threads.
5. Kenneth asked for a plain-English end-user manual; USER_MANUAL.md was
   authored and committed (3418ca9). See below - it is now also wired to
   a new /manual skill.

## Changes in this commit set

### Zone A (launchers, README, new docs - Claude Code authority)

1. launch-north-forge.bat + launch-north-forge.sh - cron re-add schedule
   corrected from "every 24h" to "0 6 * * *" for nightly-kyocera-research.
   WHY: the self-healing re-add block would have recreated the OLD drifting
   schedule after any AppData flush, silently undoing the live fix from
   this session. This was a latent bug created the moment the live job was
   rescheduled. The daily-brief line ("0 8 * * *") was already correct.

2. launch-north-forge.bat + .sh - NEW assembled-size guard. The assembly
   step now measures the final .hermes.md: >= 20,000 chars = FATAL, abort
   launch with a plain message (Hermes silently drops the middle of an
   oversized context file - a guard was explicitly requested in
   NEXT_STEPS.md's MARGIN WARNING); >= 19,800 = loud warning, launch
   continues. Verified: bash -n clean, .bat paren balance 0, guard logic
   exercised standalone (passes at current sizes).

3. README.md file-tree - added entries for USER_MANUAL.md, research-log/
   (kyocera-research-log.md + daily-brief-log.md), marked as tracked paths
   on purpose. Closes the 2026-09-04 open item.

4. USER_MANUAL.md (committed earlier this session as 3418ca9, extended in
   this commit set) - plain-English manual: every command with its ONE
   real slash form + plain-word alternates, an "After:" next-step line per
   command (decisive_assistant_rule applied to paper), the /clear-/reset
   danger section, FULL vs SALES, the two cron jobs, installed-skill list
   + how to verify live, add-a-skill walkthrough (including the
   skills-guard literal-filename trap), troubleshooting, cheat sheet.
   Extended this commit set: /manual command entry, skill counts 15 -> 16,
   SALES command list updated.

### Zone B (locked/authored content - Kenneth authorized in-session)

5. skills-source/shared/kyocera-research/SKILL.md - setup note's /cron add
   line corrected to "0 6 * * *", with a dated Blacksmith-approval note
   explaining the drift problem. Matches the live job and the launchers.

6. skills-source/tsc-only/kb-builder/SKILL.md - closed drift-audit items
   2+3 from the 2026-08-29 v21.8 OneDrive drift audit (both were "awaiting
   Blacksmith approval"; Kenneth's "fix it all" covers them):
   - Added the PRIMARY SOURCE FORMAT block (HL Case Details + Knowledge
     Details export pair as standard input; QA/SB supplementary; note
     missing case export in Deep Search Notes). Text taken verbatim from
     fallback/NORTH_FORGE_v21.8_PASTE_VERSION.md L958-959, not composed.
   - Added the "Do not ask the user to select research, Mermaid,
     multimedia, image prompts, video prompts, META, or audit separately"
     line (from L956 of the same source).

7. KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html - closed drift-audit item
   1: header "v21.5" -> "v21.8" on lines 2-3 AND line 19 (the audit
   counted 2 lines; line 19's TEMPLATE LOCK RULE carried the same stale
   version - same drift class, fixed together). Body/contact block
   untouched - verify with git diff if desired: 3 comment lines only.

8. NEW SKILL: skills-source/shared/manual/SKILL.md (name: manual ->
   registers /manual). Thin routing skill in the menu/flush pattern:
   answers "how do I use this system" questions by reading USER_MANUAL.md,
   answers only what was asked, never contradicts the manual from memory,
   always repeats the /flush-vs-/clear rule when resets come up. Carries
   the standard self-lock line. Skill count is now 16 (8 tsc-only +
   8 shared). Both mode menus (mode-blocks/full-menu.md, sales-menu.md)
   gained a /manual line. Copied into live .hermes/skills/ alongside the
   two edited skills so the running drive is consistent pre-relaunch.

### Not done / for your side to track

- .hermes.template.md was NOT touched. The command_menu section inside it
  is assembled from mode-blocks/, so /manual appears via the menu blocks.
  But the <how_this_package_is_organized> paragraph in the template still
  enumerates the shared skills WITHOUT `manual` - a one-phrase Zone B
  template edit for your next handoff (budget: assembled size is now
  FULL 18,579 / SALES 18,574 with the /manual menu lines included, so
  ~1,420 chars headroom - the old "789 headroom" figure in NEXT_STEPS
  predates this measurement).
- fallback/NORTH_FORGE_v21.8_PASTE_VERSION.md was NOT updated to mention
  /manual or the 6 AM schedule (manual-sync-by-design file, your call).
- Drift-audit item 4 (firmware-box placeholder wording) remains a
  source-package decision for a future v12.12 template rev - untouched.
- sales-assist real FAQ content - still the only unbuilt skill content.
- Live-mode QA (parts 2/4): the API-key block is GONE (proven by the
  successful cron run this session). Ready to run whenever Kenneth wants.

## Verification performed

- bash -n launch-north-forge.sh: clean.
- launch-north-forge.bat paren balance: 0.
- Size-guard Python exercised standalone against real template+blocks.
- Assembled sizes recomputed post-menu-change: FULL 18,579 / SALES 18,574.
- manual/SKILL.md frontmatter parses (name: manual, unique across all 16).
- Live cron store confirmed: job f3bbfe9c0d8f next_run 2026-09-05 06:00,
  b99661dc930b next_run 2026-09-05 08:00, both enabled.
- research-log/kyocera-research-log.md: 34 lines, committed a801cb8.

## Addendum: first-run README auto-open (commit 443cbd6, pushed)

Executed exactly per the GPT-side Claude's own instruction relayed by
Kenneth (this one originated on YOUR side, so no surprises here):

- launch-north-forge.bat: .readme-shown guard + `start "" FIRST_TIME_README.txt`
  inserted immediately after `cd /d "%~dp0"` - before mode assembly, naming
  prompt, cron re-registration, and the hermes handoff.
- launch-north-forge.sh: xdg-open/open equivalent inserted immediately after
  SCRIPT_PATH is set, same relative position. If neither opener exists
  (headless Linux), it silently skips but still touches .readme-shown -
  acceptable per the provided snippet, flagging so it's a known behavior.
- .gitignore: .readme-shown added next to .forge-mode/.agent-name.

Pre-commit checks, all PASS: sh syntax clean (bash -n); bat parens balanced;
insertion-order verified programmatically in both files (readme block <
mode assembly < cron add < hermes handoff); .readme-shown and .env both
confirmed gitignored via git check-ignore; .env confirmed NOT tracked
(git ls-files: zero matches).

Push note: this push (d0bd80b..443cbd6) also carried the session's earlier
local-only commits to origin/main: a801cb8 (first research-log pass),
3418ca9 (USER_MANUAL.md), a1f7fa1 (the fix batch described above). Remote
is now fully in sync with this handoff document.

## Addendum 2: brand assets + Windows desktop icon (Zone A)

Kenneth supplied two images this session; both are now tracked under a new
assets/ folder:

- assets/north-forge-icon.png (512x512) - the anvil+flame North Forge app
  icon (Kyocera red flame, blue accent, dark rounded tile).
- assets/north-forge.ico - multi-size Windows icon (16-256px) generated
  from it with Pillow.
- assets/logo-kyocera-1024.png - official KYOCERA wordmark from
  Kyocera_Standards (512x512 canvas, transparent).
- assets/logo-kyocera-128x64.png - content-cropped, centered 128x64
  render, sized for the KB template's contact-block logo slot (the
  template's 128x64 placeholder). NOTE for your side: actually wiring
  this image into the locked HTML template (replacing the logo
  placeholder) is a Zone B template decision - the asset is staged, the
  template is untouched.

launch-north-forge.bat gained a first-run block (right after the README
auto-open block): creates a "North Forge.lnk" on the user's Desktop
pointing at the launcher with the .ico icon - the Windows twin of the
Mac launcher's existing "North Forge.command" desktop icon. Skips
silently if the shortcut already exists. Verified live on this machine
(shortcut created, parens balanced). The .sh needed no change - its
desktop-icon block predates this.

## Addendum 3: vector master for the North Forge icon

Kenneth supplied north_forge_icon.svg - the vector source of the
anvil+flame icon. Committed as assets/north-forge-icon.svg. This is now
the icon's source of truth: any future size/format (favicon, print, a
different .ico size set) should be exported from the SVG, not upscaled
from the PNG. The previously committed PNG (512px) and multi-size .ico
are unchanged - they match this artwork.

## Addendum 4: kb-images/ intake folder (your-side instruction, executed)

Executed per the GPT-side instruction relayed by Kenneth. All items done:

- kb-images/ + kb-images/_pending/ created at repo root, with a short
  README.txt inside stating the staging-only rule and naming/scrubbing
  conventions; _pending/ held by .gitkeep.
- kb-builder SKILL.md (Zone B, per your instruction): new "Image file
  intake - kb-images/" section inserted directly after the multimedia
  selection section. Covers: KB-number vs _pending/ routing, sequence-
  prefixed scrubbed filenames, always-report-the-saved-path, the
  every-time manual review question (image-visible identifiers - tech
  decides, model only asks), and the explicit staging-only boundary
  (no HTML link generation/substitution; ServiceNow attach + manual
  placeholder replace unchanged). Media selection / prompt generation /
  placeholder text untouched. Live .hermes/skills/ copy synced.
- README.md file tree: kb-images/ entry added (same treatment as
  research-log/).
- Checks: kb-images NOT gitignored (an initial check-ignore hit was a
  false positive - git quirk querying a bare dir path against a blank
  CRLF line; definitive: check-ignore on the actual file = no match,
  git status lists kb-images/ as untracked ??). .env not staged, not
  tracked.
