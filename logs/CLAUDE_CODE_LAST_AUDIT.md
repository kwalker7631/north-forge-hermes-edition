# Claude Code Session Audit

Timestamp: 2026-09-13 (post-use audit + branding + web terminal + editions,
per `Downloads/CLAUDE_TASK_post_use_audit_branding_editions.md`)
Requested task: Kenneth actually used the deployed Excalibur drive (`E:\`)
himself tonight and found real issues. Four parts: (1) audit `E:\`'s real logs
from tonight's use, (2) find and fix remaining live Hermes-branded menu/skill
output, (3) make the web terminal easy to launch and fix its branding, (4)
make Pocket Penny / Pine Barron Farms reachable on this drive without
breaking the working Kyocera experience.

## Files inspected

Real logs from `E:\`: `north-forge-agent-launcher.log`,
`north-forge-agent-data\logs\{agent,errors,tui_gateway_crash}.log`,
`north-forge-agent-data\north-forge\provisioning.json`,
`north-forge-agent-data\profiles\kyocera\logs\{gateway,gateway-stdio,
gateway-restart,gateway-exit-diag,gui,hermes-update,update}.log`, every
`process-results\*.json`. This repo's `skills/fault-logging/SKILL.md`,
`.gitignore`, `NEXT_STEPS.md`, `DEMO_PREP_BACKLOG.md`. `north-forge-agent`
engine repo's `hermes_cli/nf_tier.py`, `hermes_cli/web_server_dashboard.py`,
`hermes_cli/main_web_build.py`, `hermes_cli/main_dashboard.py`,
`north-forge.cmd`, `scripts/make-how-to-start-shortcut.ps1`, its own ledger
(`logs/ledger/`).

## Part 1 — Audit of tonight's real E:\ logs

No unhandled process crash. Real findings:

1. **User-facing failure, reproduced twice tonight, then a working third
   attempt** (`process-results/proc_374c2ce1ddf7.json`,
   `proc_930433bf6da0.json`, `proc_9cbf5347ea31.json`): plain
   `hermes dashboard` and `hermes -p kyocera dashboard --no-open --port 9119`
   both exited 1 with `This drive is provisioned for 'kyocera' only (Basic
   tier). The 'default' edition is not available here.` — the non-isolated
   machine-dashboard route also tries to stand up the `default` profile
   alongside the pin. `hermes -p kyocera dashboard --no-open --isolated
   --port 9119` succeeded. Fixed properly under Part 3 below.
2. **A real, verified anomaly in the `north-forge-agent` engine repo**
   (opened as `ERR-2026-09-13-002` there): tonight's GUI/dashboard process
   and the `hermes update`/gateway-restart flow ran under
   `C:\Users\kwalk\.hermes\venvs\hermes-dev`, pointed at `D:\north-forge-agent`
   (Kenneth's separate dev checkout), not this drive's own isolated
   `E:\north-forge-agent-venv`. `HERMES_HOME` itself stayed correctly
   pointed at `E:\north-forge-agent-data` throughout (state.db path, a real
   pre-update snapshot) — only the serving code was wrong. Practical
   consequence: a bare `hermes` typed in an ordinary terminal on this
   machine does not exercise this drive's own code. Full evidence in the
   engine repo's `logs/ledger/errors/ERROR-LOG.md`.
3. `hermes update` ran tonight (04:47:25) against the mismatched install;
   both its logs cut off mid-run, can't confirm completion from the log
   alone. This runs against this repo's own `NEXT_STEPS.md` (2026-09-04)
   standing instruction not to run `hermes update` until the "4279 commits
   behind" banner is explained — flagged, not investigated further (real
   owner use, not a Claude Code action).
4. Non-fatal noise, correctly self-resolving: a `WebSocketDisconnect`
   traceback (normal closed-tab race); `SystemExit: 75` (part of the
   deliberate restart-for-update shutdown, matches `gateway-restart.log`'s
   two-spawn pattern); a pre-existing SQLite-WAL-bug warning.

Full technical detail lives in `north-forge-agent`'s own ledger (`RUN-
2026-09-13-006`, `ERR-2026-09-13-002`) since most of Part 1 concerns the
engine repo, not this one.

## Zone A changes made

1. **`.gitignore`** — the root-anchored `/skills/` guard was written back
   when `skills-source/` was the real tracked source dir; `d4b0abc`
   (2026-09-11, "Retire standalone launcher/installer; adopt as a Hermes
   profile distribution") flattened `skills-source/` INTO `skills/`, so the
   old guard had been silently shadowing the real tracked source directory
   since then — existing tracked files stayed tracked, but any *new* file
   under `skills/` would have been silently dropped by a plain `git add`,
   no error. Found while placing the fault-logging fix below (`git add`
   warned the path was ignored even though it committed fine).
   `git status --ignored` confirmed nothing was actually lost under
   `skills/` in this checkout. Removed the stale guard, replaced with a
   dated explanation comment. Commit `1922627`.

## Zone B changes made (placed with Kenneth's direct, specific, in-session confirmation)

1. **`skills/fault-logging/SKILL.md`** (lines 39, 58) — the printed FORGE
   FAULT REPORT / FORGE EVENT LOG template blocks both carried
   `Package: North Forge - Kyocera Edition (Hermes)`, a literal `(Hermes)`
   suffix leaking into every real fault/event report a technician
   generates. Confirmed the exact replacement wording with Kenneth via an
   in-session question before touching this Zone B file (per this repo's
   own confirmed-mechanism rule) — he chose dropping the suffix entirely,
   now reads `Package: North Forge - Kyocera Edition`. Applied identically
   to this repo, the `north-forge-agent`-nested `private-editions/kyocera`
   clone (fast-forwarded, not double-edited), and the live deployed profile
   at `E:\north-forge-agent-data\profiles\kyocera\skills\fault-logging\
   SKILL.md` (data, not source — matches the precedent set by the earlier
   Pinokio-removal session). Commit `f40229c`. Everything else matching
   "Hermes" in the deployed `skills/` tree is either the stock, globally-
   shipped Hermes skill library (not North Forge content, out of scope) or
   legitimate technical references to the engine's real native `/clear`
   command by name inside agent-facing instructions (`menu`, `flush`,
   `switch`, `hotline-ticket`) — factually correct, not a branding leak.

## Part 3 — Web terminal (fixed in `north-forge-agent`, verified live)

- **Discoverability**: added `north-forge-web.cmd` + `scripts/make-webui-
  shortcut.ps1` (writes a self-healing "Open Web Terminal.lnk" at the drive
  root, same pattern as the existing launcher/how-to-start shortcuts) to the
  engine repo. Hardcodes `--isolated` (the real fix for the Part 1 finding)
  and always launches via this checkout's own venv, never a bare `hermes`
  on `PATH`. Verified with a real launch — `curl` against the served
  dashboard returned real `HTTP 200`, three times across iterations.
  Engine-repo commit `010af24`.
- **Branding**: built a real `north-forge-kyocera` dashboard theme (schema
  confirmed by reading `hermes_cli/web_server_dashboard.py`'s
  `_normalise_theme_definition` directly, not guessed) reusing this repo's
  own CLI skin's actual forge-gold-on-dark-iron palette
  (`skins/north-forge.yaml`) so the CLI and web surfaces read as one
  product, plus the already-tracked `assets/logo-kyocera-1024.png`
  (inlined as a small base64 data URI). Set as the active theme via
  `dashboard.theme: north-forge-kyocera` in the profile's own
  `config.yaml`. **Real root cause found and worked around during
  verification**: the theme/config that actually governs the dashboard is
  the *per-profile* one (`E:\north-forge-agent-data\profiles\kyocera\
  config.yaml` / `...\profiles\kyocera\dashboard-themes\`), not the
  top-level `HERMES_HOME` — a top-level copy is inert. Verified live via
  the dashboard's own `/api/dashboard/themes` endpoint after correcting
  this: `"active":"north-forge-kyocera"`, full palette/asset definition
  present. **Not yet persisted to source control** — this theme YAML and
  the `config.yaml` line currently exist only as data on the physical `E:\`
  drive (like the CLI skin copy step, or the earlier Pinokio removal), so a
  future from-scratch Excalibur rebuild would not carry it forward. Flagged
  rather than guessed at: it's unclear whether this belongs in this content
  repo (alongside `skins/north-forge.yaml`, though that file actually ships
  from the *engine* repo, not this one), the engine repo's own
  `nf-setup.ps1` install path, or somewhere else — needs a decision before
  the next Excalibur build.

## Part 4 — Pocket Penny / Pine Barron Farms reachability (fixed in `north-forge-agent`, verified)

Real investigation confirmed the task's own hypothesis: `hermes_cli/nf_tier.py`'s
access-tier code has no mechanism for "allow exactly these N editions" — a
Basic-tier drive's `allowed_editions()` is hardcoded to exactly one pin.
Building a narrower allowlist would mean changing the access-tier schema and
enforcement logic itself — the exact category the engine ledger's own
"Agent conduct" rule says to escalate rather than self-fix. Presented this
tradeoff to Kenneth directly (the Claude Code auto-mode classifier
independently flagged the actual re-provisioning call as a permission-grant
action and blocked the first attempt until confirmed) — he chose re-
provisioning this drive full-tier. Re-signed `E:\`'s `provisioning.json`
(`tier: full`, `pinned_edition` stays `kyocera` as the default landing
profile — full-tier's own documented meaning keeps every edition
switchable without changing what a normal launch lands on), then installed
both `penny-pincher` and `pine-barron-farms` as real profiles (neither
existed on this drive before tonight). Verified: `python -m
hermes_cli.nf_tier show` reports `tier: full, locked: no`; `hermes -p
penny-pincher --version` and `-p pine-barron-farms --version` both succeed
with no tier error (previously both would have failed); `hermes doctor`
afterward shows `kyocera: anthropic/claude-sonnet-5, no alias` completely
unchanged. **Real, honest tradeoff**: full-tier removes the hard
single-edition lock entirely on this physical drive — any installed edition
becomes reachable, not only the two named. Acceptable here because this is
Kenneth's own demo drive, not a Basic-tier teammate giveaway drive. Both new
profiles show "missing config, no .env" in `hermes doctor` — expected,
explicitly acceptable per the task's own framing ("rough" is fine) — neither
has a model/API key configured, so an actual chat turn in either will fail
with a provider-not-configured error until one is set. Full options/tradeoff
record: `north-forge-agent`'s `logs/ledger/decisions/DECISION-LOG.md`,
`DECISION-2026-09-13-001`.

## Zone B findings (not fixed - reported only)

- Carried forward unchanged from the last audit: the dead
  `#gateway-service-requirements` anchor; `WELCOME.html`'s stale
  `launch-north-forge.bat`/`.sh` content; the `PINOKIO-on-drive.md` /
  `Advanced/PINOKIO.md` overlap.
- New this session: the dashboard-theme persistence gap described under
  Part 3 above — needs a Blacksmith decision on where Kyocera dashboard
  branding content should live for it to survive a fresh Excalibur build.

## Commits made this session

- `north-forge-hermes-edition`: `f40229c` (fault-logging branding fix),
  `1922627` (`.gitignore` `/skills/` guard fix).
- `north-forge-agent` (engine repo, most of tonight's actual fix work):
  `525a261`, `dd7bc11` (ledger: `ERR-2026-09-13-002` + manifest for
  checkpoint `RUN-2026-09-13-006`), `010af24` (web-terminal launcher +
  shortcut), `492d61d` (ledger: `DECISION-2026-09-13-001`).

## Uncertain / flagged for primary GPT review

1. **Dashboard-theme persistence** (see Part 3) — needs a decision on where
   Kyocera dashboard branding content should live so it survives future
   Excalibur rebuilds, same open-question shape as the earlier
   stick-class-aware-skill-curation gap.
2. **`hermes update` run tonight against `NEXT_STEPS.md`'s standing
   "don't run it" instruction** (Part 1, finding 3) — real owner action, not
   investigated further this session; the underlying "4279 commits behind"
   banner question from 2026-09-04 is still unexplained.
3. Carried forward: the Excalibur console-UI owner-label gap (now actually
   closed per `EXCALIBUR_WALKTHROUGH.md`/engine-repo commits found this
   session — a volume-label field now exists in the deploy console UI; not
   re-verified live this session, flagging that it should be re-confirmed
   next build).
4. Full-tier flip on `E:\` (Part 4) is a real, honest widening of this one
   physical drive's reachable surface — flagged plainly, not silently
   decided; Kenneth confirmed it in-session.

## Status

Needs primary GPT review — two new open items (dashboard-theme persistence,
the `hermes update` standing-instruction conflict) plus the tier-flip
tradeoff, all flagged above, none silently resolved.

Handoff bundle: HANDOFF_2026-09-13_1502.zip (sha256: ebc2338d3704f5cc78bd5f552864964aa6b4b292574524ae89882ce28e7d6f84) - created. (Same bundle as `north-forge-agent`'s own final report for this session — most of tonight's actual fix work happened in that repo; this file records this repo's own two commits and Part 2's findings.)
