@echo off
cd /d "%~dp0"
where node >nul 2>&1
if errorlevel 1 (
  echo Install Node.js 22.13 or newer from https://nodejs.org/ then run this file again.
  pause
  exit /b 1
)
start "Eco'lave" cmd /k "node server.mjs"
timeout /t 2 /nobreak >nul
start "" "http://localhost:3000"
