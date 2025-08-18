#
## 🌍 Expose n8n to the Internet (Enable Cloudflare Tunnel)

By default, public access is **disabled** for security. To enable:

1. Edit your `docker-compose.yml` and uncomment the `cloudflared` service block (at the bottom of the file):
  ```yaml
  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared
    command: tunnel --no-autoupdate --url http://n8n:5678
    depends_on:
     - n8n
    restart: unless-stopped
  ```
2. Start or restart the stack:
  ```powershell
  docker compose up -d
  ```
3. Find your public n8n URL:
  ```powershell
  .\get_tunnel_url.ps1
  ```
  or
  ```bash
  ./get_tunnel_url.sh
  ```
  Open the printed URL in your browser to access n8n from anywhere!

---


## 🐳 Useful Docker Commands

- **See running containers:**
  ```powershell
  docker compose ps
  ```
- **View logs for a service:**
  ```powershell
  docker compose logs --tail 100 n8n
  docker compose logs --tail 100 cloudflared
  ```
- **Stop all containers:**
  ```powershell
  docker compose down
  ```
- **Restart a service:**
  ```powershell
  docker compose restart n8n
  docker compose restart cloudflared
  ```

---

## 🌐 Access n8n on Localhost (with or without Cloudflare)

By default, n8n is only accessible via the Cloudflare tunnel for security.

**To also access n8n on your own machine (localhost):**

1. Edit your `docker-compose.yml` and add this under the `n8n` service:
   ```yaml
   ports:
     - "5678:5678"
   ```
   (Uncomment or add if not present.)

2. Restart the containers:
   ```powershell
   docker compose up -d
   ```

3. Now you can access n8n at:
   - [http://localhost:5678](http://localhost:5678) (local only)
   - Or via the public Cloudflare URL (if cloudflared is enabled)

**To disable Cloudflare tunnel:**
- Edit `docker-compose.yml` and comment out or remove the `cloudflared` service block.
- Restart with `docker compose up -d`.

---

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


3. **Find your public n8n URL (the easy way!):**
   - On Windows (PowerShell):
     ```powershell
     .\get_tunnel_url.ps1
     ```
   - On Mac/Linux/WSL (bash):
     ```bash
     ./get_tunnel_url.sh
     ```
   - The script will print your public n8n URL (e.g. `https://random-string.trycloudflare.com`).
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
