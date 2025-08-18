# n8n with Cloudflare Tunnel Setup using Docker Compose

This guide provides a simplified approach to setting up n8n with a Cloudflare tunnel using Docker Compose. This setup allows you to securely access your n8n instance over the internet.

## Prerequisites

1.  **Docker:** Ensure Docker is installed on your system.
    *   **Windows/macOS:** Install Docker Desktop from [Docker website](https://www.docker.com/products/docker-desktop/).
    *   **Linux:** Follow the instructions for your distribution on the [Docker documentation](https://docs.docker.com/engine/install/).
    Verify the installation by running `docker --version` in your terminal.
2.  **Cloudflare:** This setup uses Cloudflare to securely access your n8n instance. The Cloudflare URL will be dynamically generated and printed by the `health_check.sh` script.

## Setup

1.  **Run `run_compose.sh`:** This script starts the n8n and related services.
    ```bash
    # For Linux/macOS:
    chmod +x run_compose.sh
    ./run_compose.sh
    # For Windows:
    .\run_compose.sh
    ```
2.  **Run `health_check.sh`:** This script checks the health of the n8n service and prints the Cloudflare URL.
    ```bash
    # For Linux/macOS:
    chmod +x health_check.sh
    ./health_check.sh
    # For Windows:
    .\health_check.sh
    ```

## Accessing n8n

Execute the `health_check.sh` script to view the Cloudflare URL and access your n8n instance.

## Conclusion

By following these steps, you can quickly set up n8n with a Cloudflare tunnel using Docker Compose for secure remote access.
