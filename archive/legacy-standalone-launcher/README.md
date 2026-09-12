# Legacy standalone-drive launcher (retired)

This folder holds the pre-`distribution.yaml` install model for North Forge —
Hermes Edition. It is kept for reference only. **Nothing in here is runnable
from this location** — every script assumes it lives at the repo root (relative
paths, `$PSScriptRoot`/`%~dp0` assumptions, sibling files like `.env.example`,
`forge-events.log`) and none of that context exists here.

## What this used to do

This repo used to be a fully standalone, drive-installable product: cloning it
onto a USB/portable drive and running `launch-north-forge.bat` /
`launch-north-forge.sh` would provision its own private Hermes engine and venv
under `.hermes-home/` on that same drive (via `scripts/ensure-hermes.ps1/.sh`),
completely isolated from any other Hermes install on the machine. `Advanced/`
held the harder drive-lifecycle operations (fresh provisioning, full reset,
FULL/SALES mode toggling), and `scripts/hermes-drive.ps1/.sh` was the runtime
wrapper the launcher staged into place after install.

## Why it was retired

North Forge's chassis (`north-forge-agent`) grew a proper first-class mechanism
for exactly this: a **Hermes profile distribution** — a folder with
`distribution.yaml` + `SOUL.md` (+ `skills/`), installed with the engine's own
`hermes profile install <source>`, which already supports a private git URL or
a local directory natively. That makes a bespoke per-drive install/launcher
system unnecessary: this content now installs as a normal profile into an
*already-running* North Forge/Hermes environment — no separate `.hermes-home`,
no separate venv, no custom bootstrap script to maintain and test.

See the repo root `SOUL.md` and `distribution.yaml` for the current install
path, and `north-forge-agent`'s `editions/README.md` for how a distribution
becomes a live profile.

## Contents

| Original path | What it did |
| --- | --- |
| `launch-north-forge.bat` / `.sh` | Drive launcher — write-probe, `.hermes-home` setup trigger, mode selection, hand-off to the Hermes CLI. |
| `scripts/ensure-hermes.ps1` / `.sh` | Installed (or validated) the drive-local Hermes engine under `.hermes-home/`. |
| `scripts/hermes-drive.ps1` / `.sh` | Runtime wrapper staged into `.hermes-home/bin` after install. |
| `scripts/machine-reset-safety.ps1` | Guardrails around resetting a drive's Hermes install without touching shared machine state. |
| `Advanced/provision-new-drive.ps1` | Fresh-drive provisioning flow. |
| `Advanced/full-drive-reset.sh` | Full wipe-and-reprovision of a drive's `.hermes-home`. |
| `Advanced/toggle-mode.sh` | Switched a drive between FULL and SALES mode (see below). |
| `tests/*` (the ones moved alongside this README) | The dedicated test suite for all of the above — drive isolation, install/reset integrity, launcher behavior, skill assembly. |
| `tests/test_cron_registration.py`, `tests/test_drive_hermes_contract.py`, `tests/test_launcher_hermes_home.py` | Moved here 2026-09-12 (left behind at the first retirement pass, still exercising `launch-north-forge.sh`/`.bat` and failing on every run since those files moved). Cron self-scheduling for the currently shipping edition is now `north-forge-agent`'s `scripts/nf_sync_cron.py`, covered by that repo's own test suite — see this repo's `CHANGELOG.md`. |

`archive/setup-thumbdrive.ps1` (one level up, already archived before this
retirement) is the original first-time Windows setup script and is unrelated
to this quarantine — left where it already was.

## The FULL/SALES mode system

This launcher generation also carried its own internal mode system
(`skills-source/shared` + `skills-source/tsc-only` + `mode-blocks/*.md`,
assembled by `scripts/assemble-skills.ps1`) to produce a FULL- or SALES-only
runtime skill set. That system was retired in the same pass as this launcher
(see the repo's session report for this restructure) in favor of one flat
edition carrying all skills, with reachability controlled by
`north-forge-agent`'s existing Full/Basic tier + admin-passcode gate instead of
a baked-in mode. `scripts/assemble-skills.ps1` and `mode-blocks/` are archived
alongside this launcher, not inside it, since they're a separate (if related)
system — see the sibling note in this repo's restructure session report for
exactly where they landed.
