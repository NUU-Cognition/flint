# Flint Installer for Windows (PowerShell)
# Usage: irm https://raw.githubusercontent.com/NUU-Cognition/flint/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$REPO = "NUU-Cognition/flint"
$INSTALL_DIR = Join-Path $env:USERPROFILE ".flint"

# Colors
function Write-Info { Write-Host "[info] $args" -ForegroundColor Green }
function Write-Warn { Write-Host "[warn] $args" -ForegroundColor Yellow }
function Write-Error { Write-Host "[error] $args" -ForegroundColor Red; exit 1 }

# Check Node 20+
function Check-Node {
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        Write-Error "Node.js not found. Install Node 20+ first: https://nodejs.org"
    }

    $nodeVersion = node -v
    $majorVersion = [int]($nodeVersion -replace 'v(\d+)\..*', '$1')

    if ($majorVersion -lt 20) {
        Write-Error "Node 20+ required (found $nodeVersion). Update Node: https://nodejs.org"
    }

    Write-Info "Node $nodeVersion detected"
}

# Get latest release asset URL
function Get-LatestRelease {
    try {
        $response = Invoke-RestMethod -Uri "https://api.github.com/repos/$REPO/releases/latest"
        $tarballUrl = $response.assets | Where-Object { $_.name -like "*.tar.gz" } | Select-Object -First 1 -ExpandProperty browser_download_url
        return $tarballUrl
    } catch {
        return $null
    }
}

# Add to PATH if not already there
function Add-ToPath {
    param([string]$Directory)

    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")

    if ($userPath -notlike "*$Directory*") {
        Write-Info "Adding $Directory to PATH..."
        $newPath = "$userPath;$Directory"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")

        # Update current session
        $env:Path = "$env:Path;$Directory"

        Write-Warn "PATH updated. Restart your terminal for changes to take effect."
        return $true
    }

    return $false
}

# Main installation
function Main {
    Write-Host ""
    Write-Host "  Installing Flint"
    Write-Host ""

    Check-Node

    Write-Info "Fetching latest release..."
    $tarballUrl = Get-LatestRelease

    if (-not $tarballUrl) {
        Write-Error "Could not find latest release. Check https://github.com/$REPO/releases"
    }

    Write-Info "Downloading from $tarballUrl"

    # Clean existing install
    if (Test-Path $INSTALL_DIR) {
        Write-Warn "Removing existing installation at $INSTALL_DIR"
        Remove-Item -Path $INSTALL_DIR -Recurse -Force
    }

    New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null

    # Download tarball
    $tempTarball = Join-Path $env:TEMP "flint.tar.gz"
    Invoke-WebRequest -Uri $tarballUrl -OutFile $tempTarball

    # Extract using tar (available in Windows 10+)
    Write-Info "Extracting..."
    tar -xzf $tempTarball -C $INSTALL_DIR --strip-components=1

    Remove-Item $tempTarball

    # NOTE: No npm install needed - tarball already includes all dependencies
    Write-Info "Dependencies already included"

    # Add to PATH
    $binDir = Join-Path $INSTALL_DIR "bin"
    $pathUpdated = Add-ToPath $binDir

    if (-not $pathUpdated) {
        Write-Info "Already in PATH: $binDir"
    }

    Write-Host ""
    Write-Info "Flint installed successfully!"
    Write-Host ""
    Write-Host "  Run flint --version to verify."

    if ($pathUpdated) {
        Write-Host "  Restart your terminal first"
    }

    Write-Host ""
}

# Run main
Main
