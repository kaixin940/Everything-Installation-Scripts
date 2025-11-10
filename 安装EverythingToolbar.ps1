# EverythingToolbar 自动安装脚本 (兼容PowerShell 2.0+)
param(
    [switch]$Silent = $false
)

# 检查PowerShell版本
$PSVersion = $PSVersionTable.PSVersion.Major
Write-Host "PowerShell版本: $PSVersion" -ForegroundColor Gray

# 检查管理员权限 (兼容旧版本)
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "错误: 需要管理员权限运行此脚本" -ForegroundColor "Red"
    exit 1
}

$EverythingPath = "$env:ProgramFiles\Everything"
$DownloadUrl = "https://github.com/srwi/EverythingToolbar/releases/download/2.1.1/EverythingToolbar-2.1.1-x64.exe"
$DownloadPath = "$env:TEMP\EverythingToolbar-2.1.1-x64.exe"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "EverythingToolbar 自动安装脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 检查Everything是否已安装
if (-not (Test-Path "$EverythingPath\Everything.exe")) {
    Write-Host "错误: Everything未安装，请先运行安装Everything.ps1" -ForegroundColor Red
    exit 1
}

Write-Host "Everything已安装，继续安装EverythingToolbar..." -ForegroundColor "Green"

# 检查EverythingToolbar是否已安装 (兼容旧版本)
$installed = $null
try {
    if ($PSVersion -ge 3) {
        $installed = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*EverythingToolbar*" } -ErrorAction SilentlyContinue
    } else {
        # PowerShell 2.0 兼容方式
        $products = Get-WmiObject -Class Win32_Product -ErrorAction SilentlyContinue
        foreach ($product in $products) {
            if ($product.Name -like "*EverythingToolbar*") {
                $installed = $product
                break
            }
        }
    }
} catch {
    $installed = $null
}

if ($installed) {
    Write-Host "EverythingToolbar已安装" -ForegroundColor "Green"
    Write-Host "版本: $($installed.Name)" -ForegroundColor "White"
} else {
    Write-Host "正在下载EverythingToolbar..." -ForegroundColor "Yellow"
    
    try {
        # 下载EverythingToolbar (兼容旧版本)
        if ($PSVersion -ge 3) {
            $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri $DownloadUrl -OutFile $DownloadPath -ErrorAction Stop
        } else {
            # PowerShell 2.0 使用 WebClient
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($DownloadUrl, $DownloadPath)
        }
        Write-Host "下载完成" -ForegroundColor "Green"
        
        # 验证下载文件 (兼容旧版本)
        $fileInfo = Get-Item $DownloadPath -ErrorAction SilentlyContinue
        if ($fileInfo -and $fileInfo.Length -lt 1MB) {
            Write-Host "下载的文件无效，尝试其他方法..." -ForegroundColor "Yellow"
            throw "文件太小"
        }
        
    } catch {
        Write-Host "下载失败: $_" -ForegroundColor "Red"
        Write-Host "请手动下载安装: $DownloadUrl" -ForegroundColor "Cyan"
        exit 1
    }
    
    Write-Host "正在安装EverythingToolbar..." -ForegroundColor "Yellow"
    
    try {
        # 安装EverythingToolbar
        if ($Silent) {
            Start-Process -FilePath $DownloadPath -ArgumentList "/S" -Wait
        } else {
            Start-Process -FilePath $DownloadPath -Wait
        }
        
        # 等待安装完成
        Start-Sleep -Seconds 3
        
        # 验证安装 (兼容旧版本)
        $installed = $null
        try {
            if ($PSVersion -ge 3) {
                $installed = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*EverythingToolbar*" } -ErrorAction SilentlyContinue
            } else {
                # PowerShell 2.0 兼容方式
                $products = Get-WmiObject -Class Win32_Product -ErrorAction SilentlyContinue
                foreach ($product in $products) {
                    if ($product.Name -like "*EverythingToolbar*") {
                        $installed = $product
                        break
                    }
                }
            }
        } catch {
            $installed = $null
        }
        
        if ($installed) {
            Write-Host "EverythingToolbar安装成功" -ForegroundColor "Green"
        } else {
            Write-Host "EverythingToolbar安装可能失败，请检查" -ForegroundColor "Yellow"
        }
        
    } catch {
        Write-Host "安装失败: $_" -ForegroundColor "Red"
    }
    
    # 清理下载文件
    if (Test-Path $DownloadPath) {
        Remove-Item $DownloadPath -Force -ErrorAction SilentlyContinue
    }
}

