# North Forge — Kyocera Edition

<div align="center">
<img src="assets/north-forge-banner-etched.png" alt="North Forge" width="820">

# The pack for the desk

This is not a demo. This is the private manufacturer edition — the procedures,
the skills, the deploy path — loaded onto the public chassis so a technician
can work like they have a senior sitting with them.

<br>

[![Edition](https://img.shields.io/badge/Edition-Kyocera-0B1F3A?style=for-the-badge)](CURRENT.md)
[![Version](https://img.shields.io/badge/Distribution-v0.1.0-2563EB?style=for-the-badge)](distribution.yaml)
[![Access](https://img.shields.io/badge/Repository-Private-111827?style=for-the-badge)](#)
[![Philosophy](https://img.shields.io/badge/Spirit-Blue%20Book-1E3A5F?style=for-the-badge)](PHILOSOPHY.md)

**Version:** `distribution.yaml` v0.1.0 · **Kenneth C. Walker Jr.**  
**Private.** Teammates receive a drive. They do not receive this repository.

</div>

---

> [!NOTE]
> This pack does not replace judgment. It exists so judgment has somewhere honest to stand: the next step when we have it, the hole when we do not.

| Start | Purpose |
|---|---|
| **[CURRENT.md](CURRENT.md)** | Architecture and skill catalog |
| **[PHILOSOPHY.md](PHILOSOPHY.md)** | How this pack is supposed to behave — Blue Book spirit, our words |
| **[DEPLOY.md](Advanced/deploy-console/DEPLOY.md)** | Build a drive without asking a tech to learn Git |
| **`/readme kyocera`** | In-session map |

---

## Why this exists

Kyocera's house is built on doing what is right as a human being, putting the
customer first, and accumulating the kind of effort nobody applauds. The desk
is that house in miniature. A call is not a search query. It is a person, a
machine, and a clock.

North Forge Kyocera Edition is the long prompt that nobody on a live call will
ever write — broken into compartments so a teammate can stay on the floor:

- the device (print, scan, finish, paper path, supplies)
- the PC and the network it sits on
- PaperCut, MyQ, and the document tools this pack has been taught
- intake, ticket, knowledge-base draft, escalation, fault log, training

The power is not that it talks. The power is that it is supposed to **know
when it does not know**, keep what the shop teaches, and refuse to sound like
a brochure while a machine is down.

That is commitment. Not a slogan. A rule you can catch it breaking.

## What this pack can do

| Capability | On the drive |
|---|---|
| Structured intake | `/a` `/assist` — the minimum useful facts, in order |
| Hotline / ticket packet | `/hl` `/ticket` — what to send, not a novel |
| Knowledge-base draft | `/kb` — locked template, not a free-form essay |
| Escalation | `/esc` — evidence that exists, gaps named |
| Fault history | `/log` `/fault` — so the next person is not starting from zero |
| New-hire path | `/train` — the workflow, not the entire industry |
| Sales assist | when the call is still a conversation about the product |
| Official pages only | vendor hops to public pages, not rumor treated as fact |
| Nightly public watch | research / brief jobs on an admin PC that stays on |
| Documentation map | `/readme` `/readme kyocera` `/readme north-forge-agent` |

Live fault walkthroughs belong in those skills. They do not belong on this
page. The front door is the promise. The shop floor is the pack.

## Who receives what

A **technician** gets a labeled drive (`GREGW-NORTH`), double-clicks
**Start North Forge**, and talks. They do not format it. They do not learn a
vendor.

An **administrator** builds that drive from
[ADMIN_FIRST_TIME.txt](Advanced/deploy-console/ADMIN_FIRST_TIME.txt) after a
one-time GitHub sign-in on the admin PC.

This repository is a **profile pack**. It installs into the public
[north-forge-agent](https://github.com/kwalker7631/north-forge-agent) checkout.
Retired FULL/SALES launchers live under `archive/`. Do not use them for a new
drive.

## Architecture

```
USB
  Start North Forge.lnk
  HOW_TO_START.txt
  north-forge-agent/                 public chassis
    private-editions/kyocera/        this repository
  north-forge-agent-venv/
  north-forge-agent-data/            memory + admin hash
```

## Admin — advanced, by hand

Prefer the deploy console. If you must install the profile yourself, open
**PowerShell in the public North Forge folder**, then:

```
git clone git@github.com:kwalker7631/north-forge-hermes-edition.git private-editions/kyocera
scripts\nf-setup.ps1 -Tier basic -Pin kyocera -Installed kyocera
```

`-Tier full` is for an admin drive that must switch projects. Passcode:
`scripts\nf-setup.ps1 -SetPasscode` on the engine side. Hash only.

## Governance

Kenneth C. Walker Jr. is the only person who commits here. Suggestions come
back as a note or a fault log. That is not control for its own sake. It is
how the pack stays one mind.

## Thanks

The runtime is [Hermes Agent](https://github.com/NousResearch/hermes-agent)
(Nous Research, MIT). Listed last. The first page is the work.
