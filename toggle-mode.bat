@echo off
setlocal
cd /d "%~dp0"

echo Current mode file:
if exist ".forge-mode" (type ".forge-mode") else (echo (none set - defaults to SALES)
)
echo.
set /p MODE="Type FULL, SALES, or RESET and press Enter: "

if /i "%MODE%"=="FULL"  goto :do_full
if /i "%MODE%"=="SALES" goto :do_sales
if /i "%MODE%"=="RESET" goto :do_reset
echo Didn't recognize that - type exactly FULL, SALES, or RESET.
goto :end

:do_full
echo full> ".forge-mode"
echo Set to FULL. Run launch-north-forge.bat to rebuild this drive's live skills/context with everything.
goto :end

:do_sales
echo sales> ".forge-mode"
echo Set to SALES. Run launch-north-forge.bat to rebuild this drive's live skills/context with Sales Assist only.
goto :end

:do_reset
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
set /p CONFIRM="Type YES (all caps) to confirm: "
if not "%CONFIRM%"=="YES" (
    echo.
    echo Cancelled - nothing was deleted.
    goto :end
)
if exist ".env" del /q ".env"
if exist ".forge-mode" del /q ".forge-mode"
if exist ".hermes.md" del /q ".hermes.md"
if exist ".hermes\skills" rmdir /s /q ".hermes\skills"
echo.
echo Done. This drive is back to a clean first-use state.
echo Next person: run launch-north-forge.bat - it recreates .env from .env.example
echo and prompts for their own API key. Mode defaults to SALES until toggle-mode sets it.
goto :end

:end
pause
