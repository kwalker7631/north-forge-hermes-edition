@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

rem --- first run on this drive: pop open the plain-language quickstart once ---
if not exist ".readme-shown" (
    start "" "FIRST_TIME_README.txt"
    echo. > .readme-shown
)

rem --- assemble live .hermes/skills/ and .hermes.md from source, based on the mode toggle ---
set "MODE=sales"
if exist ".forge-mode" (
    set /p MODE=<".forge-mode"
)
rem trim any trailing/leading whitespace so a stray space or BOM in
rem .forge-mode doesn't silently fall through to the sales default
for /f "tokens=* delims= " %%A in ("%MODE%") do set "MODE=%%A"
if /i not "%MODE%"=="full" if /i not "%MODE%"=="sales" (
    echo Unrecognized .forge-mode value "%MODE%" - defaulting to sales for safety.
    set "MODE=sales"
)

if exist "skills" rmdir /s /q "skills"
if exist ".hermes\skills" rmdir /s /q ".hermes\skills"
mkdir ".hermes\skills"
xcopy /e /i /y "skills-source\shared" ".hermes\skills" >nul
if /i "%MODE%"=="full" (
    xcopy /e /i /y "skills-source\tsc-only" ".hermes\skills" >nul
)

if not exist ".agent-name" (
    echo.
    echo First launch on this drive: you can give your assistant a personal
    echo name if you'd like - it still runs as North Forge underneath, this
    echo just changes what it calls itself when talking to you.
    echo.
    set /p CUSTOMNAME="Name your assistant (press Enter to keep 'North Forge'): "
    if "!CUSTOMNAME!"=="" (
        echo North Forge> ".agent-name"
    ) else (
        echo !CUSTOMNAME! > ".agent-name"
    )
    echo.
)

powershell -NoProfile -Command ^
    "$m='%MODE%';" ^
    "$t=Get-Content '.hermes.template.md' -Raw;" ^
    "$b=Get-Content \"mode-blocks\$m-banner.md\" -Raw;" ^
    "$c=Get-Content \"mode-blocks\$m-menu.md\" -Raw;" ^
    "$name='North Forge'; if (Test-Path '.agent-name') { $n=(Get-Content '.agent-name' -Raw).Trim(); if ($n) { $name=$n } };" ^
    "$t=$t.Replace('{{MODE_BANNER_BLOCK}}',$b).Replace('{{COMMAND_MENU_BLOCK}}',$c).Replace('{{AGENT_NAME}}',$name);" ^
    "if ($t.Length -ge 20000) { Write-Host ('FATAL: assembled .hermes.md is ' + $t.Length + ' chars - at or over the 20,000-char context-file ceiling. Hermes would silently drop the middle of the file. Trim the template/banner/menu before launching.'); exit 1 };" ^
    "if ($t.Length -ge 19800) { Write-Host ('WARNING: assembled .hermes.md is ' + $t.Length + ' chars - within 200 of the 20,000-char ceiling. Trim soon.') };" ^
    "Set-Content -Path '.hermes.md' -Value $t -NoNewline"
if errorlevel 1 (
    echo Launch aborted: .hermes.md was not written.
    pause
    exit /b 1
)

echo North Forge running in %MODE% mode.
echo Want a different AI model or provider? Run 'hermes model' any time - it remembers your choice, doesn't ask again until you change it.

rem --- install Hermes FIRST if missing - nothing below this works without it ---
where hermes >nul 2>nul
if errorlevel 1 (
    echo Hermes not found on this machine - installing now...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm https://hermes-agent.nousresearch.com/install.ps1)"
    echo.
    echo Install finished. Close this window and double-click this launcher again.
    pause
    exit /b
)

if not exist ".env" (
    if exist ".env.example" (
        copy ".env.example" ".env" >nul
        echo.
        echo First run: created .env from the template.
        echo Add your Anthropic API key in the notepad window that opens, save, close it, then run this launcher again.
        notepad ".env"
        pause
        exit /b
    )
)

rem --- catch a .env that EXISTS but still holds the placeholder/an
rem     obviously-too-short value, instead of silently launching into a
rem     session that can't call a model. Real Anthropic keys run ~100+
rem     chars; the template placeholder and any partial paste are much
rem     shorter, so a length check below a safe threshold catches both
rem     without needing to match exact placeholder text.
for /f "usebackq delims=" %%L in (`powershell -NoProfile -Command "$line = Get-Content '.env' | Select-String '^ANTHROPIC_API_KEY='; if (-not $line) { 'MISSING' } else { $v = $line.ToString().Split('=',2)[1].Trim(); if ($v.Length -lt 30) { 'SHORT' } else { 'OK' } }"`) do set "KEYCHECK=%%L"
if not "%KEYCHECK%"=="OK" (
    echo.
    echo Your .env exists, but ANTHROPIC_API_KEY looks like a placeholder or
    echo is missing - not a real key. Launching anyway would just fail on
    echo the first real question instead of telling you clearly now.
    echo.
    echo Add your real Anthropic API key in the notepad window that opens,
    echo save, close it, then run this launcher again.
    notepad ".env"
    pause
    exit /b
)

rem --- copy the skin into place and activate it - hermes is guaranteed installed by this point ---
if defined HERMES_HOME (
    set "SKIN_DIR=%HERMES_HOME%\skins"
) else (
    set "SKIN_DIR=%LOCALAPPDATA%\hermes\skins"
)
if not exist "%SKIN_DIR%" mkdir "%SKIN_DIR%"
copy /Y "skins\north-forge.yaml" "%SKIN_DIR%\north-forge.yaml" >nul

echo Activating North Forge skin...
hermes skin use north-forge
echo Skin list after activation (look for * next to north-forge):
hermes skin list

rem Project-local skills require an explicit trust decision before Hermes will
rem load them (security gate against a git pull silently injecting a skill).
rem Auto-approved here since this repo is Blacksmith-reviewed before it ever
rem reaches a drive - see README for the tradeoff this makes.
hermes skills trust .

rem Self-healing scheduled jobs - re-adds the research and daily-brief cron
rem entries if either is missing (e.g. after an AppData flush wiped them).
rem No manual /cron add ever needed again.
hermes cron list 2>nul | findstr /C:"nightly-kyocera-research" >nul
if errorlevel 1 (
    echo Scheduling the nightly Kyocera research job...
    hermes cron add "0 6 * * *" "Run the kyocera-research pass" --skill kyocera-research --name nightly-kyocera-research >nul 2>nul
)
hermes cron list 2>nul | findstr /C:"daily-kyocera-brief" >nul
if errorlevel 1 (
    echo Scheduling the daily Kyocera brief job...
    hermes cron add "0 8 * * *" "Run the daily-brief pass" --skill daily-brief --name daily-kyocera-brief >nul 2>nul
)

hermes
