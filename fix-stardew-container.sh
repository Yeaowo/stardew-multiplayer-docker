#!/bin/bash

# 星露谷容器自动修复脚本
# 解决权限问题、目录冲突、Docker缓存等问题
# 版本: 2.0

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# 显示标题
show_header() {
    echo "=========================================="
    echo "    星露谷容器自动修复脚本 v2.0"
    echo "=========================================="
    echo
}

# 检查是否在正确的目录
check_directory() {
    if [ ! -f "docker-compose.yml" ]; then
        log_error "请在星露谷多人游戏Docker项目根目录下运行此脚本"
        exit 1
    fi
    log_success "检测到星露谷Docker项目"
}

# 检查 Docker 是否运行
check_docker() {
    log_info "检查 Docker 服务状态..."
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker 服务未运行，请启动 Docker 服务"
        exit 1
    fi
    log_success "Docker 服务运行正常"
}

# 检查容器状态
check_container() {
    log_info "检查容器状态..."
    
    if docker ps | grep -q stardew; then
        log_success "容器正在运行"
        return 0
    elif docker ps -a | grep -q stardew; then
        log_warning "容器存在但未运行"
        return 1
    else
        log_error "容器不存在"
        return 2
    fi
}

# 检查端口占用
check_ports() {
    log_info "检查端口占用情况..."
    
    local ports=("5902" "5801" "24642")
    local port_names=("VNC" "NoVNC Web" "游戏")
    
    for i in "${!ports[@]}"; do
        if ss -tlnp | grep -q ":${ports[$i]} "; then
            log_success "${port_names[$i]} 端口 (${ports[$i]}) 正在监听"
        else
            log_warning "${port_names[$i]} 端口 (${ports[$i]}) 未监听"
        fi
    done
}

# 停止容器
stop_container() {
    log_step "停止星露谷容器..."
    if docker ps | grep -q stardew; then
        docker-compose down
        log_success "容器已停止"
    else
        log_info "容器未运行，跳过停止步骤"
    fi
}

# 修复权限问题
fix_permissions() {
    log_step "修复mod目录权限..."
    
    if [ -d "docker/mods/" ]; then
        chown -R 1000:1000 docker/mods/
        log_success "mod目录权限已修复"
    else
        log_warning "docker/mods/ 目录不存在，跳过权限修复"
    fi
    
    if [ -d "valley_saves/" ]; then
        chown -R 1000:1000 valley_saves/
        log_success "存档目录权限已修复"
    else
        log_warning "valley_saves/ 目录不存在，跳过权限修复"
    fi
}

# 清理目录冲突
cleanup_conflicts() {
    log_step "检查并清理目录冲突..."
    
    # 检查SMAPI_BUILD_IN目录
    if [ -d "docker/mods/SMAPI_BUILD_IN/" ]; then
        # 清理ConsoleCommands冲突
        if [ -d "docker/mods/SMAPI_BUILD_IN/.ConsoleCommands/ConsoleCommands" ]; then
            rm -rf "docker/mods/SMAPI_BUILD_IN/.ConsoleCommands/ConsoleCommands"
            log_success "已清理 ConsoleCommands 目录冲突"
        fi
        
        # 清理SaveBackup冲突
        if [ -d "docker/mods/SMAPI_BUILD_IN/SaveBackup/SaveBackup" ]; then
            rm -rf "docker/mods/SMAPI_BUILD_IN/SaveBackup/SaveBackup"
            log_success "已清理 SaveBackup 目录冲突"
        fi
        
        # 检查其他可能的冲突
        find docker/mods/SMAPI_BUILD_IN/ -type d -name "*" 2>/dev/null | while read dir; do
            if [ -d "$dir/$(basename "$dir")" ]; then
                log_warning "发现潜在冲突: $dir"
                rm -rf "$dir/$(basename "$dir")"
                log_success "已清理冲突: $dir"
            fi
        done
    else
        log_warning "SMAPI_BUILD_IN 目录不存在，跳过冲突清理"
    fi
}

# 清理Docker缓存
cleanup_docker() {
    log_step "清理Docker缓存..."
    docker system prune -f
    log_success "Docker缓存已清理"
}

# 重新构建镜像（可选）
rebuild_image() {
    if [ "$1" = "--rebuild" ]; then
        log_step "重新构建Docker镜像..."
        docker-compose build --no-cache
        log_success "镜像重新构建完成"
    fi
}

