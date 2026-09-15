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

## Drive classes (production intent)

**BLACK-NORTH — master / Prime / superdrive**
Kenneth only. The reference. Target size is the big lab stick (up to ~2 TB
when the library and Pinokio live on it), not the 32 GB teammate stick.
Every edition, every skill, add-ons, GitHub auth required to *build*
others. This is the only drive that is allowed to spawn the rest.

**Public North Forge**
What a stranger can clone. Stock Hermes + North Forge branding. No Kyocera
private pack, no locksmith, no Excalibur numbering. Knowledge pool is
whatever the public chassis ships.

**Private North Forge Hermes Edition**
The Kyocera pack on a stick. Isolated Hermes home on that volume. Extra
features the public tree does not get: edition lock, drive-class stamp,
Excalibur numbering (`EXCAL-NOR01`–`12`), locksmith / admin passcode,
desk modes. Built only from BLACK-NORTH + GitHub auth on the admin PC.

**Greg W. (first supervisor stick)**
Label pattern `GREGW-NORTH`. One production instance besides the master.
Same private pack, not the 2 TB library. He double-clicks Terminal.
He does not see Advanced or etc.

Until more sticks exist, production is: BLACK-NORTH + Greg. That is the
whole fleet. Do not write docs as if there are twelve Excaliburs already.

## Shared knowledge pool

Every *private* stick is supposed to drink from the same well:

- Kyocera faults, fixes, and "what actually worked"
- Hotline / KB drafts
- Research the cron agents pull from public sources

The well lives with the pack (profile + skills + research-log + kb-drafts),
not as a second cloud product. Sync story later. Today: build from the
master so the pack is identical, then each stick learns locally.

## Isolated on purpose

Each stick has its own `north-forge-agent-venv` and
`north-forge-agent-data`. It must not adopt or wipe a Hermes install that
already lives on the host PC. First plug-in on a new PC may repair the
venv once. That is isolation working, not a failed install.

## What an intimidated admin actually does

1. On the admin PC: GitHub login once (`gh auth login`).
2. Open Deploy Console as administrator.
3. Pick the USB (letter or RAW Disk N).
4. Choose class / tier. Label the person (`GREGW-NORTH`).
5. FORMAT + passcode + deploy. Walk away.
6. When it says complete: Hermes dashboard or Set-Inference for the key.
7. Hand the person HOW_TO_START — two buttons, Terminal and Web.

They never type `hermes`. They never edit PATH.
