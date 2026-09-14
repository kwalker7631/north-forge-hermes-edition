# Excalibur drive — the admin/designer drive

Renamed 2026-09-14. Before this date, "Excalibur" meant the locked,
teammate-handoff stick — that drive class is now called **Round Table** (see
[ROUND-TABLE.md](ROUND-TABLE.md)). "Excalibur" means this instead: the
admin/designer's own elevated working drive — full tier, unlocked, everything
reachable. The king wields Excalibur; everyone he builds a drive for sits at
the Round Table.

`F:\` (labeled **MAIN-NORTH**) is the current, real Excalibur drive — the
primary admin drive going forward, not a rotating test letter.

## What "Excalibur" means here

Per `north-forge-agent`'s own `scripts\nf-setup.ps1` (the thing that actually
writes this distinction to disk):

> `full` — the pin is only the default landing edition; every switch path
> stays open (`hermes profile use` / the dashboard / `/edition`). Admin +
> trusted engineers.

Concretely, an Excalibur drive has:

- **`-Tier full`** provisioning (see below) — no single edition lock; every
  installed profile stays reachable and switchable.
- **Git present** and usable directly — both `north-forge-agent` and
  `north-forge-hermes-edition` (and any other editions) as real, working
  checkouts you can pull/commit/push in, not a stripped teammate copy.
- **Pinokio allowed** (per `Advanced/PINOKIO.md`) — the admin/lab case,
  distinct from Round Table, which never gets Pinokio.
- No forced single-Pin lock — you can hold every edition you're actively
  building or supporting (`field-service`, `penny-pincher`,
  `pine-barron-farms`, the private Kyocera edition, etc.) and switch between
  them, not just the one a teammate stick is locked to.
- An admin passcode still gates *re*-provisioning (changing tier/pin later),
  same mechanism as Round Table — this isn't a security-off mode, just an
  unlocked-switching one.

## Current status of `F:\` (MAIN-NORTH)

**Provisioned and verified 2026-09-14** — `state: active`, `tier: full`,
`locked: no — editions are switchable`, signature verified via
`python -m hermes_cli.nf_tier verify` (exit 0 — the same check
`north-forge.cmd` runs before every launch). Four editions installed and
switchable: `kyocera`, `field-service`, `penny-pincher`, `pine-barron-farms`.
Admin passcode set (hash only, per the mechanism above — not stored in
plaintext once configured).

The process, confirmed working on this checkout's specific layout (the
private Kyocera edition is a **sibling** checkout at the drive root, not
nested under `north-forge-agent\private-editions\` the way a
`Zero-Touch-Deploy.ps1` build produces it — `nf-setup.ps1`'s automatic
install-from-`editions\`/`private-editions\` fallback doesn't reach a
sibling checkout, so the edition needs installing as a profile explicitly
first):

```powershell
# From F:\north-forge-agent, with the drive's own venv, HERMES_HOME pointed
# at the drive-local data dir:
$env:HERMES_HOME = 'F:\north-forge-agent-data'

# Install each edition as a profile first (repeat per edition; only needed
# once per edition, or again after -Force re-provisioning if data was reset):
F:\north-forge-agent-venv\Scripts\hermes.exe profile install F:\north-forge-hermes-edition -y
F:\north-forge-agent-venv\Scripts\hermes.exe profile install F:\north-forge-agent\editions\field-service -y
F:\north-forge-agent-venv\Scripts\hermes.exe profile install F:\north-forge-agent\editions\penny-pincher -y
F:\north-forge-agent-venv\Scripts\hermes.exe profile install F:\north-forge-agent\editions\pine-barron-farms -y

# Then provision, with -SkipEditionInstall since profiles are already installed:
.\scripts\nf-setup.ps1 -Tier full -Pin default -Installed kyocera,field-service,penny-pincher,pine-barron-farms -SetPasscode -Passcode <your-passcode> -NonInteractive -SkipEditionInstall

# Verify:
python -m hermes_cli.nf_tier verify   # should print "state: active", exit 0
```

`-Pin default` lands on the generic North Forge chassis rather than any one
edition, since full tier makes every installed edition switchable anyway —
there's no single "home" edition the way a locked Round Table build has one.

## Building a *second* Excalibur drive (a new admin/designer machine)

Same pipeline as Round Table, different tier:

```powershell
Zero-Touch-Deploy.ps1 -DriveLetter E -ConfirmFormat FORMAT -Tier full -Pin <default-edition> -Passcode <your-passcode> -Label <whatever>
```

`-Tier full` also changes `Zero-Touch-Deploy.ps1`'s own default: Pinokio is
**not** excluded automatically (that default only applies to `-Tier basic` /
Round Table builds) — pass `-ExcludeSkills @('pinokio')` explicitly if you
want it off anyway.

## Excalibur vs. Round Table, side by side

| | **Excalibur** (admin) | **Round Table** (teammate) |
| --- | --- | --- |
| Tier | `full` | `basic` |
| Git | present, usable | none on the teammate path |
| Pinokio | allowed | never |
| Editions reachable | every installed one, switchable | one, locked |
| Who | you, trusted engineers | everyone else |
| API key | your real key, your call | real key configured by you before handoff |
| Built via | organic dev checkout, or `Zero-Touch-Deploy.ps1 -Tier full` | always `Zero-Touch-Deploy.ps1 -Tier basic` |
