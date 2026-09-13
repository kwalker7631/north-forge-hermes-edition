# Excalibur drive — first viewer (manager)

This is the handoff stick. Not a lab clone. Not Pinokio. Not a terabyte
of models. One prepared Kyocera drive that a Blue Book reader can
judge in ten minutes.

## What “Excalibur” means here

- Locked to the Kyocera pack
- Volume label **FIRSTL-NORTH** for the person who will hold it
- Admin passcode set (hash only)
- An inference provider actually configured (see step 7a below) — without
  this, the drive cannot answer anything at all
- **Start North Forge** at the root
- HOW_TO_START.txt and ASSIGNED_TO.txt on the root
- Public chassis + private edition already pinned
- No FULL/SALES toggle, no Git on the teammate path

If any of that is missing, it is not ready for the first viewer.

## Build it (admin PC, once)

Follow the real guide, in this order. Do not invent a second path.

1. [ADMIN_FIRST_TIME.txt](ADMIN_FIRST_TIME.txt) — Git, GitHub CLI, Python if asked, `gh auth login` once.
2. [DEPLOY.md](DEPLOY.md) — Run `Launch-Deploy-Console.cmd` **as administrator**.
3. USB or SSD, **32 GB or larger** for this stick (8 GB is the floor; give the first viewer room).
4. Assigned to: the manager's first and last name → label `GREGW-NORTH` style.
5. Agent name: leave **North Forge** unless they asked for a nickname.
6. Tier: **Locked**. Pin: **Kyocera**.
7. Type `FORMAT`. Type the passcode twice.
7a. **Configure the inference provider now — not documented anywhere
    before this, and the drive cannot answer anything without it.** From
    the checkout root (`<drive>\north-forge-agent`), with
    `HERMES_HOME=<drive>\north-forge-agent-data`:
    ```
    hermes config set ANTHROPIC_API_KEY <the real key>
    hermes config set model anthropic/claude-sonnet-5
    ```
    Confirm with `hermes config show` — `Anthropic` should show a masked
    key, `Model:` should read `anthropic/claude-sonnet-5`. Run a real
    prompt (`hermes -z "..."`) before handing the drive over; a
    "No inference provider configured" error means this step was skipped
    or failed.
8. Wait until HOW_TO_START.txt is on the root.
9. On a **second** PC if you have one, plug it in and do the four teammate steps yourself before you hand it over.

## What you say when you hand it over

Not “this is AI.” Not “this is Hermes.”

Say:

> This is a desk copy. Plug it in. Start North Forge. Talk like you
> would to the go-to on the desk. If it does not know, it is supposed
> to say so. If you teach it, it is supposed to keep that. I built it
> on the side of the job because the books ask for earnest effort, and
> a search box is not that.

Then stop talking. Let them use it.

## Ten-minute first look

1. Plug in. Confirm the volume name is theirs.
2. Double-click **Start North Forge**. First boot on a new PC can be slow.
3. Type a real morning problem in ordinary English.
4. `/menu` if lost. `/readme kyocera` for the map.
5. Ctrl+C when done.

## Do not put on this stick

Pinokio, local model zoos, AppData installs, the research archive.
Those bury the sale.

## After they use it

Write down what they corrected. That note is the next commit.
