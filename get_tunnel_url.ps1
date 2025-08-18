Write-Host "Looking for your public n8n URL..."
# Get all trycloudflare.com URLs from the logs
$matches = docker compose logs --tail 200 cloudflared | Select-String -Pattern 'https://[a-zA-Z0-9.-]+\.trycloudflare\.com'
$urls = @()
foreach ($m in $matches) {
    foreach ($val in $m.Matches) {
        $urls += $val.Value
    }
}
$urls = $urls | Select-Object -Unique
if ($urls.Count -gt 0) {
    $firstUrl = $urls | Select-Object -First 1
    Write-Host "`nYour public n8n URL is:`n$firstUrl`n"
} else {
    Write-Host "No tunnel URL found yet. Wait a few seconds and try again."
}
