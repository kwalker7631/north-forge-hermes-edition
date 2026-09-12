# North Forge — Kyocera Edition (Private)

<p align="center">
  <img src="assets/north-forge-banner-etched.png" alt="North Forge" width="820">
</p>

**This is the TSC pack.** The public repo is the chassis. This one is the brain you load onto a stick for the support desk.

It does not replace a technician. It cuts the friction on a live call: intake, a next step, and a straight “I don’t have that page” when the pack is thin.

**Version:** `distribution.yaml` v0.1.0 · **Date:** 12 September 2026 · **Author:** Kenneth C. Walker Jr.  
**Access:** private. Teammates get a stick, not this repo.

Read this first: **[CURRENT.md](CURRENT.md)**  
Build a stick: **[Advanced/deploy-console/DEPLOY.md](Advanced/deploy-console/DEPLOY.md)**  
How it learns: **[LEARNING.md](LEARNING.md)**

---

## What you hand a teammate

1. Plug the stick in.
2. Double-click **Start North Forge**.
3. Type the model and the code like a coworker.  
   Example: *TASKalfa 3554ci showing an F248 after printing.*
4. If they get lost, they type `/menu`.

Volume name is **FIRSTL-NORTH**. Greg Warhol becomes **GREGW-NORTH**. Agent name is optional; default is North Forge.

They do not need Git, GitHub, or a password. If the stick dies, they hand it back. They do not format it.

---

## What this pack covers

Print, scan, finish, paper path, supplies. The PC and network the device sits on (Windows, macOS, Linux). PaperCut, MyQ, and the other document tools the skills know. Hotline, KB draft, escalation, fault log, new-hire training.

When it has a procedure, it should give the next exact step. When it does not, it should stop and keep the answer after someone supplies it.

That is the product — not a search box with manners.

---

## Architecture (current)

As of 11 September 2026 this repo is a **profile pack**. It installs into a public North Forge checkout. It is not a standalone product with its own FULL/SALES toggle or `.hermes-home`.

Those launchers still exist under `archive/legacy-standalone-launcher/`. Do not use them for a new stick.

```
USB
  Start North Forge.lnk
  HOW_TO_START.txt
  north-forge-agent/                 public engine
    private-editions/kyocera/        this repo, cloned here
  north-forge-agent-venv/
  north-forge-agent-data/            HERMES_HOME + admin hash
```

Admin builds the stick from **Advanced/deploy-console/** on a PC that has already done `gh auth login` once.

---

## Skills (what a tech can type)

| Skill | Command | Job |
|---|---|---|
| menu | `/menu` | Front door |
| assist-intake | `/a` `/assist` | Structured intake |
| hotline-ticket | `/hl` `/ticket` | Ticket packet |
| kb-builder | `/kb` | KB draft to the locked template |
| draft-writer | `/draft` | Short draft |
| escalation-packet | `/esc` | Escalation with evidence on hand |
| fault-logging | `/log` `/fault` | Durable fault record |
| forge-audit | `/audit` `/chk` | Check a draft against the rules |
| training-guide | `/train` | Teach a new tech the workflow |
| sales-assist | sales prompts | Pre-sales |
| web-navigator | vendor hops | Official public pages only |
| kyocera-research | research / cron | Public release-note watch |
| daily-brief | brief | Morning digest |

Sharp / Ricoh / Xerox later is this table with different portals.

---

## Admin: install this pack by hand

Only if you are not using the deploy console.

```
git clone git@github.com:kwalker7631/north-forge-hermes-edition.git private-editions/kyocera
```

From the public checkout:

```
scripts\nf-setup.ps1 -Tier basic -Pin kyocera -Installed kyocera
```

Use `-Tier full` only on an admin stick that should switch projects. Passcode is set with `scripts\nf-setup.ps1 -SetPasscode` on the engine side. Hash only. Never write the code in this file.

Update later: `hermes profile update kyocera`

If a stick looks wrong: `scripts\nf-setup.ps1 -Show` and `scripts\nf-preflight.ps1` in the **engine** repo, not the old Advanced reset scripts.

---

## Governance

Kenneth C. Walker Jr. is the only person who commits here. Teammates do not touch Git. Suggestions come back as a note or a fault log.

---

## Thanks

The runtime under the public checkout is [Hermes Agent](https://github.com/NousResearch/hermes-agent) by Nous Research and contributors (MIT). Thank you. It is not what you pitch first.
