
# n8n + Postgres + Cloudflare Tunnel (Quick Start, No Login Needed)

## 🚀 One-Command Setup

1. **Install prerequisites:**
    - Docker Desktop: [Download](https://www.docker.com/products/docker-desktop/)
    - Cloudflared:
      - Windows: `winget install --id Cloudflare.cloudflared`
      - Mac/Linux: [Cloudflare Docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation/)

2. **Start everything:**
    ```powershell
    docker compose up -d
    ```

3. **Find your public n8n URL:**
    ```powershell
    docker compose logs --tail 100 cloudflared
    ```
    - Look for a line like: `https://random-string.trycloudflare.com`
    - Open that URL in your browser to access n8n from anywhere!

---

## 🛠️ Troubleshooting

- If you don’t see a tunnel URL in logs, wait a few seconds and check again.
- For help, run:
  ```powershell
  docker compose ps
  docker compose logs --tail 100 cloudflared
  ```

## 🔒 Security

- n8n is **NOT** exposed on localhost by default (unless you map ports in docker-compose.yml).
- Only accessible via the Cloudflare tunnel public URL.

---

**No Cloudflare login or credentials needed! Just run and go.**
