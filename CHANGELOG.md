# North Forge - Hermes Edition - Changelog

Plain-language running log of what actually changed and why. Distinct from `git log` (which needs git to read) and `logs/CLAUDE_CODE_LAST_AUDIT.md` (which is Claude Code's own session-to-session working notes, overwritten each session). This file is the human-readable history - what happened, in the order it happened, kept permanently.

## [Unreleased] - 2026-09-14

### Renamed (Kenneth's direct decision, later the same day) - Excalibur / Round Table

**"Excalibur" now means the admin/designer's own elevated drive** (full tier,
Git, Pinokio, every edition switchable) - `F:\` (MAIN-NORTH) is the current
one. **The locked, teammate-handoff drive this project previously called
"Excalibur" is now "Round Table"** - nothing about what that drive *is*
changed, only its name. "The king wields Excalibur; everyone he hands a
build to sits at the Round Table."

- `Advanced/deploy-console/EXCALIBUR.md` / `EXCALIBUR_WALKTHROUGH.md` ->
  `git mv`'d to `ROUND-TABLE.md` / `ROUND-TABLE_WALKTHROUGH.md` (content
  unchanged in substance, terminology updated). A **new** `EXCALIBUR.md` was
  written describing the admin drive - what it is, `F:\`'s current
  (unprovisioned) status, and how to provision one via `nf-setup.ps1 -Tier
  full`, with an explicit, un-hedged note that the exact provisioning command
  for this checkout's specific sibling-repo layout has **not** been verified
  end-to-end yet.
- Renamed throughout: `scripts/pinokio_lab_target.py`'s `--excalibur-max-gb`
  CLI flag, `DEFAULT_EXCALIBUR_MAX_GB` constant, and all "Excalibur-class"
  language -> `--round-table-max-gb` / `DEFAULT_ROUND_TABLE_MAX_GB` /
  "Round-Table-class" (functional rename, not just prose - re-ran
  `tests/test_pinokio_lab_target.py` after: 14/15 pass, the 1 failure is a
  pre-existing environment-dependent flake unrelated to this change, assumes
  drive `Z:` exists on the test-running machine). Matching updates in
  `Zero-Touch-Deploy.ps1`, `exclude-profile-skills.ps1`,
  `Install-Pinokio-Lab.ps1`, `Advanced/PINOKIO.md`, both `pinokio/SKILL.md`
  copies (`skills/` and `skills-source/shared/`), and
  `tests/test_exclude_profile_skills.py`.
- Also fixed in the same pass: my own capacity-gate error/warn messages
  (added earlier today, see below) referenced `EXCALIBUR.md` for the 8/32 GB
  sizing guidance - now correctly point at `ROUND-TABLE.md`, since that
  guidance is about the teammate stick, not the admin drive.
- **Not touched**: genuinely historical entries elsewhere in this file and in
  `NEXT_STEPS.md` that narrate a specific past session's events using
  "Excalibur" in its old sense (e.g. "Kenneth used the real deployed `E:\`
  Excalibur drive tonight") - those describe what was true and named that way
  at the time, not the current system, and rewriting them would be
  revisionist. Only forward-facing docs/code, plus this session's own
  same-day entries, were updated.
- **Source of the original confusion, found while doing this rename**:
  `EXCALIBUR_WALKTHROUGH.md`'s old Step 3 called the real Anthropic API key
  "your own elevated key" in the context of the *locked teammate* build - a
  genuinely ambiguous phrase ("elevated" reads naturally as "admin-tier",
  not "a real/paid key tier") that plausibly caused exactly this mix-up.
  Reworded in the new walkthrough content to avoid the word "elevated"
  entirely in that context.

### Fixed (drive-letter migration cleanup - this checkout elevated to F:\ MAIN-NORTH)

- **`hermes` was completely broken on this machine** (`ModuleNotFoundError: No module
  named 'hermes_cli'` on every invocation) - root cause was in `north-forge-agent`, not
  this repo: its editable pip install's generated finder
  (`__editable___hermes_agent_0_21_0_finder.py` inside the `hermes-dev` venv) had every
  package path hardcoded to `D:\north-forge-agent\...` from before the checkout moved to
  `F:\` and was relabeled `MAIN-NORTH`. Fixed by reinstalling editable from the current
  path (`uv pip install -e . --no-deps --python <hermes-dev venv>\Scripts\python.exe`).
  Not a repo file change (venv-local), noted here since it's the reason "no scripts
  worked" today and affects both repos identically.
- **`Advanced/machine-reset.bat` was unconditionally broken** - its sole dependency,
  `scripts/machine-reset-safety.ps1`, had been swept into
  `archive/legacy-standalone-launcher/` by the 2026-09-11 launcher retirement (commit
  `d4b0abc`) even though the `.ps1` has no dependency on the retired launcher/mode system
  and `machine-reset.bat` itself was deliberately kept live. Restored
  `scripts/machine-reset-safety.ps1` and its test (`tests/machine-reset-safety.Tests.ps1`)
  from the archive. See `archive/legacy-standalone-launcher/README.md` for the full
  writeup.
- **`machine-reset-safety.ps1`'s own positive-path test was silently broken** (found while
  re-running the restored suite): the script's `Validate` action wrote its result via
  `[Console]::Out.WriteLine`, invisible to PowerShell's own `$x = & script` capture (the
  test's own capture method) even though it's fine for `machine-reset.bat`'s `cmd.exe
  "> file"` redirect. Switched to `Write-Output`. Full suite now 8/8 (was 7/8 - "valid
  isolated Hermes fixture was removed" previously threw).
- **`Advanced/toggle-mode.bat` archived** - its `.sh` twin, and the FULL/SALES mode system
  it drove (`assemble-skills.ps1`, `mode-blocks/`), were archived in the 2026-09-11
  retirement; the `.bat` was missed and sat live but functionally inert (nothing has read
  `.forge-mode` since). `Advanced/deploy-console/README.md` already told operators "Do not
  use `toggle-mode.bat`" - this makes that true structurally, not just by instruction.
- **Cleared two dead entries from the Windows User `PATH`**:
  `D:\north-forge-hermes-edition\.hermes-install-staging\bin` and
  `E:\north-forge-hermes-edition\.hermes-install-staging\bin`, both leftover from earlier
  drive-letter incarnations of this checkout (`D:` is now a fully unrelated volume;
  `E:` isn't currently mounted at all).

### Known, not fixed this session (flagged for Kenneth / Blacksmith review)

- `CLAUDE.md`'s own Zone A file list (root-level `launch-north-forge.bat/.sh`,
  `toggle-mode.bat/.sh`, `machine-reset.bat`, `provision-new-drive.ps1`,
  `full-drive-reset.bat/.sh`) still names files that were quarantined into `archive/` on
  2026-09-11 and don't exist at those paths any more. Zone B (this file), not edited.
- `README.md`'s file-tree/`provision-new-drive.ps1` example and `USER_MANUAL.md`'s
  `toggle-mode.bat`/`full-drive-reset.bat`/`machine-reset.bat` instructions were already
  flagged stale in the 2026-09-12 entry below; `toggle-mode.bat`'s archival above makes
  `USER_MANUAL.md`'s reference to it fully dead now, not just path-stale.
- `Advanced/full-drive-reset.bat` still targets this drive's own (now-retired)
  `.hermes-home` concept. Its dependency (`scripts/drive-reset-safety.py`) is intact so it
  isn't concretely broken the way `machine-reset.bat` was - left as-is pending a call on
  whether it should archive alongside its `.sh` twin.
- `scripts/pinokio_lab_target.py`'s `NORTH_FORGE_MARKERS` set (used to detect "is this
  drive a North Forge teammate stick" before a lab install/wipe) still lists
  `launch-north-forge.bat`/`.sh` (archived 2026-09-11) and now also `toggle-mode.bat`
  (archived above) among its markers. The check is match-any across 9 markers and the
  other 6 (`north-forge.cmd`, `HOW_TO_START.txt`, `ASSIGNED_TO.txt`, `machine-reset.bat`,
  etc.) still resolve on a real Round Table drive (called Excalibur at the time this was
  written; renamed later the same day - see the entry below) per `ROUND-TABLE.md`'s own
  build checklist, so this isn't believed to be a live false-negative - flagged rather
  than touched given it backs a safety check that gates drive wipes.

## [Unreleased] - 2026-09-12

### Added (later session, Perplexity Computer - optional Pinokio lab install, admin-only)

- **Pinokio (https://github.com/pinokiocomputer/pinokio) can now be pointed at a
  large lab disk, mechanically kept off the teammate stick.** Kenneth's own
  `Advanced/PINOKIO.md` and `Advanced/deploy-console/EXCALIBUR.md` already ruled
  Pinokio out of the teammate/handoff drive ("Do not put on this stick: Pinokio,
  local model zoos, AppData installs, the research archive. Those bury the
  sale.") - this adds the enforcement code for that decision rather than
  overriding it. New `scripts/pinokio_lab_target.py` validates a candidate
  target directory against both hard rules from those docs: refuses any drive
  carrying a North Forge marker file (`north-forge.cmd`, `HOW_TO_START.txt`,
  `Start North Forge.lnk`, etc., checked from the target up to the drive root),
  and refuses anything under 200 GB free (500 GB+ is PINOKIO.md's own "real
  design" floor); neither check is overridable by a flag. New
  `Advanced/deploy-console/Install-Pinokio-Lab.ps1` runs that check, then - only
  if Pinokio is already installed - offers to point its `config.json` Home
  field at the validated target (backing the file up first); if Pinokio isn't
  installed yet, it just prints the target path to paste into Pinokio's own
  first-run Home prompt, since letting Pinokio's own installer/UI own an
  existing-data move is more reliable than scripting around it (see the
  GitHub issues cited in `PINOKIO.md`). Companion
  `Advanced/deploy-console/Remove-Pinokio-Lab.ps1` runs Pinokio's registered
  uninstaller if found, clears its AppData/program folders, and only deletes
  the Home data folder with an explicit `-RemoveHomeData` switch plus
  confirmation. Neither script is wired into `north-forge.cmd`,
  `bootstrap-north-forge.ps1`, `nf-setup.ps1`, or any other teammate-path
  script - both are only reachable by running them directly from the admin
  console folder. 10 new tests in `tests/test_pinokio_lab_target.py`.

### Fixed (later session, Perplexity Computer - cron auto-sync, dead-test cleanup, README/CHANGELOG)

- **Daily research/brief cron jobs now register themselves.** Root cause:
  the retired standalone launcher used to self-schedule `nightly-kyocera-research`
  and `daily-kyocera-brief` on every run; when this repo moved to the
  profile-pack model (see the 2026-09-11 entries below), nothing replaced
  that self-heal step, and the chassis's new `north-forge.cmd` /
  `scripts/nf-setup.ps1` had zero cron-related code. Result: those two jobs
  only ever got created if someone typed `/cron add ...` by hand inside a
  live session - something a Basic-tier teammate drive is never expected to
  do, which is exactly the gap Kenneth flagged. Fix, split across both
  repos: `skills/kyocera-research/SKILL.md` and `skills/daily-brief/SKILL.md`
  (this repo) now carry a machine-readable `cron:` block in their frontmatter
  alongside the existing prose "Setup note" (kept as the manual fallback);
  `north-forge-agent`'s new `scripts/nf_sync_cron.py` reads that block from
  every installed skill and creates any job that is missing by name, via the
  same `tools.cronjob_tools.cronjob()` API the CLI uses, called from
  `north-forge.cmd`'s existing self-healing block on every launch and once at
  the end of `nf-setup.ps1` right after provisioning. Add-if-missing only (a
  user's own post-creation edits to schedule/prompt are never touched),
  never pins model/provider (so it behaves identically on Basic and Full
  tier - a job created this way inherits whatever model the drive already
  has configured), and a scheduling failure only ever prints a warning, never
  blocks a launch. Added `tests/test_cron_frontmatter.py` here to keep the
  two repos' halves of this contract from drifting apart again, and a full
  unit-test suite for the sync script itself in `north-forge-agent`'s
  `tests/scripts/test_nf_sync_cron.py`.
- **Registering a job still isn't the same as it firing.** The engine's own
  cron API already reports `gateway_running: false` when nothing is polling
  the schedule for this `HERMES_HOME` (the ticker lives in the gateway
  process); `nf_sync_cron.py` surfaces that warning on-screen the same way
  the old launcher's `CRON_DEGRADED` banner did. Both skills' "Setup note"
  sections now say plainly that a stick needs `hermes gateway install` once
  for research/brief jobs to survive a teammate closing the terminal.
- **The gateway install step is automated too, not just documented.** Follow-up
  the same day, per direct request: `scripts/nf_sync_cron.py` (north-forge-agent)
  now also calls `hermes_cli.gateway.ensure_gateway_service()` — the exact
  zero-prompt, never-raising install path `hermes setup`/`hermes import`
  already use internally — whenever at least one skill here declares a cron
  job. It installs a user-scope systemd/launchd/Windows-Scheduled-Task
  service and starts it if nothing is installed yet, just starts it if a
  stopped service already exists, short-circuits immediately if one is
  already running, and safely no-ops (printing its own explanation) inside
  containers or on hosts with no supported service manager. Both skills'
  "Setup note" sections here are updated accordingly; `hermes gateway
  install` remains documented as the manual fallback for the no-service-
  manager/container case only, not as the everyday path anymore.
- **Documented exactly what the automatic gateway install needs to succeed,
  per platform.** Follow-up the same day, per direct request: a real,
  non-mocked run of `ensure_gateway_service()` in a Linux test environment
  surfaced the specific requirements the prose above only gestured at -
  `north-forge-agent`'s README now has a "Gateway service requirements"
  section spelling out that Windows needs no admin rights for the normal
  Scheduled-Task path (falling back to a Startup-folder shortcut if denied),
  while Linux needs a real running systemd plus a reachable user D-Bus
  session with linger enabled (auto-attempted via `loginctl enable-linger`,
  falling back to a printed `sudo loginctl enable-linger <user>` command),
  and macOS's `launchd` path normally needs nothing extra. Both skills'
  "Setup note" sections here now point at that section instead of only
  naming the `hermes gateway install` fallback.
- **Removed three dead tests left behind at the first migration pass.**
  `tests/test_cron_registration.py`, `tests/test_drive_hermes_contract.py`,
  and `tests/test_launcher_hermes_home.py` all read `launch-north-forge.sh`/
  `.bat` directly off disk - files that were quarantined into
  `archive/legacy-standalone-launcher/` in the 2026-09-11 retirement below,
  but these three test files were not moved alongside them, so every one of
  them has been erroring on `FileNotFoundError` (not failing an assertion -
  erroring before it could even run one) since that session. Moved (not
  deleted - `git mv`, history preserved) into
  `archive/legacy-standalone-launcher/tests/` next to the launcher files
  they actually test, and the archive folder's own `README.md` table updated
  to list them. `python -m pytest tests/` went from 12 failed / 11 passed to
  11 passed / 0 failed.

### Added (later session, Claude Code - one-line README link, Zone B handoff)

- **`README.md`'s "Start here" table: one row added**, linking to
  `north-forge-agent/ARCHITECTURE.md` (the new engineering-audience
  architecture reference in the public chassis repo). Per Kenneth's
  explicit in-session instruction naming the exact link text and target -
  this is placement of a specific, named addition, not composition of new
  README content, so it's made directly per the Zone B placement
  exception. No other `README.md` content touched.

### Security (later session, Claude Code - branch protection applied)

- **`main` branch protection applied**, matching `north-forge-agent`'s own
  hardening from `RUN-2026-09-11-002`: `enforce_admins: true`,
  `allow_force_pushes: false`, `allow_deletions: false`,
  `allow_fork_syncing: false` (via `PUT /repos/kwalker7631/
  north-forge-hermes-edition/branches/main/protection`). Closes the gap
  flagged in the same-day connector/access audit (this repo had **zero**
  branch protection before this). Verified live afterward with a separate,
  independent `GET` on the protection endpoint (not the `PUT` call's own
  echoed response) plus a direct query of the `enforce_admins`
  sub-resource specifically - all four settings confirmed enabled/disabled
  as intended, and cross-checked byte-for-byte identical to
  `north-forge-agent`'s current live config on the same four fields.

### Governance (2026-09-12 session, Claude Code - deploy-console zoned, authorship check)

- **`Advanced/deploy-console/` given a Zone A assignment in `CLAUDE.md`.**
  The whole subsystem (`Zero-Touch-Deploy.ps1`, `Start-DeployConsole.ps1`,
  `Launch-Deploy-Console.cmd`, `ui/index.html`, `VERSION.txt`) was added
  earlier the same day with no zone assignment at all, flagged in that
  session's audit. Added as Zone A (mechanical glue, same reasoning as the
  rest of that list). Deliberately left **out** of Zone A: the prose/
  admin-facing files in the same folder (`README.md`, `DEPLOY.md`,
  `Deploy-NorthForge.md`, `ADMIN_FIRST_TIME.txt`,
  `FOR_THE_PERSON_GETTING_THIS_DRIVE.txt`) - treated as Zone B by analogy
  to the root docs, pending Kenneth confirming that analogy is right (not
  yet added to the explicit Zone B list).
- **Authorship of the 2026-09-12 04:00-05:37 session (Deploy Console,
  `README.md` rewrite, `CURRENT.md`, `LEARNING.md`).** A same-day session
  note (this entry) had recorded this as "genuinely unclear" from git
  evidence alone - correct as far as it went, since git shows no
  distinguishing signal (every commit in that burst, `dbe5e7c`..`1cfdf98`,
  is unsigned, no `Co-Authored-By`/`Claude-Session`/Codex-style trailer,
  authored and committed under Kenneth's own GitHub identity either way).
  **Per Kenneth directly** (stated in chat, not inferred from git): the
  `Advanced/deploy-console/` automation (`Zero-Touch-Deploy.ps1`,
  `Start-DeployConsole.ps1`, the UI) was built working with **Grok**, which
  had direct GitHub write access to this repo at the time. The `README.md`
  rewrite and related docs (`CURRENT.md`, `LEARNING.md`,
  `skills-source/shared/readme/SKILL.md`) were produced working with
  **ChatGPT/Codex**. Recorded here as the project owner's own statement of
  record, not as something git evidence proved.

## [Unreleased] - 2026-09-11

### Changed (2026-09-11 session, Claude Code - retired standalone install model, adopted as a Hermes profile distribution)
- **This repo is no longer a standalone-installable product.** Per Kenneth's direct in-session instruction, the drive-local install/launcher model (its own `.hermes-home`, its own venv) is retired in favor of installing as a normal **Hermes profile distribution** into an already-running North Forge/Hermes environment (`north-forge-agent`'s `editions/` pattern, extended with a private `private-editions/` slot - see that repo's own session report for the other half of this change).
- **Quarantined, not deleted** (`git mv`, history preserved) into `archive/legacy-standalone-launcher/` (new README there explains why): `launch-north-forge.bat`/`.sh`, `scripts/ensure-hermes.ps1`/`.sh`, `scripts/hermes-drive.ps1`/`.sh`, `scripts/machine-reset-safety.ps1`, `Advanced/provision-new-drive.ps1`, `Advanced/full-drive-reset.sh`, `Advanced/toggle-mode.sh`, and their dedicated tests (`tests/machine-reset-safety.Tests.ps1`, `tests/provision-new-drive.Tests.ps1`, `tests/repository-hygiene.sh`, `tests/reset-integration.sh`, `tests/test-dependency-check.sh`, `tests/test-drive-hermes-install.sh`, `tests/test-drive-local-hermes.sh`, `tests/test-launcher-hermes-home.sh`, `tests/test-skill-assembly.sh`, `tests/two-drive-hermes-isolation.sh`, `tests/test-free-provider.sh`).
- **The internal FULL/SALES mode system is retired too**, same reasoning: `mode-blocks/` and `scripts/assemble-skills.ps1` quarantined into `archive/legacy-mode-system/`. Reachability of TSC-only content is now the job of `north-forge-agent`'s existing Full/Basic tier + admin-passcode gate, not a baked-in mode.
- **`skills-source/shared/` and `skills-source/tsc-only/` flattened into one `skills/`** (`git mv`, byte-identical content, 16 skill folders total) to match the `distribution.yaml` + `SOUL.md` + `skills/` shape used by `north-forge-agent`'s other editions.
- **`KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html` moved to `skills/kb-builder/assets/`** (its owning skill). `kb-builder/SKILL.md` already phrased its reference as "repo root or wherever the Blacksmith has placed it," so no Zone B text needed changing for this move.
- **New `distribution.yaml` at repo root** (`name: kyocera`) - mechanical manifest, matches the plan Kenneth approved this session.
- **NOT done here (Zone B - needs Blacksmith):** a real `SOUL.md` still needs to be authored from `.hermes.template.md` (extracting the always-loaded identity/rules, dropping the `{{MODE_BANNER_BLOCK}}`/`{{COMMAND_MENU_BLOCK}}`/`{{AGENT_NAME}}` per-drive templating that assumed the retired launcher). `.hermes.template.md` itself is left in place, untouched, at the repo root as the source for that pass. `skills/menu/SKILL.md` still describes FULL/SALES mode routing that no longer applies structurally and needs a Blacksmith rewrite. `README.md`, `USER_MANUAL.md`, `FIRST_TIME_README.txt`, and `WELCOME.html` all still describe the retired launcher/mode system throughout and need Blacksmith-authored replacement text (same pattern as the 2026-09-05 file-tree/run-instructions gap noted above) - Claude Code did not compose any of this per this repo's own Zone B rule. See `logs/CLAUDE_CODE_LAST_AUDIT.md` for the full list with line numbers.
- Verified: `hermes profile install <this-repo-path> -y` (against a real local checkout) succeeds on `distribution.yaml` alone - `SOUL.md`'s absence does not block install, it just means the profile falls back to Hermes's default persona until Kenneth's `SOUL.md` pass lands.

### Added (2026-09-11, later session, Claude Code - SOUL.md placed and voice-verified)
- **`SOUL.md` placed at the repo root** (commit `7fe61d5`), closing the gap noted immediately above. Composed last session as a draft translation of `.hermes.template.md`'s always-loaded identity/voice/rules into Hermes's native `SOUL.md` format - voice only, matching the `north-forge-agent` `editions/*/SOUL.md` pattern (no mode routing, no skill logic, the retired `{{MODE_BANNER_BLOCK}}`/`{{COMMAND_MENU_BLOCK}}`/`{{AGENT_NAME}}` templating dropped rather than translated). Reviewed by Kenneth in chat; placed byte-identical to the reviewed draft, per this repo's Zone B placement exception - not composed or edited by Claude Code at placement time.
- **Verified end-to-end, not just placed.** Ran the real `north-forge-agent` pin/install flow (`docs/BUILDING-A-DRIVE.md`'s "Pinning to a private edition" sequence) in a scratch, `HERMES_HOME`-isolated environment: bootstrap venv/data, pull the new `SOUL.md` into `private-editions/kyocera`, `nf-setup.ps1 -Pin kyocera -Installed kyocera`, confirmed `hermes profile show kyocera` reports `SOUL.md: exists` and the profile is the active pinned edition. Went one step further than last session's check (which stopped at "no inference provider configured," no key in that scratch run): configured the keyless OpenCode Free provider and got a real model response. Two of the plugin/changelog-documented default free models (`laguna-s-2.1-free`, `deepseek-v4-flash-free`) errored against the live catalog (free-tier drift, confirmed external via a direct `curl` to the provider's `/v1/models` endpoint, not a defect here); `nemotron-3-ultra-free` worked. A real one-shot identity prompt ("Who are you, and how do you and I work together?") answered "I'm North Forge — Kyocera Edition" and paraphrased `SOUL.md`'s relationship/voice/reasoning sections near point-for-point - direct confirmation the profile runs on `SOUL.md`'s voice, not a generic Hermes persona. Full transcript and the free-model-drift detail are in `logs/CLAUDE_CODE_LAST_AUDIT.md`. All scratch artifacts (venv, data dir, provisioning record/passcode, drive-root shortcut) deleted afterward; `private-editions/kyocera` itself and its git state were left clean and untouched.

## [Unreleased] - 2026-09-05

### Added (2026-09-06 session, Claude Code - plug-and-play Python 3 dependency check)
- **Both launchers now offer to install Python 3 when it's missing, instead of dead-ending.** A real field failure prompted this: a fresh drive, first run, on a machine with no Python 3 - the launcher printed "install it yourself" and quit, breaking the plug-and-play promise. Now, at the very top of `launch-north-forge.sh` / `launch-north-forge.bat` (right after the drive-writable probe, before any name entry), each checks for Python 3 and, if absent, prompts `Install it now? [Y/n] (recommended: Y)` (plain Enter = Yes). On Yes it downloads and runs the official installer unattended - Windows: the python.org per-user `.exe` with `/quiet InstallAllUsers=0 PrependPath=1 Include_launcher=1 Include_test=0` (no administrator rights needed); macOS: the python.org `.pkg` via `sudo installer` (says plainly first that it needs the admin password); Linux: the system package manager (`apt-get`/`dnf`/`pacman`/`zypper`/`apk`) via `sudo` (says so first) - shows "Installing Python ... this may take a minute", then **re-checks** that Python is actually present before continuing rather than trusting the installer's exit code. On No, or on any install/verify failure, it prints exactly what's missing plus the manual download link and exits cleanly (no crash further in). Every step is logged to `forge-events.log` with a `[deps]` tag (check result, operator's choice, install outcome). The pinned Python version is `3.13.15` (one editable line near the top of each launcher; inside Hermes's own `requires-python >=3.11,<3.14`).
- **Node.js is deliberately NOT checked.** Investigation (grep of both launchers + every `scripts/` helper) confirmed nothing on the launch path invokes `node`/`npm`/`npx`. The Hermes engine installer bootstraps its own managed Node (and its own Python, git and `uv`); the only `npx agent-browser install` reference is a manual post-install browser-research step. Adding a system-Node prompt would install something the engine never uses.
- **Fast path is free.** When Python 3 is already present the check is one `command -v` (POSIX) / two `where` probes (Windows) plus a single log line - no prompt, no measurable delay. The Windows path re-detects after install by also looking in `%LOCALAPPDATA%\Programs\Python\` since PATH in the already-running window is stale.
- **New test:** `tests/test-dependency-check.sh` - 6 scratch scenarios (fast path; decline; approve + mock installer succeeds + re-check finds it; approve + installer fails; approve + installer "succeeds" but Python still absent; non-interactive terminal). Uses env-var seams (`NORTH_FORGE_DEP_FORCE_PY_MISSING`, `NORTH_FORGE_DEP_INSTALLER`) so nothing touches the real machine's Python and no PATH shadowing is needed. The five equivalent `.bat` gate scenarios were exercised directly (a committed `.bat` harness was dropped after its plumbing proved flaky - the launcher logic itself verified correct). Full existing suite (9 shell + launcher `.py` static tests) still green.

### Fixed (later session, Claude Code - Hermes executable-resolver reconciliation + launcher cleanups)
- **The install guard and the runtime wrapper now agree on where the drive-local `hermes` executable lives.** `scripts/ensure-hermes.sh`/`.ps1` (validates a fresh install) and `scripts/hermes-drive.sh`/`.ps1` (runs Hermes for every skin/skill/cron/interactive call) had only-partially-overlapping candidate lists - they shared exactly one path each (`bin/hermes` on POSIX, `Scripts\hermes.exe` on Windows), neither of which is where the real upstream installer puts the launcher. If a fresh install had landed the executable anywhere else, `ensure-hermes` would have reported success and the very next call (`hermes skin use north-forge`) would have failed. Ground truth was read directly from the live upstream installers this session (`hermes-agent.nousresearch.com/install.sh` and `install.ps1`, plus `NousResearch/hermes-agent` `pyproject.toml [project.scripts]` and the checked-in `./hermes` launcher's file mode): a default install puts `INSTALL_DIR = $HERMES_HOME/hermes-agent`, a venv at `$INSTALL_DIR/venv` whose console script is `venv/bin/hermes` (POSIX) / `venv\Scripts\hermes.exe` (Windows), and on Windows `Set-PathVariable` then stages that launcher into `$HERMES_HOME\bin` as `hermes.exe` (normal venv) or `hermes.cmd` (relocatable venv). All four resolver lists were rewritten to one identical installer-grounded order per platform - POSIX: `hermes-agent/venv/bin/hermes` -> `bin/hermes` -> `hermes-agent/hermes`; Windows: `hermes-agent\venv\Scripts\hermes.exe` -> `bin\hermes.exe` -> `bin\hermes.cmd`. Speculative entries that no installer path produces (`.venv/`, flat `venv/`, bare `Scripts\`, bare root `hermes.exe`) were removed rather than unioned in, so a genuinely broken install still fails validation instead of being masked. Verified: `bash -n` + PowerShell AST parse clean on all four; `tests/test-drive-local-hermes.sh`, `test-drive-hermes-install.sh`, `two-drive-hermes-isolation.sh`, `test-free-provider.sh`, `test-skill-assembly.sh` and `tests/test_drive_hermes_contract.py` all pass.
- **`launch-north-forge.sh` size-guard: the "Launch aborted" message is reachable again.** The `.hermes.md` assembly step is a `python3` heredoc under `set -e`; a non-zero exit aborted the script before the following `if [ $? -ne 0 ]` could run, so `Launch aborted: .hermes.md was not written.` never printed on the failure path. Restructured as `if ! python3 - "$MODE" << 'PYEOF' ... PYEOF` / `then ... fi`, which both suppresses `errexit` for that command and reaches the message. The `.bat` side already handled this (cmd.exe has no `errexit`). Verified against the real extracted block: a forced >=20,000-char assembly now prints the abort line and exits 1 with no `.hermes.md` written; a normal assembly still writes the file and continues.
- **`launch-north-forge.bat`: removed the dead `:HERMES_READY` label.** Six trailing lines that were never `call`ed or `goto`'d from anywhere in the file and referenced a `%HERMES_EXE%` variable that is never set. Left over from before install validation was factored out to `scripts\ensure-hermes.ps1`. Zero behaviour change.

### Reorganized (later session, Claude Code - drive-root first impression)
- **Admin/support tooling moved into `Advanced/`.** `toggle-mode.bat`/`.sh`, `machine-reset.bat`, `full-drive-reset.bat`/`.sh`, and `provision-new-drive.ps1` moved from the drive root into a new `Advanced/` subfolder (`git mv`, history preserved), so a non-technical field user opening the drive in Explorer no longer sees six admin `.bat`/`.ps1` files competing with the launcher. Each moved script re-anchors its working directory one level up (`cd /d "%~dp0.."` / `cd "$(dirname "$0")/.." || exit 1`) so it still acts on the drive root - `.forge-mode`, the credential dotfiles, `.hermes/skills`, `forge-events.log`, and the `scripts/` helpers all resolve exactly as before; `machine-reset.bat`'s three `scripts\machine-reset-safety.ps1` calls became `..\scripts\...`. Version bumps: `toggle-mode.bat`/`.sh` and `machine-reset.bat` 1.1.0 -> 1.2.0; `provision-new-drive.ps1` 1.0.1 -> 1.1.0 (its body needed no change - it builds every path from the chosen drive letter). Verified: `tests/reset-integration.sh` passes against the new layout, and `toggle-mode.bat` / `machine-reset.bat` / `full-drive-reset.bat` were run on real Windows from `Advanced/` and confirmed to operate on the drive root (RESET removed the eight root state files and nothing in `Advanced/`; the `..\scripts\` safety helpers resolved and ran).
- **One real, distinct icon at the drive root: `North Forge.lnk`.** `provision-new-drive.ps1` (at provisioning time) and `launch-north-forge.bat` (first run / self-heal, bumped 1.2.1 -> 1.3.0) now generate a `North Forge.lnk` in the drive's own root, pointing at `launch-north-forge.bat` with `assets\north-forge.ico` and working directory set to the drive root so it resolves on any drive letter. A `.bat` can never carry a custom icon; only a `.lnk` can, and its target is drive-letter-specific so it must not be committed - `.gitignore` now excludes `/North Forge.lnk` (same reasoning as the per-drive markers). Verified generated on the real `E:` drive: target, working dir, and icon all resolve; `git status` stays clean.
- **Not done here (Zone B - needs Blacksmith / Claude Project chat):** `README.md`'s file-tree diagram and its `.\provision-new-drive.ps1` command example, and `USER_MANUAL.md`'s "run `toggle-mode.bat`" / `full-drive-reset.bat` / `machine-reset.bat` instructions, still show the old root paths. Exact drop-in replacement text was handed to Kenneth in the session that made this change; until it lands, those two docs point one folder too high.
- **Numbered `1-`/`2-`/`3-` file naming: recommended against** (Claude Code's judgment, per Kenneth's question). Once the admin tools are subfoldered, the root has exactly one thing a field user runs (the launcher / its `.lnk`); a number prefix implies an ordered sequence that does not exist and would churn every doc and test reference for cosmetic gain. If extra in-folder signal is wanted, a static `Advanced/WHEN-TO-USE-THESE.txt` beats prefixes.

### Merged (later session, Claude Code - reconciling concurrent Codex PRs)
While this session's Codex-audit-response fixes (above) were in progress, Codex was independently and concurrently fixing several of the same findings via its own PRs, merged to `main` mid-session (`ef4cb12..0eef03b`: "Validate welcome assets and retry failed opens," "Stop provisioning when Git update fails," "Ignore provider choice state and test repository hygiene," "Harden launcher name validation"). `git push` was rejected on a stale ref; rather than force-pushing over that work, it was pulled and merged by hand:
- **Name validation (NF-CX-05): Codex's version kept, mine discarded.** Codex introduced `scripts/name_validation.py` - a proper allowlist-based validator (letters/numbers/spaces/`'-.,()` only, 64-char cap, re-prompts on invalid input, has its own test suite) shared by both launchers, replacing the raw `read`/`set /p` name prompts entirely. This is a materially stronger fix than this session's own bracket-stripping approach for the same finding - kept Codex's, discarded mine.
- **`provision-new-drive.ps1` git-exit-code check: Codex's version kept, mine discarded.** Codex's version additionally uses `Join-Path`/`-LiteralPath` throughout and validates that the repository folder and `launch-north-forge.bat` actually exist after a clone/pull reports success (defense against a "succeeded" clone that's still incomplete) - more thorough than this session's own git-exit-code-only check for the same underlying gap. Kept Codex's, discarded mine.
- **WELCOME.html marker + `.gitignore`: functionally identical on both sides**, trivial dedup (one now-redundant comment block, one duplicate `.gitignore` line).
- **Everything else from this session's own fixes was NOT touched by Codex's concurrent work and is unaffected by the merge**: `machine-reset.bat`'s HIGH-severity target-validation fix, RESET's wipe-list fix, the provider-choice config-verification fix, the skill-copy-failure fix, and the cron on-screen-warning fix all still stand as committed earlier in this session.
- Re-verified end-to-end after merging (both `.sh` and `.bat`, full launch through skin activation/skills trust/cron scheduling) - no regressions from combining both sets of changes.

### Merged again (later session, Claude Code - Codex's remaining findings, 2 real bugs caught)
While the above merge was being finalized, Codex pushed a **second** round of PRs independently re-fixing the other 5 findings from this session's own commit `9a48117`, more thoroughly than this session's versions in every case - deferred to Codex's throughout after review:
- **`machine-reset.bat` (NF-CX-01):** new `scripts/machine-reset-safety.ps1` does real path canonicalization - rejects `..`/UNC/device paths, walks the full path from the drive root checking every segment for a symlink/junction (not just the final target), and re-validates the canonical path still matches at delete time (closes a TOCTOU gap this session's substring check never addressed). The confirmation prompt now requires retyping the exact validated path instead of `YES`.
- **`toggle-mode.sh`/`.bat` (NF-CX-02):** RESET now verifies each deletion actually succeeded and reports an error if anything remains, instead of assuming `rm -f`/`del` worked.
- **`launch-north-forge.sh`/`.bat` (NF-CX-03, NF-CX-04, NF-CX-06):** free-provider configuration and skill assembly are now fully diagnostic-capturing with secret redaction before anything reaches `forge-events.log`; skill assembly is a real staged-build-then-atomic-swap with automatic rollback to the last-known-good build on any failure (this session's version only aborted on failure, it didn't roll back); cron failures now include the actual diagnostic text, not just a generic "FAILED."

**Two real bugs found in Codex's own commits and fixed before merging, not accepted blind:**
- `launch-north-forge.sh` called a `configure_free_provider` function that was never defined anywhere in the file - would have broken with "command not found" for every user taking the default free path. Wrote the missing function to match the `.bat` launcher's already-correct `:CONFIGURE_FREE_PROVIDER` equivalent (diagnostic capture, secret redaction, correct "not set" vs. genuine-failure handling).
- `launch-north-forge.bat` referenced `%PYTHON_CMD%` three times, but the free-provider-hardening PR (built on an earlier revision) dropped the block that sets it - `name_validation.py` would silently never run under an actual Python interpreter. Restored the detection block.

Both caught by testing, not by inspection alone - full end-to-end integration runs on both launchers after the fix, plus a live console-automation run of the merged `machine-reset.bat` confirming a real full-purge deletes a validated target and nothing else.


### Changed (later session, Claude Code)
- **Onboarding default switched from a hard Anthropic-key gate to zero-config OpenCode Free.** `launch-north-forge.bat`/`.sh` (both bumped 1.0.0 -> 1.1.0) now ask once, on first launch, whether to start free (OpenCode Free - no account, no key, no payment method, configured via `hermes config set model.provider opencode-free` + `hermes config unset model.default`, which Hermes's own fallback logic auto-resolves to a real working free model at runtime) or to opt in to a personal Anthropic API key (`OWNKEY`) for the existing pay-per-token flow. The choice is remembered in `.provider-choice` (same pattern as `.agent-name`/`.drive-record.txt`) and not re-asked. `.env.example` (bumped 1.0.0 -> 1.1.0) rewritten to match: ANTHROPIC_API_KEY reframed as optional/opt-in, OpenCode Free noted as the zero-cost default, plus an explicit warning against picking a premium/credits-gated model (Fable, Mythos) without understanding it needs a separate purchased credits balance. Verified empirically: both branches tested end-to-end against an isolated scratch `HERMES_HOME`, including confirming `get_default_model_for_provider("opencode-free")` resolves to a real model (`deepseek-v4-flash-free`) with no manual model ID hardcoded into the scripts. Requested by Kenneth directly, following a recon session that found the previous hard gate had no free path at all and that the credits-gated `claude-fable-5` model has no visible warning distinguishing it from ordinary metered models.
- **`toggle-mode.bat` / `machine-reset.bat` Script version bumped 1.0.0 -> 1.0.1** to reflect the `e342f7a` admin_gate password-bypass fix, which predated the 1.0.0 versioning baseline set in the prior session (that baseline was a fresh starting point, not a reconstruction of real prior history - see that session's audit for detail).

### Fixed (later session, Claude Code - independent Codex audit findings)
An independent adversarial audit (`logs/CODEX_SECOND_AUDIT_2026-09-05.md`, 1 HIGH/4 MEDIUM/2 LOW numbered findings) was pulled and each finding independently re-verified before fixing. All confirmed real; all fixed in Zone A files only:
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

Full detail for the GPT-side Claude: `logs/HANDOFF_2026-09-04_SESSION_CHANGES.md`.

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
  `logs/CLAUDE_CODE_LAST_AUDIT.md`.

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
