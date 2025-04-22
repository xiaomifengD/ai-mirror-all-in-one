#!/bin/bash

# 定义颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to check if Docker is installed
check_docker() {
    if command -v docker &> /dev/null; then
        echo "Docker 已安装。"
        docker --version
        
        # 检查是否存在 docker-compose.yml 文件
        if [ -f "docker-compose.yml" ]; then
            echo
            echo "当前 AI 服务状态："
            docker-compose ps
        fi
        
        return 0
    else
        echo "Docker 未安装。"
        return 1
    fi
}

# Function to install Docker
install_docker() {
    echo "正在安装 Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
}

# Function to install AI services
install_ai_services() {
    if ! check_docker; then
        echo "Docker 未安装，请先安装 Docker。"
        return 1
    fi
    
    echo "正在安装 AI 服务..."
    chmod +x install.sh
    ./install.sh
}

# Function to restart services
restart_services() {
    if ! check_docker; then
        echo "Docker 未安装，请先安装 Docker。"
        return 1
    fi
    
    if [ ! -f "docker-compose.yml" ]; then
        echo "未找到 docker-compose.yml 文件，请先安装 AI 服务。"
        return 1
    fi
    
    echo "正在重启服务..."
    chmod +x restart.sh
    ./restart.sh
}

# Function to stop services
stop_services() {
    if ! check_docker; then
        echo "Docker 未安装，请先安装 Docker。"
        return 1
    fi
    
    if [ ! -f "docker-compose.yml" ]; then
        echo "未找到 docker-compose.yml 文件，请先安装 AI 服务。"
        return 1
    fi
    
    echo "正在停止服务..."
    chmod +x stop.sh
    ./stop.sh
}

# Function to backup databases
backup_databases() {
    if ! check_docker; then
        echo "Docker 未安装，请先安装 Docker。"
        return 1
    fi
    
    if [ ! -f "docker-compose.yml" ]; then
        echo "未找到 docker-compose.yml 文件，请先安装 AI 服务。"
        return 1
    fi
    
    # 获取当前时间戳
    timestamp=$(date +%Y%m%d-%H%M%S)
    
    # 创建本次备份的目录
    backup_dir="./backups/backup-${timestamp}"
    mkdir -p "${backup_dir}"
    
    echo "正在备份数据库..."
    echo "备份文件将保存在: ${backup_dir}"
    
    # 备份 cool 数据库
    echo "正在备份 cool 数据库..."
    docker compose exec mysql sh -c 'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" cool' > "${backup_dir}/cool.sql"
    
    # 备份 grok_cool 数据库
    echo "正在备份 grok_cool 数据库..."
    docker compose exec mysql sh -c 'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" grok_cool' > "${backup_dir}/grok_cool.sql"
    
    # 备份 claude_cool 数据库
    echo "正在备份 claude_cool 数据库..."
    docker compose exec mysql sh -c 'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" claude_cool' > "${backup_dir}/claude_cool.sql"
    
    echo "数据库备份完成！"
    echo "备份文件保存在: ${backup_dir}"
}

# Function to restore databases
restore_databases() {
    if ! check_docker; then
        echo "Docker 未安装，请先安装 Docker。"
        return 1
    fi
    
    if [ ! -f "docker-compose.yml" ]; then
        echo "未找到 docker-compose.yml 文件，请先安装 AI 服务。"
        return 1
    fi
    
    # 检查备份目录是否存在
    if [ ! -d "./backups" ]; then
        echo "未找到备份目录，请先进行备份。"
        return 1
    fi
    
    # 获取所有备份目录
    backup_dirs=($(ls -d ./backups/backup-* 2>/dev/null))
    
    if [ ${#backup_dirs[@]} -eq 0 ]; then
        echo "未找到任何备份文件。"
        return 1
    fi
    
    # 显示可用的备份
    echo "可用的备份："
    for i in "${!backup_dirs[@]}"; do
        echo "$(($i+1)). ${backup_dirs[$i]}"
    done
    
    # 让用户选择要还原的备份
    while true; do
        read -p "请选择要还原的备份编号 (1-${#backup_dirs[@]}): " choice
        if [[ $choice =~ ^[0-9]+$ ]] && [ $choice -ge 1 ] && [ $choice -le ${#backup_dirs[@]} ]; then
            selected_backup="${backup_dirs[$(($choice-1))]}"
            break
        else
            echo "无效的选择，请重新输入。"
        fi
    done
    
    # 确认还原
    read -p "确定要还原备份 ${selected_backup} 吗？这将覆盖现有数据！(y/n): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "已取消还原。"
        return 0
    fi
    
    echo "正在还原数据库..."
    
    # 还原 cool 数据库
    if [ -f "${selected_backup}/cool.sql" ]; then
        echo "正在还原 cool 数据库..."
        docker compose exec -T mysql sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" cool' < "${selected_backup}/cool.sql"
    fi
    
    # 还原 grok_cool 数据库
    if [ -f "${selected_backup}/grok_cool.sql" ]; then
        echo "正在还原 grok_cool 数据库..."
        docker compose exec -T mysql sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" grok_cool' < "${selected_backup}/grok_cool.sql"
    fi
    
    # 还原 claude_cool 数据库
    if [ -f "${selected_backup}/claude_cool.sql" ]; then
        echo "正在还原 claude_cool 数据库..."
        docker compose exec -T mysql sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" claude_cool' < "${selected_backup}/claude_cool.sql"
    fi
    
    echo "数据库还原完成！"
}

# Main menu
while true; do
    echo -e "${GREEN}请选择操作：${NC}"
    echo -e "${YELLOW}1. 安装 Docker${NC}"
    echo -e "${YELLOW}2. 安装 AI 服务${NC}"
    echo -e "${BLUE}3. 重启服务${NC}"
    echo -e "${BLUE}4. 停止服务${NC}"
    echo -e "${MAGENTA}5. 备份数据库${NC}"
    echo -e "${MAGENTA}6. 还原数据库${NC}"
    echo -e "${RED}7. 退出${NC}"
    
    read -p "请输入选项 (1-7): " choice < /dev/tty
    
    case $choice in
        1)
            install_docker
            ;;
        2)
            install_ai_services
            ;;
        3)
            restart_services
            ;;
        4)
            stop_services
            ;;
        5)
            backup_databases
            ;;
        6)
            restore_databases
            ;;
        7)
            echo -e "${RED}正在退出...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}无效的选项，请重新输入。${NC}"
            ;;
    esac
    
    echo
done
