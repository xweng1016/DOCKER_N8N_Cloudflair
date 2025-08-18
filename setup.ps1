# Windows setup script (PowerShell)
# Usage: PowerShell -ExecutionPolicy Bypass -File .\setup.ps1

Write-Host "== setup.ps1: preparing project =="

if (-not (Test-Path .env) -and (Test-Path .env.sample)) {
  Copy-Item .env.sample .env
  Write-Host ".env created from .env.sample. Edit .env to set real values before first run if needed."
}

# load .env into environment
if (Test-Path .env) {
  Get-Content .env | Where-Object { $_ -notmatch '^#' -and $_ -match '=' } | ForEach-Object {
    $parts = $_ -split '='; Set-Item -Path env:$($parts[0].Trim()) -Value $parts[1].Trim()
  }
}

New-Item -ItemType Directory -Force -Path .\cloudflared | Out-Null

if (Get-Command cloudflared -ErrorAction SilentlyContinue) {
  if (-not (Test-Path .\cloudflared\cert.pem)) {
    Write-Host "Running 'cloudflared login' (browser will open)..."
    cloudflared login
    $userCert = Join-Path $env:USERPROFILE ".cloudflared\cert.pem"
    if (Test-Path $userCert) {
      Copy-Item $userCert .\cloudflared\cert.pem -Force
      Write-Host "Copied cert.pem to .\cloudflared\"
    } else {
      Write-Warning "cert.pem not found in $userCert. After login, copy cert.pem to ./cloudflared/"
    }
  } else {
    Write-Host "cert.pem already present in ./cloudflared/"
  }

  if ($env:MACCARD_ID) {
    if (-not (Get-ChildItem .\cloudflared\*.json -ErrorAction SilentlyContinue)) {
      Write-Host "Creating named tunnel $env:MACCARD_ID ..."
      cloudflared tunnel create $env:MACCARD_ID | Out-Null
      Copy-Item "$env:USERPROFILE\.cloudflared\*.json" .\cloudflared\ -ErrorAction SilentlyContinue
      Write-Host "Copied tunnel credentials to ./cloudflared/"
    } else {
      Write-Host "Tunnel credentials already present in ./cloudflared/"
    }
  } else {
    Write-Warning "MACCARD_ID not set in .env"
  }
} else {
  Write-Warning "cloudflared not found. Quick tunnels may be used but won't be named tunnels."
}

Write-Host "Starting docker compose..."
docker compose up -d
Write-Host "Setup complete. Run .\health_check.sh or .\health_check.ps1 to verify."
