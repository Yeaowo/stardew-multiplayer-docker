# 星露谷物语多人服务器 Docker Compose

本项目旨在让星露谷物语多人服务器的自动启动变得尽可能简单。

## 重要说明

 - 更新到最新版本需要重新构建：`docker compose build --no-cache`
 - 虽然我会尽量发布更新，但没有时间进行全面测试，因此建议你 fork 本项目并自行修复问题。
   - 你总能在 https://github.com/norimicry/stardew-multiplayer-docker 获取到最新的 fork 版本
 - 不再支持 Ansible 和 Terraform

## 部署方法

### Docker-Compose

```
git clone https://github.com/printfuck/stardew-multiplayer-docker

docker compose up
# 如果你想让容器在后台运行
# docker compose up -d
```

## 游戏设置

首次启动时，你需要通过 VNC 或 Web 界面创建或加载一次游戏。之后，AutoLoad Mod 会在每次重启或重建容器时自动进入上次加载的存档。AutoLoad Mod 的配置文件默认作为卷挂载，因为它会保存当前存档的状态。你也可以将已有的存档复制到 `Saves` 卷，并在环境变量中指定存档名称。

### VNC

可以使用 Windows 下的 `TightVNC` 或 Linux 下的 `vncviewer` 等 VNC 客户端连接服务器。你可以在 `docker-compose.yml` 文件中修改 VNC 端口、IP 地址和密码，例如：

本地连接：
```
   # 服务器仅在本地的 2342 端口可访问...
   ports:
     - 127.0.0.1:2342:5900
   # ... 密码为 "insecure"
   environment:
     - VNCPASS=insecure
```

### Web 界面

容器内的 5800 端口提供了 Web 界面。这比单独使用 VNC 更简单易用。虽然会要求输入 VNC 密码，但不建议将该端口暴露到公网。

![img](https://store.eris.cc/uploads/859865e1ab5b23fb223923d9a7e4806b.PNG)

## 工作原理

游戏会从我的服务器拉取（假设你已经拥有正版游戏——既然你在找多人服务器——请不要盗版），mod 加载器（SMAPI）会在构建容器时从 Github 拉取。你可以通过 `docker-compose.yml` 文件中的环境变量控制 mod 的设置。

## 使用的 Mod

* [AutoLoadGame](https://www.nexusmods.com/stardewvalley/mods/2509)
* [Always On](https://community.playstarbound.com/threads/updating-mods-for-stardew-valley-1-4.156000/page-20#post-3353880)
* [Unlimited Players](https://www.nexusmods.com/stardewvalley/mods/2213)
* 以及其他一些……

## 故障排查

### 控制台错误信息

通常可以忽略控制台中的大部分信息。如果游戏无法启动或出现错误，请关注类似 “cannot open display” 的信息，这通常是权限问题。

SMAPI 加载器的错误日志位于容器内 `/config/xdg/config/StardewValley/ErrorLogs/SMAPI-latest.txt`。

### VNC

通过 VNC 访问游戏以首次加载或启动预生成的存档。你可以在这里控制服务器，或编辑 configs 文件夹中的 config.json 文件。

### 性能建议

建议使用至少四核 CPU 和 4GB 内存的 VPS/主机，否则会有严重卡顿。最低可玩配置（2-4人）建议为双核 CPU 和 1GB 内存。
