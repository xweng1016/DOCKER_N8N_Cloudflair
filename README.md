# Simplified Cloudflare Tunnel Setup for n8n with Docker Compose

This guide provides step-by-step instructions for setting up n8n with a Cloudflare tunnel using Docker Compose. This setup allows you to securely access your n8n instance without exposing it directly to the internet.

## Prerequisites

### 1. Docker Installation

First, ensure that Docker is installed on your system. If not, follow these instructions:

*   **Windows/macOS:** Download and install Docker Desktop from the official [Docker website](https://www.docker.com/products/docker-desktop/).
*   **Linux:** Follow the instructions for your specific distribution on the [Docker documentation](https://docs.docker.com/engine/install/).

After installation, verify that Docker is running by opening a terminal and running:

```bash
docker --version
```

If Docker is installed correctly, this command will display the Docker version.

### 2. Cloudflare Setup

This setup requires you to have a Cloudflare account and a domain managed by Cloudflare.  **Crucially, you need to use named tunnels.**  Cloudflare's named tunnels provide a persistent connection between your server and Cloudflare's network.

## Cloudflare Configuration

### 1. Log in to Cloudflare

Open your web browser and log in to your Cloudflare account at [https://dash.cloudflare.com/](https://dash.cloudflare.com/).

### 2. Locate the Cloudflare Configuration File

You need to obtain the configuration file for your Cloudflare tunnel. This file contains the credentials required to connect your tunnel to Cloudflare.

*   Navigate to the "Zero Trust" section of the Cloudflare dashboard.
*   Go to "Access" -> "Tunnels".
*   If you don't have a tunnel, create one.  Make sure to create a **named tunnel**.
*   Select your tunnel, and under the "Configuration" tab, you will find instructions on how to download the configuration file. The file is typically named `config.yml`.

### 3. Create the `cloudflared/` Directory and Paste the Configuration File

In your project directory (where the `docker-compose.yml` file is located), create a directory named `cloudflared`.  Then, paste the `config.yml` file you downloaded from Cloudflare into this directory.

```bash
mkdir cloudflared
# Move the config.yml file to the cloudflared directory (replace with your actual path)
mv /path/to/your/config.yml cloudflared/config.yml
```

## Docker Compose Setup

### 1. Running `run_compose.sh`

The `run_compose.sh` script simplifies the process of starting the n8n and Cloudflare tunnel services.

1.  Open your terminal, navigate to the project directory, and make the script executable:

    ```bash
    chmod +x run_compose.sh
    ```

2.  Execute the script:

    ```bash
    ./run_compose.sh
    ```

This script will:

*   Check if Docker and Docker Compose are installed.
*   Check if Docker is running.
*   Start the n8n and Cloudflare tunnel services using `docker-compose up -d`.

## Health Check

### 1. Using `health_check.sh`

The `health_check.sh` script allows you to check the health of the n8n service.

1.  Open your terminal, navigate to the project directory, and make the script executable:

    ```bash
    chmod +x health_check.sh
    ```

2.  Execute the script:

    ```bash
    ./health_check.sh
    ```

This script will check if the n8n service is running and accessible.

## Accessing n8n

After running the `run_compose.sh` script, check the logs of the `cloudflared` service to find the tunnel URL:

```bash
docker logs cloudflared
```

Look for a URL in the logs that looks like: `https://your-tunnel-name.trycloudflare.com`. Open this URL in your browser to access n8n securely.

## Conclusion

By following these steps, you can quickly and easily set up n8n with a Cloudflare tunnel using Docker Compose. This setup provides a secure and reliable way to access your n8n instance from anywhere.
