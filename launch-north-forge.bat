@echo off
rem =============================================================================
rem  North Forge - Hermes Edition (Kyocera Edition v21.8) - part of the North
rem  Forge project.
rem  File: launch-north-forge.bat | Script version: 1.1.1 | Updated: 2026-09-05
rem  Author: Kenneth C. Walker Jr. - Senior Technical Support Engineer, TSC
rem =============================================================================
setlocal enabledelayedexpansion
cd /d "%~dp0"

if /i "%~1"=="--configure-free-provider" (
    call :CONFIGURE_FREE_PROVIDER
    exit /b !ERRORLEVEL!
)

rem --- first run on this drive: pop open the styled quickstart once ---
if not exist ".readme-shown" (
    start "" "WELCOME.html"
    if errorlevel 1 (
        >> "forge-events.log" echo [%DATE% %TIME%] [WARNING] [welcome]: first-run WELCOME.html auto-open FAILED
    ) else (
        >> "forge-events.log" echo [%DATE% %TIME%] [INFO] [welcome]: first-run WELCOME.html auto-open: ok
    )
    echo. > .readme-shown
)

rem --- user tier: who-has-this-drive record (accountability only, never blocks) ---
if not exist ".drive-record.txt" (
    set "DRIVENAME="
    set /p DRIVENAME="First launch: your name for this drive's record: "
    if not defined DRIVENAME set "DRIVENAME=Unregistered"
    > ".drive-record.txt" echo !DRIVENAME!
    >> ".drive-record.txt" echo %DATE% %TIME%
    >> "forge-events.log" echo [%DATE% %TIME%] [INFO] [drive-record]: CREATE: registered to !DRIVENAME!
) else (
    set /p CURNAME=<".drive-record.txt"
    set "NEWNAME="
    set /p NEWNAME="Still !CURNAME!? [Enter to continue / type a new name to re-register]: "
    if defined NEWNAME (
        > ".drive-record.txt" echo !NEWNAME!
        >> ".drive-record.txt" echo %DATE% %TIME%
        >> "forge-events.log" echo [%DATE% %TIME%] [INFO] [drive-record]: RE-REGISTER: !CURNAME! -^> !NEWNAME!
    )
)

