# PowerShell script to automate running Docker Compose

# Check if Docker is installed
if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker is not installed. Please install it following the instructions at https://docs.docker.com/get-docker/"
    exit 1
}

# Check if Docker Compose is installed
if (!(Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Host "Docker Compose is not installed. Please install it following the instructions at https://docs.docker.com/compose/install/"
    exit 1
}

# Check if Docker is running
try {
    docker info | Out-Null
} catch {
    Write-Host "Docker is not running. Please start Docker."
    exit 1
}

# Check if docker-compose.yml exists
if (!(Test-Path "docker-compose.yml")) {
    Write-Host "docker-compose.yml not found in the current directory."
    exit 1
}

# Run Docker Compose
Write-Host "Starting Docker Compose..."
docker-compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "Docker Compose started successfully."
} else {
    Write-Host "Docker Compose failed to start."
    exit 1
}