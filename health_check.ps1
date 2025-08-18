# PowerShell script to check the health of the project
# - waits for containers to report healthy or running
# - extracts cloudflared tunnel URL

Write-Host "=== Project Health Check ==="

# Ensure Docker is available
if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Docker is not installed or not in PATH. Please install Docker Desktop and try again."
    exit 1
}

Write-Host "`nContainers (short):"
docker ps --format "table {{.Names}}`t{{.Status}}`t{{.Ports}}"

# Helper: wait for health or running
function Wait-ForHealth {
    param (
        [string]$name
    )
    Write-Host "Waiting for $name " -NoNewline
    for ($i = 1; $i -le 24; $i++) {
        try {
            $status = docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' $name -ErrorAction Stop
            if ($status -eq "healthy") {
                Write-Host "-> healthy"
                return
            }
            if ($status -eq "running") {
                Write-Host "-> running (no healthcheck)"
                return
            }
            Write-Host "." -NoNewline
            Start-Sleep -s 5
        } catch {
            Write-Host "`nTimeout waiting for $name. Current status: missing"
            return
        }
    }
    Write-Host "`nTimeout waiting for $name. Current status: $status"
}

Wait-ForHealth postgres
Wait-ForHealth n8n

Write-Host "`nCloudflared logs (searching for URL)..."
# Try to find named-tunnel URL or trycloudflare quick-tunnel URL
$url = docker logs cloudflared 2>&1 | Select-String -Pattern "https?://[a-zA-Z0-9._/-]*" | Select-String -Pattern "trycloudflare|cloudflare" | Select-Object -First 1
if ($url) {
    Write-Host "Tunnel URL: $($url.Line)"
} else {
    Write-Host "No tunnel URL found in logs."
}

Write-Host "`nUseful commands:"
Write-Host " - docker compose logs -f n8n"
Write-Host " - docker compose logs -f cloudflared"
Write-Host " - docker compose down && docker compose up -d  (restart)"

Write-Host "`nCommon fixes:"
Write-Host " - Docker not running => start Docker Desktop"
Write-Host " - cert.pem missing => run 'cloudflared login' on host and copy cert.pem to ./cloudflared/"
Write-Host " - Port 5678 conflict => change host port in docker-compose.yml"
