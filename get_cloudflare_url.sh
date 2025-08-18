#!/bin/bash

if [ "${CLOUDFLARED_ENABLED}" = "true" ]; then
  url=$(docker logs cloudflared 2>&1 | grep -o "https://[a-zA-Z0-9.-]*\.trycloudflare\.com")
  if [ -n "$url" ]; then
    echo "Cloudflare URL: $url"
  else
    echo "Cloudflare URL not found in logs."
  fi
else
  echo "Cloudflare tunnel is disabled."
fi