# DuckDNS 动态域名更新工具

这是一个轻量级、高效的 DuckDNS 客户端，使用 Go 语言编写。

## 特性

- **高效**：使用 Go 语言编写，资源占用极低。
- **批量更新**：使用官方 DuckDNS API，在一次请求中更新所有域名。
- **自动 IP 检测**：自动检测您的公网 IPv4 地址。
- **Systemd 集成**：作为后台服务运行，故障时自动重启。
- **简易安装**：提供适用于 Linux 系统的一键安装脚本。

## 安装方法

### 方法一：一键安装（推荐）

此脚本将下载最新版本，安装二进制文件，并引导您完成配置向导。

```bash
curl -fsSL https://raw.githubusercontent.com/L-Rocket/duck-ddns/main/install.sh | sudo bash
```

配置向导将询问您的：
- DuckDNS Token
- 域名（逗号分隔）
- 更新间隔（默认：300秒）
- IP 来源（默认：https://ip.3322.net）

### 方法二：手动安装

1.  从 [Releases](https://github.com/L-Rocket/duck-ddns/releases) 页面**下载**最新的二进制文件。
2.  **解压**压缩包。
3.  **移动**二进制文件到系统路径：
    ```bash
    sudo mv duck-ddns /usr/local/bin/
    ```
4.  **创建配置文件**（例如 `/etc/duck-ddns/config.json`）：
    ```json
    {
      "domains": ["domain1", "domain2"],
      "token": "your-token-here",
      "update_interval": 300,
      "log_file": "/var/log/duck-ddns.log",
      "ip_source": "https://ip.3322.net"
    }
    ```
5.  **手动运行**或创建 systemd 服务。

## 使用

指定配置文件运行：

```bash
duck-ddns /path/to/config.json
```

如果未提供参数，默认使用当前目录下的 `config/duck-ddns.json`。

## 源码编译

要求：Go 1.22+

```bash
git clone https://github.com/L-Rocket/duck-ddns.git
cd duck-ddns
go build -o duck-ddns cmd/duck-ddns/main.go
```

## 日志与维护

默认情况下，日志写入 `/var/log/duck-ddns.log`。

### 查看日志
```bash
sudo tail -f /var/log/duck-ddns.log
```

### 查看服务状态
```bash
sudo systemctl status duck-ddns
```

## 卸载

从系统中移除 DuckDNS Updater：

```bash
curl -fsSL https://raw.githubusercontent.com/L-Rocket/duck-ddns/main/uninstall.sh | sudo bash
```

## 许可证

MIT