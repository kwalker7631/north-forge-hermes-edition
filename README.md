# North Forge - Hermes Edition

North Forge - Hermes Edition (Kyocera Edition v21.8) is part of the North Forge project. Created and maintained by Kenneth C. Walker Jr. - Senior Technical Support Engineer, TSC.

A field-support AI built specifically for Kyocera Document Solutions technicians and sales reps - carries KB authoring, hotline ticket handling, escalation packets, and pre-sales product guidance, runs from your own PC or a portable drive, and never asks you to remember a slash command you don't already know.

Why this exists: a technician on a call shouldn't have to open a manual, hunt through ServiceNow, or wait on hold to find out what a code means. This tool collects the minimum evidence needed, gives a direct next step, and tells you plainly when it isn't sure - it doesn't replace judgment, it clears the fog around routine calls so judgment gets spent on the calls that actually need it.

## Built on Hermes Agent

This runs on top of [Hermes Agent](https://github.com/NousResearch/hermes-agent) by Nous Research (MIT licensed) - an open-source, general-purpose AI agent framework with real memory, scheduled background tasks, and a large tool/skill ecosystem. North Forge doesn't reimplement any of that; this repo is purely the *content layer* - the rules, the skills, the branding - that turns a general-purpose agent into this specific one. See `ATTRIBUTION.md` for the full license text and required notices.

**Want to add your own custom task or skill?** Hermes supports this natively, and it's worth knowing about beyond just this repo:

- **A one-off or recurring background task** (the pattern `kyocera-research` uses): from inside a live session, `/cron add "<schedule>" "<what to do>" --skill <optional-skill-name> --name <job-name>` - for example `/cron add "every 24h" "Check for new firmware release notes" --name nightly-firmware-check`. Check what's scheduled with `/cron list`.
- **A new skill of your own**: create a folder under `skills-source/shared/` (available in every mode) or `skills-source/tsc-only/` (FULL mode only) containing a `SKILL.md`. Give it YAML frontmatter with a `name:` field (this is what lets Hermes register it as a real `/slash-command` - without it, Hermes falls back to the folder name, which is usually not what you want) and a `description:` field, then write the actual instructions below a `---` closing line. The full Hermes documentation on skills, tools, and the wider ecosystem lives at the [Hermes Agent GitHub repo](https://github.com/NousResearch/hermes-agent) - worth a look if you want to go beyond what's built in here.

## Two-repo architecture

- **Engine:** `kwalker7631/north-forge-agent` - an untouched fork/mirror of NousResearch/hermes-agent. Never edited directly. Kept current with `gh repo sync` when Nous ships updates. This is a reference/audit copy only - it is not what the installed `hermes` command actually runs from (see below).
- **Content (this repo):** `kwalker7631/north-forge-hermes-edition` - North Forge's own material only: the always-loaded context file, the per-mode skills, and setup tooling. This is what gets built, versioned, and demoed.

A thumb drive deployment = Hermes installed locally on the host machine (from Hermes's own official installer, which creates a real git checkout under that machine's `~/.hermes` / `%LOCALAPPDATA%\hermes` and stays current via `hermes update` - pull-only, no ties to this repo) + this repo's contents pointed to as the working directory. Don't keep a separate copy of the engine on the drive itself - a static download snapshot can't be updated and isn't referenced by anything here.

## Model choice matters - this is not Claude-only

North Forge's identity, tone, and rules in `.hermes.template.md` are written model-agnostic on purpose - "you are North Forge," never "you are Claude" or any other provider name. Hermes supports 30+ model providers via `hermes model`, and switching between them is intended and encouraged, not an edge case.

**Real constraint worth knowing before experimenting:** output quality depends heavily on which model is actually running underneath. A fast/cheap or lightweight model (e.g., a "flash"/"quick" tier model) will noticeably under-perform a frontier-tier model on North Forge's actual work - KB drafting, diagnostic reasoning, following the locked template correctly. This isn't a North Forge bug to fix; it's a property of the model chosen. When in doubt, prefer a stronger model over a faster one for anything going into a real KB or a real technician's hands. Track which models have actually been tried against North Forge and how they performed in `DEMO_PREP_BACKLOG.md`, so this stays evidence-based rather than assumed.

## Repo governance

This repo is private and not published. Kenneth Walker Jr. is the sole administrator - he is the only person who creates, edits, or commits content here. Team members who use a drive built from this repo never touch the repo itself; if someone has a suggestion or hits a problem, it's relayed to Kenneth (via a log, a description, or eventually the fault-logging skill once built) and handled through the Claude Project chat + Claude Code + Blacksmith review loop - never applied directly by whoever reported it.

## What's in here

```
.hermes.template.md          <- source template for the context file (tracked in git)
.hermes.md                   <- GENERATED at each launch from the template + mode - never edit directly, never committed
mode-blocks/
  full-banner.md              <- mode banner for FULL drives
  full-menu.md                <- command menu for FULL drives
  sales-banner.md             <- mode banner for SALES drives
  sales-menu.md                <- command menu for SALES drives
skills-source/                <- the real, tracked skill content (one copy, never duplicated)
  shared/
    sales-assist/SKILL.md     <- available in BOTH modes (built, but FAQ content is still a placeholder pending real spec-sheet curation)
    web-navigator/SKILL.md    <- available in BOTH modes (built, verified real links to kyoceradocumentsolutions.us)
  tsc-only/
    kb-builder/SKILL.md          <- full /kb procedure - FULL mode only
    draft-writer/SKILL.md        <- /draft procedure - FULL mode only
    hotline-ticket/SKILL.md      <- /hl, /ticket procedure - FULL mode only
    assist-intake/SKILL.md       <- /a, /assist procedure - FULL mode only
    escalation-packet/SKILL.md   <- /esc procedure - FULL mode only
    forge-audit/SKILL.md         <- /audit, /chk procedure - FULL mode only. CORRECTION (2026-08-29): earlier named forge-audit on a wrong assumption that "audit" collided with a reserved Hermes command name - it doesn't. The real cause of it being hidden from `hermes skills list` was Hermes's security scanner flagging the literal string "CLAUDE.md" that used to appear in the skill's own text (now reworded). The folder name was never the actual issue, but is kept as forge-audit rather than reverted. The user-facing command is still /audit or /chk.
    fault-logging/SKILL.md       <- /log, /fault, /report procedure - FULL mode only
    training-guide/SKILL.md      <- /train procedure - FULL mode only
    (all 8 tsc-only skills built - see NEXT_STEPS.md for authorship history)
.hermes/skills/                 <- GENERATED at each launch from skills-source/ - the exact folder name Hermes scans for project-local skills (see note below) - never edit directly, never committed
.forge-mode                    <- GENERATED per physical drive by toggle-mode - never committed, defaults to sales if absent
.agent-name                    <- OPTIONAL, one line of text, per physical drive - a custom nickname for the agent (e.g. "Kyle"). Never committed. Defaults to "North Forge" if absent. Create it by hand (a plain text file containing just the name) - no toggle script for this yet.
toggle-mode.bat / .sh          <- Kenneth-only: sets a drive's mode to FULL or SALES, or RESET to wipe a drive's personal setup before handing it to someone else
machine-reset.bat               <- Kenneth-only: manages THIS MACHINE's Hermes state (separate from the drive) - rotate just the API key, or fully purge everything
skins/
  north-forge.yaml            <- Hermes skin: rebrands the CLI as "North Forge" using the KB visual palette
.env.example                   <- copy to .env, fill in your own Anthropic API key, never commit the real .env
.gitignore                     <- excludes secrets, per-drive mode, and generated files from version control
provision-new-drive.ps1        <- CANONICAL way to set up a new drive on Windows (see below) - drive-letter-agnostic, safe, one command
archive/
  setup-thumbdrive.ps1          <- SUPERSEDED, moved here from repo root - kept only because Kenneth's own personal drive was set up with it early on. Do not use for new drives.
launch-north-forge.bat         <- one-click Windows launcher: assembles the current mode, trusts the project skills, installs Hermes if missing, applies the skin, starts
launch-north-forge.sh          <- same, for Mac/Linux
KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html  <- locked KB HTML template, required for /kb to produce a real draft
fallback/
  NORTH_FORGE_v21.8_PASTE_VERSION.md  <- complete, original single-file prompt - paste into any chat AI if this whole Hermes setup is ever unavailable
ATTRIBUTION.md                  <- required acknowledgment that this runs on the open-source Hermes Agent engine
USER_MANUAL.md                  <- plain-English end-user manual: every command, what skills are installed, how to add one, cheat sheet - written for the least technical person who ever gets handed a drive
research-log/
  kyocera-research-log.md       <- appended by the nightly-kyocera-research cron job (6 AM daily) - real, committed field-research findings, tracked in git on purpose
  daily-brief-log.md            <- appended by the daily-kyocera-brief cron job (8 AM daily) once it first runs
kb-images/                      <- intake/staging for actual image files techs provide during /kb work - one folder per KB number, _pending/ for pre-number images. Committed and shared across drives on purpose. Staging only: ServiceNow attach + manual placeholder replace stays manual, by design
FIRST_TIME_README.txt           <- plain-language quickstart for a first-time team member receiving a drive - not for Kenneth, for whoever gets handed one
CLAUDE.md                       <- Claude Code's working rules for this repo (Zone A/B/C authority model) - read by Claude Code automatically, not by Hermes itself
NEXT_STEPS.md                   <- what's built vs. still to build
DEMO_PREP_BACKLOG.md            <- running punch-list for demo prep, polish, and things flagged for later
CHANGELOG.md                     <- plain-language running history of what changed and why, distinct from git log and from the audit report below
audit/
  CLAUDE_CODE_LAST_AUDIT.md    <- most recent Claude Code session's audit report, overwritten each session
```

**Correction from an earlier version of this repo:** the generated skill folder used to be plain `skills/` at the repo root. That was wrong - confirmed by reading Hermes's actual installed source code, the real paths it scans for project-local skills are `.hermes/skills/` or `.agents/skills/`. Fixed everywhere in this version. Worth knowing this happened if you're demoing the debugging process, not just the fix - the folder name came from a third-party blog post that turned out to be inaccurate, and checking the real source code (not just documentation) is what actually resolved it.

## Project skills need to be trusted (a Hermes security feature, not a bug)

Separately from the folder-name issue: Hermes will not load skills from a project-local folder until you run `hermes skills trust` once - this stops a compromised `git pull` from silently injecting a malicious skill into a repo you already trusted. `launch-north-forge.bat`/`.sh` **auto-run this trust step on every launch**, trading a bit of that security model away for zero friction across the team - a deliberate choice, made because this repo is Blacksmith-reviewed before it ever reaches a drive. If that tradeoff ever stops feeling right (e.g. drives get built by more people than just Kenneth, or content starts coming from less-trusted sources), removing the auto-trust line and requiring `hermes skills trust` as a manual one-time step per machine is the safer default to fall back to.

## One repo, one toggle, two drive types

There is no separate "sales version" to maintain. Every skill is authored exactly once, in `skills-source/`, tagged `shared/` (both modes) or `tsc-only/` (FULL mode only). Every launch, the launcher deletes and rebuilds the live `.hermes/skills/` folder and the live `.hermes.md` from that source plus whichever `.forge-mode` says - so there's never a chance of the two "versions" drifting apart, because there's only ever one source.

`.forge-mode` is a one-word file (`full` or `sales`) that lives on each physical drive, is never committed to git, and is set once with `toggle-mode.bat`/`.sh` (Kenneth-only tooling, not something a rep needs). Missing the file at all defaults to `sales` - fails safe rather than fails open.

`toggle-mode.bat`/`.sh` also has a third option: **RESET**, a credential/config reset that removes eight first-use state targets: `.env`, `.forge-mode`, `.hermes.md`, `.drive-record.txt`, `.provider-choice`, `.agent-name`, `.readme-shown`, and `.hermes/skills/`. The scripts verify their removal and return an error if any target remains. Any confirmation other than uppercase `YES` leaves all eight intact and returns an error. `forge-events.log` is intentionally retained as an accountability record and can contain names entered by prior users, so RESET is not a privacy or history wipe.

On a Sales-mode drive, the TSC-only skill files are never copied into the live `.hermes/skills/` folder at all - not hidden, not disabled by a prompt instruction alone, physically absent from that session. The `.hermes.md` generated for that mode also tells the model plainly to redirect any support/repair/KB request to the normal TSC channel rather than attempt it from general knowledge.

## Custom agent name (optional, per drive)

By default the agent identifies itself as "North Forge." To give a specific drive a personal nickname instead (useful for demos to people who aren't already comfortable with AI - "call it Kyle" reframes it as "my assistant" rather than "a chatbot"), create a file named `.agent-name` in the repo root containing just the name, one line, nothing else. Missing the file at all defaults to "North Forge."

The name is a cosmetic layer only - every rule and behavior in `.hermes.template.md` and every skill still applies exactly as written regardless of what the agent calls itself. This currently only changes how the model refers to itself in conversation; the CLI's own visible banner/label still says "North Forge" regardless (a further enhancement, not yet built - see `DEMO_PREP_BACKLOG.md`).

There's no toggle script for this yet (unlike `.forge-mode`) - create/edit the file by hand for now.

## Branding

The CLI is rebranded via a Hermes **skin** (`skins/north-forge.yaml`) - agent name, welcome text, and colors change to "North Forge" using the same palette already defined in the KB visual standard (Kyocera red, technical blue, confirmed-path green). Skins only affect appearance, not behavior - the underlying engine is still Hermes Agent, MIT-licensed, and that's acknowledged in `ATTRIBUTION.md`. Nous Research is not affiliated with or endorsing this deployment.

## Fallback: standalone paste-in version

`fallback/NORTH_FORGE_v21.8_PASTE_VERSION.md` is the complete, original, unsplit v21.8 master prompt - the same one used before the Hermes adaptation. If the drive, the engine, or the skill-loading mechanism is ever unavailable, copy that file's content into any chat AI (Claude, ChatGPT, Gemini, whatever's on hand) as a last resort - no setup required, works standalone. It is not auto-generated from `.hermes.template.md` and `skills-source/`, so keep it updated manually when the master prompt changes.

## Setting up a new drive (Windows) - the one canonical path

`provision-new-drive.ps1` is the only recommended way to set up a new drive. It is drive-letter-agnostic (does NOT assume D:, E:, or any specific letter - it lists the drives actually present and auto-picks if there's only one), hard-refuses to ever touch the system (`C:`) drive no matter how it's selected, and refuses to proceed on a FAT32-formatted drive (4GB file-size cap, real problems here) - exFAT or NTFS only. It installs Git if missing, clones (or pulls, if already cloned), and launches - one command, nothing else to run first.

```powershell
.\provision-new-drive.ps1
```

No GitHub CLI (`gh`), no `gh auth login`, no browser sign-in step for whoever runs this - the script clones using a read-only access token that's already embedded in the file (see below for how that got there). It only prompts when there's real ambiguity (more than one non-system drive present), and never asks for anything that could be mistyped into damaging the machine.

`archive/setup-thumbdrive.ps1` is superseded by this script and kept only for historical reasons - don't use it for new drives.

## One-click launch (what happens after provisioning, and for repeat use)

`launch-north-forge.bat` (Windows) and `launch-north-forge.sh` (Mac/Linux) live in the repo root - `provision-new-drive.ps1` calls the `.bat` automatically at the end of first-time setup, and either one is what a team member runs on every visit after that. Each one: rebuilds `.hermes/skills/` and `.hermes.md` for whatever mode this drive is set to, installs Hermes if it's missing on that machine, sets up `.env` on first run if needed, copies the current skin into place, and starts North Forge - so a team member just needs to double-click (Windows) or run the script (Mac/Linux) rather than type commands or think about mode at all.

**One real caveat on Mac/Linux:** exFAT (needed for a drive that works across Windows/Mac/Linux) can't store the Unix "executable" permission bit, and macOS doesn't auto-run anything on drive insert (Apple removed that years ago for security). So the very first time on any given Mac needs one manual step - after that, it's a real double-click icon every time.

**On a Mac, the very first time only (once per Mac, ever):**
1. Plug in the drive.
2. Open Terminal: press Cmd+Space, type `Terminal`, press Enter.
3. Type `bash ` (the word bash, then a space) - do not press Enter yet.
4. Open the drive's Finder window, find `launch-north-forge.sh`, and drag that file into the Terminal window. This fills in the correct full path automatically - do not type the path by hand.
5. Press Enter.

That single run installs Hermes if needed, sets up `.env`, and - important - creates a **"North Forge" icon on that Mac's Desktop**. From then on, that person double-clicks the Desktop icon like any normal app. They never touch Terminal again on that machine.

(This assumes the drive keeps the same volume name each time it's plugged in - macOS mounts by name, so renaming the drive after setup would need the one-time step redone.)

On Linux, the same drag-and-drop-into-terminal trick works, or `bash launch-north-forge.sh` typed directly if terminal is already comfortable. Requires `python3` on PATH - the script checks for this and gives a clear error with an install hint if it's missing, rather than failing with a raw error partway through.

Windows doesn't have any of this trouble - `.bat` files run by file extension, not permission bit, so double-click works there from the first plug-in.

`KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html` (the locked KB template) is checked in at the repo root - required before `/kb` can produce a publishable draft.

## Why the content is split into skills instead of one big file

Hermes truncates context files over 20,000 characters (drops the middle silently). The full North Forge master prompt is well past that. Rather than lose rule blocks with no error, the always-loaded `.hermes.md` carries only identity/persona/routing/universal rules, and each mode's detailed procedure lives in its own skill file that Hermes reads on demand when that mode triggers.

## Skills are locked, not self-improving

Hermes skills normally refine themselves through use. North Forge's skills are the exception - see the `hermes_specific_addendum` section in `.hermes.md`. Nothing in `skills-source/` gets auto-edited. Changes go through the Blacksmith (Kenneth Walker Jr.).

## Updating Hermes itself (not this repo)

`hermes update` updates the Hermes engine on whatever machine you run it on - it has nothing to do with this repo and doesn't touch anything git-tracked. After any update, treat it as a trigger to re-verify, not just install and move on: run `hermes doctor`, `hermes skin list`, and `hermes skills list --source local`, then do one real launch in each mode before trusting it.

**Where Hermes actually lives on a given machine:** `%LOCALAPPDATA%\hermes` on Windows (or `$HERMES_HOME` if that's set, which takes precedence). This folder holds the engine install itself, `config.yaml`, `.env` (the API key Hermes actually reads - separate from this drive's own `.env`), the skin, and all persistent state: `state.db` (memory/sessions), `cron/` (scheduled jobs), `logs/`. None of this is on the drive and none of it is git-tracked.

**To stop and remove the background gateway** (the scheduled-task process that keeps cron jobs running even when no session is open) before deleting anything in that folder:
```powershell
hermes gateway stop
hermes gateway uninstall
```
Skipping this step first is why a manual folder deletion sometimes fails partway through with a locked-file error - the gateway process is still holding files open.

**To fully wipe a machine's Hermes state** (rotate to a new API key, or start genuinely fresh on that machine) - use `machine-reset.bat` in this repo rather than doing the above by hand. It has two options: rotate just the API key (keeps memory/sessions/config intact), or a full purge (stops and uninstalls the gateway, then deletes the entire folder above).

## Kenneth's own GitHub CLI setup (repo administration - NOT needed to provision a drive)

Nothing below this point is needed by a team member setting up a drive - `provision-new-drive.ps1` handles that with no `gh` dependency at all. This section is for Kenneth's own administrative tasks: creating the read-only access token that gets embedded in `provision-new-drive.ps1`, managing repo settings, syncing the engine fork, and similar `gh`-driven tasks.

**1. Use PowerShell, not Git Bash** for these commands specifically - Git Bash can run some of it, but paths and `.bat` files behave differently there and it's not worth the translation.

**2. Check git is installed:**
```powershell
git --version
```
If that errors, install Git for Windows first (https://git-scm.com/download/win).

**3. Check GitHub CLI (`gh`) is installed:**
```powershell
gh auth status
```
If you get `'gh' is not recognized...`, install it:
```powershell
winget install --id GitHub.cli
```
Then close this PowerShell window completely and open a brand new one - this matters, PowerShell won't see the new `gh` command in the same window it was installed from.

**4. Log in:**
```powershell
gh auth login
```
Answer the prompts: **GitHub.com** -> **HTTPS** -> **Yes** (authenticate Git with GitHub credentials) -> **Login with a web browser**. It gives you a one-time code and opens your browser - paste the code, approve it, come back.

**5. Confirm:**
```powershell
gh auth status
```
You're looking for a line confirming you're logged in to github.com. Once you see that, `gh` is ready for repo administration tasks - `gh repo view`, `gh repo sync` on the engine fork, and so on.

**Generating the read-only token that goes in `provision-new-drive.ps1`:** go to `github.com/settings/personal-access-tokens/new`, scope it to this one repository only, set Repository permissions -> Contents: Read-only (nothing else needed), generate it, and paste it into the line that sets `$cloneUrl` near the top of `provision-new-drive.ps1`, replacing `YOUR_TOKEN_HERE`. This is a one-time edit before handing a drive to anyone - the script itself refuses to run with a clear message if that placeholder is still there, so a team member should never see it.
