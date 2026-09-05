@echo off
rem =============================================================================
rem  North Forge - Hermes Edition (Kyocera Edition v21.8) - part of the North
rem  Forge project.
rem  File: toggle-mode.bat | Script version: 1.0.0 | Updated: 2026-09-04
rem  Author: Kenneth C. Walker Jr. - Senior Technical Support Engineer, TSC
rem =============================================================================
setlocal enabledelayedexpansion
cd /d "%~dp0"

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
echo RESET wipes this drive's PERSONAL setup back to a clean first-use state:
echo   .env            - your Anthropic API key
echo   .forge-mode     - the FULL/SALES toggle
echo   .hermes.md      - generated at launch, rebuilds automatically
echo   .hermes\skills\  - generated at launch, rebuilds automatically
echo.
echo The tracked repo content is NOT touched - skills-source, mode-blocks, the scripts.
echo Use this before handing this physical drive to a different person, so your
echo API key does not travel with it and the next person gets a genuine first run.
echo.
set "CONFIRM="
set /p CONFIRM="Type YES (all caps) to confirm: "
if not "%CONFIRM%"=="YES" (
    echo.
    echo Cancelled - nothing was deleted.
    goto :menu
)
if exist ".env" del /q ".env"
if exist ".drive-record.txt" (
    set /p RESETWHO=<".drive-record.txt"
    >> "forge-events.log" echo [%DATE% %TIME%] [INFO] [reset]: RESET executed by !RESETWHO!
    del /q ".drive-record.txt"
) else (
    >> "forge-events.log" echo [%DATE% %TIME%] [INFO] [reset]: RESET executed ^(no drive record present^)
)
if exist ".forge-mode" del /q ".forge-mode"
if exist ".hermes.md" del /q ".hermes.md"
if exist ".hermes\skills" rmdir /s /q ".hermes\skills"
echo.
echo Done. This drive is back to a clean first-use state.
echo Next person: run launch-north-forge.bat - it recreates .env from .env.example
echo and prompts for their own API key. Mode defaults to SALES until toggle-mode sets it.
goto :menu

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
