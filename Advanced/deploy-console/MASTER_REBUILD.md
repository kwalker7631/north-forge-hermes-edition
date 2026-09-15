# New master stick (exFAT)

This machine cannot see D:. Use this after you format.

## Why launch keeps breaking

1. Typed `hermes` on a second PC hits `C:\Users\kwalk\.local\bin\hermes.exe`,
   not the stick. Start North Forge is fine. Bare `hermes` is not.
2. The venv on the stick stores the *build PC's* Python path. First launch
   on a new PC must repair it (the launcher already does — log line
   `bootstrap-repair`). Wait for `result=ready`.
3. No API key in `HERMES_HOME` = launches, then "No inference provider".
4. exFAT cannot do NTFS junctions. Dashboard `npm install --workspace`
   will fail on the stick. CLI does not need the dashboard.

## Build the master

1. Format the USB **exFAT** (console does this, or Disk Management).
2. Run `Launch-Deploy-Console.cmd` **as administrator**.
3. Pick the volume (or RAW Disk N / Browse `F`).
4. Label e.g. `BLACK-NORTH`. Type `FORMAT`. Passcode. Deploy.
5. When it says DEPLOYMENT COMPLETE, do **not** eject.
6. From an admin PowerShell on the stick:

```
cd <letter>:\  (the deploy-console folder if you kept a copy there,
               else copy Set-Inference.ps1 onto the stick)
.\Set-Inference.ps1 -Provider anthropic -Key "YOUR_KEY"
```

That script calls `<letter>:\north-forge-agent-venv\Scripts\hermes.exe`
with `HERMES_HOME=<letter>:\north-forge-agent-data`. It never uses PATH.

7. Double-click **Start North Forge**. Ask one real question.
8. Eject.

## First plug-in on another PC

Expect one `bootstrap-repair` in `north-forge-agent-launcher.log`.
If `result=ready` after that, the venv was rebuilt for that host.
Do not reformat just because the first launch repaired.

## Do not

- Type bare `hermes` to "test".
- Copy `north-forge-agent-venv` from D: onto a new letter and expect it
  to run without repair.
- Put Pinokio on a 32 GB master.
- Build the web dashboard on exFAT.
