@echo off
title Everything Complete Installation Script

echo ========================================
echo Everything Complete Installation Script
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
echo Starting Everything complete installation...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0Everything完整安装.ps1"

echo.
echo Script execution completed
pause
