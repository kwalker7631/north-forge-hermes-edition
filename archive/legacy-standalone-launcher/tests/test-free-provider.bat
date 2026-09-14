@echo off
setlocal enabledelayedexpansion
set "ROOT=%~dp0.."
set "TESTROOT=%TEMP%\north-forge-provider-tests-%RANDOM%-%RANDOM%"
mkdir "%TESTROOT%" || exit /b 1
> "%TESTROOT%\hermes-template.bat" echo @echo off
>> "%TESTROOT%\hermes-template.bat" echo if "%%1 %%2 %%3"=="config set model.provider" exit /b %%FAKE_SET_STATUS%%
>> "%TESTROOT%\hermes-template.bat" echo if "%%1 %%2 %%3"=="config unset model.default" ^(
>> "%TESTROOT%\hermes-template.bat" echo   if defined FAKE_UNSET_MESSAGE echo %%FAKE_UNSET_MESSAGE%% 1^>^&2
>> "%TESTROOT%\hermes-template.bat" echo   exit /b %%FAKE_UNSET_STATUS%%
>> "%TESTROOT%\hermes-template.bat" echo ^)
>> "%TESTROOT%\hermes-template.bat" echo exit /b 99

call :CASE success 0 0 "default removed" 0 free || goto :FAIL
call :CASE failed-set 23 0 "" 23 absent || goto :FAIL
call :CASE failed-unset 0 37 "unexpected failure api_key=supersecret" 37 absent || goto :FAIL
call :CASE already-absent 0 1 "Config key not set: model.default" 0 free || goto :FAIL
rmdir /s /q "%TESTROOT%"
echo PASS: all four isolated fake-Hermes provider cases
exit /b 0

:CASE
set "WORK=%TESTROOT%\%~1"
mkdir "!WORK!"
copy /y "%ROOT%\launch-north-forge.bat" "!WORK!\" >nul
mkdir "!WORK!\.hermes-home\bin"
copy /y "%TESTROOT%\hermes-template.bat" "!WORK!\.hermes-home\bin\hermes.bat" >nul
set "FAKE_SET_STATUS=%~2"
set "FAKE_UNSET_STATUS=%~3"
set "FAKE_UNSET_MESSAGE=%~4"
pushd "!WORK!"
call launch-north-forge.bat --configure-free-provider >terminal.txt 2>&1
set "ACTUAL=!ERRORLEVEL!"
if not "!ACTUAL!"=="%~5" (popd & echo FAIL: %~1 returned !ACTUAL!, expected %~5 & exit /b 1)
if "%~6"=="free" (
    set /p MARKER=<.provider-choice
    if not "!MARKER!"=="free" (popd & echo FAIL: %~1 did not write the free marker & exit /b 1)
) else (
    if exist .provider-choice (popd & echo FAIL: %~1 left a marker after failure & exit /b 1)
    findstr /c:"[FAILURE] [provider-config]" forge-events.log >nul || (popd & echo FAIL: %~1 did not log a diagnostic & exit /b 1)
    findstr /c:"supersecret" forge-events.log >nul && (popd & echo FAIL: %~1 wrote a credential to the log & exit /b 1)
)
popd
exit /b 0

:FAIL
rmdir /s /q "%TESTROOT%"
exit /b 1
