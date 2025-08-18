# Setting Up n8n with Cloudflare Tunnel

This guide will help you set up n8n with a Cloudflare tunnel using Docker Compose. It is designed for beginners and non-technical users.

---

## Prerequisites

Before you begin, ensure you have the following:

1. **Docker Installed**:
   - Download and install Docker from [Docker's official website](https://www.docker.com/).
   - Verify installation by running:
     ```powershell
     docker --version
     ```
     **Expected Output**:
     - Correct: `Docker version 20.xx.xx, build xxxxxxx`
     - Incorrect: `Command not found` or similar errors. Install Docker and try again.

2. **Docker Compose Installed**:
   - Docker Compose is often included with Docker Desktop. Verify by running:
     ```powershell
     docker-compose --version
     ```
     **Expected Output**:
     - Correct: `docker-compose version 1.xx.x, build xxxxxxx`
     - Incorrect: `Command not found`. Follow [this guide](https://docs.docker.com/compose/install/) to install Docker Compose.

3. **Cloudflare Account**:
   - Sign up for a free Cloudflare account at [Cloudflare's website](https://www.cloudflare.com/).

4. **Basic Command Line Knowledge**:
   - You will need to run a few commands in PowerShell or your terminal.

---

## Step-by-Step Guide

### Step 1: Clone or Download the Project

1. Open PowerShell and navigate to the folder where you want to set up the project.
2. Run the following command to download the project files:
   ```powershell
   git clone https://github.com/johermohit/DOCKER_N8N_Cloudflair.git
   ```
   Replace `<repository-url>` with the actual URL of this repository.

**Expected Output**:
- Correct: A folder named `DOCKER` is created with the necessary files.
- Incorrect: Errors like `git: command not found`. Install Git from [Git's website](https://git-scm.com/) and try again.

---

### Step 2: Navigate to the Project Directory

1. Change to the project directory:
   ```powershell
   cd DOCKER
   ```

**Expected Output**:
- Correct: Your terminal prompt changes to something like `C:\Users\YourName\DOCKER>`.
- Incorrect: `No such file or directory`. Ensure you are in the correct location.

---

### Step 3: Start the Services

1. Run the following command to start the services:
   ```powershell
   docker-compose up
   ```

**Expected Output**:
- Correct: Logs showing the `n8n` and `cloudflared` services starting.
- Incorrect: Errors like `docker-compose: command not found`. Ensure Docker Compose is installed.

2. To run the services in the background, use:
   ```powershell
   docker-compose up -d
   ```

---

### Step 4: Access n8n

1. Open your web browser and go to:
   ```
   http://localhost:5678
   ```
2. Log in using the credentials:
   - Username: `n8n`
   - Password: `S{(U^E_PA55`

**Expected Output**:
- Correct: The n8n interface loads.
- Incorrect: Errors like `Site cannot be reached`. Ensure the services are running.

---

### Step 5: Verify Cloudflare Tunnel

1. Check the logs of the `cloudflared` service:
   ```powershell
   docker logs cloudflared
   ```
2. Look for a URL in the logs that looks like:
   ```
   https://random-string.trycloudflare.com
   ```
3. Open this URL in your browser to access n8n securely.

**Expected Output**:
- Correct: The n8n interface loads via the Cloudflare tunnel.
- Incorrect: Errors like `Tunnel not found`. Ensure your Cloudflare account is set up correctly.

---

## Troubleshooting

- **Docker Errors**:
  - Ensure Docker is running.
- **Cloudflare Tunnel Issues**:
  - Check your Cloudflare account and configuration.
- **Permission Errors**:
  - Run PowerShell as Administrator.

---

## Stopping the Services

1. To stop the services, run:
   ```powershell
   docker-compose down
   ```

**Expected Output**:
- Correct: Logs showing the services stopping.
- Incorrect: Errors like `No such service`. Ensure you are in the correct directory.

---

## Additional Resources

- [n8n Documentation](https://docs.n8n.io/)
- [Cloudflare Tunnel Guide](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)

---

## Project Repository

The project is hosted on GitHub. You can find the repository here:

[DOCKER_N8N_Cloudflair](https://github.com/johermohit/DOCKER_N8N_Cloudflair)

---

## Simplified Cloudflare Tunnel Setup for Docker Users

To make the setup process seamless for Docker users, follow these steps to securely expose your `n8n` application using a Cloudflare Tunnel:

### Step 1: Install Cloudflared (One-Time Setup)
1. Download and install `cloudflared` from the [official Cloudflare website](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation/).
2. Authenticate with Cloudflare by running:
   ```bash
   cloudflared login
   ```
   - This will open a browser for you to log in to your Cloudflare account.
   - After login, a `cert.pem` file will be generated in your local Cloudflare directory (e.g., `~/.cloudflared` or `C:\Users\<YourUsername>\.cloudflared`).

### Step 2: Create a Named Tunnel (One-Time Setup)
1. Run the following command to create a named tunnel:
   ```bash
   cloudflared tunnel create n8n-tunnel
   ```
2. Note the name of the tunnel (`n8n-tunnel`) for the next step.

### Step 3: Update Docker Compose
1. Open the `docker-compose.yml` file and configure the `cloudflared` service:
   ```yaml
   cloudflared:
     image: cloudflare/cloudflared:latest
     container_name: cloudflared
     command: tunnel run n8n-tunnel
     environment:
       - TUNNEL_ORIGIN_CERT=/certs/cert.pem
     volumes:
       - ~/.cloudflared:/certs
     depends_on:
       - n8n
     restart: unless-stopped
   ```
2. Save the changes.

### Step 4: Start Everything with Docker
1. Run the following command to start all services:
   ```bash
   docker-compose up -d
   ```
2. The `cloudflared` container will establish a secure tunnel to Cloudflare.

### Step 5: Access Your Application
1. Run the following command to find the tunnel URL:
   ```bash
   docker logs cloudflared
   ```
2. Look for a line like:
   ```
   Your named Tunnel has been created! Visit it at: https://n8n-tunnel.cloudflare.com
   ```
3. Open the URL in your browser to access the `n8n` application securely.

---

### Why This is Simple for Docker Users
- **No Manual Steps After Setup**: Once the `cert.pem` file is in place and the `docker-compose.yml` is configured, everything runs with a single `docker-compose up` command.
- **Persistent URL**: The named tunnel ensures a static and reliable URL for accessing your application.
- **Secure by Default**: Cloudflare handles all the security, so you don’t need to worry about exposing your local machine.

Let us know if you encounter any issues or need further assistance!
