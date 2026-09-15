@echo off
setlocal
set "ROOT=%~d0\"
set "HERMES=%ROOT%north-forge-agent-venv\Scripts\hermes.exe"
set "HERMES_HOME=%ROOT%north-forge-agent-data"
if not exist "%HERMES%" (
  echo Missing %HERMES%
  echo Run Start North Forge once and wait for ready, then try Web again.
  pause
  exit /b 1
)
echo Starting web dashboard on this stick...
echo HERMES_HOME=%HERMES_HOME%
"%HERMES%" dashboard
