@echo off
rem =============================================================================
rem  North Forge - Hermes Edition (Kyocera Edition v21.8) - part of the North
rem  Forge project.
rem  File: launch-north-forge.bat | Script version: 1.3.0 | Updated: 2026-09-05
rem  Author: Kenneth C. Walker Jr. - Senior Technical Support Engineer, TSC
rem =============================================================================
setlocal DisableDelayedExpansion
cd /d "%~dp0"
set "HERMES_HOME=%CD%\.hermes-home"
rem Keep the complete Hermes installation, configuration, memory, and cron
rem database on this drive. Deliberately overwrite any caller-supplied or
rem inherited machine-wide value so shared host state is never used and two
rem drives can never silently share state.
rem Fail fast if this drive is not writable at all, before asking the
rem operator any questions. Probes %CD% directly - this must NOT create
rem .hermes-home itself: scripts\ensure-hermes.ps1 treats any pre-existing
rem .hermes-home as an install to validate or recover, not as "not yet
rem installed," so creating it here as a side effect made every fresh-drive
rem install fail with "partial or damaged .hermes-home" before the installer
rem ever ran (reproduced empirically 2026-09-05 on real Windows; see audit).
set "WRITE_PROBE=%CD%\.north-forge-write-probe-%RANDOM%-%RANDOM%.tmp"
> "%WRITE_PROBE%" echo North Forge write test
if errorlevel 1 (
    echo ERROR: North Forge cannot write to this drive at "%CD%". Check the drive's permissions or free space.
    >> "forge-events.log" echo [%DATE% %TIME%] [FAILURE] [hermes-home]: drive is not writable at "%CD%"
    exit /b 1
)
del /q "%WRITE_PROBE%" >nul 2>nul
set "WRITE_PROBE="

if /i "%~1"=="--configure-free-provider" (
    call :CONFIGURE_FREE_PROVIDER
    exit /b !ERRORLEVEL!
)

rem Locate Python before accepting names. Keeping input inside the shared helper
rem avoids cmd.exe metacharacter and delayed-expansion surprises. (Restored
rem during merge: this block was present after the name-validation fix but
rem missing from the free-provider-hardening fix that landed on top of it -
rem without it, %PYTHON_CMD% below is empty and name_validation.py never runs.)
set "PYTHON_CMD="
where py >nul 2>nul && set "PYTHON_CMD=py -3"
if not defined PYTHON_CMD where python >nul 2>nul && set "PYTHON_CMD=python"
rem Test seam only (see tests\test-dependency-check.sh): forces the "missing"
rem branch so the guided-install flow can be exercised without removing the
rem machine's real Python. Never set in normal use.
if defined NORTH_FORGE_DEP_FORCE_PY_MISSING set "PYTHON_CMD="
if not defined PYTHON_CMD (
    rem Python 3 is the only genuine launch-time hard dependency: this launcher
    rem needs it for scripts\name_validation.py and the .hermes.md assembly step
    rem below, before the Hermes engine (which bootstraps its own Python/Node/
    rem git) is ever reached. Node.js is deliberately NOT checked - nothing on
    rem the launch path runs node/npm/npx. See :ENSURE_PYTHON_DEP at the end of
    rem this file and the matching logic in launch-north-forge.sh.
    call :ENSURE_PYTHON_DEP
    if errorlevel 1 exit /b 1
) else (
    >> "forge-events.log" echo [%DATE% %TIME%] [INFO] [deps]: Python 3 present as "%PYTHON_CMD%" - launch dependency check passed
)

rem --- first run on this drive: pop open the styled quickstart once ---
if not exist ".readme-shown" (
    if not exist "WELCOME.html" (
        >> "forge-events.log" echo [%DATE% %TIME%] [WARNING] [welcome]: first-run WELCOME.html auto-open FAILED - file is missing
    ) else (
        start "" "WELCOME.html"
        if errorlevel 1 (
            >> "forge-events.log" echo [%DATE% %TIME%] [WARNING] [welcome]: first-run WELCOME.html auto-open FAILED
        ) else (
            echo. > .readme-shown
            >> "forge-events.log" echo [%DATE% %TIME%] [INFO] [welcome]: first-run WELCOME.html auto-open: ok
        )
    )
)

