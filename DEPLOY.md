# Cloady 部署步骤

1. 在 Cloady 创建 Application，选择 GitHub Repository：`sanjie83/cloady-singbox`。
2. 分支选择 `main`，Root Directory 留空，使用仓库根目录的 `compose.yaml`。
3. 在 Cloady Environment 中添加 `VLESS_UUID`（必填，设为 Secret）和 `WS_PATH`（可选，默认 `/ws`）。
4. 将 Web Service / Target Port 指向容器内的 `3000`。
5. 确认 Cloady HTTPS Web Endpoint 支持 WebSocket Upgrade，并将请求转发到容器 HTTP 端口。TLS 在 Cloady 边缘终止，容器内部不配置证书。
6. Deploy，查看日志中 `sing-box check` 是否通过。
7. 在 Cloady 启用 GitHub Auto Deploy / Auto Update，并绑定 `main` 分支。

**重要限制：** VLESS + WS 依赖 WebSocket Upgrade。若当前 Cloady 服务类型不支持 Upgrade 或不支持长连接，不能仅靠设置端口让该方案工作；需要先确认平台能力。不要将 SOCKS/TCP 端口误设为 HTTP Web Endpoint。

## 客户端参数

- 协议：VLESS
- 地址：Cloady 分配的主机名
- 端口：443
- UUID：与 `VLESS_UUID` 相同
- 加密：none
- 传输：WebSocket
- Path：与 `WS_PATH` 完全一致
- TLS：开启
- SNI / Host：Cloady 分配的主机名

示例（替换占位符后使用）：

```text
vless://<UUID>@<CLOADY_HOST>:443?encryption=none&security=tls&sni=<CLOADY_HOST>&type=ws&host=<CLOADY_HOST>&path=%2Fws#cloady-singbox
```

## 故障排查

- 启动退出：检查 UUID、镜像拉取和 `sing-box check` 日志。
- 客户端无法连接：检查 WebSocket Upgrade、目标端口、路径、Host 和 SNI。
- 速度慢：检查网络延迟、丢包及服务端出站质量；WS 封装本身不会提升线路质量。
