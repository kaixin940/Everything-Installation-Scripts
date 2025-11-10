# 修复Everything命令行搜索工具
# 确保es.exe可以正常使用

$EverythingPath = "$env:ProgramFiles\Everything"
$es_exe = "$EverythingPath\es.exe"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "修复Everything命令行搜索" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 检查Everything是否安装
if (-not (Test-Path "$EverythingPath\Everything.exe")) {
    Write-Host "✗ Everything未安装" -ForegroundColor Red
    exit 1
}

# 检查es.exe是否存在
if (-not (Test-Path $es_exe)) {
    Write-Host "✗ es.exe不存在，正在下载..." -ForegroundColor Yellow
    
    try {
        # 下载es.exe
        $ESUrl = "https://www.voidtools.com/ES-1.1.0.10.zip"
        $TempZip = "$env:TEMP\ES.zip"
        $TempExtract = "$env:TEMP\ESExtract"
        
        Write-Host "→ 下载ES命令行工具..."
        Invoke-WebRequest -Uri $ESUrl -OutFile $TempZip
        
        Write-Host "→ 解压文件..."
        Expand-Archive -Path $TempZip -DestinationPath $TempExtract -Force
        
        Write-Host "→ 复制es.exe..."
        Copy-Item "$TempExtract\es.exe" $EverythingPath -Force
        
        # 清理临时文件
        Remove-Item $TempZip -Force
        Remove-Item $TempExtract -Recurse -Force
        
        Write-Host "✓ es.exe安装完成" -ForegroundColor Green
    } catch {
        Write-Host "✗ 安装es.exe失败: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✓ es.exe已存在" -ForegroundColor Green
}

# 添加到PATH
Write-Host "`n→ 配置环境变量..."
try {
    $CurrentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($CurrentPath -notlike "*$EverythingPath*") {
        $NewPath = "$CurrentPath;$EverythingPath"
        [Environment]::SetEnvironmentVariable("Path", $NewPath, "Machine")
        Write-Host "✓ 系统PATH已更新" -ForegroundColor Green
    } else {
        Write-Host "✓ PATH已配置" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ 更新PATH失败: $_" -ForegroundColor Red
}

# 启动Everything服务
Write-Host "`n→ 启动Everything服务..."
try {
    $service = Get-Service -Name Everything -ErrorAction SilentlyContinue
    if ($service -and $service.Status -ne "Running") {
        Start-Service -Name Everything
        Write-Host "✓ 服务已启动" -ForegroundColor Green
    } elseif (-not $service) {
        Start-Process "$EverythingPath\Everything.exe" -WindowStyle Hidden
        Write-Host "✓ Everything已启动" -ForegroundColor Green
    } else {
        Write-Host "✓ Everything正在运行" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠ 启动服务失败: $_" -ForegroundColor Yellow
}

# 测试es.exe
Write-Host "`n→ 测试命令行工具..."
Start-Sleep -Seconds 2
try {
    $result = & $es_exe *.exe -max-results 1 2>$null
    if ($result) {
        Write-Host "✓ es.exe工作正常" -ForegroundColor Green
    } else {
        Write-Host "⚠ es.exe测试无结果，可能需要等待索引" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ es.exe测试失败: $_" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "使用说明" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n基本命令:" -ForegroundColor Yellow
Write-Host "  es filename        # 搜索文件" -ForegroundColor White
Write-Host "  es -folder name    # 搜索文件夹" -ForegroundColor White
Write-Host "  es -case filename  # 区分大小写" -ForegroundColor White
Write-Host "  es -regex pattern  # 正则表达式" -ForegroundColor White
Write-Host "  es -size:>1mb      # 按大小搜索" -ForegroundColor White
Write-Host "  es -path:d:\ *.txt # 指定路径" -ForegroundColor White

Write-Host "`n提示:" -ForegroundColor Cyan
Write-Host "  • 请重新打开命令行窗口以使PATH生效" -ForegroundColor White
Write-Host "  • 首次使用可能需要等待Everything建立索引" -ForegroundColor White
Write-Host "  • 使用 -help 查看完整帮助" -ForegroundColor White

Write-Host "`n✓ 修复完成！" -ForegroundColor Green
