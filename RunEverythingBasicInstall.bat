@echo off
title Everything Basic Installation Script

echo ========================================
echo Everything Basic Installation Script
echo ========================================
echo.

echo Checking administrator privileges...
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Administrator privileges confirmed
) else (
    echo ERROR: Administrator privileges required
    echo Please right-click this file and select "Run as administrator"
    pause
    exit /b 1
)

echo.
echo Starting Everything basic installation...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0安装Everything.ps1"

echo.
echo Script execution completed
pause
