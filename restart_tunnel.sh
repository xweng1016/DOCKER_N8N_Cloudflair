#!/bin/bash
# Restart Cloudflare Tunnel and Get New URL

set -e

echo "🔄 Restarting Cloudflare Tunnel..."

# Check if Docker Compose is available
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    echo "❌ Docker Compose not found!"
    exit 1
fi

# Stop cloudflared container
echo "⏹️  Stopping cloudflared container..."
$COMPOSE_CMD stop cloudflared

# Wait a moment
sleep 2

# Start cloudflared container
echo "▶️  Starting cloudflared container..."
$COMPOSE_CMD start cloudflared

# Wait for tunnel to establish
echo "⏳ Waiting for tunnel to establish (30 seconds)..."
sleep 30

# Get the new tunnel URL
echo "🔍 Getting tunnel URL..."
TUNNEL_URL=$($COMPOSE_CMD logs cloudflared | grep -oE 'https://[^[:space:]]*\.trycloudflare\.com' | tail -1)

if [ -n "$TUNNEL_URL" ]; then
    echo ""
    echo "✅ Tunnel restarted successfully!"
    echo "🌐 New Tunnel URL: $TUNNEL_URL"
    echo ""
    
    # Try to copy to clipboard (if available)
    if command -v pbcopy &> /dev/null; then
        echo "$TUNNEL_URL" | pbcopy
        echo "✅ URL copied to clipboard! (macOS)"
    elif command -v xclip &> /dev/null; then
        echo "$TUNNEL_URL" | xclip -selection clipboard
        echo "✅ URL copied to clipboard! (Linux)"
    else
        echo "📋 Copy the URL above manually"
    fi
else
    echo "❌ Could not find tunnel URL in logs"
    echo "📋 Check logs manually:"
    echo "   $COMPOSE_CMD logs cloudflared"
    exit 1
fi

echo ""
echo "💡 Tip: If the tunnel disconnects again, run this script: ./restart_tunnel.sh"
