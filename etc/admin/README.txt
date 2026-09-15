Admin tooling is not in this folder.

It lives here so a teammate does not trip over it at the drive root:

    Advanced\deploy-console\

    Launch-Deploy-Console.cmd   — build or spawn another stick
    Zero-Touch-Deploy.ps1
    Set-Inference.ps1           — API key (trusted)
    Check-HermesPath.ps1
    PATH_FOR_DUMMIES.txt
    MASTER_REBUILD.md

Do not move those files into etc\admin. Scripts find each other by
their own folder. A move breaks deploy.
