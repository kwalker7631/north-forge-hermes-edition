# North Forge: Zero-Touch Deployment (current architecture)

Use this with the Deploy Console in this folder. The Kyocera edition is a
**Hermes profile**, not a standalone product.

## Talking points

1. Authenticate the admin machine once: `gh auth login` as kwalker7631.
2. Insert a blank USB. Do not use the system drive.
3. Double-click `Launch-Deploy-Console.cmd`.
4. Pick the stick, choose `full` or `basic`, type `FORMAT`, set the admin passcode.
5. The console:
   - formats exFAT / label `NorthForge`
   - shallow-clones `north-forge-agent`
   - clones `north-forge-hermes-edition` into `private-editions/kyocera`
   - runs `scripts\bootstrap-north-forge.ps1` (venv + HERMES_HOME as siblings)
   - runs `scripts\nf-setup.ps1 -NonInteractive -Tier … -Pin kyocera -SetPasscode`
6. Launch with `north-forge.cmd`. Check `/menu`.

## Do not use

- Cloning the private edition onto the drive *root*
- The retired `launch-north-forge.bat` / FULL-SALES toggle from the edition repo
- The corrupted chat-draft PowerShell (broken loops / Word artifacts)
