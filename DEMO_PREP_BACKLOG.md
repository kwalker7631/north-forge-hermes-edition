# Demo Prep & Polish Backlog

Running list of things flagged for the Greg demo and beyond. Add to this as
things come up - doesn't need to be exhaustive in one pass.

## 1. Visual interface / branding for the demo (OPEN)

Current state: CLI only, with the `north-forge.yaml` skin (colors, agent
name, welcome text). Functional, but not what Kenneth wants to show Greg -
looking for a "Cadillac," not a terminal window.

Real option identified: Hermes's **Web Dashboard** (`hermes dashboard`,
browser-based, `localhost:9119`) supports a genuine custom theme (YAML) plus
a plugin system capable of a full visual reskin (custom panels, logos, HUD
elements) - not just terminal colors. The dashboard embeds the actual North
Forge chat as one tab (real TUI over an authenticated connection), so
underlying behavior is unchanged - this is purely a "how it looks" upgrade.

Hermes Desktop (native installed app) was also found and considered, but
it's Nous Research's own app shell - less room to make it look
Kyocera-specific than the Dashboard's theme/plugin route.

Not yet built: an actual Kyocera-branded dashboard theme + plugin. Needs:
Kyocera logo asset, confirmation of exact brand colors beyond what's already
in the KB visual standard, and a decision on layout/panels wanted for the
demo before this gets built.

## (add more items here as they come up)

## 2. Fault-logging skill - priority bumped (OPEN)

Kenneth confirmed the actual support loop he wants: a team member never
touches this repo directly. If someone has a problem or suggestion, it comes
to Kenneth as a log/description, he relays it into the Claude Project chat,
gets a diagnosis + fix, and applies it (directly or via Claude Code). This
makes `skills-source/tsc-only/fault-logging/` (still just a placeholder, not
built) load-bearing for how the whole team-facing side of this is actually
meant to work, not just one item in a list of six equally-weighted unbuilt
skills. Build this one next, ahead of the other five placeholders.

## 3. Pine Barren Farms - separate deployment, not started (OPEN)

Kenneth's other project: portable AI demos for elderly-home audiences (his
mother's facility in Edison, and one other, so far). Target user is someone
who "knows nothing about computers" but follows instructions well - a much
higher simplicity bar than the TSC team. Likely wants mobile-friendliness
specifically (Hermes's messaging-gateway bridge to Telegram/WhatsApp/etc. was
mentioned earlier in this project as a real, already-available path, not
speculative).

Concrete plan (2026-08-26): Pine Barren Farms already exists as a separate,
already-developed project (details TBD - not yet described what form it
takes: prompt, scripts, video material, etc.). Intent is to prove the Forge
System skeleton generalizes by porting it in as a proof-of-concept, using
North Forge Kyocera Edition's build as the template.

IMPORTANT - recommended approach, flagged back to Kenneth for confirmation:
build this as a SIBLING repo (e.g. `north-forge-pine-barren-farms`), not by
overwriting or repurposing this repo's content. Kyocera Edition is an active,
soon-to-be-demoed deliverable (Greg) - the proof-of-concept that the
architecture generalizes and the safety of that specific deliverable should
never be the same risk. The Forge System conventions (engine/content split,
mode toggle, skin, launcher scripts, CLAUDE.md governance) are what transfers
- a new repo built the same way, not this one converted.

Next input needed before this can actually start: what the existing Pine
Barren Farms material actually consists of today.

## 7. Third proof case, informal - franchise/food-service ops (OPEN, someday)

Kenneth has a friend who owns/manages several Dunkin' Donuts locations -
mentioned as someone who might be interested in a similar tool trained on
that business's menu/processes/procedures, for internal store-manager use
("a boss or super brain on speed dial"), not customer-facing. Not being
pursued now - logged as a third possible proof-of-concept for the Forge
System pattern generalizing across verticals (tech support -> elder-care
demos -> food-service franchise ops), consistent with item 6's framing.


## 4. Multi-model reality check (OPEN, ongoing)

Confirmed goal: North Forge should run well across many model providers, not
just Claude - Kenneth wants his team actively experimenting with different
models via `hermes model`. Known constraint: weaker/faster models (e.g. a
"flash"/"quick" tier) visibly underperform on North Forge's actual work.
Nothing to fix here - this is a tracking item. Log real model trials below
as they happen:

| Model | Tried by | Result | Notes |
|---|---|---|---|
| (none logged yet) | | | |

## 5. Drive serial tracking (OPEN, design only - not built)

Kenneth wants to track how many physical drives are in circulation and who
has which one - not real copy protection (there's no way to actually prevent
someone copying a folder), just an honor-system tracking convention so
Kenneth can tell which numbered unit is whose, and notice if the count grows
past what he handed out. Likely shape: a small `DRIVE_ID.txt` file written
onto each physical drive at provisioning time (NOT committed to the git repo
- it's per-physical-unit, not per-version, and would leak across every drive
via git pull if it lived in the repo), paired with a private log Kenneth
keeps himself (outside this repo) mapping serial -> recipient -> date. Needs
a real conversation about the actual mechanism before building - parked here
so it doesn't get lost.

## 6. "Forge System" as a product family, not just this one project (OPEN - strategic, not a build)

Kenneth's framing: **Forge System** is the reusable underlying
architecture (Hermes engine + the mode-toggle/skills-source/skin/launcher/
CLAUDE.md conventions built in this repo) - **North Forge** is a specific
instance of it for Kyocera, and the same pattern could produce other
"editions" for entirely different organizations/verticals (Pine Barren Farms
was named as the next real one; other examples were hypothetical/humorous).

This validates the engine/content split made early in this build - a new
edition is a new content repo pointed at the same engine, not a rebuild.
Worth taking seriously as a real naming/architecture question once a second
edition actually gets built (Pine Barren Farms is the real candidate, per
item 3 above) - not something to design in the abstract before there's a
second real instance to learn from. No action taken on this yet; logged so
the framing doesn't get lost between sessions.

## 8. Cross-platform testing status (OPEN, low priority)

Demo scope decided (2026-08-26): Windows-only for the Greg demo, disclosed
honestly as the one actually field-tested path (blank drive ->
`provision-new-drive.ps1` -> clone -> launch -> verified, done live).
Mac/Linux launchers are built the same way and should work, but neither has
been run on a real machine yet - "should work" isn't the same claim as
"confirmed," and that gap shouldn't get papered over in how the demo is
described.

Test hardware available whenever there's time (not urgent, not blocking the
demo): several Macs in Kenneth's lab, plus Linux boxes (Red Hat, possibly
another distro). Linux sees little real use on the team either way, so this
is "nice to have a working utility eventually," not a near-term priority.