rem Names: 64 characters maximum; letters, numbers, spaces, apostrophe, hyphen,
rem period, comma, and parentheses only. Help: press Enter to keep the default.
%PYTHON_CMD% scripts\name_validation.py drive
if errorlevel 1 exit /b 1

rem User name input is finished, so delayed expansion is safe for existing
rem launcher bookkeeping below. It was deliberately OFF while names were read.
setlocal EnableDelayedExpansion

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

rem --- one obvious thing to double-click at the drive root itself: a real
rem .lnk carrying assets\north-forge.ico and pointing at this launcher. A .bat
rem can never show a custom icon; only a .lnk can. This must land at the
rem actual drive root (e.g. E:\), NOT inside this checkout's own folder -
rem provision-new-drive.ps1 always clones into a "north-forge-hermes-edition"
rem subfolder, so %~dp0 (this script's own directory) IS that subfolder, one
rem level below the real root, on every drive set up that way. Using %~dp0
rem here silently placed the shortcut a folder too deep (reproduced on a real
rem drive 2026-09-11: "North Forge.lnk" landed in
rem <drive>:\north-forge-hermes-edition\ instead of <drive>:\). %~d0 is the
rem drive letter only, so "%~d0\" is the true root regardless of how deep
rem this script itself is nested. The target path is drive-letter-specific,
rem so it is generated here (and by provision-new-drive.ps1 at provisioning
rem time) and never committed.
set "ROOTSHORTCUT=%~d0\North Forge.lnk"
if not exist "%ROOTSHORTCUT%" (
    powershell -NoProfile -Command ^
        "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('%ROOTSHORTCUT%');" ^
        "$s.TargetPath='%~f0'; $s.WorkingDirectory='%~dp0';" ^
        "$s.IconLocation='%~dp0assets\north-forge.ico'; $s.Description='North Forge - double-click to start'; $s.Save()" >nul 2>nul
    if exist "%ROOTSHORTCUT%" (
        >> "forge-events.log" echo [%DATE% %TIME%] [INFO] [shortcut]: drive-root North Forge.lnk created with icon at "%ROOTSHORTCUT%"
    ) else (
        >> "forge-events.log" echo [%DATE% %TIME%] [WARNING] [shortcut]: drive-root North Forge.lnk creation FAILED ^(target: "%ROOTSHORTCUT%"^)
    )
)
set "ROOTSHORTCUT="

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

powershell -NoProfile -ExecutionPolicy Bypass -File "scripts\assemble-skills.ps1" -Mode "%MODE%"
if errorlevel 1 (
    echo ERROR: Skills could not be assembled. The previous working build was preserved.
    exit /b 1
)
if "%NORTH_FORGE_ASSEMBLE_ONLY%"=="1" exit /b 0

rem Disable delayed expansion around the assistant-name prompt too. The helper
rem owns the raw text, so characters such as ! never enter a batch variable.
setlocal DisableDelayedExpansion
%PYTHON_CMD% scripts\name_validation.py agent
if errorlevel 1 exit /b 1
endlocal

powershell -NoProfile -Command ^
    "$m='%MODE%';" ^
    "$t=Get-Content '.hermes.template.md' -Raw;" ^
    "$b=Get-Content \"mode-blocks\$m-banner.md\" -Raw;" ^
    "$c=Get-Content \"mode-blocks\$m-menu.md\" -Raw;" ^
    "$name=(& %PYTHON_CMD% scripts\name_validation.py get --file .agent-name --default 'North Forge'); if ($LASTEXITCODE -ne 0) { exit 1 };" ^
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

rem --- require the drive's own validated engine; never fall back to host Hermes ---
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "scripts\ensure-hermes.ps1" -RepoRoot "%CD%"
if errorlevel 1 (
    set "INSTALL_EXIT=!ERRORLEVEL!"
    pause
    exit /b !INSTALL_EXIT!
)
set "PATH=%HERMES_HOME%\Scripts;%HERMES_HOME%\bin;%HERMES_HOME%;%PATH%"

rem Every interactive command uses the same explicit drive-local entry point
rem as cron/gateway registration; PATH can no longer redirect one operation
rem to a machine-wide Hermes installation. This assignment was present when
rem originally added (commit c2c7303) but was lost in a later merge that
rem restructured the install-guard block above it, leaving every %HERMES_CMD%
rem call site below silently expanding to nothing - cmd.exe would try to run
rem "skin"/"skills"/etc. as a bare command and fail with "is not recognized".
rem Restoring this line surfaced a second, previously-unreachable bug in
rem scripts\hermes-drive.ps1 (a reserved-variable crash) fixed alongside it -
rem see that file's own comment (reproduced empirically 2026-09-05 on real
rem Windows).
set "HERMES_CMD=powershell -NoProfile -ExecutionPolicy Bypass -File scripts\hermes-drive.ps1"

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
set "SKIN_DIR=%HERMES_HOME%\skins"
if not exist "%SKIN_DIR%" mkdir "%SKIN_DIR%"
copy /Y "skins\north-forge.yaml" "%SKIN_DIR%\north-forge.yaml" >nul

