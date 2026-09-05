@echo off
rem =============================================================================
rem  North Forge - Hermes Edition (Kyocera Edition v21.8) - part of the North
rem  Forge project.
rem  File: machine-reset.bat | Script version: 1.1.0 | Updated: 2026-09-05
rem  Author: Kenneth C. Walker Jr. - Senior Technical Support Engineer, TSC
rem =============================================================================
setlocal DisableDelayedExpansion
cd /d "%~dp0"
set "EXIT_CODE=0"

rem --- admin gate (Phase 4): required before key rotation and full purge ---
rem Failed-attempt count is session-scoped (this variable only), never
rem persisted. The log records PASS/FAIL + attempt number, never the value.
set /a ADMIN_ATTEMPTS=0

rem ===========================================================================
rem  machine-reset.bat - reset Hermes state on THIS COMPUTER
rem
rem  Distinct from toggle-mode.bat: that one resets the DRIVE (this repo's
rem  own .env / .forge-mode / build artifacts). This one only touches the
rem  per-machine Hermes folder - %HERMES_HOME%, or %LOCALAPPDATA%\hermes when
rem  HERMES_HOME is not set - and never touches the repo content on this drive.
rem
rem  Two options:
rem    1  Rotate the API key - delete only .env. Model config (config.yaml),
rem       memory, sessions, and skills are all left in place. Meant to be run
rem       routinely as a key-rotation habit.
rem    2  Full purge - stop and uninstall the messaging gateway service, then
rem       delete the entire per-machine Hermes folder. Requires typing the
rem       exact validated canonical path.
rem ===========================================================================

rem PowerShell is the safety boundary: it validates the untrusted environment
rem value before cmd.exe displays, compares, or passes it to deletion code.
set "VALIDATION_FILE=%TEMP%\north-forge-reset-%RANDOM%-%RANDOM%.txt"
powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0scripts\machine-reset-safety.ps1" -Action Validate > "%VALIDATION_FILE%"
if errorlevel 1 (
    >> "forge-events.log" echo [%DATE% %TIME%] [ERROR] [machine-reset]: Hermes home safety validation rejected the target
    echo.
    echo Reset stopped safely. Nothing was deleted. Fix HERMES_HOME and try again.
    set "EXIT_CODE=2"
    del /q "%VALIDATION_FILE%" >nul 2>nul
    goto :end
)
set /p VALIDATED_HERMES_HOME=<"%VALIDATION_FILE%"
del /q "%VALIDATION_FILE%" >nul 2>nul

echo ============================================================
echo  North Forge - MACHINE reset
echo ============================================================
echo This resets Hermes state on THIS COMPUTER only. It does not
echo touch this drive's repo content, and it is not the same as
echo toggle-mode ^(which resets the DRIVE, not the machine^).
echo.
echo Per-machine Hermes folder:
powershell.exe -NoLogo -NoProfile -NonInteractive -Command "Write-Host ('  ' + $env:VALIDATED_HERMES_HOME)"
echo.
echo   1  Rotate the API key  - delete only .env
echo                            ^(model config, memory, sessions, skills kept^)
echo   2  Full purge          - stop + uninstall the messaging gateway,
echo                            then delete the ENTIRE folder above
echo   3  Cancel
echo.
set "CHOICE="
set /p CHOICE="Type 1, 2, or 3 and press Enter: "
powershell.exe -NoLogo -NoProfile -NonInteractive -Command "switch -CaseSensitive ($env:CHOICE) { '1' { exit 11 }; '2' { exit 12 }; '3' { exit 13 }; default { exit 1 } }"
if errorlevel 13 goto :cancel
if errorlevel 12 goto :full_purge
if errorlevel 11 goto :rotate_key
echo.
echo Didn't recognize that - run this again and type exactly 1, 2, or 3.
set "EXIT_CODE=1"
goto :end


:rotate_key
call :admin_gate "API key rotation"
if errorlevel 1 goto :end
echo.
echo About to delete:
powershell.exe -NoLogo -NoProfile -NonInteractive -Command "Write-Host ('  ' + (Join-Path $env:VALIDATED_HERMES_HOME '.env'))"
echo.
echo Your current Anthropic API key is removed from this machine. Any
echo messaging-gateway relay credentials kept in the same .env go with it.
echo Model choice, memory, sessions, and skills are all left alone.
echo.
call :confirm_canonical
if errorlevel 1 (
    echo.
    echo Cancelled - nothing was deleted.
    set "EXIT_CODE=1"
    goto :end
)
powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0scripts\machine-reset-safety.ps1" -Action RemoveEnv
if errorlevel 1 (
    echo.
    echo Could not safely remove .env. Close Hermes and try again.
    >> "forge-events.log" echo [%DATE% %TIME%] [ERROR] [machine-reset]: API-key deletion failed or was partial
    set "EXIT_CODE=1"
    goto :end
)
echo.
echo Done - .env removed.
echo Add your new key with:  hermes setup
echo   ^(or run hermes setup and follow its prompts^)
echo If you use the messaging gateway, re-enroll with:  hermes gateway enroll
goto :end


