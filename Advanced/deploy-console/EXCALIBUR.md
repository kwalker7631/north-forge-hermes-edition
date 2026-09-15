# Excalibur drive — an admin-capable drive (not the Prime drive)

Renamed 2026-09-14. Before this date, "Excalibur" meant the locked,
teammate-handoff stick — that drive class is now called **Round Table** (see
[ROUND-TABLE.md](ROUND-TABLE.md)). "Excalibur" means this instead:
admin-capable, full-tier, unlocked working drives distributed to trusted
engineers.

**[CORRECTED 2026-09-15]** As of the 2026-09-14 four-drive-class redesign
(see the deploy console UI, `Advanced/deploy-console/ui/index.html`, the
current authoritative source for all four classes), Excalibur is NOT the
top admin tier — **Prime** is. **Prime (BLACK-NORTH) is Kenneth's own
drive only, the one tier with every edition, every skill, and Pinokio
included, and the only drive that can build/provision any other tier.**
Excalibur is "admin-capable, not prime" — capped at 12 drives ("Knights
of the Round Table", label pattern `EXCAL-NOR01`–`12`), carrying Kyocera +
Pine Barron Farms + Pocket Penny plus a curated skill set, and **no
Pinokio** (the section below previously said the opposite — that was wrong;
corrected here). Sections below describing "everything reachable" and
"Pinokio allowed" for Excalibur predate this redesign and are corrected
inline rather than left standing.

This doc previously named a single hardcoded drive letter/label (`F:\`,
`MAIN-NORTH`) as "the current, real Excalibur drive." That concrete example
is kept below for its still-useful command walkthrough, but genericized to
`<DRIVE>:\` — Excalibur is a capped pool of up to 12 drives, not one fixed
letter, and the actual current Prime/admin drive is BLACK-NORTH, not an
Excalibur-class drive at all (see Prime's own definition above).

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
- **No Pinokio** (per the deploy console UI's current class definitions) —
  Pinokio (`Advanced/PINOKIO.md`) is Prime-only (BLACK-NORTH), not part of
  a standard Excalibur build. [CORRECTED 2026-09-15 — this bullet previously
  said the opposite.]
- No forced single-Pin lock — you can hold every edition you're actively
  building or supporting (`field-service`, `penny-pincher`,
  `pine-barron-farms`, the private Kyocera edition, etc.) and switch between
  them, not just the one a teammate stick is locked to.
- An admin passcode still gates *re*-provisioning (changing tier/pin later),
  same mechanism as Round Table — this isn't a security-off mode, just an
  unlocked-switching one.

## Reference example — a sibling-checkout Excalibur-style build

**[GENERICIZED 2026-09-15 — this section previously hardcoded `F:\`
(labeled MAIN-NORTH) as "the current, real Excalibur drive." That specific
drive's current status was not re-verified this pass; the command
walkthrough below is kept as a still-useful reference for this checkout
layout, with the drive letter genericized. The actual current Prime/admin
drive is BLACK-NORTH — see the correction at the top of this file — not an
Excalibur-class drive.]**

The process below is confirmed to work on a **sibling-checkout** layout
(the private Kyocera edition is a sibling checkout at the drive root, not
nested under `north-forge-agent\private-editions\` the way a
`Zero-Touch-Deploy.ps1` build produces it — `nf-setup.ps1`'s automatic
install-from-`editions\`/`private-editions\` fallback doesn't reach a
sibling checkout, so the edition needs installing as a profile explicitly
first). BLACK-NORTH itself does NOT use this sibling layout — its private
Kyocera edition checkout was relocated into
`north-forge-agent\private-editions\kyocera\` during its 2026-09-15
provisioning session specifically so the automatic fallback *does* apply
there; use whichever layout matches the drive actually in front of you:

```powershell
# From <DRIVE>:\north-forge-agent, with the drive's own venv, HERMES_HOME
# pointed at the drive-local data dir:
$env:HERMES_HOME = '<DRIVE>:\north-forge-agent-data'

# Sibling layout only - install each edition as a profile first (repeat per
# edition; only needed once per edition, or again after -Force
# re-provisioning if data was reset):
<DRIVE>:\north-forge-agent-venv\Scripts\hermes.exe profile install <DRIVE>:\north-forge-hermes-edition -y
<DRIVE>:\north-forge-agent-venv\Scripts\hermes.exe profile install <DRIVE>:\north-forge-agent\editions\field-service -y
<DRIVE>:\north-forge-agent-venv\Scripts\hermes.exe profile install <DRIVE>:\north-forge-agent\editions\penny-pincher -y
<DRIVE>:\north-forge-agent-venv\Scripts\hermes.exe profile install <DRIVE>:\north-forge-agent\editions\pine-barron-farms -y

# Then provision, with -SkipEditionInstall since profiles are already installed:
.\scripts\nf-setup.ps1 -Tier full -Pin default -Installed kyocera,field-service,penny-pincher,pine-barron-farms -SetPasscode -Passcode <your-passcode> -NonInteractive -SkipEditionInstall

# Verify:
python -m hermes_cli.nf_tier verify   # should print "state: active", exit 0
```

Excalibur's standard edition set per the deploy console UI is Kyocera +
Pine Barron Farms + Pocket Penny (no Field Service) — the command above
installs all four because it is a sibling-layout reference example, not
a strict Excalibur-class recipe; drop the `field-service` install/pin if
building an actual Excalibur-class drive to match its documented curated
set.

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

## Excalibur vs. Round Table vs. Prime, side by side

**[CORRECTED 2026-09-15 — added the Prime column; fixed the Pinokio row,
which previously said Excalibur allows it.]**

| | **Prime** (Kenneth only) | **Excalibur** (admin, capped at 12) | **Round Table** (teammate) |
| --- | --- | --- | --- |
| Tier | `full` | `full` | `basic` |
| Git | present, usable | present, usable | none on the teammate path |
| Pinokio | yes — the only class that gets it | **no** | never |
| Editions reachable | every one, switchable | every one, switchable | one, locked |
| Who | Kenneth only | trusted engineers | everyone else |
| API key | your real key, your call | your real key, your call | real key configured by you before handoff |
| Built via | organic dev checkout, provisioned `--prime --admin` | organic dev checkout, or `Zero-Touch-Deploy.ps1 -Tier full` | always `Zero-Touch-Deploy.ps1 -Tier basic` |

Sales and North-Forge classes also exist (see the deploy console UI) but
are out of scope for this admin-drive comparison.
