# North Forge - Hermes Edition - Changelog

Plain-language running log of what actually changed and why. Distinct from `git log` (which needs git to read) and `audit/CLAUDE_CODE_LAST_AUDIT.md` (which is Claude Code's own session-to-session working notes, overwritten each session). This file is the human-readable history - what happened, in the order it happened, kept permanently.

## [Unreleased] - 2026-09-05

### Changed (later session, Claude Code)
- **Onboarding default switched from a hard Anthropic-key gate to zero-config OpenCode Free.** `launch-north-forge.bat`/`.sh` (both bumped 1.0.0 -> 1.1.0) now ask once, on first launch, whether to start free (OpenCode Free - no account, no key, no payment method, configured via `hermes config set model.provider opencode-free` + `hermes config unset model.default`, which Hermes's own fallback logic auto-resolves to a real working free model at runtime) or to opt in to a personal Anthropic API key (`OWNKEY`) for the existing pay-per-token flow. The choice is remembered in `.provider-choice` (same pattern as `.agent-name`/`.drive-record.txt`) and not re-asked. `.env.example` (bumped 1.0.0 -> 1.1.0) rewritten to match: ANTHROPIC_API_KEY reframed as optional/opt-in, OpenCode Free noted as the zero-cost default, plus an explicit warning against picking a premium/credits-gated model (Fable, Mythos) without understanding it needs a separate purchased credits balance. Verified empirically: both branches tested end-to-end against an isolated scratch `HERMES_HOME`, including confirming `get_default_model_for_provider("opencode-free")` resolves to a real model (`deepseek-v4-flash-free`) with no manual model ID hardcoded into the scripts. Requested by Kenneth directly, following a recon session that found the previous hard gate had no free path at all and that the credits-gated `claude-fable-5` model has no visible warning distinguishing it from ordinary metered models.
- **`toggle-mode.bat` / `machine-reset.bat` Script version bumped 1.0.0 -> 1.0.1** to reflect the `e342f7a` admin_gate password-bypass fix, which predated the 1.0.0 versioning baseline set in the prior session (that baseline was a fresh starting point, not a reconstruction of real prior history - see that session's audit for detail).

### Fixed (later session, Claude Code - independent Codex audit findings)
An independent adversarial audit (`audit/CODEX_SECOND_AUDIT_2026-09-05.md`, 1 HIGH/4 MEDIUM/2 LOW numbered findings) was pulled and each finding independently re-verified before fixing. All confirmed real; all fixed in Zone A files only:
- **`machine-reset.bat` full-purge target validation strengthened (HIGH, NF-CX-01).** `HERMES_DIR` (environment-controlled) previously only had to satisfy ONE of two weak markers (a `hermes-agent\` folder OR a `config.yaml` file - the latter a very common filename) to be accepted for `rmdir /s /q`, and relative/UNC/bare-drive-root paths were never rejected outright. Now requires an absolute drive path (verified via substring extraction, not `findstr /r` - an equivalent regex was tested standalone and found to error out as "Bad command line," which would have silently sent every legitimate path to the rejection branch) AND both markers together. Verified against 3 live scenarios via real console automation (a genuine Hermes-shaped folder deleted correctly, a folder with only `config.yaml` correctly refused, a relative path correctly refused).
- **RESET now wipes the 3 markers it was missing (MEDIUM, NF-CX-02).** `toggle-mode.sh`/`.bat` RESET deleted `.env`/`.forge-mode`/`.hermes.md`/`.drive-record.txt`/`.hermes/skills` but left `.provider-choice`, `.agent-name`, and `.readme-shown` behind - meaning the next drive holder inherited the prior holder's provider choice/assistant name and never saw the first-run welcome, contradicting RESET's own "clean first-use state" / "genuine first run" messaging. Now wipes all 8. Verified end-to-end on both scripts (real console automation for the `.bat`, direct stdin for the `.sh`).
- **Free-provider setup no longer records success on failure (MEDIUM, NF-CX-03).** `launch-north-forge.sh`/`.bat` wrote `.provider-choice=free` unconditionally, before checking whether `hermes config set/unset` actually succeeded - a total command failure (reproduced empirically by Codex with a fake `hermes` returning nonzero) was marked as success and never retried. Now `.provider-choice=free` is only written after `hermes config set model.provider opencode-free` genuinely succeeds; on failure it warns on-screen and falls back to the OWNKEY path instead. `unset model.default`'s own nonzero-when-already-absent case (the common, expected outcome) is told apart from a genuine failure by its output text rather than misreported as an error. Verified via isolated logic unit tests (bash function mocks / batch label mocks - deliberately not a live fake-`hermes`-on-PATH test, since that technique proved unreliable and unsafe: see "Uncertain / flagged" in this session's audit).
- **Skill-copy failures no longer silent (MEDIUM, NF-CX-04).** Both launchers suppressed every `cp`/`xcopy` error when building `.hermes/skills/` from `skills-source/`, then trusted and ran on whatever partial result came out. Now a copy failure aborts the launch with a clear FATAL message instead of silently running on an incomplete/empty skill set. Verified: an intentionally-missing `skills-source/` now aborts loudly; a normal checkout still assembles correctly.
- **Drive-record and assistant-name input sanitized (MEDIUM, NF-CX-05).** Typed text went straight into `forge-events.log`'s bracketed-field format unescaped - Codex demonstrated entering `Mallory ] [FAILURE] [admin-gate]: forged PASS` as a drive name and having it reproduced verbatim as a fabricated log line. Both launchers now strip control bytes (bash) and `[`/`]` (both languages) and cap length at 60 chars on the drive-record name and the assistant name before they reach the log or the generated `.hermes.md` context. Does not fully resolve the separate governance question Codex raised (an unrestricted assistant name is effectively free-text injected into the system prompt) - flagged for Kenneth, not decided unilaterally.
- **Cron scheduling failures now shown on-screen (LOW, NF-CX-06).** Previously logged only to `forge-events.log`, which a field tech is unlikely to ever open - a failed research/brief job registration could stay silently absent indefinitely. Both launchers now also print a plain on-screen warning.
- **`.gitignore` was missing `.provider-choice` (LOW, NF-CX-07).** The one per-drive state marker not in the per-drive ignore list, introduced with the Phase 2 onboarding rework and missed at the time. Added; verified with `git check-ignore`.
- **Additional, smaller fixes from the same audit:** WELCOME.html's first-run marker is now only written when the auto-open actually succeeds (both launchers), so a failed open retries on the next launch instead of never showing again; `provision-new-drive.ps1` now checks `$LASTEXITCODE` after `git pull`/`git clone` (native-exe failures don't throw under `$ErrorActionPreference = "Stop"`) instead of silently launching against a possibly-stale or half-cloned checkout.

Incident during this session, corrected immediately: an early verification attempt for NF-CX-03 tried to shadow the real `hermes` command with a fake on `PATH` from within a Bash session and, due to bash's command-hash caching not being invalidated by a mid-session `PATH` prepend, twice actually invoked the real `hermes` binary against Kenneth's live machine config instead of the intended fake - his `model.provider`/`model.default` were reverted back to `anthropic`/`claude-sonnet-4-6` (the Phase 1 setting from the prior session) immediately both times. All further verification for this and the other findings used either a real console process with `HERMES_HOME` explicitly isolated, or fully in-process function/label mocks with no external `hermes` invocation at all.

## [Unreleased] - 2026-09-04

### Added (later session, Claude Code)
- **Version/authorship headers added to every Zone A file** (`launch-north-forge.bat`/`.sh`, `toggle-mode.bat`/`.sh`, `machine-reset.bat`, `provision-new-drive.ps1`, `.env.example`, `skins/north-forge.yaml`, `.gitignore`): a standard comment block stating the file is part of the North Forge project (Kyocera Edition v21.8, the existing canonical release tag already used in `.hermes.template.md`/`fallback/`), a per-file script version (starting at 1.0.0 - no prior per-file versioning existed), an updated-date, and authorship: Kenneth C. Walker Jr. - Senior Technical Support Engineer, TSC. Requested by Kenneth directly.
- **Authorship/project-attribution line placed into 7 Zone B files** (`README.md`, `ATTRIBUTION.md`, `FIRST_TIME_README.txt`, `USER_MANUAL.md`, `.hermes.template.md`, `fallback/NORTH_FORGE_v21.8_PASTE_VERSION.md`, `KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html`): "North Forge - Hermes Edition (Kyocera Edition v21.8) is part of the North Forge project. Created and maintained by Kenneth C. Walker Jr. - Senior Technical Support Engineer, TSC." Claude Code did not compose this on its own initiative - CLAUDE.md's Zone B rule bars that even on a direct broad request - it was drafted, shown to Kenneth verbatim, and explicitly approved live in-session ("approve as-is, place it now") before placement, satisfying the Blacksmith hand-off exception. Added additively next to existing content in `.hermes.template.md` and the KYO_KB_TITAN header comment (both already carried a shorter "AUTHORSHIP: Kenneth Walker Jr. / TSC" line) rather than replacing it. `skills-source/**` and `mode-blocks/*` were intentionally left out - not part of the approved file list.
- **`USER_MANUAL.md`** - plain-English end-user manual: every command with its one real slash form, an explicit "what to do after" line per command, the /clear-and-/reset danger warning, FULL vs SALES differences, the scheduled research jobs, installed skills and how to verify them, and a step-by-step add-a-skill walkthrough. Written for the least technical person who ever gets handed a drive.
- **New `/manual` skill** (`skills-source/shared/manual/`) - answers "how do I use this system" questions by reading USER_MANUAL.md instead of improvising from memory. Skill count 15 -> 16 (8 tsc-only + 8 shared). Added to both mode menus.
- **Assembled-size guard in both launchers** - the `.hermes.md` assembly step now aborts the launch (with a plain message) if the assembled file reaches the 20,000-char ceiling Hermes silently truncates at, and warns loudly within 200 chars of it. Closes the standing MARGIN WARNING's "no automated guard" gap. Current sizes: FULL 18,579 / SALES 18,574.

### Fixed (later session, Claude Code)
- **Research job ran at ~2 PM instead of overnight.** The `nightly-kyocera-research` cron job used "every 24h", which anchors to whenever the job was created - so it drifted to mid-afternoon and fed the 8 AM daily brief ~18-hour-stale findings. Rescheduled the live job to fixed 6:00 AM, and corrected the same schedule in BOTH launchers' self-healing re-add blocks (which would otherwise have silently recreated the drifting schedule after any AppData flush) and in the kyocera-research skill's setup note (Blacksmith-approved locked-skill edit).
- **First-ever research pass executed successfully** (manual fire as a shakedown): created `research-log/kyocera-research-log.md` with 5 classified findings, committed. Also installed the browser fallback (`npx agent-browser install --with-deps`) so future passes can corroborate bot-walled forum sources instead of leaving them stuck at Unverified.
- **KB template header version drift**: `KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html` comment headers said "v21.5" in three places (lines 2-3 and the TEMPLATE LOCK RULE line); now "v21.8". Body and contact block untouched. (Drift-audit item 1, Blacksmith-approved.)
- **kb-builder skill was missing two blocks present in the v21.8 master**: the PRIMARY SOURCE FORMAT block (HL Case Details + Knowledge Details export pair as the standard /kb input) and the "do not ask the user to select research/Mermaid/multimedia/META separately" rule. Both added verbatim from the fallback paste version. (Drift-audit items 2+3, Blacksmith-approved.)
- **README file tree** now lists `USER_MANUAL.md` and `research-log/` as real tracked paths.

Full detail for the GPT-side Claude: `audit/HANDOFF_2026-09-04_SESSION_CHANGES.md`.

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
