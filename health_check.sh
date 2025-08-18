#!/usr/bin/env bash
set -euo pipefail

# Cross-platform health check for the project
# - waits for containers to report healthy or running
# - extracts cloudflared tunnel URL

echo "=== Project Health Check ==="

# ensure docker is available
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker is not installed or not in PATH. Please install Docker Desktop and try again."
  exit 1
fi

echo "\nContainers (short):"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# helper: wait for health or running
wait_for_health() {
  name=$1
  printf "Waiting for %s " "$name"
  for i in {1..24}; do
    status=$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$name" 2>/dev/null || echo "missing")
    if [ "$status" = "healthy" ]; then
      printf "-> healthy\n"
      return 0
    fi
    if [ "$status" = "running" ]; then
      printf "-> running (no healthcheck)\n"
      return 0
    fi
    printf "."
    sleep 5
  done
  printf "\nTimeout waiting for %s. Current status: %s\n" "$name" "$status"
  return 1
}

wait_for_health postgres || echo "Postgres may not be ready (see: docker logs postgres)"
wait_for_health n8n || echo "n8n may not be ready (see: docker logs n8n)"

echo "\nCloudflared logs (searching for URL)..."
# try to find named-tunnel URL or trycloudflare quick-tunnel URL
url=$(docker logs cloudflared 2>&1 | grep -Eo "https?://[a-zA-Z0-9._/-]*" | grep -E "trycloudflare|cloudflare" | head -n1 || true)
if [ -n "$url" ]; then
  echo "Tunnel URL: $url"
else
  echo "No tunnel URL found in logs."
  echo "  - If you used quick tunnel, run: docker logs cloudflared | grep trycloudflare"
  echo "  - For a stable named tunnel: run 'cloudflared login' on host, create tunnel named as MACCARD_ID, copy cert.pem into ./cloudflared, then restart containers."
fi

cat <<'EOF'

Useful commands:
 - docker compose logs -f n8n
 - docker compose logs -f cloudflared
 - docker compose down && docker compose up -d  (restart)

Common fixes:
 - Docker not running => start Docker Desktop
 - cert.pem missing => run 'cloudflared login' on host and copy cert.pem to ./cloudflared/
 - Port 5678 conflict => change host port in docker-compose.yml
EOF
