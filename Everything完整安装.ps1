# Everything Complete Installation Script
# Includes command-line tools and EverythingToolbar

param(
    [string]$LocalInstallerPath = "",
    [switch]$Silent = $true,
    [switch]$NoToolbar = $false
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
$ToolbarDownloadUrl = "https://github.com/srwi/EverythingToolbar/releases/download/2.1.1/EverythingToolbar-2.1.1-x64.exe"
$ToolbarDownloadPath = "$env:TEMP\EverythingToolbar-2.1.1-x64.exe"
$ESDownloadUrl = "https://www.voidtools.com/ES-1.1.0.10.zip"
$ESTempZip = "$env:TEMP\ES.zip"
$ESTempExtract = "$env:TEMP\ESExtract"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Everything Complete Installation Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Silent Mode: $Silent" -ForegroundColor Gray
Write-Host "Toolbar Installation: $(-not $NoToolbar)" -ForegroundColor Gray

# Step 1: Check Everything installation
Write-Host "`nStep 1: Checking Everything installation..." -ForegroundColor Yellow
if (-not (Test-Path "$EverythingPath\Everything.exe")) {
    Write-Host "ERROR: Everything not installed. Please run InstallEverything.ps1 first." -ForegroundColor Red
    exit 1
}
Write-Host "Everything is installed" -ForegroundColor Green

# Step 2: Configure command-line tools (es.exe)
Write-Host "`nStep 2: Configuring command-line tools..." -ForegroundColor Yellow
$es_exe = "$EverythingPath\es.exe"

if (-not (Test-Path $es_exe)) {
    Write-Host "es.exe not found, downloading..." -ForegroundColor Yellow
    
    $downloadSuccess = $false
    $attemptCount = 0
    $maxAttempts = 3
    
    # Try multiple download attempts with different URLs
    $downloadUrls = @(
        "https://wget.rongyizuo.com/2025-11/ES-1.1.0.8.zip",
        "https://www.voidtools.com/ES-1.1.0.10.zip",
        "https://www.voidtools.com/ES-1.1.0.9.zip"
    )
    
    foreach ($url in $downloadUrls) {
        if ($downloadSuccess) { break }
        $attemptCount++
        
        Write-Host "Attempt ${attemptCount}: Downloading from ${url}" -ForegroundColor White
        
        try {
            Write-Host "Downloading ES command-line tools..." -ForegroundColor White
            $webClient = New-Object System.Net.WebClient
            # Set timeout only if the property exists (PowerShell 3.0+)
            if ($webClient.PSObject.Properties.Name -contains "Timeout") {
                $webClient.Timeout = 30000  # 30 seconds timeout
            }
            $webClient.DownloadFile($url, $ESTempZip)
            
            if (Test-Path $ESTempZip) {
                $fileInfo = Get-Item $ESTempZip
                Write-Host "Downloaded file size: $($fileInfo.Length) bytes" -ForegroundColor Gray
                if ($fileInfo.Length -gt 50000) {  # Reduced threshold to 50KB
                    Write-Host "Download completed successfully" -ForegroundColor Green
                    
                    # Extract the ZIP file
                    if (Test-Path $ESTempExtract) {
                        Remove-Item $ESTempExtract -Recurse -Force
                    }
                    New-Item -ItemType Directory -Path $ESTempExtract -Force | Out-Null
                    
                    $shell = New-Object -ComObject Shell.Application
                    $zip = $shell.NameSpace($ESTempZip)
                    foreach($item in $zip.items()) {
                        $shell.Namespace($ESTempExtract).CopyHere($item)
                    }
                    
                    # Copy es.exe to Everything directory
                    if (Test-Path "$ESTempExtract\es.exe") {
                        Copy-Item "$ESTempExtract\es.exe" $EverythingPath -Force
                        Write-Host "es.exe installed successfully" -ForegroundColor Green
                        $downloadSuccess = $true
                    } else {
                        Write-Host "es.exe not found in extracted files" -ForegroundColor Yellow
                    }
                    
                    # Cleanup
                    Remove-Item $ESTempZip -Force
                    Remove-Item $ESTempExtract -Recurse -Force
                } else {
                    Write-Host "Downloaded file is too small, trying next URL..." -ForegroundColor Yellow
                    if (Test-Path $ESTempZip) {
                        Remove-Item $ESTempZip -Force
                    }
                }
            }
            
        } catch {
            Write-Host "Download failed from ${url} : $_" -ForegroundColor Yellow
            if (Test-Path $ESTempZip) {
                Remove-Item $ESTempZip -Force
            }
            if (Test-Path $ESTempExtract) {
                Remove-Item $ESTempExtract -Recurse -Force
            }
        }
        
        if ($attemptCount -ge $maxAttempts) { break }
    }
    
    if (-not $downloadSuccess) {
        Write-Host "Failed to download es.exe after ${attemptCount} attempts" -ForegroundColor Red
        Write-Host "Please download manually from: https://www.voidtools.com/downloads/" -ForegroundColor Cyan
        Write-Host "Or continue without command-line tools" -ForegroundColor Yellow
    }
} else {
    Write-Host "es.exe already exists" -ForegroundColor Green
}

# Step 3: Add to PATH
Write-Host "`nStep 3: Configuring PATH environment variable..." -ForegroundColor Yellow
try {
    $CurrentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($CurrentPath -notlike "*$EverythingPath*") {
        $NewPath = "$CurrentPath;$EverythingPath"
        [Environment]::SetEnvironmentVariable("Path", $NewPath, "Machine")
        Write-Host "System PATH updated" -ForegroundColor Green
    } else {
        Write-Host "PATH already configured" -ForegroundColor Green
    }
} catch {
    Write-Host "Failed to update PATH: $_" -ForegroundColor Red
}

# Step 4: Install EverythingToolbar (if not disabled)
if (-not $NoToolbar) {
    Write-Host "`nStep 4: Installing EverythingToolbar..." -ForegroundColor Yellow
    
    # Check if already installed
    $alreadyInstalled = $false
    try {
        $products = Get-WmiObject -Class Win32_Product -ErrorAction SilentlyContinue
        foreach ($product in $products) {
            if ($product.Name -like "*EverythingToolbar*") {
                $alreadyInstalled = $true
                Write-Host "EverythingToolbar already installed: $($product.Name)" -ForegroundColor Green
                break
            }
        }
    } catch {
        Write-Host "Error checking installed programs" -ForegroundColor Yellow
    }
    
    if (-not $alreadyInstalled) {
        # Determine installer source
        $installerPath = ""
        
        if ($LocalInstallerPath -and (Test-Path $LocalInstallerPath)) {
            $installerPath = $LocalInstallerPath
            Write-Host "Using local installer: $LocalInstallerPath" -ForegroundColor White
        } else {
            Write-Host "Downloading EverythingToolbar..." -ForegroundColor White
            try {
                $webClient = New-Object System.Net.WebClient
                # Set timeout only if the property exists (PowerShell 3.0+)
                if ($webClient.PSObject.Properties.Name -contains "Timeout") {
                    $webClient.Timeout = 30000  # 30 seconds timeout
                }
                $webClient.DownloadFile($ToolbarDownloadUrl, $ToolbarDownloadPath)
                $installerPath = $ToolbarDownloadPath
                
                $fileInfo = Get-Item $installerPath
                if ($fileInfo.Length -lt 1000000) {
                    Write-Host "Warning: Downloaded file may be incomplete" -ForegroundColor Yellow
                    Write-Host "File size: $($fileInfo.Length) bytes" -ForegroundColor Gray
                } else {
                    Write-Host "Download completed successfully" -ForegroundColor Green
                }
                
            } catch {
                Write-Host "Failed to download EverythingToolbar: $_" -ForegroundColor Red
                Write-Host "Please download manually: $ToolbarDownloadUrl" -ForegroundColor Cyan
                Write-Host "Continuing without EverythingToolbar installation..." -ForegroundColor Yellow
                $installerPath = $null
            }
        }
        
        # Install EverythingToolbar
        if ($installerPath -and (Test-Path $installerPath)) {
            Write-Host "Installing EverythingToolbar..." -ForegroundColor White
            try {
                if ($Silent) {
                    Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait
                } else {
                    Start-Process -FilePath $installerPath -Wait
                }
                Write-Host "EverythingToolbar installation completed" -ForegroundColor Green
                
            } catch {
                Write-Host "Installation failed: $_" -ForegroundColor Red
            }
            
            # Cleanup downloaded file
            if ($installerPath -eq $ToolbarDownloadPath -and (Test-Path $installerPath)) {
                Remove-Item $installerPath -Force
            }
        }
    }
}

# Step 5: Start Everything service
Write-Host "`nStep 5: Starting Everything service..." -ForegroundColor Yellow
try {
    $everythingProcess = Get-Process -Name "Everything" -ErrorAction SilentlyContinue
    if (-not $everythingProcess) {
        Write-Host "Starting Everything service..." -ForegroundColor White
        Start-Process "$EverythingPath\Everything.exe"
        Start-Sleep -Seconds 2
        Write-Host "Everything started" -ForegroundColor Green
    } else {
        Write-Host "Everything is already running" -ForegroundColor Green
    }
} catch {
    Write-Host "Failed to start Everything" -ForegroundColor Red
}

# Step 6: Test command-line tools
Write-Host "`nStep 6: Testing command-line tools..." -ForegroundColor Yellow
try {
    Start-Process "$EverythingPath\es.exe" -ArgumentList "--help" -Wait -NoNewWindow -RedirectStandardOutput "$env:TEMP\es_test.txt" -RedirectStandardError "$env:TEMP\es_error.txt"
    
    if (Test-Path "$env:TEMP\es_test.txt") {
        $output = Get-Content "$env:TEMP\es_test.txt" -Raw
        if ($output -like "*Usage*") {
            Write-Host "es.exe is working correctly" -ForegroundColor Green
        } else {
            Write-Host "es.exe test failed" -ForegroundColor Yellow
        }
        Remove-Item "$env:TEMP\es_test.txt" -Force
    }
} catch {
    Write-Host "Failed to test es.exe" -ForegroundColor Yellow
}

# Step 7: Configuration instructions
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Installation Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nCompleted components:" -ForegroundColor Green
Write-Host "- Everything base installation: OK" -ForegroundColor White
Write-Host "- Command-line tools (es.exe): OK" -ForegroundColor White
if (-not $NoToolbar) {
    Write-Host "- EverythingToolbar: OK" -ForegroundColor White
}

Write-Host "`nUsage Instructions:" -ForegroundColor Yellow
Write-Host "1. Command-line search:" -ForegroundColor White
Write-Host "   es *.txt                    - Search for txt files" -ForegroundColor Gray
Write-Host "   es filename.ext             - Search for specific file" -ForegroundColor Gray
Write-Host "   es 'folder name'            - Search in specific folder" -ForegroundColor Gray

if (-not $NoToolbar) {
    Write-Host "2. Taskbar search:" -ForegroundColor White
    Write-Host "   Right-click taskbar -> Toolbars -> EverythingToolbar" -ForegroundColor Gray
    Write-Host "   Use search box on taskbar" -ForegroundColor Gray
}

Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
Write-Host "- Restart command prompt to use es.exe" -ForegroundColor White
Write-Host "- If toolbar not visible, restart Windows Explorer" -ForegroundColor White
Write-Host "- Ensure Everything service is running" -ForegroundColor White

Write-Host "`nInstallation completed successfully!" -ForegroundColor Green

# Cleanup temp files
if (Test-Path "$env:TEMP\es_error.txt") {
    Remove-Item "$env:TEMP\es_error.txt" -Force
}
