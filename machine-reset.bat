@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

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
rem       delete the entire per-machine Hermes folder. Requires typing YES.
rem ===========================================================================

rem --- resolve the per-machine Hermes folder the same way the launcher does ---
if defined HERMES_HOME (
    set "HERMES_DIR=%HERMES_HOME%"
) else (
    set "HERMES_DIR=%LOCALAPPDATA%\hermes"
)
rem drop a trailing backslash so the safety comparisons below are exact
if "%HERMES_DIR:~-1%"=="\" set "HERMES_DIR=%HERMES_DIR:~0,-1%"

echo ============================================================
echo  North Forge - MACHINE reset
echo ============================================================
echo This resets Hermes state on THIS COMPUTER only. It does not
echo touch this drive's repo content, and it is not the same as
echo toggle-mode ^(which resets the DRIVE, not the machine^).
echo.
echo Per-machine Hermes folder:
echo   %HERMES_DIR%
if not exist "%HERMES_DIR%\" echo   ^(does not exist - nothing here to reset^)
echo.
echo   1  Rotate the API key  - delete only .env
echo                            ^(model config, memory, sessions, skills kept^)
echo   2  Full purge          - stop + uninstall the messaging gateway,
echo                            then delete the ENTIRE folder above ^(type YES^)
echo   3  Cancel
echo.
set "CHOICE="
set /p CHOICE="Type 1, 2, or 3 and press Enter: "

if "%CHOICE%"=="1" goto :rotate_key
if "%CHOICE%"=="2" goto :full_purge
if "%CHOICE%"=="3" goto :cancel
echo.
echo Didn't recognize that - run this again and type exactly 1, 2, or 3.
goto :end


:rotate_key
call :admin_gate "API key rotation"
if errorlevel 1 goto :end
echo.
if not exist "%HERMES_DIR%\.env" (
    echo No .env found at "%HERMES_DIR%\.env" - nothing to rotate.
    echo Add a key later with:  hermes setup
    goto :end
)
echo About to delete:
echo   %HERMES_DIR%\.env
echo.
echo Your current Anthropic API key is removed from this machine. Any
echo messaging-gateway relay credentials kept in the same .env go with it.
echo Model choice, memory, sessions, and skills are all left alone.
echo.
set "CONFIRM="
set /p CONFIRM="Press Y then Enter to delete .env: "
if /i not "%CONFIRM%"=="Y" (
    echo.
    echo Cancelled - nothing was deleted.
    goto :end
)
del /q "%HERMES_DIR%\.env"
if exist "%HERMES_DIR%\.env" (
    echo.
    echo Could not delete .env - a Hermes session or the gateway is probably
    echo still running. Close everything Hermes and run this again.
    goto :end
)
echo.
echo Done - .env removed.
echo Add your new key with:  hermes setup
echo   ^(or recreate %HERMES_DIR%\.env with one line:  ANTHROPIC_API_KEY=your-new-key^)
echo If you use the messaging gateway, re-enroll with:  hermes gateway enroll
goto :end


:full_purge
call :admin_gate "full machine purge"
if errorlevel 1 goto :end
echo.
if not exist "%HERMES_DIR%\" (
    echo No Hermes folder found at "%HERMES_DIR%" - nothing to purge.
    goto :end
)
rem --- refuse an obviously-wrong deletion target ---
if /i "%HERMES_DIR%"=="%SystemDrive%"  goto :bad_target
if /i "%HERMES_DIR%"=="%USERPROFILE%"  goto :bad_target
if /i "%HERMES_DIR%"=="%LOCALAPPDATA%" goto :bad_target
if /i "%HERMES_DIR%"=="%APPDATA%"      goto :bad_target
if not exist "%HERMES_DIR%\hermes-agent\" if not exist "%HERMES_DIR%\config.yaml" goto :bad_target

echo FULL PURGE - this will:
echo   1. hermes gateway stop       ^(stop the background messaging service^)
echo   2. hermes gateway uninstall  ^(remove that service^)
echo   3. rmdir /s /q "%HERMES_DIR%"
echo.
echo Everything on this machine goes: API key, model config, memory,
echo sessions, skills, cron jobs, kanban, logs, and the Hermes program
echo itself. This drive's repo content is NOT touched. None of it is
echo recoverable afterward.
echo.
set "CONFIRM="
set /p CONFIRM="Type YES (all caps) to confirm: "
if not "%CONFIRM%"=="YES" (
    echo.
    echo Cancelled - nothing was stopped, uninstalled, or deleted.
    goto :end
)

echo.
where hermes >nul 2>nul
if errorlevel 1 (
    echo hermes not on PATH - skipping gateway stop/uninstall, deleting folder only.
) else (
    echo Stopping messaging gateway...
    call hermes gateway stop
    echo Uninstalling messaging gateway service...
    call hermes gateway uninstall
)

echo.
echo Deleting %HERMES_DIR% ...
rmdir /s /q "%HERMES_DIR%"
if exist "%HERMES_DIR%\" (
    echo.
    echo Partly done - some files under "%HERMES_DIR%" could not be deleted,
    echo usually because a Hermes process ^(a chat window, the gateway, an
    echo editor^) still has them open. Close everything Hermes, then run this
    echo option again or delete that folder by hand.
    goto :end
)
echo.
echo Done - Hermes is fully removed from this machine.
echo To reinstall, run launch-north-forge.bat ^(it reinstalls Hermes when it
echo is missing^), or use the installer one-liner from README.md.
echo You may need to open a new terminal for PATH changes to take effect.
goto :end


:bad_target
echo.
echo Refusing to delete "%HERMES_DIR%".
echo It does not look like a Hermes install ^(no hermes-agent\ folder and no
echo config.yaml inside it^), or it points at a drive root or home folder.
echo If HERMES_HOME is set wrong, fix it and run this again.
goto :end


:cancel
echo.
echo Cancelled - nothing was changed.
goto :end


:admin_gate
rem Arg 1 = action name for the prompt and log. Returns errorlevel 0 on
rem correct password, 1 on wrong. Never logs the entered value.
set "PW="
set /p PW="Admin password required for %~1: "
set /a ADMIN_ATTEMPTS+=1
if "!PW!"=="RumpleStiltskin" (
    >> "forge-events.log" echo [%DATE% %TIME%] [INFO] [admin-gate]: attempt !ADMIN_ATTEMPTS! PASS ^(%~1^)
    exit /b 0
)
>> "forge-events.log" echo [%DATE% %TIME%] [INFO] [admin-gate]: attempt !ADMIN_ATTEMPTS! FAIL (%~1)
echo Wrong password - %~1 cancelled.
if !ADMIN_ATTEMPTS! GEQ 3 echo Hint: Brothers Grimm
exit /b 1


:end
echo.
pause
