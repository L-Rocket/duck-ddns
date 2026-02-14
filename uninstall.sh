#!/bin/bash
set -e

# Configuration
SERVICE_NAME="duck-ddns"
BINARY_PATH="/usr/local/bin/duck-ddns"
CONFIG_DIR="/etc/duck-ddns"
LOG_FILE="/var/log/duck-ddns.log"
SERVICE_FILE="/etc/systemd/system/duck-ddns.service"
USER="duckddns"

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

echo "Stopping and disabling $SERVICE_NAME service..."
if systemctl is-active --quiet $SERVICE_NAME; then
    systemctl stop $SERVICE_NAME
fi
if systemctl is-enabled --quiet $SERVICE_NAME; then
    systemctl disable $SERVICE_NAME
fi

echo "Removing systemd service file..."
if [ -f "$SERVICE_FILE" ]; then
    rm "$SERVICE_FILE"
    systemctl daemon-reload
    echo "Removed $SERVICE_FILE"
fi

echo "Removing binary..."
if [ -f "$BINARY_PATH" ]; then
    rm "$BINARY_PATH"
    echo "Removed $BINARY_PATH"
fi

echo "Removing configuration..."
if [ -d "$CONFIG_DIR" ]; then
    rm -rf "$CONFIG_DIR"
    echo "Removed $CONFIG_DIR"
fi

echo "Removing log file..."
if [ -f "$LOG_FILE" ]; then
    rm "$LOG_FILE"
    echo "Removed $LOG_FILE"
fi

# Optional: Remove user
if id "$USER" &>/dev/null; then
    echo "Removing user $USER..."
    userdel "$USER"
fi

echo "----------------------------------------"
echo "Uninstallation Complete!"
echo "----------------------------------------"
