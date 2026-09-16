# Greg, keys, and switching rooms

## Gregory W. — GREGW-NOREX

TSE of the desk. Same **admin privileges** as BLACK-NORTH (he may change
engine, keys, and models in the Hermes web UI at any time). The *build*
is still technical-support, not the workshop.

On his stick:

- Desk (TSC / hotline voice)
- Humanizer
- Well Three (the three North Forge + Hermes tools)

Off his stick unless the job is those businesses:

- Workshop / task-builder catalog
- Pinokio
- Pocket Penny
- Pine Barron Farms

Record the two production faces: **BLACK-NORTH**, **GREGW-NOREX**.
"Norax" in speech = the `-NOREX` Excalibur suffix. Name is `NOREX`,
not a separate product.

## Keys

Both of those sticks ship with an application key already set for the
**Anthropic** engine (Hermes Env / `hermes config set ANTHROPIC_API_KEY`).

| Who | Key |
|---|---|
| Corporation | Corporate Anthropic key |
| Kenneth demos | Private Anthropic key, about $25 credit |

Do not put the private demo key on a stick that leaves your bag unless
you mean to burn that $25. Corp key on Greg's production stick. Demo
key on the stick you carry into a room.

Greg can change engine in the web UI whenever he wants. That is the
privilege. Default at setup is still Anthropic until he picks another.

Kenneth also keeps five or six other agents' keys and switches by hand
when a balance dies. Auto-switch between providers is a **later plugin**,
not this build.

## Models at setup

- **BASIC / standard:** the interface already lists a large catalog
  (60+). We do not curate that list down in code this week.
- **Kenneth / elevated:** also offer **recommended free** models so
  someone can explore with no bill and no cap panic.
- Default for a first-run BASIC or explore path: **best available free
  model** (confirm the exact slug at setup; "Noir" / "NOS" name is
  not locked — pick one free default and write the slug on the stick
  envelope).
- BLACK-NORTH and GREGW-NOREX production: Anthropic first, free list
  still visible in Models so they can step down if the bill should stop.

## Two rooms, both first-class

At launch the person chooses **Terminal** or **Web**. Both are correct.
They switch when the job changes.

| From | To | How |
|---|---|---|
| Root | Terminal | Start North Forge / Terminal.lnk |
| Root | Web | Web Interface / `Start-Web-Interface.cmd` |
| Terminal | Web | `WAC web` (or `/web`) — opens the dashboard for engine, credits, models |
| Web | Terminal | A control that launches the desk CLI (link or button labeled Terminal) |

`WAC web` is the old task that already meant "open the web terminal for
reconfig and credit." Keep that name in the desk pack so muscle memory
lives. Wiring `/web` → `hermes dashboard` is a small skill on tsc-core;
do not invent a third UI.

If the web control to spawn Terminal is missing in stock Hermes, that is
a plugin slot — same class as the gold caption. Recommend it; do not
fork `web/src` until the two sticks answer.
