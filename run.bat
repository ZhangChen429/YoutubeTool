@echo off
setlocal
cd /d "%~dp0" || exit /b 1

git submodule update --init -- VideoCaptioner
if errorlevel 1 goto failed

set "UV=%~dp0.runtime\uv\uv.exe"
if not exist "%UV%" (
    where uv.exe >nul 2>&1
    if errorlevel 1 (
        echo Downloading uv for Windows x64...
        powershell.exe -NoProfile -Command "$ErrorActionPreference='Stop'; $target=Split-Path -Parent $env:UV; $zip=Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString()+'.zip'); try { Invoke-WebRequest -UseBasicParsing 'https://github.com/astral-sh/uv/releases/latest/download/uv-x86_64-pc-windows-msvc.zip' -OutFile $zip; Expand-Archive -LiteralPath $zip -DestinationPath $target -Force } finally { if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip } }"
        if errorlevel 1 goto failed
    ) else (
        set "UV=uv.exe"
    )
)

for %%F in ("%~dp0tools\ffmpeg\bin\ffmpeg.exe") do if exist "%%~fF" if %%~zF GTR 1024 set "PATH=%~dp0tools\ffmpeg\bin;%PATH%"
set "UV_PYTHON_INSTALL_DIR=%~dp0.runtime\uv-python"
cd /d "%~dp0VideoCaptioner" || goto failed
"%UV%" run --locked --no-dev --python 3.12 videocaptioner-gui
if errorlevel 1 goto failed
exit /b 0

:failed
echo VideoCaptioner could not start. See the error above.
pause
exit /b 1
