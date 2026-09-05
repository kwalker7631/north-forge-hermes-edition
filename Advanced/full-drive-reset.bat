@echo off
setlocal DisableDelayedExpansion
rem This script lives in Advanced\ but purges the drive root's .hermes-home.
rem "%~dp0.." is the drive root regardless of drive letter; scripts\ and
rem forge-events.log below resolve against it.
cd /d "%~dp0.."
set "REPO=%CD%"
set "CANDIDATE=%CD%\.hermes-home"
set "CHECK=%TEMP%\north-forge-drive-purge-%RANDOM%-%RANDOM%.txt"
python scripts\drive-reset-safety.py --action validate --repo "%REPO%" --candidate "%CANDIDATE%" >"%CHECK%"
if errorlevel 1 (echo Full drive purge stopped safely; nothing was deleted.& del /q "%CHECK%" 2>nul& exit /b 2)
set /p TARGET=<"%CHECK%"
del /q "%CHECK%" 2>nul
echo FULL DRIVE PURGE removes the local engine and ALL drive Hermes state:
echo   %TARGET%
echo Credentials, memory, sessions, cron jobs, and logs will be unrecoverable.
echo Help: copy the complete path above, paste it below, then press Enter.
set "CONFIRM="
set /p CONFIRM="Exact folder path: "
powershell.exe -NoLogo -NoProfile -NonInteractive -Command "if ($env:CONFIRM -ceq $env:TARGET) { exit 0 } else { exit 1 }"
if errorlevel 1 (echo Cancelled - the path did not match; nothing was changed.& exit /b 1)
where hermes >nul 2>nul || (echo Safety stop: hermes is not on PATH, so the gateway cannot be checked.& exit /b 1)
set "HERMES_HOME=%TARGET%"
call hermes gateway stop || (echo Safety stop: gateway stop failed; no files were deleted.& >>forge-events.log echo [%DATE% %TIME%] [ERROR] [drive-purge]: gateway stop failed& exit /b 1)
call hermes gateway uninstall || (echo Safety stop: gateway uninstall failed; no files were deleted.& >>forge-events.log echo [%DATE% %TIME%] [ERROR] [drive-purge]: gateway uninstall failed& exit /b 1)
python scripts\drive-reset-safety.py --action purge --repo "%REPO%" --candidate "%TARGET%" --confirmed "%TARGET%"
if errorlevel 1 (echo Purge failed; close Hermes and try again.& exit /b 1)
>>forge-events.log echo [%DATE% %TIME%] [INFO] [drive-purge]: exact .hermes-home removed
echo Done - this drive's Hermes engine and state were fully removed.
exit /b 0
