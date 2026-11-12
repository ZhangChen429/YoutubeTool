@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0import-cookies.ps1" "%~1"
set "result=%ERRORLEVEL%"
pause
exit /b %result%
