# North Forge - Hermes Edition

This repo is the **content layer** for North Forge (Kyocera Edition) running on Hermes Agent. It is intentionally small - the Hermes engine itself is NOT in here.

## Two-repo architecture

- **Engine:** `kwalker7631/north-forge-agent` - an untouched fork/mirror of NousResearch/hermes-agent. Never edited directly. Kept current with `gh repo sync` when Nous ships updates.
- **Content (this repo):** `kwalker7631/north-forge-hermes-edition` - North Forge's own material only: the always-loaded context file, the per-mode skills, and setup tooling. This is what gets built, versioned, and demoed.

A thumb drive deployment = Hermes installed locally on the host machine (from the engine) + this repo's contents pointed to as the working directory.

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
    sales-assist/SKILL.md     <- available in BOTH modes (placeholder - not yet authored)
  tsc-only/
    kb-builder/SKILL.md       <- full /kb procedure (built) - FULL mode only
    (placeholders for hotline-ticket, assist-intake, escalation-packet, audit, fault-logging, training-guide)
.hermes/skills/                 <- GENERATED at each launch from skills-source/ - the exact folder name Hermes scans for project-local skills (see note below) - never edit directly, never committed
.forge-mode                    <- GENERATED per physical drive by toggle-mode - never committed, defaults to sales if absent
toggle-mode.bat / .sh          <- Kenneth-only: sets a drive's mode to FULL or SALES
skins/
  north-forge.yaml            <- Hermes skin: rebrands the CLI as "North Forge" using the KB visual palette
.env.example                   <- copy to .env, fill in your own Anthropic API key, never commit the real .env
.gitignore                     <- excludes secrets, per-drive mode, and generated files from version control
setup-thumbdrive.ps1           <- first-time Windows setup script (manual, step-by-step)
launch-north-forge.bat         <- one-click Windows launcher: assembles the current mode, trusts the project skills, installs Hermes if missing, applies the skin, starts
launch-north-forge.sh          <- same, for Mac/Linux
KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html  <- locked KB HTML template, required for /kb to produce a real draft
fallback/
  NORTH_FORGE_v21.8_PASTE_VERSION.md  <- complete, original single-file prompt - paste into any chat AI if this whole Hermes setup is ever unavailable
