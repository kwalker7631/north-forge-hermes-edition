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

As of 2026-09-14: **unprovisioned** (confirmed via
`python -m hermes_cli.nf_tier show` from the drive's own venv — no
`provisioning.json` record exists yet). It has been a working dev checkout
all along, which is why it's been usable without any tier record, but it has
not yet gone through a real `nf-setup.ps1 -Tier full` Setup Run.

To provision it as a real Excalibur (full-tier) drive:

```powershell
# From F:\north-forge-agent, with the drive's own venv:
F:\north-forge-agent-venv\Scripts\python.exe -m hermes_cli.nf_tier show   # confirm current state first

.\scripts\nf-setup.ps1 -Tier full -Pin <default-edition> -Installed <edition1,edition2,...> -SetPasscode -Passcode <your-passcode>
```

**Not yet verified end-to-end on this specific checkout layout** — flagging
honestly rather than asserting it's been tested: `nf-setup.ps1` auto-installs
an edition as a Hermes profile from `editions\<name>\` (public) or
`private-editions\<name>\` (gitignored, admin-cloned) *inside the
`north-forge-agent` checkout*. On `F:\`, the private Kyocera edition
(`north-forge-hermes-edition`) is a **sibling** checkout at the drive root,
not nested under either of those paths — which is a different layout than a
Zero-Touch-Deploy.ps1 build produces (that script clones it *into*
`private-editions\kyocera\` directly). It may need `hermes profile install
F:\north-forge-hermes-edition` run first, with `-SkipEditionInstall` on the
`nf-setup.ps1` call, rather than relying on its automatic install fallback.
Confirm this together with Kenneth before treating it as documented fact —
do not copy this command block into a Round Table build's instructions, and
do not assume it works unmodified until someone has actually run it once
against this exact layout.

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
