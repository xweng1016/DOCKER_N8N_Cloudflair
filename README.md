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


# n8n + Postgres — Quick, safe, and logical

This repo defaults to a safe, local-only workflow. Public exposure is optional and documented below.

1) Local-only (safe, recommended for beginners)

Prereqs:
- Docker Desktop (Windows/macOS) or Docker Engine (Linux)

Steps:
1. Ensure `n8n` exposes localhost in `docker-compose.yml`:
```yaml
services:
  n8n:
    # ...
    ports:
      - "5678:5678"
```
2. Start the stack:
```powershell
docker compose up -d
```
3. Open n8n locally:
 - http://localhost:5678

2) Optional: expose n8n to the internet via Cloudflare Tunnel

Use this only when you need external access. Cloudflared is disabled by default in the compose file.

Steps:
1. Install `cloudflared` on your machine:
   - Windows: `winget install --id Cloudflare.cloudflared`
   - Mac/Linux: follow Cloudflare docs
2. In `docker-compose.yml` uncomment the `cloudflared` service block (near the bottom):
```yaml
cloudflared:
  image: cloudflare/cloudflared:latest
  container_name: cloudflared
  command: tunnel --no-autoupdate --url http://n8n:5678
  depends_on:
    - n8n
  restart: unless-stopped
```
3. Start or restart the stack:
```powershell
docker compose up -d
```
4. Get the public URL:
 - PowerShell: `.
\get_tunnel_url.ps1`
 - Bash: `./get_tunnel_url.sh`
The script prints a `*.trycloudflare.com` URL. Open it in your browser.

3) Useful Docker commands

- See running containers:
```powershell
docker compose ps
```
- View logs:
```powershell
docker compose logs --tail 100 n8n
docker compose logs --tail 100 cloudflared
```
- Stop everything:
```powershell
docker compose down
```
- Restart a service:
```powershell
docker compose restart n8n
docker compose restart cloudflared
```

Troubleshooting hints
- If cloudflared logs show no URL: wait 10–30s and re-run `get_tunnel_url`.
- If a container is stuck, check `docker compose ps` and `docker compose logs --tail 200 <service>`.

Security note
- Default = local only. Only enable Cloudflare tunnel when you understand the tradeoffs.

That's it — local first, then public if you need it.
---

## 🌍 Optional: Expose n8n to the Internet (Enable Cloudflare Tunnel)

By default, public access is **disabled** for security. To enable public access:

1. **Install Cloudflared:**
   - Windows: `winget install --id Cloudflare.cloudflared`
   - Mac/Linux: [Cloudflare Docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation/)

2. **Edit your `docker-compose.yml`:**
   - Uncomment the `cloudflared` service block at the bottom of the file:
     ```yaml
     cloudflared:
       image: cloudflare/cloudflared:latest
       container_name: cloudflared
       command: tunnel --no-autoupdate --url http://n8n:5678
       depends_on:
         - n8n
       restart: unless-stopped
     ```

3. **Start or restart everything:**
   ```powershell
   docker compose up -d
   ```

4. **Find your public n8n URL:**
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
