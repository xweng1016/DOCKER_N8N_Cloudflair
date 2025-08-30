#!/bin/bash
# Simple test for bash syntax

echo "Testing bash script syntax..."

# Check if the restart_tunnel.sh has valid syntax
if bash -n restart_tunnel.sh; then
    echo "✅ restart_tunnel.sh has valid bash syntax"
else
    echo "❌ restart_tunnel.sh has syntax errors"
    exit 1
fi

echo "✅ All checks passed!"
