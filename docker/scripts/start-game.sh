#!/bin/bash

# 设置错误处理
set -e

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 检查游戏文件是否存在
check_game_files() {
    log "检查游戏文件..."
    
    if [ ! -f "${STARDEW_PATH}/Stardew Valley/StardewValley" ]; then
        log "错误: 游戏可执行文件不存在: ${STARDEW_PATH}/Stardew Valley/StardewValley"
        return 1
    fi
    
    if [ ! -d "${STARDEW_PATH}/Stardew Valley/Mods" ]; then
        log "错误: Mods 目录不存在"
        return 1
    fi
    
    log "游戏文件检查通过"
    return 0
}

# 检查并设置 mod
setup_mods() {
    log "设置 mod..."
    
    # 确保 SMAPI_BUILD_IN 目录存在且有正确权限
    mkdir -p /data/mods/SMAPI_BUILD_IN
    chmod -R 777 /data/mods/SMAPI_BUILD_IN
    chown -R 1000:1000 /data/mods/SMAPI_BUILD_IN
    log "确保 SMAPI_BUILD_IN 目录存在"

    # 检查 ConsoleCommands mod
    if [ -d "${STARDEW_PATH}/Stardew Valley/Mods.bak/ConsoleCommands" ]; then
        if [ "${ENABLE_CONSOLE_COMMANDS_MOD}" != "true" ]; then
            mv "${STARDEW_PATH}/Stardew Valley/Mods.bak/ConsoleCommands" "/data/mods/SMAPI_BUILD_IN/.ConsoleCommands"
            log "禁用 ConsoleCommands mod"
        else
            mv "${STARDEW_PATH}/Stardew Valley/Mods.bak/ConsoleCommands" "/data/mods/SMAPI_BUILD_IN/ConsoleCommands"
            log "启用 ConsoleCommands mod"
        fi
    else
        log "警告: ConsoleCommands mod 未找到，跳过"
    fi

    # 检查 SaveBackup mod
    if [ -d "${STARDEW_PATH}/Stardew Valley/Mods.bak/SaveBackup" ]; then
        if [ "${ENABLE_SAVE_BACKUP_MOD}" != "true" ]; then
            mv "${STARDEW_PATH}/Stardew Valley/Mods.bak/SaveBackup" "/data/mods/SMAPI_BUILD_IN/.SaveBackup"
            log "禁用 SaveBackup mod"
        else
            mv "${STARDEW_PATH}/Stardew Valley/Mods.bak/SaveBackup" "/data/mods/SMAPI_BUILD_IN/SaveBackup"
            log "启用 SaveBackup mod"
        fi
    else
        log "警告: SaveBackup mod 未找到，跳过"
    fi
    
    log "Mod 设置完成"
}

# 启动游戏
start_game() {
    log "启动 Stardew Valley..."
    
    # 检查 strangle 命令
    if command -v strangle >/dev/null 2>&1; then
        log "使用 strangle 进行 FPS 限制"
        VSYNC=0 strangle 8 "${STARDEW_PATH}/Stardew Valley/StardewValley"
    else
        log "警告: strangle 命令未找到，不使用 FPS 限制"
        VSYNC=0 "${STARDEW_PATH}/Stardew Valley/StardewValley"
    fi
}

# 主函数
main() {
    log "开始启动流程..."
    
    # 检查游戏文件
    if ! check_game_files; then
        log "游戏文件检查失败，退出"
        exit 1
    fi
    
    # 设置 mod
    setup_mods
    
    # 启动游戏
    start_game
}

# 运行主函数
main "$@" 