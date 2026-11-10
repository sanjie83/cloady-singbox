# cloady-singbox

面向 [Cloady](https://cloady.com) 的 sing-box VLESS + WebSocket 服务端部署项目。

本项目不使用 Cloady 原生 sing-box 模板，直接通过仓库内的 Dockerfile 构建镜像。Cloady 从 GitHub 仓库部署后，可在开启 Auto update 的情况下随分支 Push 自动重新构建和部署。

## 方案说明

- sing-box 固定使用官方镜像版本 `v1.14.4`，避免跟随 latest 漂移。
- Dockerfile 显式声明 `ENTRYPOINT` 和 `CMD`，不依赖平台猜测启动命令。
- VLESS + WebSocket，监听容器内 `3000/tcp`。
- TLS 由 Cloady Web Endpoint 终止，容器内 sing-box 使用普通 HTTP/WebSocket，不配置证书。
- UUID 和 WebSocket 路径由环境变量注入；公开仓库不保存真实凭据。
- 启动时先渲染配置并执行 `sing-box check`，配置无效则容器直接退出并输出错误。

## 仓库结构

```text
.
├── Dockerfile
├── compose.yaml
├── docker-entrypoint.sh
├── config/
│   └── config.json
├── .dockerignore
├── .env.example
├── .github/
│   └── workflows/
│       └── docker-build.yml
├── DEPLOY.md
├── CHANGELOG.md
└── README.md
```

## 快速部署

1. 在 Cloady 新建 Application，选择 GitHub Repository。
2. 选择 `sanjie83/cloady-singbox`，分支选择 `main`。
3. 保持仓库根目录作为 Build Root。Cloady 会优先识别 `compose.yaml`，由 Compose 调用仓库 Dockerfile 构建。
4. 在应用的 Settings → Environment 中添加：
   - `VLESS_UUID`：必填，使用自己生成的 UUID，并标记为 Secret。
   - `WS_PATH`：可选，默认 `/ws`，建议设置为不易猜测的路径，并与客户端保持一致。
5. 确认应用对外提供 Web Endpoint，容器端口为 `3000`，然后 Deploy。
6. 部署成功后，在 Cloady 应用页面查看 HTTPS 主机名。客户端使用该主机名、443 端口、TLS + WebSocket 连接。

详细步骤见 [DEPLOY.md](DEPLOY.md)。

## 本地构建验证

需要 Docker：

```bash
docker build -t cloady-singbox:local .
docker run --rm \
  -e VLESS_UUID=00000000-0000-4000-8000-000000000001 \
  -e WS_PATH=/ws \
  cloady-singbox:local version
```

该命令用于验证镜像能构建、入口脚本能渲染并检查配置；`version` 子命令执行后容器退出，不会启动长期服务。

## 客户端参数

部署完成后按实际 Cloady 主机名填写：

| 参数 | 值 |
| --- | --- |
| 协议 | VLESS |
| 地址 | Cloady 分配的应用主机名 |
| 端口 | 443 |
| UUID | Cloady 环境变量中的 `VLESS_UUID` |
| 加密 | none |
| 传输 | WebSocket |
| WebSocket Path | 与 `WS_PATH` 一致，默认 `/ws` |
| TLS | 开启 |
| SNI / Host | Cloady 应用主机名 |

示例 URI（请替换占位符，不要直接使用）：

```text
vless://<UUID>@<CLOADY_HOST>:443?encryption=none&security=tls&sni=<CLOADY_HOST>&type=ws&host=<CLOADY_HOST>&path=%2Fws#cloady-singbox
```

## 安全说明

- 不要把真实 UUID、私钥、令牌或个人节点 URI 提交到仓库。
- `.env` 已加入忽略规则；生产凭据只配置在 Cloady Environment，并标记为 Secret。
- `.env.example` 仅包含无效示例值。
- WebSocket 路径不是身份认证，真正的身份校验由 VLESS UUID 完成。
- 请只向可信用户分发节点信息，并遵守部署地区及服务提供商的使用条款。

## 版本更新

sing-box 版本在 Dockerfile 中固定。升级时修改基础镜像版本，先通过 GitHub Actions 构建检查，再推送到部署分支。Cloady 会根据 GitHub 自动更新设置触发重新部署。
