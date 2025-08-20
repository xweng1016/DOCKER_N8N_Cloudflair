# Windows one-shot setup: start Compose, wait for app, print URL
$ErrorActionPreference = "Stop"
$AppUrl = $env:APP_URL
if (-not $AppUrl) { $AppUrl = "http://localhost:5678" }
$Attempts = [int](${env:ATTEMPTS} ? ${env:ATTEMPTS} : 30)
$SleepBetween = [int](${env:SLEEP_BETWEEN} ? ${env:SLEEP_BETWEEN} : 2)

Write-Host "== setup.ps1 =="
Write-Host "Target URL: $AppUrl"

function Has-Cmd($name) { $null -ne (Get-Command $name -ErrorAction SilentlyContinue) }

# 1) Prereqs
if (-not (Has-Cmd "docker")) { throw "Docker not found. Install Docker Desktop and re-run." }

# Prefer 'docker compose' over legacy docker-compose
$composeCmd = $null
try { docker compose version | Out-Null; $composeCmd = "docker compose" }
catch {
  if (Has-Cmd "docker-compose") { $composeCmd = "docker-compose" }
  else { throw "Docker Compose not found. Install Docker Desktop (with Compose) and re-run." }
}

# 2) Start stack
Write-Host "▶️  Starting services..."
& $composeCmd up -d

# 3) Health: 2xx/3xx/4xx => ready (handles 401 Basic Auth)
Write-Host "⏳ Waiting for service at $AppUrl ..."
for ($i=1; $i -le $Attempts; $i++) {
  try {
    $resp = Invoke-WebRequest -Uri $AppUrl -UseBasicParsing -TimeoutSec 3
    if ($resp.StatusCode -ge 200 -and $resp.StatusCode -lt 500) {
      Write-Host "✅ Ready: $AppUrl  (HTTP $($resp.StatusCode))"
      exit 0
    }
  } catch {
    if ($_.Exception.Response.StatusCode.value__ -ge 400 -and $_.Exception.Response.StatusCode.value__ -lt 500) {
      Write-Host "✅ Ready: $AppUrl  (HTTP $($_.Exception.Response.StatusCode.value__))"
      exit 0
    }
    Start-Sleep -Seconds $SleepBetween
  }
}

Write-Warning "Containers started, but $AppUrl didn't respond yet."
Write-Host "Check logs: $composeCmd logs -f"
exit 1
