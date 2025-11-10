# Everything 自动下载安装脚本
param(
    [switch]$Silent = $false
)

# 检查管理员权限
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "错误: 需要管理员权限运行此脚本" -ForegroundColor Red
    exit 1
}

$DownloadPath = "$env:TEMP\Everything-Installer.exe"
$EverythingPath = "$env:ProgramFiles\Everything"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Everything 自动安装脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 检查是否已安装
if (Test-Path "$EverythingPath\Everything.exe") {
    Write-Host "Everything 已安装在: $EverythingPath" -ForegroundColor Green
} else {
    Write-Host "正在下载Everything安装程序..." -ForegroundColor Yellow
    
    try {
        # 下载最新版本
        $DownloadUrl = "https://www.voidtools.com/Everything-1.4.1.1026.x64-Setup.exe"
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $DownloadPath -ErrorAction Stop
        Write-Host "下载完成" -ForegroundColor Green
    } catch {
        Write-Host "下载失败: $_" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "正在安装Everything..." -ForegroundColor Yellow
    
    # 静默安装
    if ($Silent) {
        Start-Process -FilePath $DownloadPath -ArgumentList "/S" -Wait
    } else {
        Start-Process -FilePath $DownloadPath -Wait
    }
    
    # 等待安装完成
    Start-Sleep -Seconds 5
    
    # 验证安装
    if (Test-Path "$EverythingPath\Everything.exe") {
        Write-Host "Everything 安装成功" -ForegroundColor Green
    } else {
        Write-Host "Everything 安装失败" -ForegroundColor Red
        exit 1
    }
    
    # 清理下载文件
    Remove-Item $DownloadPath -Force
}

# 下载并安装es.exe命令行工具
Write-Host "正在配置命令行工具..." -ForegroundColor Yellow
$es_exe = "$EverythingPath\es.exe"

if (-not (Test-Path $es_exe)) {
    try {
        Write-Host "正在下载es.exe..." -ForegroundColor Yellow
        $ESUrl = "https://www.voidtools.com/ES-1.1.0.10.zip"
        $TempZip = "$env:TEMP\ES.zip"
        $TempExtract = "$env:TEMP\ESExtract"
        
        Invoke-WebRequest -Uri $ESUrl -OutFile $TempZip
        Expand-Archive -Path $TempZip -DestinationPath $TempExtract -Force
        Copy-Item "$TempExtract\es.exe" $EverythingPath -Force
        
        # 清理临时文件
        Remove-Item $TempZip -Force
        Remove-Item $TempExtract -Recurse -Force
        
        Write-Host "es.exe 安装完成" -ForegroundColor Green
    } catch {
        Write-Host "安装es.exe失败: $_" -ForegroundColor Red
    }
} else {
    Write-Host "es.exe 已存在" -ForegroundColor Green
}

# 添加到系统PATH
try {
    $CurrentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($CurrentPath -notlike "*$EverythingPath*") {
        $NewPath = "$CurrentPath;$EverythingPath"
        [Environment]::SetEnvironmentVariable("Path", $NewPath, "Machine")
        Write-Host "系统PATH已更新" -ForegroundColor Green
    } else {
        Write-Host "PATH已配置" -ForegroundColor Green
    }
} catch {
    Write-Host "更新PATH失败: $_" -ForegroundColor Red
}

# 创建桌面快捷方式
try {
    $DesktopPath = "$env:USERPROFILE\Desktop"
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$DesktopPath\Everything.lnk")
    $Shortcut.TargetPath = "$EverythingPath\Everything.exe"
    $Shortcut.WorkingDirectory = $EverythingPath
    $Shortcut.IconLocation = "$EverythingPath\Everything.exe,0"
    $Shortcut.Save()
    Write-Host "桌面快捷方式已创建" -ForegroundColor Green
} catch {
    Write-Host "创建快捷方式失败: $_" -ForegroundColor Yellow
}

# 启动Everything
Write-Host "正在启动Everything..." -ForegroundColor Yellow
try {
    Start-Process "$EverythingPath\Everything.exe"
    Write-Host "Everything 已启动" -ForegroundColor Green
} catch {
    Write-Host "启动Everything失败: $_" -ForegroundColor Red
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "安装完成！" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "提示: 请重新打开命令行窗口以使PATH更改生效" -ForegroundColor Cyan
Write-Host "现在可以使用 'es' 命令进行文件搜索" -ForegroundColor Green

exit 0
