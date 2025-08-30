# Restart Cloudflare Tunnel and Get New URL
$ErrorActionPreference = "Stop"

Write-Host "🔄 Restarting Cloudflare Tunnel..." -ForegroundColor Cyan

# Check if Docker Compose is available
function Has-Cmd($name) { 
    return $null -ne (Get-Command $name -ErrorAction SilentlyContinue) 
}

# Detect Docker Compose command
$composeCmd = $null
if (Has-Cmd "docker-compose") {
    $composeCmd = "docker-compose"
} else {
    try {
        docker compose version | Out-Null
        $composeCmd = "docker compose"
    } catch {
        Write-Host "❌ Docker Compose not found!" -ForegroundColor Red
        exit 1
    }
}

try {
    # Stop cloudflared container
    Write-Host "⏹️  Stopping cloudflared container..." -ForegroundColor Yellow
    if ($composeCmd -eq "docker compose") {
        docker compose stop cloudflared
    } else {
        docker-compose stop cloudflared
    }
    
    # Wait a moment
    Start-Sleep -Seconds 2
    
    # Start cloudflared container
    Write-Host "▶️  Starting cloudflared container..." -ForegroundColor Green
    if ($composeCmd -eq "docker compose") {
        docker compose start cloudflared
    } else {
        docker-compose start cloudflared
    }
    
    # Wait for tunnel to establish
    Write-Host "⏳ Waiting for tunnel to establish (30 seconds)..." -ForegroundColor Cyan
    Start-Sleep -Seconds 30
    
    # Get the new tunnel URL
    Write-Host "🔍 Getting tunnel URL..." -ForegroundColor Cyan
    
    $tunnelLogs = if ($composeCmd -eq "docker compose") {
        docker compose logs cloudflared
    } else {
        docker-compose logs cloudflared
    }
    
    $tunnelUrl = $tunnelLogs | Select-String -Pattern "https://.*\.trycloudflare\.com" | 
                 ForEach-Object { $_.Matches.Value } | Select-Object -Last 1
    
    if ($tunnelUrl) {
        Write-Host ""
        Write-Host "✅ Tunnel restarted successfully!" -ForegroundColor Green
        Write-Host "🌐 New Tunnel URL: $tunnelUrl" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "📋 URL copied to clipboard (if available)" -ForegroundColor Yellow
        
        # Try to copy to clipboard (Windows only)
        try {
            $tunnelUrl | Set-Clipboard
            Write-Host "✅ URL copied to clipboard!" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  Could not copy to clipboard, but URL is shown above" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ Could not find tunnel URL in logs" -ForegroundColor Red
        Write-Host "📋 Check logs manually:" -ForegroundColor Yellow
        Write-Host "   $composeCmd logs cloudflared" -ForegroundColor Gray
        exit 1
    }
    
} catch {
    Write-Host "❌ Error restarting tunnel: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "💡 Tip: If the tunnel disconnects again, run this script: .\restart_tunnel.ps1" -ForegroundColor Blue
