#!/bin/bash

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

# 检查必要文件
check_requirements() {
    log_info "检查必要文件..."
    
    local required_files=(
        "docker/Dockerfile.virtual-keyboard"
        "docker/virtual-keyboard.html"
        "docker-compose-virtual-keyboard.yml"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            log_error "缺少必要文件: $file"
            return 1
        fi
    done
    
    log_success "所有必要文件都存在"
    return 0
}

# 构建基础镜像
build_base_image() {
    log_info "构建基础 Stardew Valley 镜像..."
    
    # 检查基础镜像是否存在
    if ! docker images | grep -q "stardew-multiplayer.*debian-11-v3.5.8"; then
        log_info "基础镜像不存在，开始构建..."
        
        # 构建基础镜像
        docker build -t stardew-multiplayer:debian-11-v3.5.8 docker/
        
        if [ $? -eq 0 ]; then
            log_success "基础镜像构建成功"
        else
            log_error "基础镜像构建失败"
            return 1
        fi
    else
        log_success "基础镜像已存在"
    fi
    
    return 0
}

# 构建虚拟键盘镜像
build_keyboard_image() {
    log_info "构建虚拟键盘镜像..."
    
    # 使用 docker-compose 构建
    docker-compose -f docker-compose-virtual-keyboard.yml build
    
    if [ $? -eq 0 ]; then
        log_success "虚拟键盘镜像构建成功"
        return 0
    else
        log_error "虚拟键盘镜像构建失败"
        return 1
    fi
}

# 启动服务
start_services() {
    log_info "启动虚拟键盘服务..."
    
    # 停止现有服务
    docker-compose -f docker-compose-virtual-keyboard.yml down
    
    # 启动新服务
    docker-compose -f docker-compose-virtual-keyboard.yml up -d
    
    if [ $? -eq 0 ]; then
        log_success "服务启动成功"
        return 0
    else
        log_error "服务启动失败"
        return 1
    fi
}

# 显示访问信息
show_access_info() {
    log_info "获取访问信息..."
    
    # 获取容器状态
    local container_status=$(docker-compose -f docker-compose-virtual-keyboard.yml ps | grep stardew-virtual-keyboard)
    
    if [ -n "$container_status" ]; then
        log_success "========== 虚拟键盘版本部署成功 =========="
        echo ""
        echo -e "${GREEN}访问地址:${NC}"
        echo -e "  🌐 Web界面 (含虚拟键盘): ${BLUE}http://localhost:5801${NC}"
        echo -e "  🖥️  VNC客户端:          ${BLUE}localhost:5902${NC}"
        echo -e "  🎮 游戏端口:            ${BLUE}24642${NC}"
        echo ""
        echo -e "${GREEN}虚拟键盘功能:${NC}"
        echo -e "  ⌨️  键盘切换按钮位于右下角"
        echo -e "  🔤 支持多种布局：默认、Shift、数字、符号、中文"
        echo -e "  📱 完美支持移动设备"
        echo -e "  🎯 点击游戏内任意位置即可激活输入"
        echo ""
        echo -e "${GREEN}密码:${NC}"
        echo -e "  🔒 VNC密码: ${YELLOW}CRUD${NC}"
        echo ""
        echo -e "${GREEN}日志查看:${NC}"
        echo -e "  📋 docker-compose -f docker-compose-virtual-keyboard.yml logs -f"
        echo ""
        echo -e "${GREEN}停止服务:${NC}"
        echo -e "  🛑 docker-compose -f docker-compose-virtual-keyboard.yml down"
        echo ""
    else
        log_error "服务未正常启动"
        return 1
    fi
}

# 主函数
main() {
    echo -e "${GREEN}========== Stardew Valley 虚拟键盘版本构建 ==========${NC}"
    echo ""
    
    # 检查 Docker 是否运行
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker 未运行或无权限访问"
        exit 1
    fi
    
    # 检查 docker-compose 是否安装
    if ! command -v docker-compose > /dev/null 2>&1; then
        log_error "docker-compose 未安装"
        exit 1
    fi
    
    # 检查必要文件
    if ! check_requirements; then
        exit 1
    fi
    
    # 构建基础镜像
    if ! build_base_image; then
        exit 1
    fi
    
    # 构建虚拟键盘镜像
    if ! build_keyboard_image; then
        exit 1
    fi
    
    # 启动服务
    if ! start_services; then
        exit 1
    fi
    
    # 等待服务启动
    log_info "等待服务启动..."
    sleep 5
    
    # 显示访问信息
    show_access_info
}

# 检查命令行参数
case "$1" in
    --help|-h)
        echo "用法: $0 [选项]"
        echo ""
        echo "选项:"
        echo "  --help, -h     显示帮助信息"
        echo "  --build-only   仅构建镜像，不启动服务"
        echo "  --start-only   仅启动服务（需要镜像已构建）"
        echo "  --stop         停止服务"
        echo "  --logs         查看日志"
        echo ""
        echo "示例:"
        echo "  $0              # 完整构建和启动"
        echo "  $0 --build-only # 仅构建"
        echo "  $0 --start-only # 仅启动"
        echo "  $0 --stop       # 停止服务"
        echo "  $0 --logs       # 查看日志"
        exit 0
        ;;
    --build-only)
        log_info "仅构建模式"
        check_requirements && build_base_image && build_keyboard_image
        exit $?
        ;;
    --start-only)
        log_info "仅启动模式"
        start_services && sleep 5 && show_access_info
        exit $?
        ;;
    --stop)
        log_info "停止服务"
        docker-compose -f docker-compose-virtual-keyboard.yml down
        log_success "服务已停止"
        exit 0
        ;;
    --logs)
        log_info "查看日志"
        docker-compose -f docker-compose-virtual-keyboard.yml logs -f
        exit 0
        ;;
    "")
        # 默认：完整构建和启动
        main
        ;;
    *)
        log_error "未知选项: $1"
        echo "使用 $0 --help 查看帮助信息"
        exit 1
        ;;
esac