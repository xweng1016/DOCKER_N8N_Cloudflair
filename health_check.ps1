<#
PowerShell Health Check for the n8n + postgres + cloudflared compose stack

Usage: run this from the repository root in PowerShell:
  .\health_check.ps1

What it does:
- Verifies Docker is installed
- Shows `docker compose ps` output
- Shows short health/status for postgres and n8n
- Extracts any URL(s) from cloudflared logs (trycloudflare / https links)
- Prints quick troubleshooting hints
#>

function ExitWith($code, $msg) {
    if ($msg) { Write-Host $msg }
    exit $code
}

Write-Host "== health_check.ps1: Checking environment =="

# Check Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    ExitWith 2 "Docker executable not found in PATH. Install Docker Desktop and re-run."
}

# Show Docker Compose status
Write-Host "`n== docker compose ps =="
try {
    docker compose ps
} catch {
    Write-Host "Failed to run 'docker compose ps'. Make sure you're in the repo root and Docker is running."
}

Write-Host "`n== Service quick status (postgres, n8n, cloudflared) =="
$services = @('postgres','n8n','cloudflared')
foreach ($s in $services) {
    try {
        $has = docker compose ps | Select-String -Pattern $s -SimpleMatch -Quiet
        if ($has) {
            docker compose ps | Select-String -Pattern $s -SimpleMatch | ForEach-Object { Write-Host $_.Line }
        } else {
            Write-Host "Service '$s' not found in 'docker compose ps' output. It may not be created yet."
        }
    } catch {
        Write-Host "Could not inspect service: $s"
    }
}

Write-Host "`n== cloudflared logs (last 200 lines) =="
try {
    $logs = docker compose logs --tail 200 cloudflared 2>&1
    if (-not $logs) { Write-Host "No logs available for cloudflared (service may not exist or is still starting)." }
    else { $logs | Select-Object -First 200 | ForEach-Object { Write-Host $_ } }
} catch {
    Write-Host "Failed to fetch cloudflared logs: $_"
    $logs = $null
}

# Try to extract URLs from logs
Write-Host "`n== Extracted URLs from cloudflared logs =="
if ($logs) {
    $joined = ($logs -join "`n")
    $matches = [regex]::Matches($joined, 'https?://\S+') | ForEach-Object { $_.Value } | Select-Object -Unique
    if ($matches.Count -gt 0) {
        foreach ($u in $matches) { Write-Host $u }
    } else {
        Write-Host "No http(s) URLs found in cloudflared logs."
        if ($joined -match 'Cannot find a valid certificate' -or $joined -match 'Error locating origin cert' -or $joined -match 'cannot find a valid certificate') {
            Write-Host "Hint: cloudflared cannot find 'cert.pem' in the mounted ./cloudflared directory."
            Write-Host "  - Ensure you ran 'cloudflared login' and 'cloudflared tunnel create <MACCARD_ID>' on the host"
            Write-Host "  - Copy $env:USERPROFILE\\.cloudflared\\cert.pem and the tunnel JSON into .\\cloudflared\\"
            Write-Host "  - Then run: docker compose restart cloudflared"
        }
    }
} else {
    Write-Host "No cloudflared logs to analyze."
}

Write-Host "`n== n8n logs (short tail) =="
try {
    docker compose logs --tail 100 n8n | Select-Object -First 100 | ForEach-Object { Write-Host $_ }
} catch {
    Write-Host "Could not fetch n8n logs."
}

Write-Host "`n== Summary / Next steps =="
Write-Host "- If you saw a trycloudflare / https URL above, open it in your browser to reach n8n through the tunnel."
Write-Host "- If cloudflared is restarting with origin cert errors, run cloudflared login + tunnel create on your machine and copy cert.json + cert.pem into .\\cloudflared\\ (we added this to the README)."
Write-Host "- If you want, I can wire this into the setup script or push the file to remote."

Exit 0