# 启动容器
start_container() {
    log_step "启动星露谷容器..."
    docker-compose up -d
    
    # 等待容器启动
    log_info "等待容器启动..."
    sleep 10
    
    # 检查容器状态
    if docker ps | grep -q stardew; then
        log_success "容器启动成功！"
        show_status
    else
        log_error "容器启动失败，请检查日志"
        show_logs
        exit 1
    fi
}

# 显示容器状态
show_status() {
    log_info "容器状态："
    docker ps | grep stardew || log_warning "容器未运行"
    
    log_info "访问信息："
    echo "  VNC连接: localhost:5902 (密码: CRUD)"
    echo "  Web VNC: http://localhost:5801"
    echo "  多人游戏端口: 24642/udp"
}

# 显示日志
show_logs() {
    log_info "最近的容器日志："
    echo "----------------------------------------"
    docker logs stardew --tail 20 2>/dev/null || log_warning "无法获取日志"
    echo "----------------------------------------"
}

# 显示连接信息
show_connection_info() {
    log_info "连接信息："
    echo "----------------------------------------"
    echo "VNC 连接:"
    echo "  地址: localhost:5902"
    echo "  密码: CRUD"
    echo ""
    echo "Web 界面:"
    echo "  地址: http://localhost:5801"
    echo ""
    echo "游戏端口:"
    echo "  UDP: 24642"
    echo "----------------------------------------"
}

# 系统状态检查
system_check() {
    log_step "执行系统状态检查..."
    check_docker
    check_container
    check_ports
}

# 主菜单
show_menu() {
    echo ""
    echo "=== 星露谷容器故障排除菜单 ==="
    echo "1. 系统状态检查"
    echo "2. 显示容器日志"
    echo "3. 重启容器"
    echo "4. 重建容器"
    echo "5. 显示连接信息"
    echo "6. 自动修复（推荐）"
    echo "7. 退出"
    echo ""
    read -p "请选择操作 (1-7): " choice
}

# 自动修复流程
auto_fix() {
    log_step "开始自动修复流程..."
    check_directory
    stop_container
    fix_permissions
    cleanup_conflicts
    cleanup_docker
    rebuild_image "$1"
    start_container
    
    echo
    log_success "修复完成！"
    echo
    log_info "如果仍有问题，请运行以下命令查看详细日志："
    echo "  docker logs stardew"
    echo
}

# 重启容器
restart_container() {
    log_step "重启容器..."
    docker compose down
    docker compose up -d
    sleep 5
    check_container
}

# 重建容器
rebuild_container() {
    log_step "重建容器..."
    docker compose down
    docker compose build --no-cache
    docker compose up -d
    sleep 10
    check_container
}

# 主函数
main() {
    show_header
    
    # 如果提供了参数，执行自动修复
    if [ "$1" = "--rebuild" ]; then
        auto_fix "$1"
        return
    fi
    
    # 交互式菜单
    while true; do
        show_menu
        
        case $choice in
            1)
                system_check
                ;;
            2)
                show_logs
                ;;
            3)
                restart_container
                ;;
            4)
                rebuild_container
                ;;
            5)
                show_connection_info
                ;;
            6)
                auto_fix
                ;;
            7)
                log_info "退出故障排除工具"
                exit 0
                ;;
            *)
                log_error "无效选择，请重新输入"
                ;;
        esac
        
        echo ""
        read -p "按回车键继续..."
    done
}

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo
    echo "选项:"
    echo "  --rebuild    重新构建Docker镜像并修复"
    echo "  --help       显示此帮助信息"
    echo "  (无参数)     启动交互式菜单"
    echo
    echo "示例:"
    echo "  $0              # 启动交互式菜单"
    echo "  $0 --rebuild    # 自动修复并重新构建镜像"
    echo
    echo "功能说明:"
    echo "  - 修复mod目录和存档目录权限"
    echo "  - 清理SMAPI_BUILD_IN目录冲突"
    echo "  - 清理Docker系统缓存"
    echo "  - 自动重启容器并验证状态"
    echo "  - 提供系统状态检查和日志查看"
}

# 参数处理
case "$1" in
    --help|-h)
        show_help
        exit 0
        ;;
    --rebuild)
        main "$1"
        ;;
    "")
        main
        ;;
    *)
        log_error "未知参数: $1"
        show_help
        exit 1
        ;;
esac 