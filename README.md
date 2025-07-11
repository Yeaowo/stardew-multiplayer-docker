# stardew-multiplayer-docker

This project aims to autostart a Stardew Valley Multiplayer Server as easy as possible.

## Important

 - Updating to most recent version requires a rebuild: `docker compose build --no-cache` 
 - Although I'm trying to put out updates, I don't have the time for testing, so I recommend forking and fixing things on your own.
   - You will always get the most recent version with the fork at https://github.com/norimicry/stardew-multiplayer-docker
 - Ansible and Terraform will not be supported anymore

## Setup

### Docker-Compose
 
```
git clone https://github.com/printfuck/stardew-multiplayer-docker

docker compose up
# if you want run containers in the background
# docker compose up -d
```

## Game Setup

Initially you have to create or load a game once via VNC or Web interface. After that the Autoload Mod jumps into the previously loaded save game every time you restart or rebuild the container. The AutoLoad Mod config file is by default mounted as a volume, since it keeps the state of the ongoing SaveGame, but you can also copy your existing SaveGame to the `Saves` volume and define the SaveGame's name in the environment variables.

### VNC

Use a vnc client like `TightVNC` on Windows or plain `vncviewer` on any Linux distribution to connect to the server. You can modify the VNC Port and IP address and Password in the `docker-compose.yml` file like this:

Localhost:
```
   # Server is only reachable on localhost on port 2342...
   ports:
     - 127.0.0.1:2342:5900
   # ... with the password "insecure"
   environment:
     - VNCPASS=insecure
```

### Web Interface

On port 5800 inside the container is a web interface. This is a bit easier and more accessible than just the VNC interface. Although you will be asked for the vnc password, I wouldn't recommend exposing the port to the outside world.

![img](https://store.eris.cc/uploads/859865e1ab5b23fb223923d9a7e4806b.PNG)

## How it works

The game will be pulled from my servers (I'll assume you already own the game - since you're looking for a multiplayer - so please don't rip it from there) and the modLoader (SMAPI) will be pulled from Github when building the container. You can control the mods's settings with environment variables in the `docker-compose.yml` file.

## Used Mods

* [AutoLoadGame](https://www.nexusmods.com/stardewvalley/mods/2509)
* [Always On](https://community.playstarbound.com/threads/updating-mods-for-stardew-valley-1-4.156000/page-20#post-3353880)
* [Unlimited Players](https://www.nexusmods.com/stardewvalley/mods/2213)
* some more ...

## Troubleshooting

### 快速修复

如果遇到启动问题，可以运行故障排除脚本：

```bash
./fix-issues.sh
```

这个交互式脚本提供以下功能：
1. 检查系统状态（Docker、容器、端口）
2. 显示容器日志
3. 重启容器
4. 重建容器
5. 显示连接信息

### 自动修复

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

通过 VNC 访问游戏来初始加载或启动预生成的存档。您可以从那里控制服务器或编辑 configs 文件夹中的 config.json 文件。

### 性能要求

建议使用至少四个逻辑 CPU 和 4GB 内存的 VPS/机器，否则会出现严重延迟。我认为可玩的最低配置（2-4 名玩家）是两个逻辑 CPU 和 1GB 内存。

### 详细故障排除

更多详细信息请查看 [TROUBLESHOOTING.md](TROUBLESHOOTING.md) 文件。