ATTRIBUTION.md                  <- required acknowledgment that this runs on the open-source Hermes Agent engine
NEXT_STEPS.md                   <- what's built vs. still to build
```

**Correction from an earlier version of this repo:** the generated skill folder used to be plain `skills/` at the repo root. That was wrong - confirmed by reading Hermes's actual installed source code, the real paths it scans for project-local skills are `.hermes/skills/` or `.agents/skills/`. Fixed everywhere in this version. Worth knowing this happened if you're demoing the debugging process, not just the fix - the folder name came from a third-party blog post that turned out to be inaccurate, and checking the real source code (not just documentation) is what actually resolved it.

## Project skills need to be trusted (a Hermes security feature, not a bug)

Separately from the folder-name issue: Hermes will not load skills from a project-local folder until you run `hermes skills trust` once - this stops a compromised `git pull` from silently injecting a malicious skill into a repo you already trusted. `launch-north-forge.bat`/`.sh` **auto-run this trust step on every launch**, trading a bit of that security model away for zero friction across the team - a deliberate choice, made because this repo is Blacksmith-reviewed before it ever reaches a drive. If that tradeoff ever stops feeling right (e.g. drives get built by more people than just Kenneth, or content starts coming from less-trusted sources), removing the auto-trust line and requiring `hermes skills trust` as a manual one-time step per machine is the safer default to fall back to.

## One repo, one toggle, two drive types

There is no separate "sales version" to maintain. Every skill is authored exactly once, in `skills-source/`, tagged `shared/` (both modes) or `tsc-only/` (FULL mode only). Every launch, the launcher deletes and rebuilds the live `.hermes/skills/` folder and the live `.hermes.md` from that source plus whichever `.forge-mode` says - so there's never a chance of the two "versions" drifting apart, because there's only ever one source.

`.forge-mode` is a one-word file (`full` or `sales`) that lives on each physical drive, is never committed to git, and is set once with `toggle-mode.bat`/`.sh` (Kenneth-only tooling, not something a rep needs). Missing the file at all defaults to `sales` - fails safe rather than fails open.

On a Sales-mode drive, the TSC-only skill files are never copied into the live `.hermes/skills/` folder at all - not hidden, not disabled by a prompt instruction alone, physically absent from that session. The `.hermes.md` generated for that mode also tells the model plainly to redirect any support/repair/KB request to the normal TSC channel rather than attempt it from general knowledge.

## Branding

The CLI is rebranded via a Hermes **skin** (`skins/north-forge.yaml`) - agent name, welcome text, and colors change to "North Forge" using the same palette already defined in the KB visual standard (Kyocera red, technical blue, confirmed-path green). Skins only affect appearance, not behavior - the underlying engine is still Hermes Agent, MIT-licensed, and that's acknowledged in `ATTRIBUTION.md`. Nous Research is not affiliated with or endorsing this deployment.

## Fallback: standalone paste-in version

`fallback/NORTH_FORGE_v21.8_PASTE_VERSION.md` is the complete, original, unsplit v21.8 master prompt - the same one used before the Hermes adaptation. If the drive, the engine, or the skill-loading mechanism is ever unavailable, copy that file's content into any chat AI (Claude, ChatGPT, Gemini, whatever's on hand) as a last resort - no setup required, works standalone. It is not auto-generated from `.hermes.template.md` and `skills-source/`, so keep it updated manually when the master prompt changes.

## Windows drive provisioning (recommended way to set up a new drive)

`provision-new-drive.ps1` is the safe, drive-letter-agnostic way to get North Forge onto a fresh thumb drive on Windows. It does NOT assume D:, E:, or any specific letter - it lists the drives actually present, auto-picks if there's only one, and hard-refuses to ever touch the system (`C:`) drive no matter how it's selected. It also checks the target drive's filesystem and refuses to proceed on FAT32 (4GB file-size cap, real problems here) - exFAT or NTFS only. Then it clones (or pulls, if already cloned) and launches.

**One-time prep Kenneth does before handing this to anyone (not a team-member step):** the script needs a real GitHub access token filled in on line 5, replacing `YOUR_TOKEN_HERE`, since this repo is private. Generate a fine-grained, read-only (Contents: Read-only), single-repo-scoped token at `github.com/settings/personal-access-tokens/new`, then edit that one line. The script itself checks for the placeholder and refuses to run with a clear message if it's still there - a team member should never see that message, only Kenneth preparing a drive should.

Run it from PowerShell: `.\provision-new-drive.ps1` - it prompts only when there's real ambiguity (more than one non-system drive present), and never asks for anything that could be mistyped into damaging the machine.

## One-click launch (for team distribution)

`launch-north-forge.bat` (Windows) and `launch-north-forge.sh` (Mac/Linux) live in the repo root. Each one: rebuilds `.hermes/skills/` and `.hermes.md` for whatever mode this drive is set to, installs Hermes if it's missing on that machine, sets up `.env` on first run if needed, copies the current skin into place, and starts North Forge - so a team member just needs to double-click (Windows) or run the script (Mac/Linux) rather than type commands or think about mode at all.

**One real caveat on Mac/Linux:** exFAT (needed for a drive that works across Windows/Mac/Linux) can't store the Unix "executable" permission bit, and macOS doesn't auto-run anything on drive insert (Apple removed that years ago for security). So the very first time on any given Mac needs one manual step - after that, it's a real double-click icon every time.

**On a Mac, the very first time only (once per Mac, ever):**
1. Plug in the drive.
2. Open Terminal: press Cmd+Space, type `Terminal`, press Enter.
3. Type `bash ` (the word bash, then a space) - do not press Enter yet.
4. Open the drive's Finder window, find `launch-north-forge.sh`, and drag that file into the Terminal window. This fills in the correct full path automatically - do not type the path by hand.
5. Press Enter.

That single run installs Hermes if needed, sets up `.env`, and - important - creates a **"North Forge" icon on that Mac's Desktop**. From then on, that person double-clicks the Desktop icon like any normal app. They never touch Terminal again on that machine.

(This assumes the drive keeps the same volume name each time it's plugged in - macOS mounts by name, so renaming the drive after setup would need the one-time step redone.)

On Linux, the same drag-and-drop-into-terminal trick works, or `bash launch-north-forge.sh` typed directly if terminal is already comfortable.

Windows doesn't have any of this trouble - `.bat` files run by file extension, not permission bit, so double-click works there from the first plug-in.

`KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html` (the locked KB template) is checked in at the repo root - required before `/kb` can produce a publishable draft.

## Why the content is split into skills instead of one big file

Hermes truncates context files over 20,000 characters (drops the middle silently). The full North Forge master prompt is well past that. Rather than lose rule blocks with no error, the always-loaded `.hermes.md` carries only identity/persona/routing/universal rules, and each mode's detailed procedure lives in its own skill file that Hermes reads on demand when that mode triggers.

## Skills are locked, not self-improving

Hermes skills normally refine themselves through use. North Forge's skills are the exception - see the `hermes_specific_addendum` section in `.hermes.md`. Nothing in `skills-source/` gets auto-edited. Changes go through the Blacksmith (Kenneth Walker Jr.).

## Prerequisites (check these before step 1)

Do this once per machine, before creating or cloning anything.

**1. Use PowerShell, not Git Bash.** Every command in this README and in the setup scripts is written for PowerShell. Git Bash can run some of it, but paths and `.bat` files behave differently there and it's not worth the translation. To open PowerShell: press the Windows key, type `PowerShell`, press Enter.

**2. Check git is installed:**
```powershell
git --version
```
If that errors, install Git for Windows first (https://git-scm.com/download/win) before continuing.

**3. Check GitHub CLI (`gh`) is installed:**
```powershell
gh auth status
```
If you get `'gh' is not recognized...`, it's not installed yet:
```powershell
winget install --id GitHub.cli
```
Then **close this PowerShell window completely and open a brand new one** — this matters, PowerShell won't see the new `gh` command in the same window it was installed from.

**4. Log in:**
```powershell
gh auth login
```
Answer the prompts: **GitHub.com** → **HTTPS** → **Yes** (authenticate Git with GitHub credentials) → **Login with a web browser**. It gives you a one-time code and opens your browser — paste the code, approve it, come back.

**5. Confirm:**
```powershell
gh auth status
```
You're looking for `✓ Logged in to github.com account <your username>`. Once you see that, move on to cloning the repo below.

## First-time setup

Run `setup-thumbdrive.ps1` from PowerShell on the machine you're setting up (see script header for what it does and why the Hermes engine installs locally rather than living on the drive itself - short version: exFAT can't hold the symlinks a Python venv needs, and a Windows-built runtime won't run on Mac/Linux anyway).
