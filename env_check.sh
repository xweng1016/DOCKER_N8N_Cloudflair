#!/usr/bin/env bash
# simple .env validator
REQUIRED=(POSTGRES_USER POSTGRES_PASSWORD POSTGRES_DB N8N_BASIC_AUTH_USER N8N_BASIC_AUTH_PASSWORD MACCARD_ID)
if [ ! -f .env ]; then
  echo ".env not found. Copy .env.sample -> .env and edit required values."
  exit 2
fi

missing=()
for k in "${REQUIRED[@]}"; do
  if ! grep -q "^${k}=" .env; then
    missing+=("$k")
  fi
done

if [ ${#missing[@]} -gt 0 ]; then
  echo "Missing required .env keys: ${missing[*]}"
  exit 3
fi

echo ".env looks OK (all required keys present)."
