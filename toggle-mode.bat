@echo off
setlocal
cd /d "%~dp0"

echo Current mode file:
if exist ".forge-mode" (type ".forge-mode") else (echo (none set - defaults to SALES)
)
echo.
set /p MODE="Type FULL or SALES and press Enter: "

if /i "%MODE%"=="FULL" (
    echo full> ".forge-mode"
    echo Set to FULL. Run launch-north-forge.bat to rebuild this drive's live skills/context with everything.
) else if /i "%MODE%"=="SALES" (
    echo sales> ".forge-mode"
    echo Set to SALES. Run launch-north-forge.bat to rebuild this drive's live skills/context with Sales Assist only.
) else (
    echo Didn't recognize that - type exactly FULL or SALES.
)
pause
