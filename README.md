# North Forge - Hermes Edition

This repo is the **content layer** for North Forge (Kyocera Edition) running on Hermes Agent. It is intentionally small - the Hermes engine itself is NOT in here.

## Two-repo architecture

- **Engine:** `kwalker7631/north-forge-agent` - an untouched fork/mirror of NousResearch/hermes-agent. Never edited directly. Kept current with `gh repo sync` when Nous ships updates.
- **Content (this repo):** `kwalker7631/north-forge-hermes-edition` - North Forge's own material only: the always-loaded context file, the per-mode skills, and setup tooling. This is what gets built, versioned, and demoed.

A thumb drive deployment = Hermes installed locally on the host machine (from the engine) + this repo's contents pointed to as the working directory.

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
skills/                        <- GENERATED at each launch from skills-source/ - never edit directly, never committed
.forge-mode                    <- GENERATED per physical drive by toggle-mode - never committed, defaults to sales if absent
toggle-mode.bat / .sh          <- Kenneth-only: sets a drive's mode to FULL or SALES
skins/
  north-forge.yaml            <- Hermes skin: rebrands the CLI as "North Forge" using the KB visual palette
.env.example                   <- copy to .env, fill in your own Anthropic API key, never commit the real .env
.gitignore                     <- excludes secrets, per-drive mode, and generated files from version control
setup-thumbdrive.ps1           <- first-time Windows setup script (manual, step-by-step)
launch-north-forge.bat         <- one-click Windows launcher: assembles the current mode, installs Hermes if missing, applies the skin, starts
launch-north-forge.sh          <- same, for Mac/Linux
ATTRIBUTION.md                  <- required acknowledgment that this runs on the open-source Hermes Agent engine
NEXT_STEPS.md                   <- what's built vs. still to build
```

## One repo, one toggle, two drive types

There is no separate "sales version" to maintain. Every skill is authored exactly once, in `skills-source/`, tagged `shared/` (both modes) or `tsc-only/` (FULL mode only). Every launch, the launcher deletes and rebuilds the live `skills/` folder and the live `.hermes.md` from that source plus whichever `.forge-mode` says - so there's never a chance of the two "versions" drifting apart, because there's only ever one source.

`.forge-mode` is a one-word file (`full` or `sales`) that lives on each physical drive, is never committed to git, and is set once with `toggle-mode.bat`/`.sh` (Kenneth-only tooling, not something a rep needs). Missing the file at all defaults to `sales` - fails safe rather than fails open.

On a Sales-mode drive, the TSC-only skill files are never copied into the live `skills/` folder at all - not hidden, not disabled by a prompt instruction alone, physically absent from that session. The `.hermes.md` generated for that mode also tells the model plainly to redirect any support/repair/KB request to the normal TSC channel rather than attempt it from general knowledge.

## Branding

The CLI is rebranded via a Hermes **skin** (`skills/north-forge.yaml`) - agent name, welcome text, and colors change to "North Forge" using the same palette already defined in the KB visual standard (Kyocera red, technical blue, confirmed-path green). Skins only affect appearance, not behavior - the underlying engine is still Hermes Agent, MIT-licensed, and that's acknowledged in `ATTRIBUTION.md`. Nous Research is not affiliated with or endorsing this deployment.

## One-click launch (for team distribution)

`launch-north-forge.bat` (Windows) and `launch-north-forge.sh` (Mac/Linux) live in the repo root. Each one: rebuilds `skills/` and `.hermes.md` for whatever mode this drive is set to, installs Hermes if it's missing on that machine, sets up `.env` on first run if needed, copies the current skin into place, and starts North Forge - so a team member just needs to double-click (Windows) or run the script (Mac/Linux) rather than type commands or think about mode at all.

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

You'll also need `KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html` (the locked KB template) placed in this repo's root before `/kb` can produce a publishable draft - it's not checked in here yet because it needs to come from the existing Claude Project's knowledge base.

## Why the content is split into skills instead of one big file

Hermes truncates context files over 20,000 characters (drops the middle silently). The full North Forge master prompt is well past that. Rather than lose rule blocks with no error, the always-loaded `.hermes.md` carries only identity/persona/routing/universal rules, and each mode's detailed procedure lives in its own skill file that Hermes reads on demand when that mode triggers.

## Skills are locked, not self-improving

Hermes skills normally refine themselves through use. North Forge's skills are the exception - see the `hermes_specific_addendum` section in `.hermes.md`. Nothing in `skills/` gets auto-edited. Changes go through the Blacksmith (Kenneth Walker Jr.).

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