echo Activating North Forge skin...
%HERMES_CMD% skin use north-forge
echo Skin list after activation (look for * next to north-forge):
%HERMES_CMD% skin list

rem Project-local skills require an explicit trust decision before Hermes will
rem load them (security gate against a git pull silently injecting a skill).
rem Auto-approved here since this repo is Blacksmith-reviewed before it ever
rem reaches a drive - see README for the tradeoff this makes.
%HERMES_CMD% skills trust .

rem Self-healing scheduled jobs - re-adds the research and daily-brief cron
rem entries if either is missing (e.g. after an AppData flush wiped them).
rem No manual /cron add ever needed again.
set "CRON_DEGRADED="
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts\hermes-drive.ps1" cron list 2>nul | findstr /C:"nightly-kyocera-research" >nul
if errorlevel 1 (
    echo Scheduling the nightly Kyocera research job...
    set "CRON_DIAG=%TEMP%\north-forge-cron-!RANDOM!-!RANDOM!.txt"
    powershell -NoProfile -ExecutionPolicy Bypass -File "scripts\hermes-drive.ps1" cron add "0 6 * * *" "Run the kyocera-research pass" --skill kyocera-research --name nightly-kyocera-research >"!CRON_DIAG!" 2>&1
    set "CRON_EXIT=!ERRORLEVEL!"
    if not "!CRON_EXIT!"=="0" (
        powershell -NoProfile -Command "$d=(Get-Content -Raw -LiteralPath $env:CRON_DIAG -ErrorAction SilentlyContinue) -replace '[\x00-\x1f\x7f]',' '; if (-not $d) {$d='no diagnostic output'}; if ($d.Length -gt 500) {$d=$d.Substring(0,500)}; $w='WARNING: Could not schedule nightly-kyocera-research (exit '+$env:CRON_EXIT+'; diagnostic: '+$d+'). Interactive North Forge can continue, but the automated nightly research will not run. Check the drive-local Hermes cron list, then relaunch North Forge to try again.'; Write-Host $w; Add-Content -LiteralPath 'forge-events.log' ('['+(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')+'] [WARNING] [cron]: '+$w)"
        set "CRON_DEGRADED=nightly-kyocera-research"
    ) else (
        >> "forge-events.log" echo [%DATE% %TIME%] [INFO] [cron]: re-registered nightly-kyocera-research ^(0 6 * * *^)
    )
    del /q "!CRON_DIAG!" 2>nul
)
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts\hermes-drive.ps1" cron list 2>nul | findstr /C:"daily-kyocera-brief" >nul
if errorlevel 1 (
    echo Scheduling the daily Kyocera brief job...
    set "CRON_DIAG=%TEMP%\north-forge-cron-!RANDOM!-!RANDOM!.txt"
    powershell -NoProfile -ExecutionPolicy Bypass -File "scripts\hermes-drive.ps1" cron add "0 8 * * *" "Run the daily-brief pass" --skill daily-brief --name daily-kyocera-brief >"!CRON_DIAG!" 2>&1
    set "CRON_EXIT=!ERRORLEVEL!"
    if not "!CRON_EXIT!"=="0" (
        powershell -NoProfile -Command "$d=(Get-Content -Raw -LiteralPath $env:CRON_DIAG -ErrorAction SilentlyContinue) -replace '[\x00-\x1f\x7f]',' '; if (-not $d) {$d='no diagnostic output'}; if ($d.Length -gt 500) {$d=$d.Substring(0,500)}; $w='WARNING: Could not schedule daily-kyocera-brief (exit '+$env:CRON_EXIT+'; diagnostic: '+$d+'). Interactive North Forge can continue, but the automated daily brief will not run. Check the drive-local Hermes cron list, then relaunch North Forge to try again.'; Write-Host $w; Add-Content -LiteralPath 'forge-events.log' ('['+(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')+'] [WARNING] [cron]: '+$w)"
        if defined CRON_DEGRADED (set "CRON_DEGRADED=!CRON_DEGRADED!; daily-kyocera-brief") else set "CRON_DEGRADED=daily-kyocera-brief"
    ) else (
        >> "forge-events.log" echo [%DATE% %TIME%] [INFO] [cron]: re-registered daily-kyocera-brief ^(0 8 * * *^)
    )
    del /q "!CRON_DIAG!" 2>nul
)

