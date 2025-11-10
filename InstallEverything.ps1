# Everything Installation Script - Compatible Version
param(
    [switch]$Silent = $false
)

# Check PowerShell version
$PSVersion = $PSVersionTable.PSVersion.Major

# Check admin rights (compatible with old versions)
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: Administrator rights required" -ForegroundColor "Red"
    Read-Host "Press any key to exit"
    exit 1
}

$DownloadPath = "$env:TEMP\Everything-Installer.exe"
$EverythingPath = "$env:ProgramFiles\Everything"

Write-Host "========================================" -ForegroundColor "Cyan"
Write-Host "Everything Installation Script" -ForegroundColor "Cyan"
Write-Host "PowerShell Version: $PSVersion" -ForegroundColor "Gray"
Write-Host "========================================" -ForegroundColor "Cyan"

# Check if already installed
if (Test-Path "$EverythingPath\Everything.exe") {
    Write-Host "Everything is already installed at: $EverythingPath" -ForegroundColor "Green"
} else {
    Write-Host "Downloading Everything installer..." -ForegroundColor "Yellow"
    
    try {
        # Download latest version (compatible with old versions)
        $DownloadUrl = "https://www.voidtools.com/Everything-1.4.1.1026.x64-Setup.exe"
        
        if ($PSVersion -ge 3) {
            $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri $DownloadUrl -OutFile $DownloadPath -ErrorAction Stop
        } else {
            # PowerShell 2.0 compatible download
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($DownloadUrl, $DownloadPath)
        }
        
        Write-Host "Download completed" -ForegroundColor "Green"
    } catch {
        Write-Host "Download failed: $_" -ForegroundColor "Red"
        Write-Host "Please download manually: $DownloadUrl" -ForegroundColor "Cyan"
        Read-Host "Press any key to exit"
        exit 1
    }
    
    Write-Host "Installing Everything..." -ForegroundColor "Yellow"
    
    try {
        # Silent installation
        if ($Silent) {
            Start-Process -FilePath $DownloadPath -ArgumentList "/S" -Wait
        } else {
            Start-Process -FilePath $DownloadPath -Wait
        }
        
        # Wait for installation to complete
        Start-Sleep -Seconds 5
        
        # Verify installation
        if (Test-Path "$EverythingPath\Everything.exe") {
            Write-Host "Everything installed successfully" -ForegroundColor "Green"
        } else {
            Write-Host "Everything installation failed" -ForegroundColor "Red"
            Read-Host "Press any key to exit"
            exit 1
        }
        
        # Clean up download file
        if (Test-Path $DownloadPath) {
            Remove-Item $DownloadPath -Force
        }
        
    } catch {
        Write-Host "Installation failed: $_" -ForegroundColor "Red"
        Read-Host "Press any key to exit"
        exit 1
    }
}

# Download and install es.exe command-line tool
Write-Host "Configuring command-line tools..." -ForegroundColor "Yellow"
$es_exe = "$EverythingPath\es.exe"

if (-not (Test-Path $es_exe)) {
    try {
        Write-Host "Downloading es.exe..." -ForegroundColor "Yellow"
        $ESUrl = "https://www.voidtools.com/ES-1.1.0.10.zip"
        $TempZip = "$env:TEMP\ES.zip"
        $TempExtract = "$env:TEMP\ESExtract"
        
        # Download (compatible with old versions)
        if ($PSVersion -ge 3) {
            Invoke-WebRequest -Uri $ESUrl -OutFile $TempZip
        } else {
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($ESUrl, $TempZip)
        }
        
        # Extract (compatible with old versions)
        if ($PSVersion -ge 3) {
            Expand-Archive -Path $TempZip -DestinationPath $TempExtract -Force
        } else {
            # PowerShell 2.0 compatible extraction
            $shell = New-Object -ComObject Shell.Application
            $zip = $shell.NameSpace($TempZip)
            if (Test-Path $TempExtract) {
                Remove-Item $TempExtract -Recurse -Force
            }
            New-Item -ItemType Directory -Path $TempExtract -Force | Out-Null
            foreach($item in $zip.items()) {
                $shell.Namespace($TempExtract).CopyHere($item)
            }
        }
        
        Copy-Item "$TempExtract\es.exe" $EverythingPath -Force
        
        # Clean up temporary files
        if (Test-Path $TempZip) {
            Remove-Item $TempZip -Force
        }
        if (Test-Path $TempExtract) {
            Remove-Item $TempExtract -Recurse -Force
        }
        
        Write-Host "es.exe installation completed" -ForegroundColor "Green"
    } catch {
        Write-Host "Failed to install es.exe: $_" -ForegroundColor "Red"
    }
} else {
    Write-Host "es.exe already exists" -ForegroundColor "Green"
}

# Add to system PATH
try {
    $CurrentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($CurrentPath -notlike "*$EverythingPath*") {
        $NewPath = "$CurrentPath;$EverythingPath"
        [Environment]::SetEnvironmentVariable("Path", $NewPath, "Machine")
        Write-Host "System PATH updated" -ForegroundColor "Green"
    } else {
        Write-Host "PATH already configured" -ForegroundColor "Green"
    }
} catch {
    Write-Host "Failed to update PATH: $_" -ForegroundColor "Red"
}

# Create desktop shortcut
try {
    $DesktopPath = "$env:USERPROFILE\Desktop"
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$DesktopPath\Everything.lnk")
    $Shortcut.TargetPath = "$EverythingPath\Everything.exe"
    $Shortcut.WorkingDirectory = $EverythingPath
    $Shortcut.IconLocation = "$EverythingPath\Everything.exe,0"
    $Shortcut.Save()
    Write-Host "Desktop shortcut created" -ForegroundColor "Green"
} catch {
    Write-Host "Failed to create shortcut: $_" -ForegroundColor "Yellow"
}

# Start Everything
Write-Host "Starting Everything..." -ForegroundColor "Yellow"
try {
    Start-Process "$EverythingPath\Everything.exe"
    Write-Host "Everything started" -ForegroundColor "Green"
} catch {
    Write-Host "Failed to start Everything: $_" -ForegroundColor "Red"
}

Write-Host "========================================" -ForegroundColor "Cyan"
Write-Host "Installation completed!" -ForegroundColor "Cyan"
Write-Host "========================================" -ForegroundColor "Cyan"

Write-Host "Note: Please reopen command prompt to make PATH changes effective" -ForegroundColor "Cyan"
Write-Host "You can now use 'es' command for file search" -ForegroundColor "Green"

Write-Host ""
Write-Host "Usage examples:" -ForegroundColor "Yellow"
Write-Host "  es *.txt                    - Search for txt files" -ForegroundColor "White"
Write-Host "  es filename.ext             - Search for specific file" -ForegroundColor "White"
Write-Host "  es 'folder name'            - Search in specific folder" -ForegroundColor "White"

Write-Host ""
Read-Host "Press any key to exit"
