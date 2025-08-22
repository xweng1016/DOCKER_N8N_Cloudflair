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

## 🛑 Shutting Down

To safely shut down all containers:

```powershell
docker compose down
```

This will stop and remove all containers while preserving your data in the Docker volumes.

If you want to completely remove everything including all data:

```powershell
docker compose down -v
```

---

## 🌐 Exposing n8n to the Internet (Cloudflare Tunnel)

By default, your n8n instance is only accessible locally for security. To expose it to the internet using Cloudflare Tunnel:

1. **Edit your `docker-compose.yml`** file:
   - Uncomment the `cloudflared` service block (remove the `#` symbols):
     ```yaml
     cloudflared:
       image: cloudflare/cloudflared:latest
       container_name: cloudflared
       command: tunnel --no-autoupdate --url http://n8n:5678
       depends_on:
         - n8n
       restart: unless-stopped
     ```

2. **Apply the changes**:
   ```powershell
   docker compose up -d
   ```

3. **Get your public URL**:
   - **Windows**:
     ```powershell
     .\get_tunnel_url.ps1
     ```
   - **Linux/macOS**:
     ```bash
     ./get_tunnel_url.sh
     ```

The script will output a URL (like `https://random-words.trycloudflare.com`). Use this to access your n8n instance from anywhere!

> **Note**: This uses Cloudflare's free ephemeral tunnels. The URL will change if you restart the stack. No Cloudflare account is required.

---

## 🛠 Troubleshooting

If you encounter issues, follow these steps:

1. **Check running containers:**
   ```powershell
   docker compose ps
   ```

2. **View logs:**
   ```powershell
   docker compose logs --tail 100 n8n
   docker compose logs --tail 100 cloudflared
   ```

3. **Common issues with Cloudflare Tunnel:**
   - **No tunnel URL appears**: 
     - Wait 10-30 seconds for the tunnel to establish
     - Check logs: `docker compose logs cloudflared`
     - Restart cloudflared: `docker compose restart cloudflared`
   
   - **n8n not accessible via tunnel URL**:
     - Check if n8n is running: `docker compose ps`
     - Verify n8n is reachable locally: [http://localhost:5678](http://localhost:5678)
     - Check network connectivity between containers: `docker compose logs cloudflared`

4. **Fixing port conflicts:**
   If port 5678 is already in use on your system, modify the ports in `docker-compose.yml`:
   ```yaml
   ports:
     - "8080:5678"  # Change 8080 to any free port
   ```
   Then restart with: `docker compose up -d`

---

## 🤖 Setting Up the RAG Workflows

This repository includes pre-built workflows in the `n8n workflows` folder that implement a Retrieval-Augmented Generation (RAG) system. Follow these steps to set them up:

### 1. Import the Ingestion Workflow

1. Open your n8n instance ([http://localhost:5678](http://localhost:5678) or your Cloudflare Tunnel URL)
2. Log in with the default credentials:
   - Username: `admin`
   - Password: `securepassword`
3. Click **Workflows** in the left sidebar
4. Click the **Import from File** button (or press `i`)
5. Select the `INGESTION.json` file from the `n8n workflows` folder
6. Click **Import** and then **Save** the workflow

### 2. Import the Chat Workflow

1. Following the same steps, import the `CHAT.json` file from the `n8n workflows` folder
2. Click **Import** and then **Save** the workflow

### 3. Configure Google Gemini API Credentials

1. In your n8n instance, go to **Settings** > **Credentials**
2. Find and click on **Google Gemini (PaLM) API** or click **Create New**
3. To get your Google Gemini API key:
   - Go to [https://console.cloud.google.com](https://console.cloud.google.com)
   - Sign in with your Google account or create a new one
   - Create a new project
   - Navigate to the Google AI Studio
   - Click **Generate API Key** (make sure to select the same project)
   - Copy the generated API key
4. In n8n, paste the API key into the **API Key** field
5. The **Host** should be set to `https://generativelanguage.googleapis.com` (default)
6. Click **Save**

### 4. Configure PostgreSQL Credentials

1. In your n8n instance, go to **Settings** > **Credentials**
2. Find and click on **Postgres PGVector Store** or click **Create New**
3. Enter the following connection details:
   - **Host**: `postgres`
   - **Database**: `n8ndb`
   - **User**: `user`
   - **Password**: `password`
   - **Port**: `5432`
   - **SSL**: `Disabled`
4. Click **Save**

### 5. Test the Workflows

1. Go to the **Workflows** page
2. Open the **INGESTION** workflow and click **Execute Workflow** to load data
3. Then open the **CHAT** workflow to start asking questions about the ingested data

That's it! Your RAG system is now set up and ready to use.

---

## 🔒 Security Notes

1. **Default credentials**:
   - **n8n web interface**: 
     - Username: `your username `
     - Password: ` your securepassword`
   - **PostgreSQL database**:
     - Username: `user`
     - Password: `password`
   - **⚠️ For production use, change these default credentials** in `docker-compose.yml`

2. **Network security**:
   - By default, the setup is local-only
   - When using Cloudflare Tunnel:
     - Your n8n instance is accessible from the internet
     - The URL is public but randomly generated
     - Consider enabling n8n's encryption features for sensitive workflows

3. **API keys**:
   - The Google Gemini API key you generate is stored in n8n's encrypted credentials
   - Avoid sharing your workflows with credential IDs included

---

For advanced usage and additional commands, refer to the original documentation in this repository.
