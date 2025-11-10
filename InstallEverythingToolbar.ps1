# EverythingToolbar Installation Script - Simple Version
param(
    [switch]$Silent = $false
)

# Check admin rights
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: Administrator rights required" -ForegroundColor Red
    exit 1
}

# Variables
$EverythingPath = "$env:ProgramFiles\Everything"
$DownloadUrl = "https://github.com/srwi/EverythingToolbar/releases/download/2.1.1/EverythingToolbar-2.1.1-x64.exe"
$DownloadPath = "$env:TEMP\EverythingToolbar-2.1.1-x64.exe"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "EverythingToolbar Installation Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Check Everything installed
if (-not (Test-Path "$EverythingPath\Everything.exe")) {
    Write-Host "ERROR: Everything not installed" -ForegroundColor Red
    exit 1
}

Write-Host "Everything installed, continuing..." -ForegroundColor Green

# Check if already installed
$alreadyInstalled = $false
try {
    $products = Get-WmiObject -Class Win32_Product -ErrorAction SilentlyContinue
    foreach ($product in $products) {
        if ($product.Name -like "*EverythingToolbar*") {
            $alreadyInstalled = $true
            Write-Host "EverythingToolbar already installed" -ForegroundColor Green
            Write-Host "Version: $($product.Name)" -ForegroundColor White
            break
        }
    }
} catch {
    Write-Host "Error checking installed programs" -ForegroundColor Yellow
}

if (-not $alreadyInstalled) {
    Write-Host "Downloading EverythingToolbar..." -ForegroundColor Yellow
    
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($DownloadUrl, $DownloadPath)
        Write-Host "Download completed" -ForegroundColor Green
        
        $fileInfo = Get-Item $DownloadPath
        if ($fileInfo.Length -lt 1000000) {
            Write-Host "Warning: Downloaded file may be incomplete" -ForegroundColor Yellow
        }
        
    } catch {
        Write-Host "Download failed: $_" -ForegroundColor Red
        Write-Host "Please download manually: $DownloadUrl" -ForegroundColor Cyan
        exit 1
    }
    
    Write-Host "Installing EverythingToolbar..." -ForegroundColor Yellow
    
    try {
        if ($Silent) {
            Start-Process -FilePath $DownloadPath -ArgumentList "/S" -Wait
        } else {
            Start-Process -FilePath $DownloadPath -Wait
        }
        
        Write-Host "Installation completed" -ForegroundColor Green
        
    } catch {
        Write-Host "Installation failed: $_" -ForegroundColor Red
    }
    
    if (Test-Path $DownloadPath) {
        Remove-Item $DownloadPath -Force
    }
}

# Start Everything
Write-Host "Checking Everything service..." -ForegroundColor Yellow
try {
    $everythingProcess = Get-Process -Name "Everything" -ErrorAction SilentlyContinue
    if (-not $everythingProcess) {
        Write-Host "Starting Everything service..." -ForegroundColor Yellow
        Start-Process "$EverythingPath\Everything.exe"
        Start-Sleep -Seconds 2
        Write-Host "Everything started" -ForegroundColor Green
    } else {
        Write-Host "Everything is running" -ForegroundColor Green
    }
} catch {
    Write-Host "Failed to start Everything" -ForegroundColor Red
}

# Get OS version
Write-Host "Detecting system version..." -ForegroundColor Yellow
$osVersion = ""
try {
    $os = Get-WmiObject -Class Win32_OperatingSystem
    $osVersion = $os.Caption
    Write-Host "OS Version: $osVersion" -ForegroundColor White
} catch {
    Write-Host "Cannot detect OS version" -ForegroundColor Yellow
    $osVersion = "Unknown"
}

# Configuration instructions
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuration Instructions" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($osVersion -like "*Windows 11*") {
    Write-Host ""
    Write-Host "Windows 11 Configuration:" -ForegroundColor Yellow
    Write-Host "1. Setup wizard will start automatically"
    Write-Host "2. Follow the wizard to complete configuration"
    Write-Host "3. Search icon will appear on taskbar"
    Write-Host "4. Click the search icon to use"
} elseif ($osVersion -like "*Windows 10*") {
    Write-Host ""
    Write-Host "Windows 10 Configuration:" -ForegroundColor Yellow
    Write-Host "1. Right-click on empty space of taskbar"
    Write-Host "2. Select 'Toolbars' -> 'EverythingToolbar'"
    Write-Host "3. If not visible, right-click taskbar again"
    Write-Host "4. Unlock taskbar to adjust toolbar size"
    Write-Host "5. Everything search box will appear on taskbar"
} else {
    Write-Host ""
    Write-Host "General Configuration:" -ForegroundColor Yellow
    Write-Host "1. Right-click on empty space of taskbar"
    Write-Host "2. Select 'Toolbars' -> 'EverythingToolbar'"
    Write-Host "3. If option not visible, restart Windows Explorer"
}

Write-Host ""
Write-Host "Usage Instructions:" -ForegroundColor Yellow
Write-Host "- Click taskbar search box to search"
Write-Host "- Supports all Everything search syntax"
Write-Host "- Examples: *.txt, filename.ext, foldername"

Write-Host ""
Write-Host "Troubleshooting:" -ForegroundColor Yellow
Write-Host "- If toolbar not visible, restart Windows Explorer"
Write-Host "- Ensure Everything is running"
Write-Host "- Check instance name in EverythingToolbar settings"

Write-Host ""
Write-Host "EverythingToolbar installation completed!" -ForegroundColor Green
Write-Host ""
