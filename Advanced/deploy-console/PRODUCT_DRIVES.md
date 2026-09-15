# What we are actually shipping

These scripts exist so a non-technical admin can stand up a portable
Hermes without living in Git. Intimidation is the bug. The stick is the fix.

There are two different "web" things. Do not blend them.

| Thing | Who | Job |
|---|---|---|
| **Deploy Console** (`Launch-Deploy-Console.cmd`) | Admin with GitHub auth | Format, partition, clone, label, lock, spawn another stick |
| **Hermes dashboard** (`Start-Web-Interface.cmd` / `hermes dashboard`) | Whoever has the stick | Keys, models, skills, memory / vector store |

## Volume labels (current rule)

| Class | Pattern | Example |
|---|---|---|
| Master / Prime | `BLACK-NORTH` | `BLACK-NORTH` |
| Excalibur | `FIRSTL-NOREX` | `GREGW-NOREX` |
| Standard private | `FIRSTL-NORTH` | `SARAHM-NORTH` |
| Basic | `BASIC-NORTH` | `BASIC-NORTH` |

Greg Warhol is Excalibur → `GREGW-NOREX`. Not `GREGW-NORTH`, not bare `NOR-EX`.

## Drive classes (production intent)

**BLACK-NORTH** — master / Prime. Kenneth only. Superdrive (up to ~2 TB
when the library and Pinokio live on it). Only drive allowed to spawn others.
GitHub auth required to build.

**Public North Forge** — stock Hermes + branding. No private pack.

**Private North Forge Hermes Edition** — Kyocera pack, locksmith, desk
modes. Built from BLACK-NORTH + GitHub auth.

**Greg W.** — first Excalibur in production. Label `GREGW-NOREX`.
Terminal only for him. Production fleet today: BLACK-NORTH + GREGW-NOREX.

## Shared knowledge pool

Private sticks share the Kyocera well (faults, fixes, KB drafts, agent
research) by cloning the pack from the master. Local learning after that.

## Isolated on purpose

Own venv + `north-forge-agent-data` per stick. Must not touch a host Hermes.
First plug-in on a new PC may repair the venv once.

## Intimidated admin

Deploy Console as admin → label from the table → FORMAT + passcode →
Hermes dashboard or Set-Inference for the key → HOW_TO_START.
Never type `hermes`. Never edit PATH.
