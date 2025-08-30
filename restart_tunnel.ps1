# Simple Restart Cloudflare Tunnel Script
Write-Host "Restarting Cloudflare Tunnel..." -ForegroundColor Cyan

# Check if n8n is running
$n8nRunning = docker ps --filter "name=n8n" --filter "status=running" --format "table {{.Names}}" | Select-String "n8n"
if (-not $n8nRunning) {
    Write-Host "n8n container is not running. Starting the full stack..." -ForegroundColor Yellow
    docker compose up -d
    Start-Sleep -Seconds 10
} else {
    Write-Host "n8n container is running" -ForegroundColor Green
}

# Check if cloudflared exists
$cloudflaredExists = docker ps -a --filter "name=cloudflared" --format "table {{.Names}}" | Select-String "cloudflared"
if (-not $cloudflaredExists) {
    Write-Host "Cloudflared container not found!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "Cloudflared container found" -ForegroundColor Green
}

# Stop and start cloudflared
Write-Host "Stopping cloudflared..." -ForegroundColor Yellow
docker compose stop cloudflared

Start-Sleep -Seconds 3

Write-Host "Starting cloudflared..." -ForegroundColor Green
docker compose start cloudflared

Write-Host "Waiting for tunnel to establish..." -ForegroundColor Cyan
Start-Sleep -Seconds 15

# Get tunnel URL
$tunnelLogs = docker compose logs cloudflared
$tunnelUrl = $tunnelLogs | Select-String -Pattern "https://.*\.trycloudflare\.com" | ForEach-Object { $_.Matches.Value } | Select-Object -Last 1

if ($tunnelUrl) {
    Write-Host ""
    Write-Host "Tunnel restarted successfully!" -ForegroundColor Green
    Write-Host "New Tunnel URL: $tunnelUrl" -ForegroundColor Cyan
    
    # Copy to clipboard
    try {
        $tunnelUrl | Set-Clipboard
        Write-Host "URL copied to clipboard!" -ForegroundColor Green
    } catch {
        Write-Host "Could not copy to clipboard" -ForegroundColor Yellow
    }
} else {
    Write-Host "Could not find tunnel URL in logs" -ForegroundColor Red
}