if defined CRON_DEGRADED echo WARNING SUMMARY: North Forge is starting in degraded mode. Unscheduled job^(s^): !CRON_DEGRADED!. Interactive North Forge is still available; check the drive-local Hermes cron list, then relaunch to retry.

rem Plain call (was already not exec'd on Windows) - log how the session ended.
%HERMES_CMD%
set "HERMES_EXIT=%ERRORLEVEL%"
if "%HERMES_EXIT%"=="0" (
    >> "forge-events.log" echo [%DATE% %TIME%] [INFO] [hermes]: session ended normally ^(exit 0^)
) else (
    >> "forge-events.log" echo [%DATE% %TIME%] [WARNING] [hermes]: session ended with exit %HERMES_EXIT%
)
exit /b %HERMES_EXIT%

:CONFIGURE_FREE_PROVIDER
setlocal EnableDelayedExpansion
del /q ".provider-choice" >nul 2>nul
set "CONFIG_TMP=%TEMP%\north-forge-provider-!RANDOM!-!RANDOM!"
mkdir "!CONFIG_TMP!" >nul 2>nul

%HERMES_CMD% config set model.provider opencode-free >"!CONFIG_TMP!\set.out" 2>"!CONFIG_TMP!\set.err"
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

%HERMES_CMD% config unset model.default >"!CONFIG_TMP!\unset.out" 2>"!CONFIG_TMP!\unset.err"
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

:ENSURE_PYTHON_DEP
rem Offer to install Python 3 unattended when it is missing, then re-check.
rem On success: publishes PYTHON_CMD back to the caller via `endlocal & set`
rem and returns 0. On decline or failure: prints manual instructions and
rem returns 1 (the caller then exits). Mirrors launch-north-forge.sh.
setlocal EnableDelayedExpansion
set "NF_PY_VERSION=3.13.15"
>> "forge-events.log" echo [%DATE% %TIME%] [WARNING] [deps]: Python 3 not found - launch-time dependency missing
echo.
echo North Forge needs Python 3 to run, and it's not installed on this computer.
set "NF_ANS="
set /p "NF_ANS=Install it now? [Y/n] (recommended: Y): "
if /i "!NF_ANS!"=="n" goto :ENSURE_PYTHON_DEP_DECLINE
if /i "!NF_ANS!"=="no" goto :ENSURE_PYTHON_DEP_DECLINE
>> "forge-events.log" echo [%DATE% %TIME%] [INFO] [deps]: operator approved the Python 3 install - starting
echo.
echo Installing Python !NF_PY_VERSION! ... this may take a minute.
echo This is a per-user install - Windows will NOT prompt for administrator rights.

set "NF_INSTALL_RC=0"
if defined NORTH_FORGE_DEP_INSTALLER (
    rem Test seam: run a stand-in for the whole download-and-install step.
    call "!NORTH_FORGE_DEP_INSTALLER!"
    set "NF_INSTALL_RC=!ERRORLEVEL!"
) else (
    set "NF_PY_EXE=%TEMP%\north-forge-python-!RANDOM!!RANDOM!.exe"
    set "NF_PY_URL=https://www.python.org/ftp/python/!NF_PY_VERSION!/python-!NF_PY_VERSION!-amd64.exe"
    echo Downloading the official installer from python.org ...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -UseBasicParsing -Uri $env:NF_PY_URL -OutFile $env:NF_PY_EXE } catch { Write-Host $_.Exception.Message; exit 1 }"
    if errorlevel 1 (
        >> "forge-events.log" echo [%DATE% %TIME%] [FAILURE] [deps]: Python installer download failed
        echo Download failed.
        goto :ENSURE_PYTHON_DEP_MANUAL
    )
    rem /quiet no UI; InstallAllUsers=0 per-user (no elevation); PrependPath=1
    rem puts it on PATH for future shells; Include_launcher=1 installs `py`;
    rem Include_test=0 skips the bundled test suite. `start "" /wait` because
    rem the installer is a GUI-subsystem exe - cmd would not block otherwise.
    start "" /wait "!NF_PY_EXE!" /quiet InstallAllUsers=0 PrependPath=1 Include_launcher=1 Include_test=0
    set "NF_INSTALL_RC=!ERRORLEVEL!"
    del /q "!NF_PY_EXE!" >nul 2>nul
)
rem 3010 = "success, reboot required" - treat as success here.
if not "!NF_INSTALL_RC!"=="0" if not "!NF_INSTALL_RC!"=="3010" (
    >> "forge-events.log" echo [%DATE% %TIME%] [FAILURE] [deps]: Python installer exited !NF_INSTALL_RC!
    echo The Python installer did not finish successfully ^(exit !NF_INSTALL_RC!^).
    goto :ENSURE_PYTHON_DEP_MANUAL
)