rem --- first run on this machine: put a real North Forge icon on the Desktop
rem (Windows twin of the Mac launcher's "North Forge.command" desktop icon).
rem Points at this launcher wherever the drive is mounted right now.
rem Resolved via WScript.Shell SpecialFolders, not %USERPROFILE%\Desktop -
rem that hardcoded path does not exist whenever Desktop is OneDrive-redirected
rem (e.g. C:\Users\<user>\OneDrive\Desktop instead of C:\Users\<user>\Desktop,
rem a common Windows setup), which silently failed shortcut creation on every
rem launch (reproduced 2026-09-04: DirectoryNotFoundException on $s.Save()).
for /f "usebackq delims=" %%D in (`powershell -NoProfile -Command "(New-Object -ComObject WScript.Shell).SpecialFolders('Desktop')"`) do set "DESKTOPDIR=%%D"
if not defined DESKTOPDIR set "DESKTOPDIR=%USERPROFILE%\Desktop"
if not exist "!DESKTOPDIR!\North Forge.lnk" (
    powershell -NoProfile -Command ^
        "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('!DESKTOPDIR!\North Forge.lnk');" ^
        "$s.TargetPath='%~f0'; $s.WorkingDirectory='%~dp0';" ^
        "$s.IconLocation='%~dp0assets\north-forge.ico'; $s.Save()" >nul 2>nul
    if exist "!DESKTOPDIR!\North Forge.lnk" (
        >> "forge-events.log" echo [%DATE% %TIME%] [INFO] [shortcut]: Desktop shortcut created with icon at !DESKTOPDIR!
    ) else (
        >> "forge-events.log" echo [%DATE% %TIME%] [WARNING] [shortcut]: Desktop shortcut creation FAILED ^(target: !DESKTOPDIR!^)
    )
)

rem --- log repo state at launch (no git pull happens here by design - drives
rem update manually; this records what code the session ran on) ---
where git >nul 2>nul
if errorlevel 1 (
    >> "forge-events.log" echo [%DATE% %TIME%] [WARNING] [git]: git not on PATH - repo state unknown at launch
) else (
    for /f "usebackq delims=" %%H in (`git rev-parse --short HEAD 2^>nul`) do set "GITHEAD=%%H"
    if defined GITHEAD (
        >> "forge-events.log" echo [%DATE% %TIME%] [INFO] [git]: launch at commit !GITHEAD!
    ) else (
        >> "forge-events.log" echo [%DATE% %TIME%] [WARNING] [git]: .git missing or unreadable - repo state unknown at launch
    )
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
    "if ($t.Length -ge 20000) { Add-Content 'forge-events.log' ('[' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + '] [FAILURE] [size-guard]: assembled .hermes.md ' + $t.Length + ' chars ge 20000 ceiling - launch aborted'); Write-Host ('FATAL: assembled .hermes.md is ' + $t.Length + ' chars - at or over the 20,000-char context-file ceiling. Hermes would silently drop the middle of the file. Trim the template/banner/menu before launching.'); exit 1 };" ^
    "if ($t.Length -ge 19800) { Add-Content 'forge-events.log' ('[' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + '] [WARNING] [size-guard]: assembled .hermes.md ' + $t.Length + ' chars - within 200 of the 20000 ceiling'); Write-Host ('WARNING: assembled .hermes.md is ' + $t.Length + ' chars - within 200 of the 20,000-char ceiling. Trim soon.') };" ^
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

rem --- provider choice: default to zero-config OpenCode Free (no key, no
rem     account, no block); using your own Anthropic API key is opt-in, not
rem     the hard gate this used to be. Asked once, remembered in
rem     .provider-choice, same pattern as .agent-name/.drive-record.txt. ---
if not exist ".provider-choice" (
    echo.
    echo North Forge needs an AI provider before it can answer questions.
    echo.
    echo   Press ENTER  - start now for free, no account or key needed
    echo                  ^(uses OpenCode Free - good for trying it out^)
    echo   Type OWNKEY  - use your own Anthropic API key instead
    echo                  ^(paid, pay-per-token - pick this for real field/production use^)
    echo.
    set "PROVIDERCHOICE="
    set /p PROVIDERCHOICE="Your choice [ENTER = free / OWNKEY = your own key]: "
    if /i "!PROVIDERCHOICE!"=="OWNKEY" (
        echo ownkey> ".provider-choice"
    ) else (
        call :CONFIGURE_FREE_PROVIDER
        if errorlevel 1 exit /b !ERRORLEVEL!
    )
)

set /p PROVIDERMODE=<".provider-choice"
for /f "tokens=* delims= " %%A in ("%PROVIDERMODE%") do set "PROVIDERMODE=%%A"

if /i "%PROVIDERMODE%"=="ownkey" (
    if not exist ".env" (
        if exist ".env.example" (
            copy ".env.example" ".env" >nul
            echo.
            echo First run: created .env from the template.
            echo Add your Anthropic API key in the notepad window that opens, save, close it, then run this launcher again.
            echo IMPORTANT: run 'hermes model' and pick a standard model ^(Sonnet or Opus^) -
            echo avoid a premium/credits-gated model ^(Fable, Mythos^) unless you specifically
            echo know it needs a separate purchased credits balance on top of this API key.
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
    if errorlevel 1 (
        >> "forge-events.log" echo [%DATE% %TIME%] [WARNING] [cron]: re-registration of nightly-kyocera-research FAILED
    ) else (
        >> "forge-events.log" echo [%DATE% %TIME%] [INFO] [cron]: re-registered nightly-kyocera-research ^(0 6 * * *^)
    )
)
hermes cron list 2>nul | findstr /C:"daily-kyocera-brief" >nul
if errorlevel 1 (
    echo Scheduling the daily Kyocera brief job...
    hermes cron add "0 8 * * *" "Run the daily-brief pass" --skill daily-brief --name daily-kyocera-brief >nul 2>nul
    if errorlevel 1 (
        >> "forge-events.log" echo [%DATE% %TIME%] [WARNING] [cron]: re-registration of daily-kyocera-brief FAILED
    ) else (
        >> "forge-events.log" echo [%DATE% %TIME%] [INFO] [cron]: re-registered daily-kyocera-brief ^(0 8 * * *^)
    )
)

rem Plain call (was already not exec'd on Windows) - log how the session ended.
hermes
set "HERMES_EXIT=%ERRORLEVEL%"
if "%HERMES_EXIT%"=="0" (
    >> "forge-events.log" echo [%DATE% %TIME%] [INFO] [hermes]: session ended normally ^(exit 0^)
) else (
    >> "forge-events.log" echo [%DATE% %TIME%] [WARNING] [hermes]: session ended with exit %HERMES_EXIT%
)
exit /b %HERMES_EXIT%

:CONFIGURE_FREE_PROVIDER
del /q ".provider-choice" >nul 2>nul
set "CONFIG_TMP=%TEMP%\north-forge-provider-!RANDOM!-!RANDOM!"
mkdir "!CONFIG_TMP!" >nul 2>nul

hermes config set model.provider opencode-free >"!CONFIG_TMP!\set.out" 2>"!CONFIG_TMP!\set.err"
set "SET_STATUS=!ERRORLEVEL!"
if not "!SET_STATUS!"=="0" (
    echo ERROR: Hermes could not select OpenCode Free ^(exit !SET_STATUS!^).
    echo Nothing was saved. Please review the details below, then run North Forge again.
    type "!CONFIG_TMP!\set.out" & type "!CONFIG_TMP!\set.err"
    >> "forge-events.log" echo [%DATE% %TIME%] [FAILURE] [provider-config]: set model.provider failed ^(exit !SET_STATUS!^); .provider-choice not written
    call :LOG_PROVIDER_DETAIL "!CONFIG_TMP!\set.out" "!CONFIG_TMP!\set.err"
    rmdir /s /q "!CONFIG_TMP!"
    exit /b !SET_STATUS!
)

hermes config unset model.default >"!CONFIG_TMP!\unset.out" 2>"!CONFIG_TMP!\unset.err"
set "UNSET_STATUS=!ERRORLEVEL!"
set "UNSET_ABSENT=0"
if "!UNSET_STATUS!"=="1" (
    powershell -NoProfile -Command "$a=(Get-Content -Raw -LiteralPath ($env:CONFIG_TMP+'\unset.out'))+(Get-Content -Raw -LiteralPath ($env:CONFIG_TMP+'\unset.err')); if ($a.TrimEnd([char]13,[char]10) -ceq 'Config key not set: model.default') { exit 0 } else { exit 1 }"
    if not errorlevel 1 set "UNSET_ABSENT=1"
)
if not "!UNSET_STATUS!"=="0" if not "!UNSET_ABSENT!"=="1" (
    echo ERROR: Hermes selected OpenCode Free, but could not clear the old default model ^(exit !UNSET_STATUS!^).
    echo Nothing was saved. Please review the details below, then run North Forge again.
    type "!CONFIG_TMP!\unset.out" & type "!CONFIG_TMP!\unset.err"
    >> "forge-events.log" echo [%DATE% %TIME%] [FAILURE] [provider-config]: unset model.default failed ^(exit !UNSET_STATUS!^); .provider-choice not written
    call :LOG_PROVIDER_DETAIL "!CONFIG_TMP!\unset.out" "!CONFIG_TMP!\unset.err"
    rmdir /s /q "!CONFIG_TMP!"
    exit /b !UNSET_STATUS!
)

> ".provider-choice" echo free
rmdir /s /q "!CONFIG_TMP!"
exit /b 0

:LOG_PROVIDER_DETAIL
powershell -NoProfile -Command "$text=((Get-Content -Raw -LiteralPath '%~1')+(Get-Content -Raw -LiteralPath '%~2')); $safe=$text -replace '(?i)(api[_-]?key|token|secret|password)(\s*[:=]\s*)\S+','$1$2[REDACTED]'; Add-Content -LiteralPath 'forge-events.log' -Value ('[provider-config detail] '+$safe.Trim())"
exit /b 0
