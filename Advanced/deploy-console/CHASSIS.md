# Chassis (why Zero-Touch was "broken")

`north-forge-agent` on GitHub is the Hermes engine. It does **not** ship
`scripts/bootstrap-north-forge.ps1`, `scripts/nf-setup.ps1`, or `north-forge.cmd`.

This folder is the pack's copy. Zero-Touch clones the engine, clones this pack
into `private-editions\kyocera`, then copies these three files into the engine
checkout before bootstrap.

- `bootstrap-north-forge.ps1` — runs engine `scripts\install.ps1` with
  `-HermesHome` = sibling `north-forge-agent-data` and `-InstallDir` = the clone.
- `nf-setup.ps1` — copies SOUL/skills into `HERMES_HOME\profiles\kyocera`.
- `north-forge.cmd` — starts the drive's `hermes.exe`, never `%USERPROFILE%\.local\bin`.
