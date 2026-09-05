@echo off
rem =============================================================================
rem  North Forge - Hermes Edition (Kyocera Edition v21.8) - part of the North
rem  Forge project.
rem  File: toggle-mode.bat | Script version: 1.2.0 | Updated: 2026-09-05
rem  Author: Kenneth C. Walker Jr. - Senior Technical Support Engineer, TSC
rem =============================================================================
setlocal enabledelayedexpansion
rem This script lives in Advanced\ but operates on the drive root (one level
rem up): .forge-mode, the credential dotfiles, .hermes\skills, and
rem forge-events.log all live there. "%~dp0.." resolves to the drive root
rem regardless of drive letter.
cd /d "%~dp0.."

rem --- admin gate (Phase 4): required before mode switches and RESET ---
rem Failed-attempt count lives in ADMIN_ATTEMPTS only - session-scoped,
rem never written to any file. The log records PASS/FAIL + attempt number,
rem never the entered value.
set /a ADMIN_ATTEMPTS=0

:menu
echo.
echo Current mode file:
if exist ".forge-mode" (type ".forge-mode") else (echo ^(none set - defaults to SALES^))
echo.
set "MODE="
set /p MODE="Type FULL, SALES, RESET, EXIT, or Q (blank = quit): "

if not defined MODE goto :end
if /i "%MODE%"=="EXIT" goto :end
if /i "%MODE%"=="Q"    goto :end
if /i "%MODE%"=="FULL"  goto :do_full
if /i "%MODE%"=="SALES" goto :do_sales
if /i "%MODE%"=="RESET" goto :do_reset
echo Didn't recognize that - type exactly FULL, SALES, RESET, or EXIT.
goto :menu

:do_full
call :admin_gate "mode switch to FULL"
if errorlevel 1 goto :menu
echo full> ".forge-mode"
echo Set to FULL. Run launch-north-forge.bat to rebuild this drive's live skills/context with everything.
goto :menu

:do_sales
call :admin_gate "mode switch to SALES"
if errorlevel 1 goto :menu
echo sales> ".forge-mode"
echo Set to SALES. Run launch-north-forge.bat to rebuild this drive's live skills/context with Sales Assist only.
goto :menu

:do_reset
call :admin_gate "RESET"
if errorlevel 1 goto :menu
echo.
echo RESET performs a fast onboarding/content reset:
echo   .env, .forge-mode, .hermes.md, .drive-record.txt
echo   .provider-choice, .agent-name, .readme-shown, .hermes\skills\
echo.
echo The tracked repo content is NOT touched - skills-source, mode-blocks, the scripts.
echo .hermes-home is PRESERVED. Hermes credentials, memory, sessions, and cron state remain.
echo forge-events.log is intentionally RETAINED as an accountability record.
echo It can contain names entered by prior users; RESET is not a privacy/log purge.
echo Use this before handing the drive to someone else so credentials and settings
echo do not travel with it and the next person gets a genuine first run.
echo.
set "CONFIRM="
set /p CONFIRM="Type YES (all caps) to confirm: "
if not "%CONFIRM%"=="YES" (
    echo.
    echo Cancelled - nothing was deleted.
    exit /b 1
)
if exist ".drive-record.txt" (
    set /p RESETWHO=<".drive-record.txt"
    >> "forge-events.log" echo [%DATE% %TIME%] [INFO] [reset]: RESET executed by !RESETWHO!
) else (
    >> "forge-events.log" echo [%DATE% %TIME%] [INFO] [reset]: RESET executed ^(no drive record present^)
)
for %%F in (".env" ".forge-mode" ".hermes.md" ".drive-record.txt" ".provider-choice" ".agent-name" ".readme-shown") do if exist "%%~F" del /f /q "%%~F"
if exist ".hermes\skills" rmdir /s /q ".hermes\skills"
set "RESET_FAILED=0"
for %%F in (".env" ".forge-mode" ".hermes.md" ".drive-record.txt" ".provider-choice" ".agent-name" ".readme-shown") do if exist "%%~F" (
    echo ERROR: Could not remove %%~F. Check permissions, then try RESET again.
    set "RESET_FAILED=1"
)
if exist ".hermes\skills" (
    echo ERROR: Could not remove .hermes\skills. Check permissions, then try RESET again.
    set "RESET_FAILED=1"
)
echo.
if "!RESET_FAILED!"=="1" (
    echo Credential/config reset was incomplete. forge-events.log was intentionally retained.
    exit /b 1
)
echo Done. Onboarding/content reset completed; first-use setup will run next time.
echo Hermes credentials, memory, sessions, and cron state remain in .hermes-home.
echo forge-events.log was intentionally retained as the accountability record
echo and can contain names entered by prior users.
echo Next person: run launch-north-forge.bat and follow the first-use prompts.
exit /b 0

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
pause
