# Claude Code Session Audit

Timestamp: 2026-09-12 (Pinokio validator reconciliation, deploy-console
repair-path/parse-bug fix, real Excalibur drive build + verification)
Requested task: per `Downloads/CLAUDE_TASK_concern_check_and_excalibur_build.md` -
Part 1 (confirm/fix the Pinokio same-drive-vs-separate-disk validator
conflict), Part 2 (build ONE real, deployable Excalibur drive, verified end
to end, not assumed). Plus two owner asks mid-session: a standing drive-root
"How To Start" docs entry point (landed in `north-forge-agent`'s own
ledger), and a deploy-console repair-path fix for "someone messed where
they shouldn't."

## Files inspected

- `scripts/pinokio_lab_target.py`, `tests/test_pinokio_lab_target.py`,
  `logs/HANDOFF_PERPLEXITY_PINOKIO_2026-09-12.md`
- `Advanced/deploy-console/Zero-Touch-Deploy.ps1`,
  `Install-Pinokio-Lab.ps1`, `EXCALIBUR.md`
- The real target drive: `E:\` (label `GREG-NORTH`, 231 GB exFAT, empty at
  session start)
- Post-deploy: `E:\north-forge-agent-data\profiles\kyocera\` (installed
  profile contents), `hermes skills list`, `hermes status`,
  both drive-root `.lnk` shortcuts

## Zone A changes made

1. **`scripts/pinokio_lab_target.py`** + tests - reconciled the Excalibur-
   vs-Learning-class hard-block rule (full detail in the prior revision of
   this report; unchanged since). Commit `87b513c`.

2. **`Advanced/deploy-console/Zero-Touch-Deploy.ps1`** - private-edition
   repair-path fix (`git pull --ff-only` -> fetch + force-checkout, matching
   the agent checkout) and a parse-breaking missing-BOM fix, found by
   actually invoking the script. Commit `e9b6ae9`. Full detail in the prior
   revision of this report.

3. **This session's real Excalibur build on `E:\`** (not a code change to
   this repo, but the actual deliverable Part 2 asked for):
   - Confirmed `EXCALIBUR.md`'s sequence against the real
     `Zero-Touch-Deploy.ps1`/`Install-Pinokio-Lab.ps1` on `origin/main`
     before running anything (no drift beyond the previously-flagged
     console-UI owner-label gap, worked around here by invoking the engine
     script directly with `-Label` rather than through the web console).
   - Ran the real deploy: `-DriveLetter E -SkipFormat -Tier basic
     -Pin kyocera -Passcode <owner-supplied> -Label GREG-NORTH`. Real
     `git clone`/`gh repo clone`, real venv bootstrap (67 packages), real
     `nf-setup.ps1` provisioning. Exit code 0, "DEPLOYMENT COMPLETE."
   - **Drive-root shortcut, verified not assumed**: `Start North Forge.lnk`
     landed at `E:\` (not inside the checkout) - read back its real
     `TargetPath`/`WorkingDirectory` via COM, confirmed correct. This is the
     exact bug class EXCALIBUR.md flags as a prior issue; confirmed fixed on
     this real build.
   - **Real test prompt -> real response: NOT completed.** `hermes status`
     on this drive's `HERMES_HOME` shows no model, no provider, every API
     key unset, no `.env` - and none of `EXCALIBUR.md`, `ADMIN_FIRST_TIME.txt`,
     or `DEPLOY.md` mention configuring an inference provider anywhere in
     the build sequence. Asked the owner how to proceed (their own
     OpenRouter key, Nous Portal login, or defer); owner chose to defer as
     a manual follow-up rather than supply credentials in-session. So this
     specific verification item is **open**, not silently skipped - the
     drive cannot answer anything, Kyocera-voiced or otherwise, until a
     provider is configured.
   - **Pinokio/admin-tooling visible to the teammate experience - found a
     real violation, fixed it on this drive**: `hermes skills list` on the
     freshly-provisioned profile showed `pinokio` as `enabled` alongside
     the 17 legitimate Kyocera skills - directly reachable via `/pinokio` in
     chat, contradicting `EXCALIBUR.md`'s own "Do not put on this stick:
     Pinokio" and `PINOKIO-on-drive.md`'s "Do not put Pinokio on the 32 GB
     manager-first stick." Root cause: the private-edition profile install
     copies the entire `north-forge-hermes-edition` source tree (all 18
     skills, `Advanced/deploy-console/*`, `PINOKIO-on-drive.md`, etc.) into
     `profiles/kyocera/` with no stick-class-aware curation - there is
     currently no mechanism anywhere in this pipeline to exclude a skill
     from a specific build. Removed the installed `skills/pinokio/` and
     `skills-source/shared/pinokio/` copies from this drive's profile
     directly (data, not source - safely regenerable, nothing lost) and
     re-verified: `hermes skills list` now shows exactly the 17 remaining
     skills, all still enabled. **Not fixed at the source**: the underlying
     gap (no way to exclude a skill per stick-class) still exists and will
     recur on the next Excalibur build unless someone decides how it should
     work - see "Uncertain," below. The admin-only scripts
     (`Install-Pinokio-Lab.ps1`, `Remove-Pinokio-Lab.ps1`,
     `pinokio_lab_target.py`) also landed in the profile folder on disk;
     these are not skill/chat-reachable (not wired into any command), so
     left in place rather than risk breaking a future `hermes update` that
     may expect the full source tree - flagged, not removed.

## Zone B findings (not fixed - reported only)

- Carried forward unchanged: the dead `#gateway-service-requirements`
  anchor; `WELCOME.html`'s stale `launch-north-forge.bat`/`.sh` content
  (now the actual target of the real, working "How To Start.lnk" on this
  drive - so a teammate clicking it today gets instructions for the wrong
  launcher); the `PINOKIO-on-drive.md` / `Advanced/PINOKIO.md` overlap.

## Commits made this session

- `87b513c` - Reconcile pinokio_lab_target.py with the Learning-class same-drive design
- `e9b6ae9` - Fix Zero-Touch-Deploy.ps1: repair path for private edition + parse-breaking BOM gap
- `d10992b` - Session audit (mid-session revision, superseded by this one)
- `<pending - this file, immediately after this report is written>`

(Deploy + profile fixes to `E:\` itself are not commits - they're the real
drive build and a direct, data-only edit to that drive's installed profile,
outside any git repo.)

## Uncertain / flagged for primary GPT review

1. **No stick-class-aware skill curation exists anywhere in the pipeline.**
   The Pinokio-skill leak found and patched on `E:\` this session will
   recur on every future Excalibur build unless one of these (or another
   option) is decided: (a) a per-skill "tier"/"stick-class" metadata field
   the profile installer reads and filters on, (b) a second, stripped
   distribution variant of the private edition for Excalibur builds
   specifically, or (c) a documented manual post-deploy cleanup step in
   `EXCALIBUR.md` itself (lowest engineering cost, easiest to forget).
2. **No inference provider is configured anywhere in the documented build
   sequence.** A fresh Excalibur (or Learning) drive cannot answer anything
   until one is set up - this needs to become an explicit, documented step
   somewhere (`EXCALIBUR.md`, `ADMIN_FIRST_TIME.txt`, or `nf-setup.ps1`
   itself), and someone needs to decide the actual mechanism (shared
   OpenRouter key baked in at build time vs. Nous Portal login vs. each
   teammate configuring their own).
3. Carried forward: the Excalibur console-UI owner-label gap (no `-Label`
   field in `Start-DeployConsole.ps1`'s web UI - worked around this session
   by calling `Zero-Touch-Deploy.ps1` directly); `PINOKIO-on-drive.md` vs
   `Advanced/PINOKIO.md` overlap.

## Status

**Not yet ready to hand to a person.** Mechanically, the drive deployed
cleanly: locked to Kyocera, both drive-root shortcuts verified correct via
a real launch (not assumed), the Pinokio skill leak found and removed from
this specific drive. But two real gaps remain open, not silently passed
over: (1) no inference provider configured, so it cannot produce any
response yet - deferred by the owner as a manual follow-up rather than
supply credentials in-session; (2) the skill-curation gap that let Pinokio
leak through in the first place is fixed on this one drive only, not at the
source, so it will recur on the next build without a decision from the
items above.

Handoff bundle: <pending - filled in with scripts/build-handoff-bundle.ps1>
