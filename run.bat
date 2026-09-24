@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

if not exist .env (
    copy /y .env.example .env >nul
    echo Created .env from .env.example.
)

findstr /b "OPENROUTER_API_KEY=sk-or-v1-your-key-here" .env >nul
if %errorlevel%==0 (
    set /p OR_KEY="Enter your OpenRouter API key (https://openrouter.ai/): "
    powershell -NoProfile -Command "$c = (Get-Content .env) -replace '^OPENROUTER_API_KEY=.*', 'OPENROUTER_API_KEY=!OR_KEY!'; [System.IO.File]::WriteAllLines((Resolve-Path .env), $c, (New-Object System.Text.UTF8Encoding $false))"
)

findstr /b "PLAYER_NAME=YourName" .env >nul
if %errorlevel%==0 (
    set /p PLAYER_NAME_INPUT="Enter your name: "
    powershell -NoProfile -Command "$c = (Get-Content .env) -replace '^PLAYER_NAME=.*', 'PLAYER_NAME=!PLAYER_NAME_INPUT!'; [System.IO.File]::WriteAllLines((Resolve-Path .env), $c, (New-Object System.Text.UTF8Encoding $false))"
)

echo Starting Docker containers...
docker compose up -d
if errorlevel 1 (
    echo Failed to start Docker containers -- is Docker Desktop running?
    pause
    exit /b 1
)

echo Starting the discovery announcer -- leave this window open.
bin\homebody-server.exe
