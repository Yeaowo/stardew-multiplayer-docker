# Stardew Valley 多人游戏 Docker 故障排除指南

## 常见问题

### 1. strangle 命令未找到

**错误信息：**
```
/startapp.sh: line 26: strangle: command not found
```

**原因：**
libstrangle 库安装失败或未正确安装到系统路径中。

**解决方案：**
- 检查 Dockerfile 中的 libstrangle 安装部分
- 确保 libstrangle.ignore.zip 文件存在且包含正确的源代码
- 如果 strangle 命令不可用，游戏仍会正常运行，只是没有 FPS 限制

**临时解决方案：**
修改 `docker/docker-entrypoint.sh` 文件，添加 strangle 命令检查：

```bash
# 检查strangle命令是否可用
if command -v strangle >/dev/null 2>&1; then
    echo "Using strangle for FPS limiting"
    VSYNC=0 strangle 8 "${STARDEW_PATH}/Stardew Valley/StardewValley"
else
    echo "Warning: strangle command not found, running without FPS limit"
    VSYNC=0 "${STARDEW_PATH}/Stardew Valley/StardewValley"
fi
```

### 2. Mod 移动失败

**错误信息：**
```
mv: cannot move '/data/stardew/Stardew Valley/Mods.bak/ConsoleCommands' to '/data/mods/SMAPI_BUILD_IN/.ConsoleCommands': No such file or directory
mv: cannot move '/data/stardew/Stardew Valley/Mods.bak/SaveBackup' to '/data/mods/SMAPI_BUILD_IN/SaveBackup': No such file or directory
```

**原因：**
SMAPI 安装过程中可能没有正确创建这些内置 mod，或者 mod 目录结构发生了变化。

**解决方案：**
- 检查 SMAPI 安装是否成功
- 验证 Mods.bak 目录中是否存在这些 mod
- 如果 mod 不存在，游戏仍会正常运行，只是没有这些功能

**临时解决方案：**
修改 `docker/docker-entrypoint.sh` 文件，添加目录检查：

```bash
# 检查ConsoleCommands mod是否存在
if [ -d "${STARDEW_PATH}/Stardew Valley/Mods.bak/ConsoleCommands" ]; then
    # 移动 mod
else
    echo "Warning: ConsoleCommands mod not found in Mods.bak directory"
fi
```

### 3. VNC 连接问题

**错误信息：**
```
listen6: bind: Address already in use
Not listening on IPv6 interface.
```

**原因：**
IPv6 端口已被占用，但 IPv4 端口仍然可用。

**解决方案：**
- 这通常不是严重问题，VNC 仍然可以通过 IPv4 连接
- 如果需要 IPv6 支持，检查端口 5900 是否被其他服务占用

### 4. X11 相关警告

**错误信息：**
```
Xlib: extension "DPMS" missing on display ":0".
X display is not capable of DPMS.
```

**原因：**
Docker 容器中的 X11 显示服务器不支持某些扩展。

**解决方案：**
- 这些是警告信息，不影响游戏运行
- 可以忽略这些警告

## 环境变量配置

### 启用/禁用内置 Mod

在 `docker-compose.yml` 中设置环境变量：

```yaml
environment:
  - "ENABLE_CONSOLE_COMMANDS_MOD=false"  # 禁用控制台命令 mod
  - "ENABLE_SAVE_BACKUP_MOD=true"        # 启用存档备份 mod
```

### VNC 密码设置

```yaml
environment:
  - "VNC_PASSWORD=your_password_here"
```

## 端口配置

- **VNC**: 5902 (外部) -> 5900 (内部)
- **NoVNC Web**: 5801 (外部) -> 5800 (内部)  
- **游戏**: 24642 (外部) -> 24642 (内部) UDP

## 日志查看

查看容器日志：
```bash
docker logs stardew
```

查看 SMAPI 日志：
```bash
docker exec stardew tail -f /config/xdg/config/StardewValley/Logs/SMAPI-latest.txt
```

## 重建容器

如果遇到严重问题，可以重建容器：

```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## 联系支持

如果问题仍然存在，请：
1. 检查完整的容器日志
2. 确认所有必需文件都存在
3. 验证网络连接和端口配置
4. 检查系统资源使用情况 