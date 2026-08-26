# North Forge - Hermes Edition - first-time Windows setup
#
# WHAT THIS DOES:
#   1. Installs the Hermes engine locally on THIS machine (not on the drive - see why below)
#   2. Creates your .env from .env.example and asks for your Anthropic API key
#   3. Runs `hermes doctor` to sanity-check the install
#   4. Tells you the exact command to start North Forge from this folder
#
# WHY THE ENGINE INSTALLS LOCALLY INSTEAD OF LIVING ON THE DRIVE:
#   The Hermes runtime is a Python venv, and exFAT (the cross-platform format
#   this drive uses) can't hold the symlinks a venv needs. A runtime built on
#   Windows won't run on Mac/Linux anyway. So the engine gets installed fresh,
#   quickly, on whatever machine you're using - this repo (the content: the
#   context file and skills) is what actually travels on the drive.
#
# RUN THIS FROM INSIDE THE CLONED REPO FOLDER (e.g. D:\north-forge-hermes-edition)

$ErrorActionPreference = "Stop"

Write-Host "== North Forge - Hermes Edition setup ==" -ForegroundColor Cyan

# 1. Check for Hermes, install if missing
$hermesInstalled = Get-Command hermes -ErrorAction SilentlyContinue
if (-not $hermesInstalled) {
    Write-Host "Hermes not found - installing now (this runs the official Nous Research installer)..." -ForegroundColor Yellow
    iex (irm https://hermes-agent.nousresearch.com/install.ps1)
    Write-Host "Install finished. You may need to open a NEW PowerShell window for the 'hermes' command to be recognized." -ForegroundColor Yellow
} else {
    Write-Host "Hermes already installed: $($hermesInstalled.Source)" -ForegroundColor Green
}

# 2. Confirm we're running from inside the repo (look for .hermes.template.md as a marker -
#    .hermes.md itself is generated fresh at each launch, so it won't exist yet on a clean clone)
if (-not (Test-Path ".hermes.template.md")) {
    Write-Host "ERROR: .hermes.template.md not found in the current folder." -ForegroundColor Red
    Write-Host "Run this script FROM INSIDE the cloned north-forge-hermes-edition folder." -ForegroundColor Red
    exit 1
}

# 2b. Set the mode toggle if it doesn't exist yet (defaults to sales for safety)
if (-not (Test-Path ".forge-mode")) {
    Write-Host ""
    Write-Host "No mode set for this drive yet. FULL = TSC + Sales. SALES = product/spec questions only." -ForegroundColor Yellow
    $mode = Read-Host "Type FULL or SALES"
    if ($mode -ieq "full") { "full" | Set-Content ".forge-mode" -NoNewline }
    else { "sales" | Set-Content ".forge-mode" -NoNewline }
}

# 3. Set up .env
if (-not (Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Host ""
        Write-Host "This is an Anthropic API key from console.anthropic.com - NOT your claude.ai Pro/Max login." -ForegroundColor Yellow
        Write-Host "Anthropic does not permit routing Pro/Max subscription credentials through third-party tools." -ForegroundColor Yellow
        $secureKey = Read-Host "Paste your Anthropic API key" -AsSecureString
        $plainKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
        )
        (Get-Content ".env") -replace "your-key-here", $plainKey | Set-Content ".env"
        Write-Host ".env created. Remember: this file is gitignored on purpose - never commit it." -ForegroundColor Green
    } else {
        Write-Host "WARNING: .env.example not found - skipping .env setup. Create .env manually." -ForegroundColor Yellow
    }
} else {
    Write-Host ".env already exists - leaving it alone." -ForegroundColor Green
}

# 4. Sanity check
Write-Host ""
Write-Host "Running hermes doctor..." -ForegroundColor Cyan
hermes doctor

# 5. Next steps
Write-Host ""
Write-Host "== Setup complete ==" -ForegroundColor Cyan
Write-Host "Next steps:"
Write-Host "  1. Run 'hermes model' once to pick Anthropic / Claude as your provider (if not already set)."
Write-Host "  2. Run 'hermes' from this folder to start North Forge."
Write-Host "  3. Once it's running, check that project skills were picked up: run '/skills' or 'skills_list' and"
Write-Host "     look for kb-builder tagged [project]. If it does NOT show up, the project-skill discovery path"
Write-Host "     may not be exactly 'skills/' in this Hermes version - check the Skills docs for the exact convention"
Write-Host "     and flag it back for a fix rather than assuming it's broken."
