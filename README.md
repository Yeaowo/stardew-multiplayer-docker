# stardew-multiplayer-docker

本项目旨在让 Stardew Valley（星露谷物语）多人服务器的自启动变得尽可能简单。

## 重要说明

 - 更新到最新版本需要重建镜像：`docker compose build --no-cache`
 - 虽然我会尽量发布更新，但没有时间做全面测试，建议你 fork 一份自行维护和修复。
   - 你可以在 https://github.com/norimicry/stardew-multiplayer-docker 获取最新的 fork 版本
 - 不再支持 Ansible 和 Terraform

## 🚀 快速开始

### 1. 克隆项目
```bash
git clone https://github.com/Yeaowo/stardew-multiplayer-docker.git
cd stardew-multiplayer-docker
```

### 2. 启动服务
```bash
docker compose up -d
```

### 3. 访问游戏
- **VNC连接**: `localhost:5902` (密码: `CRUD`)
- **Web界面**: `http://localhost:5801`
- **多人游戏端口**: `24642/udp`

## 🔧 自动修复脚本

项目包含一个强大的自动修复脚本，可以解决大部分常见问题：

### 使用方法

```bash
# 启动交互式菜单
./fix-stardew-container.sh

# 自动修复并重新构建镜像
./fix-stardew-container.sh --rebuild

# 查看帮助
./fix-stardew-container.sh --help
```

### 脚本功能

✅ **系统检查**: 检查Docker服务、容器状态、端口占用  
✅ **权限修复**: 修复mod目录和存档目录权限  
✅ **冲突清理**: 清理SMAPI_BUILD_IN目录中的重复子目录  
✅ **缓存清理**: 清理Docker系统缓存  
✅ **容器管理**: 自动重启、重建容器并验证状态  
✅ **日志查看**: 实时查看容器日志  
✅ **连接信息**: 显示访问地址和端口  

### 交互式菜单

脚本提供友好的交互式菜单，包含以下选项：

1. **系统状态检查** - 检查Docker、容器、端口状态
2. **显示容器日志** - 查看最近的容器日志
3. **重启容器** - 快速重启容器
4. **重建容器** - 重新构建并启动容器
5. **显示连接信息** - 显示访问地址和端口
6. **自动修复（推荐）** - 执行完整的自动修复流程
7. **退出** - 退出脚本

## 部署方法

### Docker-Compose

```bash
git clone https://github.com/Yeaowo/stardew-multiplayer-docker.git
cd stardew-multiplayer-docker

docker compose up -d
```

## 游戏设置

首次启动时，你需要通过 VNC 或 Web 界面创建或加载一次存档。之后 Autoload Mod 会在每次重启或重建容器时自动加载上次的存档。AutoLoad Mod 的配置文件默认作为卷挂载，因为它会保存当前存档的状态，你也可以将已有存档复制到 `Saves` 卷，并在环境变量中指定存档名。

### VNC

你可以使用 Windows 下的 `TightVNC` 或 Linux 下的 `vncviewer` 等 VNC 客户端连接服务器。你可以在 `docker-compose.yml` 文件中修改 VNC 端口、IP 和密码，例如：

本地连接：
```yaml
   # 服务器只在本地 2342 端口可访问...
   ports:
     - 127.0.0.1:2342:5900
   # ... 密码为 "insecure"
   environment:
     - VNCPASS=insecure
```

### Web 界面

容器内 5800 端口有一个 Web 界面，比 VNC 更易用、更方便。虽然会要求输入 VNC 密码，但不建议将此端口暴露到公网。

![img](https://store.eris.cc/uploads/859865e1ab5b23fb223923d9a7e4806b.PNG)

## 工作原理

游戏文件会从我的服务器拉取（假设你已经拥有正版游戏——既然你在找多人服务器，就请不要盗版），mod 加载器（SMAPI）会在构建容器时从 Github 拉取。你可以通过 `docker-compose.yml` 文件中的环境变量控制 mod 设置。

## 使用的 Mod

* [AutoLoadGame](https://www.nexusmods.com/stardewvalley/mods/2509)
* [Always On](https://community.playstarbound.com/threads/updating-mods-for-stardew-valley-1-4.156000/page-20#post-3353880)
* [Unlimited Players](https://www.nexusmods.com/stardewvalley/mods/2213)
* 还有其他一些 ...

## 故障排除

### 🛠️ 使用自动修复脚本（推荐）

```bash
# 一键修复所有问题
./fix-stardew-container.sh

# 重新构建镜像并修复
./fix-stardew-container.sh --rebuild
```

### 手动故障排除

#### 快速修复

如果遇到启动问题，可以运行故障排除脚本：

```bash
./fix-issues.sh
```

#### 自动修复

如果只需要快速重启，可以运行：

```bash
docker compose down
docker compose up -d
```

### 常见错误信息

#### strangle 命令未找到
```
/startapp.sh: line 26: strangle: command not found
```
**解决方案**: 游戏仍会正常运行，只是没有 FPS 限制。这是非致命错误。

#### Mod 移动失败
```
mv: cannot move '/data/stardew/Stardew Valley/Mods.bak/ConsoleCommands' to '/data/mods/SMAPI_BUILD_IN/.ConsoleCommands': No such file or directory
```
**解决方案**: 这些是 SMAPI 内置 mod，如果不存在游戏仍会正常运行。

#### VNC IPv6 端口占用
```
listen6: bind: Address already in use
Not listening on IPv6 interface.
```
**解决方案**: 这通常不是问题，VNC 仍可通过 IPv4 连接。

### 日志查看

查看容器日志：
```bash
docker logs stardew
```

查看 SMAPI 日志：
```bash
docker exec stardew tail -f /config/xdg/config/StardewValley/Logs/SMAPI-latest.txt
```

### VNC 连接

通过 VNC 访问游戏来初始加载或启动预生成的存档。你可以从那里控制服务器或编辑 configs 文件夹中的 config.json 文件。

### 性能要求

建议使用至少四个逻辑 CPU 和 4GB 内存的 VPS/机器，否则会出现严重延迟。我认为可玩的最低配置（2-4 名玩家）是两个逻辑 CPU 和 1GB 内存。

## 📋 项目结构

```
stardew-multiplayer-docker/
├── docker-compose.yml          # Docker Compose 配置
├── fix-stardew-container.sh    # 自动修复脚本
├── README.md                   # 项目说明文档
├── TROUBLESHOOTING.md          # 详细故障排除文档
├── docker/                     # Docker 相关文件
│   ├── Dockerfile              # 主 Dockerfile
│   ├── Dockerfile.ubuntu       # Ubuntu 版本 Dockerfile
│   ├── docker-entrypoint.sh    # 容器启动脚本
│   └── mods/                   # 游戏 Mod 文件
└── valley_saves/               # 游戏存档目录
```

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

本项目基于 MIT 许可证开源。

## 🔗 相关链接

- [Stardew Valley](https://www.stardewvalley.net/)
- [SMAPI](https://smapi.io/)
- [Docker](https://www.docker.com/)

---

更多详细信息请查看 [TROUBLESHOOTING.md](TROUBLESHOOTING.md) 文件。
