# What we are actually shipping

These scripts exist so a non-technical admin can stand up a portable
Hermes without living in Git. Intimidation is the bug. The stick is the fix.

There are two different "web" things. Do not blend them.

| Thing | Who | Job |
|---|---|---|
| **Deploy Console** (`Launch-Deploy-Console.cmd`) | Admin with GitHub auth | Format, partition, clone, label, lock, spawn another stick |
| **Hermes dashboard** (`Start-Web-Interface.cmd` / `hermes dashboard`) | Whoever has the stick | Keys, models, skills, memory / vector store |

Deploy Console is authorized drive *creation*. Hermes dashboard is day-to-day
*configuration*. We customize the live Hermes repo for the second. We do not
rebuild it inside the first.

## Volume labels (current rule)

See DRIVE_LABELS.txt. Short form:

| Class | Label |
|---|---|
| Master / Prime | `BLACK-NORTH` |
| Excalibur (supervisor) | `NOR-EX` (Greg's stick). Not `GREGW-NORTH`. |
| Standard private | `FirstnameLastinitial-NORTH` e.g. `SARAHM-NORTH` |
| Basic | `BASIC-NORTH` |

Older docs that say `GREGW-NORTH` or `EXCAL-NOR01` for Greg are stale.
Greg is Excalibur → `NOR-EX`.

## Drive classes (production intent)

**BLACK-NORTH — master / Prime / superdrive**
Kenneth only. The reference. Target size is the big lab stick (up to ~2 TB
when the library and Pinokio live on it), not the 32 GB teammate stick.
Every edition, every skill, add-ons, GitHub auth required to *build*
others. This is the only drive that is allowed to spawn the rest.

**Public North Forge**
What a stranger can clone. Stock Hermes + North Forge branding. No Kyocera
private pack, no locksmith, no Excalibur label. Knowledge pool is
whatever the public chassis ships.

**Private North Forge Hermes Edition**
The Kyocera pack on a stick. Isolated Hermes home on that volume.
Locksmith / admin passcode, desk modes, drive-class stamp. Built only
from BLACK-NORTH + GitHub auth on the admin PC.

**Greg W. (first Excalibur in production)**
Label `NOR-EX`. One production instance besides the master. Same private
pack, not the 2 TB library. He double-clicks Terminal. He does not see
Advanced or etc.

Until more sticks exist, production is: BLACK-NORTH + NOR-EX. That is the
whole fleet.

## Shared knowledge pool

Every *private* stick drinks from the same well: Kyocera faults, fixes,
hotline / KB drafts, research the cron agents pull. The well lives with
the pack. Sync across sticks later. Today: clone from the master.

## Isolated on purpose

Each stick has its own venv and `north-forge-agent-data`. It must not
adopt or wipe a Hermes install already on the host PC. First plug-in on
a new PC may repair the venv once.

## What an intimidated admin actually does

1. GitHub login once on the admin PC.
2. Deploy Console as administrator.
3. Pick the USB (letter or RAW Disk N).
4. Label from the table above (`NOR-EX`, `SARAHM-NORTH`, `BASIC-NORTH`).
5. FORMAT + passcode + deploy. Walk away.
6. Hermes dashboard or Set-Inference for the key.
7. HOW_TO_START — Terminal and Web only.

They never type `hermes`. They never edit PATH.
