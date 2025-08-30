# Cross-Platform Compatibility Summary

## ✅ Restart Tunnel Scripts

### Windows (`restart_tunnel.ps1`)
- **Tested**: ✅ Working on Windows PowerShell 5.1+
- **Health checks**: Container status verification
- **Clipboard**: Automatic copy using `Set-Clipboard`
- **Connectivity test**: Uses `Invoke-WebRequest`

### Linux/macOS (`restart_tunnel.sh`)
- **Bash compatibility**: ✅ Standard bash features
- **Health checks**: Container status verification  
- **Clipboard support**:
  - macOS: `pbcopy` (pre-installed)
  - Linux X11: `xclip` (install: `sudo apt install xclip`)
  - Linux Wayland: `wl-copy` (install: `sudo apt install wl-clipboard`)
- **Connectivity test**: Uses `curl` (install if not available)

## 🔧 Requirements

### All Platforms
- Docker or Docker Desktop
- Docker Compose (v1 or v2)

### Linux Additional Packages (optional)
```bash
# For clipboard support
sudo apt install xclip              # X11 systems
sudo apt install wl-clipboard       # Wayland systems

# For connectivity testing
sudo apt install curl               # Most distros have this
```

### macOS
- No additional packages needed (pbcopy and curl are pre-installed)

## 🚀 Usage
Both scripts provide identical functionality:
1. Health check of containers
2. Restart cloudflared tunnel
3. Extract new tunnel URL
4. Copy to clipboard (when possible)
5. Test connectivity (when tools available)

Choose the appropriate script for your platform and run when the tunnel disconnects!
