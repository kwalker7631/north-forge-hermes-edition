@echo off
setlocal
set "ROOT=%~d0\"
set "PINOKIO_HOME=%ROOT%pinokio-home"
if not exist "%PINOKIO_HOME%" mkdir "%PINOKIO_HOME%"
if exist "%ROOT%pinokio-app\Pinokio.exe" (
  start "" "%ROOT%pinokio-app\Pinokio.exe"
) else (
  echo Pinokio.exe is not on this drive.
  echo See Advanced\PINOKIO.md — put the app under pinokio-app\
  pause
)
