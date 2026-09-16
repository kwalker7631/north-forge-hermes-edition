@echo off
setlocal
set "HERE=%~dp0"
if /I "%HERE:~-1%"=="\" set "HERE=%HERE:~0,-1%"

rem Works from engine folder OR volume-root "Start North Forge.cmd"
if exist "%HERE%\pyproject.toml" (
  set "AGENT=%HERE%"
) else if exist "%HERE%\north-forge-agent\pyproject.toml" (
  set "AGENT=%HERE%\north-forge-agent"
) else (
  set "AGENT=%HERE%"
)

for %%I in ("%AGENT%") do set "PARENT=%%~dpI"
if /I "%PARENT:~-1%"=="\" set "PARENT=%PARENT:~0,-1%"
for %%I in ("%AGENT%") do set "LEAF=%%~nxI"
set "HERMES_HOME=%PARENT%\%LEAF%-data"
set "PATH=%AGENT%\venv\Scripts;%HERMES_HOME%\hermes-agent\venv\Scripts;%HERMES_HOME%\bin;%PATH%"

if exist "%AGENT%\venv\Scripts\hermes.exe" (
  "%AGENT%\venv\Scripts\hermes.exe" %*
  exit /b %ERRORLEVEL%
)
if exist "%HERMES_HOME%\hermes-agent\venv\Scripts\hermes.exe" (
  "%HERMES_HOME%\hermes-agent\venv\Scripts\hermes.exe" %*
  exit /b %ERRORLEVEL%
)
if exist "%HERMES_HOME%\bin\hermes.exe" (
  "%HERMES_HOME%\bin\hermes.exe" %*
  exit /b %ERRORLEVEL%
)
echo North Forge: hermes.exe not found. Run Deploy Console again, or repair the venv.
echo AGENT=%AGENT%
echo HERMES_HOME=%HERMES_HOME%
exit /b 1
