# Final four — 2026-09-15 19:25 EDT

Nothing already working was moved. Deploy console stays at
`Advanced/deploy-console\`. A move to `etc\admin\` tonight would break
Launch-Deploy-Console.cmd, Zero-Touch, RAW-disk fix, Set-Inference, and
Check-HermesPath. Buried by a pointer instead.

## 1. Web UI API key — CLI still the trusted path

The dashboard **has pages that can hold keys**:
- `web/src/pages/EnvPage.tsx` — environment / secrets
- `web/src/pages/ModelsPage.tsx` — models / providers

Nobody in this session opened a browser against a live gateway and saved
a dummy key. Claude also never visually confirmed it. Treat the web field
as **unverified**. Keep using:

    Set-Inference.ps1
    or  <DRIVE>:\north-forge-agent-venv\Scripts\hermes.exe config set …

with `HERMES_HOME=<DRIVE>:\north-forge-agent-data`.

Dashboard on exFAT still cannot `npm install --workspace` on the stick.

## 2. Drive-letter sweep

| Place | Severity | Status |
|---|---|---|
| EXCALIBUR.md | doc | Already `<DRIVE>:\` |
| ADMIN_FIRST_TIME.txt | doc | Generic after tonight |
| PATH_FOR_DUMMIES / Check-HermesPath / Set-Inference | code | Resolve current letter |
| Start-DeployConsole / Zero-Touch | code | No D: hardcoded |
| logs/CHANGELOG/NEXT_STEPS | history | Leave D:/F: as what happened |
| archive/setup-thumbdrive.ps1 | dead | Ignore |
| Install-Pinokio-Lab example `D:\PinokioHome` | doc | Example only |

nf-preflight / nf-path-guard (chassis `83c85b3`) use the live venv path,
not D:.

## 3. Bury admin tooling

Not moved. Pointer: `etc/admin/README.txt` → `Advanced/deploy-console\`.
User-facing root should only show Terminal + Web (templates below).

## 4. Drive-spawning vs first setup

Still **two steps, same console**:
1. First-ever: Deploy Console formats + clones + passcode.
2. Later sticks: same Deploy Console, pick another disk, other class/tier.

Not folded into the Hermes web Config page. Drive class in the web
dashboard is **not built**. Class today is the console Tier dropdown +
`nf-setup.ps1 -DriveClass` on the chassis.

## 5. Branding

Hermes wordmark stays (upstream). Attribution plugin exists in the Kyocera
profile. **Not seen in a browser this session.**

## Left alone on purpose

SOUL, DESK_MODES, ALIASES, /clr vs /fl, RAW disk scan, Set-Inference,
Check-HermesPath, PATH_FOR_DUMMIES.

Handoff bundle: NOT created (no D:/F: from here). Deliverable is this file
plus `etc/admin/README.txt` and the two root launcher templates.
