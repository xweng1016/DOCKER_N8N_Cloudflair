# Windows one-shot setup: start Compose, wait for app, print URL
$ErrorActionPreference = "Stop"
$AppUrl = $env:APP_URL
if (-not $AppUrl) { $AppUrl = "http://localhost:5678" }
# Use if-else instead of ternary operator for PowerShell 5.1 compatibility
$Attempts = if (${env:ATTEMPTS}) { [int]${env:ATTEMPTS} } else { 30 }
$SleepBetween = if (${env:SLEEP_BETWEEN}) { [int]${env:SLEEP_BETWEEN} } else { 2 }
$ComposeFile = Join-Path $PSScriptRoot "docker-compose.yml"

Write-Host "== setup.ps1 =="
Write-Host "Target URL: $AppUrl"
Write-Host "Using compose file: $ComposeFile"

function Has-Cmd($name) { 
    return $null -ne (Get-Command $name -ErrorAction SilentlyContinue) 
}

# 1) Prereqs
if (-not (Has-Cmd "docker")) {
    Write-Host "🔄 Docker not found. Would you like to install Docker Desktop? (y/n)" -ForegroundColor Yellow
    $choice = Read-Host
    if ($choice -eq 'y') {
        Write-Host "📥 Downloading Docker Desktop for Windows..." -ForegroundColor Cyan
        $installerPath = Join-Path $env:TEMP "DockerDesktopInstaller.exe"
        Invoke-WebRequest -Uri "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe" -OutFile $installerPath
        Write-Host "🚀 Installing Docker Desktop. Please follow the installer prompts..." -ForegroundColor Cyan
        Start-Process $installerPath -Wait
        Write-Host "⚠️ Please restart your computer after installation and run this script again." -ForegroundColor Yellow
        exit 0
    } else {
        throw "Docker not found. Please install Docker Desktop and re-run this script."
    }
}

# Check Docker is running
try {
    docker info | Out-Null
} catch {
    Write-Host "⚠️ Docker is not running. Please start Docker Desktop and run this script again." -ForegroundColor Red
    exit 1
}

# Detect Docker Compose
$composeCmd = $null
if (Has-Cmd "docker-compose") {
    # Legacy version
    $composeCmd = "docker-compose"
} else {
    # Try using the new Docker Compose V2 integrated command
    try {
        docker compose version | Out-Null
        $composeCmd = "docker compose"
    } catch {
        Write-Host "⚠️ Docker Compose not found. Installing Docker Compose plugin..." -ForegroundColor Yellow
        Write-Host "Please install Docker Compose and run this script again." -ForegroundColor Red
        exit 1
    }
}

# 2) Start stack
Write-Host "▶️  Starting services..." -ForegroundColor Green

# Ensure we use explicit file path for compose
if ($composeCmd -eq "docker compose") {
    docker compose -f "$ComposeFile" up -d
} else {
    docker-compose -f "$ComposeFile" up -d
}

# 3) Health: 2xx/3xx/4xx => ready (handles 401 Basic Auth)
Write-Host "⏳ Waiting for service at $AppUrl ..." -ForegroundColor Cyan
for ($i=1; $i -le $Attempts; $i++) {
    try {
        $resp = Invoke-WebRequest -Uri $AppUrl -UseBasicParsing -TimeoutSec 3
        if ($resp.StatusCode -ge 200 -and $resp.StatusCode -lt 500) {
            Write-Host "✅ Ready: $AppUrl  (HTTP $($resp.StatusCode))" -ForegroundColor Green
            
            # Check if cloudflared is running and get tunnel URL
            Write-Host "🔍 Checking for Cloudflare Tunnel..." -ForegroundColor Cyan
            try {
                if ($composeCmd -eq "docker compose") {
                    $tunnelLogs = docker compose -f "$ComposeFile" logs cloudflared
                } else {
                    $tunnelLogs = docker-compose -f "$ComposeFile" logs cloudflared
                }
                
                $tunnelUrl = $tunnelLogs | Select-String -Pattern "https://.*\.trycloudflare\.com" | 
                            ForEach-Object { $_.Matches.Value } | Select-Object -Last 1
                            
                if ($tunnelUrl) {
                    Write-Host "🌐 Public URL (Cloudflare Tunnel): $tunnelUrl" -ForegroundColor Green
                }
            } catch {
                # Cloudflared might not be running, which is OK
            }
            
            exit 0
        }
    } catch {
        if ($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -ge 400 -and $_.Exception.Response.StatusCode.value__ -lt 500) {
            Write-Host "✅ Ready: $AppUrl  (HTTP $($_.Exception.Response.StatusCode.value__))" -ForegroundColor Green
            exit 0
        }
        Write-Host "  Attempt $i/$Attempts - Waiting for service to be ready..." -ForegroundColor Yellow
        Start-Sleep -Seconds $SleepBetween
    }
}

Write-Warning "Containers started, but $AppUrl didn't respond yet."
Write-Host "Check container status: docker ps" -ForegroundColor Yellow
Write-Host "Check logs: docker compose -f '$ComposeFile' logs -f" -ForegroundColor Yellow
Write-Host "Or try: docker compose -f '$ComposeFile' restart n8n" -ForegroundColor Yellow
exit 1
