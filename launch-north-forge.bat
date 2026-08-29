@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

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

powershell -NoProfile -Command ^
    "$m='%MODE%';" ^
    "$t=Get-Content '.hermes.template.md' -Raw;" ^
    "$b=Get-Content \"mode-blocks\$m-banner.md\" -Raw;" ^
    "$c=Get-Content \"mode-blocks\$m-menu.md\" -Raw;" ^
    "$t=$t.Replace('{{MODE_BANNER_BLOCK}}',$b).Replace('{{COMMAND_MENU_BLOCK}}',$c);" ^
    "Set-Content -Path '.hermes.md' -Value $t -NoNewline"

echo North Forge running in %MODE% mode.

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

hermes
