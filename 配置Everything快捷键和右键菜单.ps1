# 修复Everything任务栏搜索集成
$EverythingPath = "$env:ProgramFiles\Everything"
$Everything_exe = "$EverythingPath\Everything.exe"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "修复Everything任务栏搜索集成" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 检查Everything是否安装
if (-not (Test-Path $Everything_exe)) {
    Write-Host "ERROR: Everything未安装" -ForegroundColor Red
    exit 1
}

Write-Host "OK: Everything已安装" -ForegroundColor Green

# 1. 配置快捷键 Ctrl+Alt+E
Write-Host "`n1. 配置快捷键..." -ForegroundColor Yellow
try {
    $RegPath = "HKCU:\Software\VoidTools\Everything"
    if (-not (Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }
    New-ItemProperty -Path $RegPath -Name "search_shortcut" -Value 0xC45 -PropertyType DWord -Force | Out-Null
    Write-Host "OK: 快捷键 Ctrl+Alt+E 已设置" -ForegroundColor Green
} catch {
    Write-Host "ERROR: 设置快捷键失败 $_" -ForegroundColor Red
}

# 2. 添加右键菜单
Write-Host "`n2. 添加右键菜单..." -ForegroundColor Yellow
try {
    $ContextMenuPath = "HKCU:\Software\Classes\*\shell\Everything"
    $CommandPath = "$ContextMenuPath\command"
    
    New-Item -Path $ContextMenuPath -Force | Out-Null
    New-ItemProperty -Path $ContextMenuPath -Name "(Default)" -Value "用Everything搜索文件" -PropertyType String -Force | Out-Null
    New-Item -Path $CommandPath -Force | Out-Null
    New-ItemProperty -Path $CommandPath -Name "(Default)" -Value "`"$Everything_exe`" -search `"%1`"" -PropertyType String -Force | Out-Null
    Write-Host "OK: 右键菜单已添加" -ForegroundColor Green
} catch {
    Write-Host "ERROR: 添加右键菜单失败 $_" -ForegroundColor Red
}

# 3. 创建任务栏快捷方式
Write-Host "`n3. 创建任务栏快捷方式..." -ForegroundColor Yellow
try {
    $TaskbarPath = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
    if (Test-Path $TaskbarPath) {
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut("$TaskbarPath\Everything.lnk")
        $Shortcut.TargetPath = $Everything_exe
        $Shortcut.WorkingDirectory = $EverythingPath
        $Shortcut.IconLocation = "$Everything_exe,0"
        $Shortcut.Description = "Everything 文件搜索工具"
        $Shortcut.Save()
        Write-Host "OK: 任务栏快捷方式已创建" -ForegroundColor Green
    } else {
        Write-Host "WARNING: 任务栏路径不存在" -ForegroundColor Yellow
    }
} catch {
    Write-Host "ERROR: 创建任务栏快捷方式失败 $_" -ForegroundColor Red
}

# 4. 配置自启动
Write-Host "`n4. 配置自启动..." -ForegroundColor Yellow
try {
    $AutoStartPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    New-ItemProperty -Path $AutoStartPath -Name "Everything" -Value "`"$Everything_exe`" -startup" -PropertyType String -Force | Out-Null
    Write-Host "OK: 自启动已启用" -ForegroundColor Green
} catch {
    Write-Host "ERROR: 配置自启动失败 $_" -ForegroundColor Red
}

# 5. 优化Everything设置
Write-Host "`n5. 优化Everything设置..." -ForegroundColor Yellow
try {
    $RegPath = "HKCU:\Software\VoidTools\Everything"
    $Settings = @{
        "run_as_admin" = 0
        "auto_include_fixed_volumes" = 1
        "auto_include_removable_volumes" = 0
        "auto_include_network_volumes" = 0
        "minimize_to_tray" = 1
        "show_menu_search" = 1
        "show_filter" = 1
        "show_status_bar" = 1
    }
    
    foreach ($setting in $Settings.GetEnumerator()) {
        New-ItemProperty -Path $RegPath -Name $setting.Key -Value $setting.Value -PropertyType DWord -Force | Out-Null
    }
    Write-Host "OK: Everything设置已优化" -ForegroundColor Green
} catch {
    Write-Host "ERROR: 优化设置失败 $_" -ForegroundColor Red
}

# 6. 启动Everything
Write-Host "`n6. 启动Everything..." -ForegroundColor Yellow
try {
    Start-Process $Everything_exe
    Write-Host "OK: Everything已启动" -ForegroundColor Green
} catch {
    Write-Host "ERROR: 启动Everything失败 $_" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "配置完成" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n使用方法:" -ForegroundColor Yellow
Write-Host "- 快捷键: Ctrl+Alt+E 打开Everything搜索" -ForegroundColor White
Write-Host "- 右键菜单: 右键文件 -> 用Everything搜索文件" -ForegroundColor White
Write-Host "- 任务栏: 点击任务栏Everything图标" -ForegroundColor White
Write-Host "- 自启动: Windows启动时自动运行Everything" -ForegroundColor White

Write-Host "`n注意:" -ForegroundColor Cyan
Write-Host "- 右键菜单可能需要重启资源管理器生效" -ForegroundColor White
Write-Host "- 任务栏快捷方式可能需要手动固定" -ForegroundColor White
Write-Host "- Windows搜索集成需要Everything专业版" -ForegroundColor White

Write-Host "`n✓ 所有配置完成！" -ForegroundColor Green
