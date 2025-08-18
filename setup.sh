#!/usr/bin/env bash
set -euo pipefail

# Setup script (Linux / macOS)
# - copies .env.sample -> .env if missing
# - attempts cloudflared login/create tunnel using MACCARD_ID from .env
# - copies cert and tunnel JSONs into ./cloudflared
# - starts docker compose (not pushed to remote until user asks)

echo "== setup.sh: preparing project (interactive where needed) =="

# copy sample .env
if [ ! -f .env ] && [ -f .env.sample ]; then
  cp .env.sample .env
  echo ".env created from .env.sample. Edit .env to set real values before first run if needed."
fi

# load .env into env
if [ -f .env ]; then
  # shellcheck disable=SC1091
  export $(grep -v '^#' .env | xargs)
fi

mkdir -p ./cloudflared

if command -v cloudflared >/dev/null 2>&1; then
  if [ ! -f ./cloudflared/cert.pem ]; then
    echo "Running 'cloudflared login' (browser will open). Follow prompts..."
    cloudflared login || true
    if [ -f "${HOME}/.cloudflared/cert.pem" ]; then
      cp "${HOME}/.cloudflared/cert.pem" ./cloudflared/cert.pem || true
      echo "Copied cert.pem to ./cloudflared/"
    else
      echo "Warning: cert.pem not found in ~/.cloudflared after login. Please copy it manually into ./cloudflared/"
    fi
  else
    echo "cert.pem already present in ./cloudflared/"
  fi

  if [ -n "${MACCARD_ID-}" ]; then
    # create tunnel if not present
    if ! ls ./cloudflared/*.json >/dev/null 2>&1; then
      echo "Creating named tunnel '${MACCARD_ID}'..."
      cloudflared tunnel create "${MACCARD_ID}" || true
      cp "${HOME}/.cloudflared"/*.json ./cloudflared/ 2>/dev/null || true
      echo "Copied tunnel credentials to ./cloudflared/"
    else
      echo "Tunnel credentials already present in ./cloudflared/"
    fi
  else
    echo "MACCARD_ID not set in .env — set it to a short name and re-run setup.sh"
  fi
else
  echo "cloudflared not installed. Quick tunnels may still work, but named tunnel won't be available."
fi

echo "Starting services via docker compose..."
docker compose up -d

echo "Setup complete. Run './health_check.sh' to verify."
