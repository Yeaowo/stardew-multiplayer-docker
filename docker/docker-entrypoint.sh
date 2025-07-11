#!/bin/bash

# 设置错误处理
set -e

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 修复权限问题
fix_permissions() {
    log "修复权限问题..."
    
    # 确保 /data/mods 目录存在且有正确权限
    mkdir -p /data/mods
    chmod -R 777 /data/mods
    chown -R 1000:1000 /data/mods
    
    # 确保 SMAPI_BUILD_IN 目录存在
    mkdir -p /data/mods/SMAPI_BUILD_IN
    chmod -R 777 /data/mods/SMAPI_BUILD_IN
    chown -R 1000:1000 /data/mods/SMAPI_BUILD_IN
    
    log "权限修复完成"
}

# 启动 SMAPI 日志监控
log "启动 SMAPI 日志监控..."
/opt/tail-smapi-log.sh &

# 修复权限
fix_permissions

# 使用改进的启动脚本
log "启动游戏..."
/opt/start-game.sh