:full_purge
call :admin_gate "full machine purge"
if errorlevel 1 goto :end
echo.
echo FULL PURGE - this will:
echo   1. hermes gateway stop       ^(stop the background messaging service^)
echo   2. hermes gateway uninstall  ^(remove that service^)
echo   3. safely remove the validated folder displayed above
echo.
echo Everything on this machine goes: API key, model config, memory,
echo sessions, skills, cron jobs, kanban, logs, and the Hermes program
echo itself. This drive's repo content is NOT touched. None of it is
echo recoverable afterward.
echo.
call :confirm_canonical
if errorlevel 1 (
    echo.
    echo Cancelled - nothing was stopped, uninstalled, or deleted.
    set "EXIT_CODE=1"
    goto :end
)

echo.
where hermes >nul 2>nul
if errorlevel 1 (
    echo Safety stop: hermes is not on PATH, so the gateway cannot be checked.
    >> "forge-events.log" echo [%DATE% %TIME%] [ERROR] [machine-reset]: gateway command unavailable; purge stopped
    set "EXIT_CODE=1"
    goto :end
) else (
    echo Stopping messaging gateway...
    call hermes gateway stop
    if errorlevel 1 goto :gateway_failed
    echo Uninstalling messaging gateway service...
    call hermes gateway uninstall
    if errorlevel 1 goto :gateway_failed
)

echo.
echo Deleting the validated Hermes folder...
powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0scripts\machine-reset-safety.ps1" -Action Purge
if errorlevel 1 (
    echo.
    echo Partly done - some files could not be deleted,
    echo usually because a Hermes process ^(a chat window, the gateway, an
    echo editor^) still has them open. Close everything Hermes, then run this
    echo option again or delete that folder by hand.
    >> "forge-events.log" echo [%DATE% %TIME%] [ERROR] [machine-reset]: full purge failed or was partial
    set "EXIT_CODE=1"
    goto :end
)
echo.
echo Done - Hermes is fully removed from this machine.
echo To reinstall, run launch-north-forge.bat ^(it reinstalls Hermes when it
echo is missing^), or use the installer one-liner from README.md.
echo You may need to open a new terminal for PATH changes to take effect.
goto :end


:gateway_failed
echo.
echo Safety stop: the gateway command failed, so no files were deleted.
echo Fix the gateway problem and run this option again.
>> "forge-events.log" echo [%DATE% %TIME%] [ERROR] [machine-reset]: gateway stop or uninstall failed; purge stopped
set "EXIT_CODE=1"
goto :end


:cancel
echo.
echo Cancelled - nothing was changed.
set "EXIT_CODE=1"
goto :end


:confirm_canonical
echo.
echo Safety confirmation: type the exact folder path displayed below.
echo Help: this proves you reviewed the destination; copy it exactly, then press Enter.
powershell.exe -NoLogo -NoProfile -NonInteractive -Command "Write-Host $env:VALIDATED_HERMES_HOME"
set "CONFIRM="
set /p CONFIRM="Exact folder path: "
powershell.exe -NoLogo -NoProfile -NonInteractive -Command "if ($env:CONFIRM -ceq $env:VALIDATED_HERMES_HOME) { exit 0 } else { exit 1 }"
exit /b %ERRORLEVEL%


:admin_gate
rem Arg 1 = action name for the prompt and log. Returns errorlevel 0 on
rem correct password, 1 on wrong. Never logs the entered value.
set "PW="
set /p PW="Admin password required for %~1: "
set /a ADMIN_ATTEMPTS+=1
powershell.exe -NoLogo -NoProfile -NonInteractive -Command "if ($env:PW -ceq 'RumpleStiltskin') { exit 0 } else { exit 1 }"
set "PW="
if not errorlevel 1 (
    >> "forge-events.log" echo [%DATE% %TIME%] [INFO] [admin-gate]: PASS ^(%~1^)
    exit /b 0
)
>> "forge-events.log" echo [%DATE% %TIME%] [INFO] [admin-gate]: FAIL (%~1)
echo Wrong password - %~1 cancelled.
if %ADMIN_ATTEMPTS% GEQ 3 echo Hint: Brothers Grimm
set "EXIT_CODE=1"
exit /b 1


:end
echo.
pause
exit /b %EXIT_CODE%
