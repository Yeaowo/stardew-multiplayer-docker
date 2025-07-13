# 🎯 方案B：HTML5虚拟键盘集成 - 完整实施指南

## 📋 方案概述

**方案B** 是为您的 Stardew Valley Docker 容器集成完整的 HTML5 虚拟键盘解决方案。此方案提供：

- ✅ **跨平台支持**：PC、手机、平板完美兼容
- ✅ **多布局键盘**：支持英文、数字、符号、中文等多种布局
- ✅ **专业界面**：深色主题，移动优化设计
- ✅ **即开即用**：一键构建和部署
- ✅ **高度可定制**：支持自定义布局和样式

## 🚀 快速实施

### 第一步：文件准备

所有必要文件已为您创建：

```
📦 新增文件
├── docker/
│   ├── Dockerfile.virtual-keyboard      # 虚拟键盘 Dockerfile
│   └── virtual-keyboard.html           # 虚拟键盘界面文件
├── docker-compose-virtual-keyboard.yml  # Docker Compose 配置
├── build-virtual-keyboard.sh           # 一键构建脚本
├── 虚拟键盘使用说明.md                  # 详细使用说明
└── 方案B-虚拟键盘实施指南.md             # 本文件
```

### 第二步：一键部署

```bash
# 给构建脚本添加执行权限（如果需要）
chmod +x build-virtual-keyboard.sh

# 一键构建和启动
./build-virtual-keyboard.sh
```

### 第三步：访问验证

部署成功后，您将看到：

```
========== 虚拟键盘版本部署成功 ==========

访问地址:
  🌐 Web界面 (含虚拟键盘): http://localhost:5801
  🖥️  VNC客户端:          localhost:5902
  🎮 游戏端口:            24642

虚拟键盘功能:
  ⌨️  键盘切换按钮位于右下角
  🔤 支持多种布局：默认、Shift、数字、符号、中文
  📱 完美支持移动设备
  🎯 点击游戏内任意位置即可激活输入
```

## 🎮 使用方法

### 基本操作

1. **打开游戏**：访问 `http://您的IP:5801`
2. **显示键盘**：点击右下角的 ⌨️ 按钮
3. **切换布局**：点击键盘上方的布局按钮
4. **输入文字**：在游戏中需要输入时使用虚拟键盘

### 支持的场景

- 🗨️ **多人聊天**：按 `T` 键打开聊天，使用虚拟键盘输入
- 🏷️ **物品命名**：右键物品选择重命名
- 🎣 **钓鱼命名**：给捕获的鱼起名字
- 🐎 **宠物命名**：给农场动物起中文名字
- 📝 **农场命名**：创建农场时使用中文名称

## 🔧 高级配置

### 自定义分辨率

编辑 `docker-compose-virtual-keyboard.yml`：

```yaml
environment:
  # 手机优化
  - "DISPLAY_WIDTH=1280"
  - "DISPLAY_HEIGHT=720"
  
  # 平板优化  
  - "DISPLAY_WIDTH=1920"
  - "DISPLAY_HEIGHT=1080"
  
  # 4K显示器
  - "DISPLAY_WIDTH=3840"
  - "DISPLAY_HEIGHT=2160"
```

### 键盘布局自定义

编辑 `docker/virtual-keyboard.html`，找到 `keyboardLayouts` 对象：

```javascript
const keyboardLayouts = {
    // 添加游戏专用布局
    gaming: [
        'w a s d {space} {enter}',     // 移动键
        'q e r t y u i o p',           // 快捷键
        '1 2 3 4 5 6 7 8 9 0',         // 数字键
        '{shift} {space} {bksp}'       // 功能键
    ],
    
    // 添加农场专用布局
    farming: [
        '种 植 收 获 浇 水 {bksp}',
        '钓 鱼 挖 矿 伐 木 {enter}',
        '动 物 建 筑 {space}'
    ]
};
```

### 样式自定义

在 `docker/virtual-keyboard.html` 的 `<style>` 部分修改：

```css
/* 键盘主题色 */
.simple-keyboard .hg-button {
    background: #2d3748;    /* 深灰色 */
    color: #e2e8f0;         /* 浅色文字 */
    border: 1px solid #4a5568;
}

/* 悬停效果 */
.simple-keyboard .hg-button:hover {
    background: #4a5568;
    border-color: #718096;
}

/* 激活效果 */
.simple-keyboard .hg-button:active {
    background: #3182ce;    /* 蓝色激活 */
    transform: scale(0.95);
}
```

## 🛠️ 故障排除

### 常见问题

#### 1. 构建失败

```bash
# 检查 Docker 状态
docker info

# 检查基础镜像
docker images | grep stardew-multiplayer

# 手动构建基础镜像
docker build -t stardew-multiplayer:debian-11-v3.5.8 docker/
```

#### 2. 虚拟键盘不显示

