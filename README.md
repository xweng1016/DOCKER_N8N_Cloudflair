# n8n + Postgres — Quick Setup

This repository provides a simple way to run n8n with Postgres using Docker Compose. By default, the setup is local-only for security. Follow the steps below to get started.

---

## 🚀 Quick Start

### Prerequisites:
- **Docker Desktop** (for Windows/macOS) or Docker Engine (for Linux)
  - *The setup script will offer to install Docker Desktop if it's not detected*

### Setup:
1. Run the setup script:
   - **Linux/macOS:**
     ```bash
     ./setup.sh
     ```
   - **Windows:**
     ```powershell
     .\setup.ps1
     ```
     (Note: Use `.\` not `./` for Windows PowerShell)

2. Access n8n:
   - Local: [http://localhost:5678](http://localhost:5678)
   - Public (via Cloudflare Tunnel): The script will print a public URL (e.g., `*.trycloudflare.com`).

That's it! Your n8n instance is ready to use.

---

## 🛠 Troubleshooting

If you encounter issues, follow these steps:

1. **Check running containers:**
   ```powershell
   docker compose ps
   ```

2. **View logs:**
   ```powershell
   docker compose logs --tail 100 <service>
   ```

3. **Modify `docker-compose.yml` if needed:**
   - To expose n8n locally, ensure the `ports` section is present under the `n8n` service:
     ```yaml
     ports:
       - "5678:5678"
     ```
   - To enable Cloudflare Tunnel, uncomment the `cloudflared` service block.

4. Restart the stack:
   ```powershell
   docker compose up -d
   ```

---

## Security Note

By default, the setup is local-only. Only enable Cloudflare Tunnel if you understand the tradeoffs.

---

For advanced usage and additional commands, refer to the original documentation in this repository.
