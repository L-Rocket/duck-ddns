# duck-ddns

中文文档。英文版见 [README_EN.md](README_EN.md)。

一个用 Go 编写的 DuckDNS 动态域名更新器。当前仓库为项目骨架，包含配置示例与 systemd 服务模板，核心逻辑尚未实现。

## 功能目标

- 按固定间隔更新 DuckDNS 解析
- 支持多域名批量更新
- 记录更新日志，便于排查问题
- 以 systemd 服务方式运行

## 目录结构

```
cmd/duck-ddns/        # 程序入口
config/duck-ddns.json # 配置示例
internal/             # 业务逻辑与工具包（待实现）
logs/                 # 日志目录（可选）
systemd/duck_ddns.service # systemd 服务示例
```

## 配置说明

配置文件示例见 [config/duck-ddns.json](config/duck-ddns.json)。

```json
{
  "domains": ["your domain"],
  "token": "your token",
  "update_interval": 300,
  "log_file": "/var/log/duckdns_updater.log"
}
```

- `domains`: 需要更新的 DuckDNS 域名数组
- `token`: DuckDNS 账号 token
- `update_interval`: 更新间隔（秒）
- `log_file`: 日志文件路径

## 快速开始

1. 按需修改配置文件。
2. 构建程序：

```bash
go build -o duck-ddns ./cmd/duck-ddns
```

3. 运行程序：

```bash
./duck-ddns -config ./config/duck-ddns.json
```

> 说明：当前入口文件仍为空，以上命令用于预留后续使用方式。

## systemd 部署

1. 修改 [systemd/duck_ddns.service](systemd/duck_ddns.service) 中的路径与用户信息。
2. 安装并启动：

```bash
sudo cp systemd/duck_ddns.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now duck_ddns.service
```

## 开发计划

- [ ] 配置解析与校验
- [ ] DuckDNS 更新请求
- [ ] 日志与错误处理
- [ ] 单元测试与 CI