```bash
# 检查容器日志
docker-compose -f docker-compose-virtual-keyboard.yml logs -f

# 检查网络连接
curl -I http://localhost:5801

# 重启容器
docker-compose -f docker-compose-virtual-keyboard.yml restart
```

#### 3. 按键无响应

- 确保点击游戏区域获取焦点
- 检查 VNC 连接状态
- 尝试不同的键盘布局

#### 4. 中文显示问题

```yaml
# 确认环境变量设置
environment:
  - "ENABLE_CJK_FONT=1"
  - "LANG=zh_CN.UTF-8"
```

### 调试命令

```bash
# 查看容器状态
docker-compose -f docker-compose-virtual-keyboard.yml ps

# 进入容器调试
docker exec -it stardew-virtual-keyboard bash

# 查看资源使用
docker stats stardew-virtual-keyboard

# 查看端口占用
netstat -tlnp | grep -E "(5801|5902|24642)"
```

## 📊 性能优化

### 资源配置

```yaml
# 在 docker-compose-virtual-keyboard.yml 中
services:
  valley:
    mem_limit: 2g           # 内存限制
    memswap_limit: 2g       # 交换限制
    cpus: "1.5"             # CPU 限制
    
    environment:
      - "APP_NICENESS=-10"  # 提高游戏优先级
```

### 网络优化

```yaml
# 如果网络较慢，调整这些参数
environment:
  - "DISPLAY_WIDTH=1024"    # 降低分辨率
  - "DISPLAY_HEIGHT=576"    # 降低分辨率
  - "DISPLAY_MODE=scale"    # 使用缩放模式
```

## 🔄 管理命令

### 日常操作

```bash
# 启动服务
./build-virtual-keyboard.sh --start-only

# 停止服务
./build-virtual-keyboard.sh --stop

# 查看日志
./build-virtual-keyboard.sh --logs

# 重新构建
./build-virtual-keyboard.sh --build-only

# 完整重建
./build-virtual-keyboard.sh
```

### 备份和恢复

```bash
# 备份存档
cp -r valley_saves/ valley_saves_backup_$(date +%Y%m%d)

# 备份配置
cp docker-compose-virtual-keyboard.yml docker-compose-virtual-keyboard.yml.bak

# 恢复到普通版本
./build-virtual-keyboard.sh --stop
docker-compose up -d
```

## 🎯 使用场景示例

### 场景1：手机上多人聊天

1. 手机访问 `http://您的IP:5801`
2. 进入游戏后按 `T` 键打开聊天
3. 点击右下角 ⌨️ 按钮显示虚拟键盘
4. 选择"中文"布局，输入中文消息
5. 按虚拟键盘的 `Enter` 键发送

### 场景2：平板上农场管理

1. 平板访问游戏界面
2. 创建新农场时使用中文名称
3. 给动物起中文名字
4. 使用数字布局输入数量
5. 使用符号布局输入特殊字符

### 场景3：PC上的辅助输入

1. 当物理键盘不便使用时
2. 需要输入特殊字符时
3. 中文输入法冲突时
4. 多人游戏时的快速输入

## 💡 专业技巧

### 键盘布局选择

- **默认布局**：适合英文输入
- **Shift布局**：输入大写字母
- **数字布局**：输入数量、价格
- **符号布局**：特殊字符和标点
- **中文布局**：常用中文词汇

### 效率提升

1. **记住常用按键位置**
2. **合理使用布局切换**
3. **充分利用空格和回车**
4. **在移动设备上使用双手操作**

## 🆕 更新和扩展

### 更新虚拟键盘

```bash
# 获取最新的 Simple Keyboard 库
wget -O docker/simple-keyboard-latest.js \
  https://cdn.jsdelivr.net/npm/simple-keyboard@latest/build/index.js

# 重新构建
./build-virtual-keyboard.sh --build-only
```

### 扩展功能

可以考虑添加：

- 🔊 **按键音效**
- 🎨 **更多主题**
- 🌍 **多语言支持**
- 📱 **手势操作**
- 🎮 **游戏特定快捷键**

## 📞 技术支持

如果您在实施过程中遇到问题：

1. 📖 查看 `虚拟键盘使用说明.md` 获取详细使用指南
2. 🔍 检查容器日志定位问题
3. 🛠️ 尝试重启容器解决临时问题
4. 🔄 重新构建镜像解决配置问题

---

## 🎉 总结

**方案B** 为您提供了一个完整的虚拟键盘解决方案，让您可以在任何设备上畅玩 Stardew Valley。通过这个方案，您可以：

- 🌐 在手机/平板上轻松玩游戏
- 💬 使用中文与朋友聊天
- 🎮 享受无缝的游戏体验
- 🔧 根据需要自定义功能

现在开始享受您的移动农场生活吧！🌾

**Happy Farming with Virtual Keyboard! 🎮⌨️**