rem Re-detect. PATH in THIS window was read before the install, so also look
rem in the fixed per-user location the python.org installer uses.
set "NF_PY_FOUND="
where py >nul 2>nul && set "NF_PY_FOUND=py -3"
if not defined NF_PY_FOUND where python >nul 2>nul && set "NF_PY_FOUND=python"
if not defined NF_PY_FOUND if exist "%LOCALAPPDATA%\Programs\Python\" (
    for /f "delims=" %%P in ('dir /b /s "%LOCALAPPDATA%\Programs\Python\python.exe" 2^>nul') do (
        if not defined NF_PY_FOUND set "NF_PY_FOUND=%%P"
    )
)
if not defined NF_PY_FOUND if defined NORTH_FORGE_DEP_PY_EXTRA if exist "!NORTH_FORGE_DEP_PY_EXTRA!" set "NF_PY_FOUND=!NORTH_FORGE_DEP_PY_EXTRA!"
rem Test seam only: "always" also suppresses this post-install re-check so the
rem "installed but still not visible" path can be exercised.
if /i "!NORTH_FORGE_DEP_FORCE_PY_MISSING!"=="always" set "NF_PY_FOUND="
if not defined NF_PY_FOUND (
    >> "forge-events.log" echo [%DATE% %TIME%] [FAILURE] [deps]: installer reported success but Python 3 is still not detectable
    echo Python 3 was installed but this launcher still can't see it.
    echo Close this window and start the launcher again - a fresh window picks it up.
    goto :ENSURE_PYTHON_DEP_MANUAL
)
>> "forge-events.log" echo [%DATE% %TIME%] [INFO] [deps]: Python 3 installed and verified (!NF_PY_FOUND!)
echo Python 3 is installed. Continuing ...
endlocal & set "PYTHON_CMD=%NF_PY_FOUND%" & exit /b 0

:ENSURE_PYTHON_DEP_DECLINE
>> "forge-events.log" echo [%DATE% %TIME%] [INFO] [deps]: operator declined the Python 3 install - exiting cleanly
call :PYTHON_DEP_MANUAL_HELP
endlocal & exit /b 1

:ENSURE_PYTHON_DEP_MANUAL
call :PYTHON_DEP_MANUAL_HELP
endlocal & exit /b 1

:PYTHON_DEP_MANUAL_HELP
echo.
echo North Forge can't start without Python 3. Install it by hand, then run
echo this launcher again:
echo   1. Open  https://www.python.org/downloads/windows/
echo   2. Download the latest "Windows installer (64-bit)".
echo   3. Run it and TICK "Add python.exe to PATH" on the first screen.
echo.
pause
exit /b 0
