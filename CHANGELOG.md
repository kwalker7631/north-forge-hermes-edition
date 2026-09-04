# North Forge - Hermes Edition - Changelog

Plain-language running log of what actually changed and why. Distinct from `git log` (which needs git to read) and `audit/CLAUDE_CODE_LAST_AUDIT.md` (which is Claude Code's own session-to-session working notes, overwritten each session). This file is the human-readable history - what happened, in the order it happened, kept permanently.

## [Unreleased] - 2026-09-04

### Fixed
- **Ghost-text contrast (`banner_dim`)**: `skins/north-forge.yaml` line 46
  changed from `#282828` (near-black) to `#888888` (medium gray). The
  near-black value was carried over from the KB visual standard, which
  targets printed documents on a white background — reused as-is for the
  terminal's dim/hint text, it was effectively invisible against a black
  terminal background. Fixed as a single-line value change; inline comment
  updated to match. Commit `91b6e39`, pushed to `main`
  (`692414d..91b6e39`). Verified still present and unreverted in the
  2026-09-04 integrity audit.

### Audited
- Full integrity audit run (git fsck, orphan/gap check, skill frontmatter
  check, CLAUDE.md zone consistency check). No orphaned files, no dangling
  git objects, no zero-byte/truncated files, no drift in Zone A/B/C
  boundaries. One real gap found: see Known open items below. Full report:
  `audit/CLAUDE_CODE_LAST_AUDIT.md`.

### Known open items carried forward
- **`research-log/` not in `.gitignore`**: three files (`.hermes.template.md`,
  `kyocera-research` skill, `daily-brief` skill) write to `research-log/`,
  but the folder isn't yet gitignored or documented as intentionally
  committed. Decision: treat as a real, committed, KB-relevant record (not
  throwaway runtime state) — matches how `.hermes.template.md` already
  treats it as consultable field knowledge. Action needed: do NOT add to
  `.gitignore`; instead add `research-log/` to README's file-tree section
  as a real tracked path, and commit its contents once either cron job
  produces output for the first time.
- **"4279 commits behind" banner — unresolved.** Every git/GitHub state
  connected to this project (this repo's `main` vs `origin/main`, the
  Hermes engine's own install vs its upstream, the mirror fork vs
  NousResearch upstream) checked out at 0 ahead / 0 behind. The literal
  string "commits behind" does not appear anywhere in this repo or the
  local Hermes engine install. Not reproduced, not explained. Needs a
  screenshot or raw copy-paste of the actual banner next time it appears
  before it can be traced further.

## 2026-09-03

- **Fixed: slash commands (`/hl`, `/kb`, `/menu`, etc.) didn't work at all.** Root cause: Hermes only registers a skill as a real slash command if its `SKILL.md` declares a `name:` field in YAML frontmatter - without it, Hermes falls back to the literal folder name (`hotline-ticket`, not `hl`), and any command that doesn't match gets rejected before the model ever sees it. Added frontmatter to all skills; added two new skills (`menu`, `flush`) that didn't exist as real commands at all before this.
- **Fixed: `/clear` and `/reset` are dangerous, not just unavailable.** Both are real, native Hermes commands (wipe the whole session / start fresh) that happen to collide with words we'd used for something much softer. Renamed our commands to `/flush` (soft reset, stays in mode) and `/switch` (hard reset, returns to menu) - matching the same two-behavior split the original paste-in-GPT project independently arrived at.
- **Added:** `daily-brief` and `kyocera-research` skills - scheduled research/digest tasks. Both now self-schedule automatically at every launch (checks `hermes cron list`, adds itself if missing) - no manual `/cron add` ever needed again, and it survives an AppData flush.
- **Added:** `machine-reset.bat` - rotate just the API key, or fully purge this machine's Hermes state, separate from the drive's own `toggle-mode` RESET.
- **Added:** interactive first-launch naming prompt - give the assistant a personal name right at first launch, instead of needing to know a hidden `.agent-name` file exists.
- **Fixed:** the terminal banner showed stock Hermes branding (title text, and a Hermes-staff icon) instead of anything North Forge specific - both required an explicit skin field (`banner_logo`, `banner_hero`) that was never set. Now a real "NORTH FORGE" title and an anvil+flame mark, both Braille-art converted from real generated images, not hand-typed.
- **Fixed:** the ghost-text/ghost-suggestion color at the terminal prompt was nearly unreadable (a value tuned for printed KB documents on white paper, wrongly reused for terminal text on a black background).

## 2026-08-28 to 2026-08-29

- Initial Hermes Edition build: ported the full North Forge v21.8 ruleset (persona, router, KB-builder, evidence-collection, escalation, fault-logging) from the original paste-in-anywhere project into skill files Hermes can load.
- Built the provisioning flow: `provision-new-drive.ps1` (format guard, token check, clone), `launch-north-forge.bat`/`.sh` (install-if-missing, key validation, skin activation), `toggle-mode.bat`/`.sh` (FULL/SALES/RESET).
- Established the CLAUDE.md Zone A/B/C governance model for how Claude Code and this chat hand work back and forth safely.
