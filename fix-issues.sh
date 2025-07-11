#!/bin/bash

# Stardew Valley 多人游戏 Docker 故障排除脚本
# 作者: AI Assistant
# 版本: 1.0

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# 显示容器日志
show_logs() {
    log_info "显示最近的容器日志..."
    echo "----------------------------------------"
    docker logs stardew --tail 20
    echo "----------------------------------------"
}

# 重启容器
restart_container() {
    log_info "重启容器..."
    docker compose down
    docker compose up -d
    sleep 5
    check_container
}

# 重建容器
rebuild_container() {
    log_info "重建容器..."
    docker compose down
    docker compose build --no-cache
    docker compose up -d
    sleep 10
    check_container
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

# 主菜单
show_menu() {
    echo ""
    echo "=== Stardew Valley 多人游戏 Docker 故障排除 ==="
    echo "1. 检查系统状态"
    echo "2. 显示容器日志"
    echo "3. 重启容器"
    echo "4. 重建容器"
    echo "5. 显示连接信息"
    echo "6. 退出"
    echo ""
    read -p "请选择操作 (1-6): " choice
}

# 主函数
main() {
    log_info "Stardew Valley 多人游戏 Docker 故障排除工具"
    log_info "=========================================="
    
    while true; do
        show_menu
        
        case $choice in
            1)
                check_docker
                check_container
                check_ports
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

# 如果直接运行脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 