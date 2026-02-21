# DuckDNS Updater

[中文](README_CN.md)

A lightweight, efficient DuckDNS client written in Go.

## Features

- **Efficient**: Written in Go, minimal resource usage.
- **Batch Updates**: Updates all your domains in a single request using the official DuckDNS API.
- **Auto-IP Detection**: Automatically detects your public IPv4 address.
- **Log Management**: Built-in log rotation (10MB per file, 7 rotations) via logrotate.
- **Systemd Integration**: Runs as a background service with automatic restart on failure.
- **Easy Installation**: One-click install script for Linux systems.

## Installation

### Method 1: One-Click Install (Recommended)

This script will download the latest release, install the binary, and guide you through the configuration wizard.

```bash
curl -fsSL https://raw.githubusercontent.com/L-Rocket/duck-ddns/main/install.sh | sudo bash
```

The wizard will ask for your:
- DuckDNS Token
- Domains (comma-separated)
- Update Interval (default: 300s)
- IP Source (default: https://ip.3322.net)

### Method 2: Manual Installation

1.  **Download** the latest binary from the [Releases](https://github.com/L-Rocket/duck-ddns/releases) page.
2.  **Extract** the archive.
3.  **Move** the binary to your path:
    ```bash
    sudo mv duck-ddns /usr/local/bin/
    ```
4.  **Create a config file** (e.g., `/etc/duck-ddns/config.json`):
    ```json
    {
      "domains": ["domain1", "domain2"],
      "token": "your-token-here",
      "update_interval": 300,
      "log_file": "/var/log/duck-ddns.log",
      "ip_source": "https://ip.3322.net"
    }
    ```
5.  **Run** manually or create a systemd service.

## Usage

Run with a specific configuration file:

```bash
duck-ddns /path/to/config.json
```

If no argument is provided, it defaults to `config/duck-ddns.json` relative to the current directory.

## Build from Source

Requirements: Go 1.22+

```bash
git clone https://github.com/L-Rocket/duck-ddns.git
cd duck-ddns
go build -o duck-ddns cmd/duck-ddns/main.go
```

## Logging and Maintenance

By default, logs are written to `/var/log/duck-ddns.log`. The installation script sets up **logrotate** to prevent the log file from growing indefinitely (limits to 10MB per file, keeping up to 7 historical logs).

### View Logs
```bash
sudo tail -f /var/log/duck-ddns.log
```

### Check Service Status
```bash
sudo systemctl status duck-ddns
```

## Uninstallation

To remove DuckDNS Updater from your system:

```bash
curl -fsSL https://raw.githubusercontent.com/L-Rocket/duck-ddns/main/uninstall.sh | sudo bash
```

## License

MIT