# 确保Everything正在运行
Write-Host "检查Everything服务状态..." -ForegroundColor "Yellow"
$everythingProcess = $null
try {
    $everythingProcess = Get-Process -Name "Everything" -ErrorAction SilentlyContinue
} catch {
    $everythingProcess = $null
}

if (-not $everythingProcess) {
    Write-Host "启动Everything服务..." -ForegroundColor "Yellow"
    try {
        Start-Process "$EverythingPath\Everything.exe"
        Start-Sleep -Seconds 2
        Write-Host "Everything已启动" -ForegroundColor "Green"
    } catch {
        Write-Host "启动Everything失败: $_" -ForegroundColor "Red"
    }
} else {
    Write-Host "Everything正在运行" -ForegroundColor "Green"
}

# 根据Windows版本提供配置说明 (兼容旧版本)
$os = $null
try {
    if ($PSVersion -ge 3) {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
    } else {
        # PowerShell 2.0 使用 Get-WmiObject
        $os = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction SilentlyContinue
    }
} catch {
    $os = $null
}

if ($os) {
    Write-Host "系统版本: $($os.Caption)" -ForegroundColor "White"
} else {
    Write-Host "无法检测系统版本" -ForegroundColor "Yellow"
}

Write-Host "`n========================================" -ForegroundColor "Cyan"
Write-Host "配置说明" -ForegroundColor "Cyan"
Write-Host "========================================" -ForegroundColor "Cyan"

if ($os -and $os.Caption -like "*Windows 11*") {
    Write-Host "`nWindows 11 配置步骤:" -ForegroundColor "Yellow"
    Write-Host "1. 安装后会自动启动设置向导" -ForegroundColor "White"
    Write-Host "2. 按照向导完成配置" -ForegroundColor "White"
    Write-Host "3. 任务栏会出现搜索图标" -ForegroundColor "White"
    Write-Host "4. 点击搜索图标即可使用" -ForegroundColor "White"
} elseif ($os -and $os.Caption -like "*Windows 10*") {
    Write-Host "`nWindows 10 配置步骤:" -ForegroundColor "Yellow"
    Write-Host "1. 右键点击任务栏空白处" -ForegroundColor "White"
    Write-Host "2. 选择 '工具栏' -> 'EverythingToolbar'" -ForegroundColor "White"
    Write-Host "3. 如果第一次没看到，请再次右键任务栏" -ForegroundColor "White"
    Write-Host "4. 解锁任务栏以调整工具栏大小" -ForegroundColor "White"
    Write-Host "5. 任务栏会出现Everything搜索框" -ForegroundColor "White"
} else {
    Write-Host "`n通用配置步骤:" -ForegroundColor "Yellow"
    Write-Host "1. 右键点击任务栏空白处" -ForegroundColor "White"
    Write-Host "2. 选择 '工具栏' -> 'EverythingToolbar'" -ForegroundColor "White"
    Write-Host "3. 如果没有看到选项，请重启Windows资源管理器" -ForegroundColor "White"
}

Write-Host "`n使用说明:" -ForegroundColor "Yellow"
Write-Host "- 点击任务栏搜索框进行搜索" -ForegroundColor "White"
Write-Host "- 支持Everything的所有搜索语法" -ForegroundColor "White"
Write-Host "- 例如: *.txt, filename.ext, foldername" -ForegroundColor "White"

Write-Host "`n故障排除:" -ForegroundColor "Yellow"
Write-Host "- 如果工具栏没有出现，重启Windows资源管理器" -ForegroundColor "White"
Write-Host "- 确保Everything正在运行" -ForegroundColor "White"
Write-Host "- 检查EverythingToolbar设置中的实例名称" -ForegroundColor "White"

Write-Host "`n✓ EverythingToolbar安装配置完成！" -ForegroundColor "Green"

exit 0
