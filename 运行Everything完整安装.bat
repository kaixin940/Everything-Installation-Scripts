@echo off
chcp 65001 >nul
title Everything完整安装脚本

echo ========================================
echo Everything完整安装脚本
echo ========================================
echo.

echo 正在检查管理员权限...
net session >nul 2>&1
if %errorLevel% == 0 (
    echo 管理员权限检查通过
) else (
    echo 错误: 需要管理员权限运行此脚本
    echo 请右键点击此文件，选择"以管理员身份运行"
    pause
    exit /b 1
)

echo.
echo 正在启动Everything完整安装脚本...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0Everything完整安装.ps1"

echo.
echo 脚本执行完成
pause
