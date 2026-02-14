#!/bin/bash
set -e

# Repository information
REPO_OWNER="L-Rocket"
REPO_NAME="duck-ddns"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/duck-ddns"
CONFIG_FILE="$CONFIG_DIR/duck-ddns.json"
SERVICE_FILE="/etc/systemd/system/duck-ddns.service"
USER="duckddns"

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root."
  exit 1
fi

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check for required tools
if ! command_exists curl || ! command_exists jq || ! command_exists tar; then
  echo "Error: curl, jq, and tar are required. Please install them first."
  echo "Example (Ubuntu/Debian): apt-get update && apt-get install -y curl jq tar"
  exit 1
fi

clear
echo "========================================"
echo "   DuckDNS Updater - Installation"
echo "========================================"

echo "Gathering latest release information..."
LATEST_RELEASE_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest"
RELEASE_JSON=$(curl -s "$LATEST_RELEASE_URL")

# Check if release info was fetched successfully
if echo "$RELEASE_JSON" | grep -q "Not Found"; then
  echo "Error: Could not find latest release for $REPO_OWNER/$REPO_NAME."
  exit 1
fi

TAG_NAME=$(echo "$RELEASE_JSON" | jq -r .tag_name)
DOWNLOAD_URL=$(echo "$RELEASE_JSON" | jq -r '.assets[] | select(.name | contains("linux-amd64.tar.gz")) | .browser_download_url')

if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" == "null" ]; then
  echo "Error: Could not find a linux-amd64 asset in the latest release ($TAG_NAME)."
  exit 1
fi

echo "Found latest release: $TAG_NAME"
echo "Downloading $DOWNLOAD_URL..."

TMP_DIR=$(mktemp -d)
curl -L -o "$TMP_DIR/duck-ddns.tar.gz" "$DOWNLOAD_URL"

echo "Extracting..."
tar -xzf "$TMP_DIR/duck-ddns.tar.gz" -C "$TMP_DIR"

echo "Installing binary to $INSTALL_DIR..."
mv "$TMP_DIR/duck-ddns-linux-amd64" "$INSTALL_DIR/duck-ddns"
chmod +x "$INSTALL_DIR/duck-ddns"
rm -rf "$TMP_DIR"

# Create duckddns user if not exists
if ! id "$USER" &>/dev/null; then
    echo "Creating system user $USER..."
    useradd -r -s /bin/false "$USER"
fi

# Configuration Wizard Loop
while true; do
    echo ""
    echo "----------------------------------------"
    echo "Configuration Wizard"
    echo "----------------------------------------"

    mkdir -p "$CONFIG_DIR"

    # Prompt for Token
    while [ -z "$TOKEN" ]; do
      read -p "Enter your DuckDNS Token: " TOKEN
    done

    # Prompt for Domains
    while [ -z "$DOMAINS" ]; do
      read -p "Enter your Domains (comma separated, e.g., mydomain,other): " DOMAINS
    done

    # Convert comma-separated string to JSON array.
    # Using 'gsub' to trim whitespace around domains.
    DOMAINS_JSON=$(echo "$DOMAINS" | jq -R 'split(",") | map(gsub("^\\s+|\\s+$";"\\"))')

    # Prompt for Update Interval
    read -p "Enter Update Interval in seconds [default: 300]: " UPDATE_INTERVAL
    UPDATE_INTERVAL=${UPDATE_INTERVAL:-300}

    # Validate Update Interval (must be an integer)
    if ! [[ "$UPDATE_INTERVAL" =~ ^[0-9]+$ ]]; then
        echo "Warning: Invalid input for update interval. Resetting to default: 300"
        UPDATE_INTERVAL=300
    fi

    # Prompt for IP Source
    read -p "Enter IP Source URL [default: https://ip.3322.net]: " IP_SOURCE
    IP_SOURCE=${IP_SOURCE:-"https://ip.3322.net"}

    # Validate IP Source
    if [[ ! "$IP_SOURCE" =~ ^https?:// ]]; then
        echo "Warning: Invalid IP Source URL. Resetting to default: https://ip.3322.net"
        IP_SOURCE="https://ip.3322.net"
    fi

    echo ""
    echo "----------------------------------------"
    echo "Review Configuration"
    echo "----------------------------------------"
    echo "Token:           $TOKEN"
    echo "Domains:         $DOMAINS"
    echo "Update Interval: $UPDATE_INTERVAL"
    echo "IP Source:       $IP_SOURCE"
    echo "----------------------------------------"
    
    read -p "Is this correct? [Y/n]: " CONFIRM
    CONFIRM=${CONFIRM:-Y}
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        break
    else
        echo "Restarting configuration wizard..."
        TOKEN=""
        DOMAINS=""
        UPDATE_INTERVAL=""
        IP_SOURCE=""
    fi
done

# Create Config File safely using jq
jq -n \
  --argjson domains "$DOMAINS_JSON" \
  --arg token "$TOKEN" \
  --argjson interval "$UPDATE_INTERVAL" \
  --arg ip_source "$IP_SOURCE" \
  '{ 
    domains: $domains,
    token: $token,
    update_interval: $interval,
    log_file: "/var/log/duck-ddns.log",
    ip_source: $ip_source
  }' > "$CONFIG_FILE"
echo "Configuration saved to $CONFIG_FILE"

# Set permissions for config
chown -R "$USER:$USER" "$CONFIG_DIR"
chmod 600 "$CONFIG_FILE"

# Create Log File and set permissions
touch /var/log/duck-ddns.log
chown "$USER:$USER" /var/log/duck-ddns.log

# Create Systemd Service
echo "Creating systemd service..."
cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=DuckDNS Updater Service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$USER
Group=$USER
ExecStart=$INSTALL_DIR/duck-ddns "$CONFIG_FILE"
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd daemon..."
systemctl daemon-reload

echo "Enabling and starting duck-ddns service..."
systemctl enable duck-ddns
systemctl restart duck-ddns

echo "----------------------------------------"
echo "Installation Complete!"
echo "Status:"
systemctl status duck-ddns --no-pager
echo "----------------------------------------"
