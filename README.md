# duck-ddns

English documentation. For Chinese, see [README_CN.md](README_CN.md).

A DuckDNS dynamic DNS updater written in Go. This repository is currently a skeleton with a config example and a systemd service template; the core logic is not implemented yet.

## Goals

- Update DuckDNS records on a fixed interval
- Support multiple domains in one run
- Write update logs for troubleshooting
- Run as a systemd service

## Structure

```
cmd/duck-ddns/            # Program entry
config/duck-ddns.json     # Config example
internal/                 # Business logic and utils (to be implemented)
logs/                     # Log directory (optional)
systemd/duck_ddns.service # systemd service example
```

## Configuration

See [config/duck-ddns.json](config/duck-ddns.json).

```json
{
	"domains": ["your domain"],
	"token": "your token",
	"update_interval": 300,
	"log_file": "/var/log/duckdns_updater.log"
}
```

- `domains`: DuckDNS domain list to update
- `token`: DuckDNS account token
- `update_interval`: update interval in seconds
- `log_file`: log file path

## Quick Start

1. Update the config file as needed.
2. Build:

```bash
go build -o duck-ddns ./cmd/duck-ddns
```

3. Run:

```bash
./duck-ddns -config ./config/duck-ddns.json
```

Note: the entrypoint is currently empty; these commands show the intended usage.

## systemd Deployment

1. Edit [systemd/duck_ddns.service](systemd/duck_ddns.service) with the correct paths and user.
2. Install and start:

```bash
sudo cp systemd/duck_ddns.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now duck_ddns.service
```

## Roadmap

- [ ] Config parsing and validation
- [ ] DuckDNS update request
- [ ] Logging and error handling
- [ ] Unit tests and CI
