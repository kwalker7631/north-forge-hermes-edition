# North Forge Deploy Console

Admin-only tool for building a **formatted USB thumb drive** that carries:

1. Public engine: `kwalker7631/north-forge-agent`
2. Private Kyocera edition: `kwalker7631/north-forge-hermes-edition` → `private-editions/kyocera`
3. Drive-local Python venv + `HERMES_HOME` (siblings of the checkout)
4. Signed provisioning (`full` or `basic`, pinned to `kyocera`)
5. Admin passcode hash in `<data>\north-forge\.nf-admin` (never stored in this repo)

This matches the architecture locked on **2026-09-11**: the Hermes edition is a
profile distribution, not a standalone launcher.

## What you get

| File | Role |
|---|---|
| `Launch-Deploy-Console.cmd` | Double-click. Opens the web UI. |
| `Start-DeployConsole.ps1` | Local web UI (default http://127.0.0.1:8765) |
| `Zero-Touch-Deploy.ps1` | The actual deploy engine (CLI or called by the UI) |
| `ui/index.html` | The console page |

The web UI never talks to the internet except through `git` / `gh` on your machine.
USB format and clones run **locally** as the logged-in Windows user.

## Before first use (admin machine)

1. Windows 10/11, PowerShell 5.1+
2. [Git](https://git-scm.com/) on PATH
3. [GitHub CLI](https://cli.github.com/) on PATH, signed in as **kwalker7631**:

   ```
   gh auth login
   ```

   HTTPS is fine. Confirm private-repo access:

   ```
   gh repo view kwalker7631/north-forge-hermes-edition
   ```

4. Python 3.11+ **or** `uv` on PATH (bootstrap uses host toolchain if the drive
   does not yet carry `north-forge-agent-toolchain`). First bootstrap needs
   network.

## Web UI (recommended)

```
Launch-Deploy-Console.cmd
```

Or:

```
powershell -ExecutionPolicy Bypass -File Start-DeployConsole.ps1
```

Then in the page:

1. Refresh USB list
2. Pick the **removable** drive
3. Choose tier (`full` = switcher on, `basic` = locked to kyocera)
4. Type `FORMAT` (exact) — this is the only way format runs
5. Set the admin passcode (≥ 6 characters). It is sent once into
   `nf-setup.ps1 -NonInteractive -SetPasscode -Passcode …` and stored as a
   PBKDF2 hash. It is not written into any file in this console.
6. Deploy. Watch the live log.

The UI **refuses**:

- System drive / `C:`
- Non-removable volumes
- Empty or mismatched FORMAT confirmation
- Missing `git` / `gh` / GitHub auth

## CLI (same engine, no browser)

```
powershell -ExecutionPolicy Bypass -File Zero-Touch-Deploy.ps1 `
  -DriveLetter E `
  -ConfirmFormat FORMAT `
  -Tier full `
  -Passcode "your-admin-passcode"
```

Optional:

```
-SkipFormat          # reuse a drive already labeled NorthForge
-SkipBootstrap       # repos already cloned; only pin / passcode
-AgentRepoUrl        # override public clone URL
-EditionRepoUrl      # override private clone URL
-Label NorthForge
```

## What lands on the stick

```
E:\
  north-forge-agent\              engine checkout
    private-editions\kyocera\     private profile (gitignored on the engine)
  north-forge-agent-venv\         Python venv (sibling)
  north-forge-agent-data\         HERMES_HOME (sibling)
  .uv-cache\                      optional uv cache on the same volume
```

Launch after deploy:

```
E:\north-forge-agent\north-forge.cmd
```

## Why the old attached .ps1 was replaced

The draft in chat was corrupted by Word/Markdown (broken `Where-Object`,
broken `for` loop, split `Write-Host` strings, `Set-Location` to a bare
drive letter). This console is the clean replacement and calls the real
`scripts\bootstrap-north-forge.ps1` and `scripts\nf-setup.ps1` from the
engine repo instead of inventing a third install path.

## On-the-fly edits after a drive exists

Do **not** format again. From the engine checkout on the stick:

```
cd E:\north-forge-agent
git -C private-editions\kyocera pull
powershell -ExecutionPolicy Bypass -File scripts\nf-setup.ps1 -Show
```

Content updates for an already-pinned profile:

```
hermes profile update kyocera
```

(run via `north-forge.cmd` so `HERMES_HOME` points at the sibling data dir)

Re-pin / rotate passcode (admin only):

```
powershell -ExecutionPolicy Bypass -File scripts\nf-setup.ps1 -SetPasscode
powershell -ExecutionPolicy Bypass -File scripts\nf-setup.ps1 -Tier full -Pin kyocera -Installed kyocera
```
