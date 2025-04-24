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
        echo -e "${GREEN}Docker 已安装。${NC}"
        docker --version
        
        # 检查是否存在 docker-compose.yml 文件
        if [ -f "docker-compose.yml" ]; then
            echo
            echo -e "${BLUE}正在检查 AI 服务状态...${NC}"
            echo -e "${YELLOW}当前 AI 服务状态：${NC}"
            docker compose  ps
        fi
        
        return 0
    else
        echo -e "${RED}Docker 未安装。${NC}"
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
    backup_dir="./backups/sql/backup-${timestamp}"
    mkdir -p "${backup_dir}"
    
    echo "正在备份数据库..."
    echo "备份文件将保存在: ${backup_dir}"
    
    # 备份 cool 数据库
    echo "正在备份 cool 数据库..."
    docker compose exec  mysql sh -c 'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" cool' > "${backup_dir}/cool.sql"
    
    # 备份 grok_cool 数据库
    echo "正在备份 grok_cool 数据库..."
    docker compose exec  mysql sh -c 'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" grok_cool' > "${backup_dir}/grok_cool.sql"
    
    # 备份 claude_cool 数据库
    echo "正在备份 claude_cool 数据库..."
    docker compose exec  mysql sh -c 'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" claude_cool' > "${backup_dir}/claude_cool.sql"
    
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
    backup_dirs=($(ls -d ./backups/sql/backup-* 2>/dev/null))
    
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
        docker compose exec  -T mysql sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" cool' < "${selected_backup}/cool.sql"
    fi
    
    # 还原 grok_cool 数据库
    if [ -f "${selected_backup}/grok_cool.sql" ]; then
        echo "正在还原 grok_cool 数据库..."
        docker compose exec  -T mysql sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" grok_cool' < "${selected_backup}/grok_cool.sql"
    fi
    
    # 还原 claude_cool 数据库
    if [ -f "${selected_backup}/claude_cool.sql" ]; then
        echo "正在还原 claude_cool 数据库..."
        docker compose exec  -T mysql sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" claude_cool' < "${selected_backup}/claude_cool.sql"
    fi
    
    echo "数据库还原完成！"
}

# Function to setup auto backup
setup_auto_backup() {
    if ! check_docker; then
        echo "Docker 未安装，请先安装 Docker。"
        return 1
    fi
    
    if [ ! -f "docker-compose.yml" ]; then
        echo "未找到 docker-compose.yml 文件，请先安装 AI 服务。"
        return 1
    fi

    # 检查是否已经设置了自动备份
    crontab -l 2>/dev/null | grep -q "auto_backup.sh"
    if [ $? -eq 0 ]; then
        echo -e "${YELLOW}检测到已经设置了自动备份任务。${NC}"
        read -p "是否要取消自动备份？(y/n): " cancel
        if [[ $cancel =~ ^[Yy]$ ]]; then
            # 删除现有的自动备份任务
            (crontab -l 2>/dev/null | grep -v "auto_backup.sh") | crontab -
            echo -e "${GREEN}已取消自动备份任务。${NC}"
        fi
        return 0
    fi

    # 设置自动备份
    echo -e "${BLUE}正在设置每天凌晨4点自动备份...${NC}"
    
    # 获取脚本所在目录的绝对路径
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    
    # 确保备份脚本有执行权限
    chmod +x "${SCRIPT_DIR}/auto_backup.sh"
    
    # 添加定时任务
    (crontab -l 2>/dev/null; echo "0 4 * * * ${SCRIPT_DIR}/auto_backup.sh >> ${SCRIPT_DIR}/backups/auto_backup.log 2>&1") | crontab -
    
    echo -e "${GREEN}自动备份已设置完成！${NC}"
    echo -e "${BLUE}系统将在每天凌晨4点自动进行数据库备份${NC}"
    echo -e "${YELLOW}备份日志将保存在 backups/auto_backup.log${NC}"
}

# Function to configure R2 settings
configure_r2() {
    if [ ! -f "config.env.example" ]; then
        echo -e "${RED}错误：未找到配置模板文件 config.env.example${NC}"
        return 1
    fi

    # 如果配置文件不存在，从模板创建
    if [ ! -f "config.env" ]; then
        cp config.env.example config.env
        echo -e "${GREEN}已创建配置文件 config.env${NC}"
    fi

    # 读取当前配置
    if [ -f "config.env" ]; then
        source config.env
    fi

    # 检查 AWS CLI
    if ! command -v aws &> /dev/null; then
        echo -e "${YELLOW}未检测到 AWS CLI${NC}"
        echo -e "${BLUE}是否要安装 AWS CLI？(y/n)${NC}"
        read install_aws
        if [[ $install_aws =~ ^[Yy]$ ]]; then
            chmod +x install_awscli.sh
            ./install_awscli.sh
            if [ $? -ne 0 ]; then
                echo -e "${RED}AWS CLI 安装失败${NC}"
                return 1
            fi
        else
            echo -e "${YELLOW}跳过 AWS CLI 安装。注意：没有 AWS CLI 将无法使用 R2 上传功能。${NC}"
        fi
    fi

    echo -e "${BLUE}配置 Cloudflare R2 设置${NC}"
    echo -e "${YELLOW}请输入以下信息（如果要保持当前值，直接按回车）：${NC}"
    
    # R2 Endpoint
    echo -n "R2 Endpoint [${R2_ENDPOINT:-未设置}]: "
    read r2_endpoint
    if [ -n "$r2_endpoint" ]; then
        sed -i "s|^R2_ENDPOINT=.*|R2_ENDPOINT=$r2_endpoint|" config.env
    fi

    # Access Key ID
    echo -n "Access Key ID [${R2_ACCESS_KEY_ID:-未设置}]: "
    read access_key
    if [ -n "$access_key" ]; then
        sed -i "s|^R2_ACCESS_KEY_ID=.*|R2_ACCESS_KEY_ID=$access_key|" config.env
    fi

    # Secret Access Key
    echo -n "Secret Access Key [${R2_SECRET_ACCESS_KEY:-未设置}]: "
    read secret_key
    if [ -n "$secret_key" ]; then
        sed -i "s|^R2_SECRET_ACCESS_KEY=.*|R2_SECRET_ACCESS_KEY=$secret_key|" config.env
    fi

    # Bucket Name
    echo -n "Bucket Name [${R2_BUCKET:-未设置}]: "
    read bucket
    if [ -n "$bucket" ]; then
        sed -i "s|^R2_BUCKET=.*|R2_BUCKET=$bucket|" config.env
    fi

    echo -e "${GREEN}R2 配置已更新！${NC}"
    
    # 测试配置
    if [ -n "$R2_ENDPOINT" ] && [ -n "$R2_ACCESS_KEY_ID" ] && [ -n "$R2_SECRET_ACCESS_KEY" ] && [ -n "$R2_BUCKET" ]; then
        echo -e "${BLUE}正在测试 R2 连接...${NC}"
        export AWS_ACCESS_KEY_ID="$R2_ACCESS_KEY_ID"
        export AWS_SECRET_ACCESS_KEY="$R2_SECRET_ACCESS_KEY"
        export AWS_DEFAULT_REGION="$R2_REGION"
        
        if aws s3 ls "s3://$R2_BUCKET" --endpoint-url "$R2_ENDPOINT" &> /dev/null; then
            echo -e "${GREEN}R2 连接测试成功！${NC}"
        else
            echo -e "${RED}R2 连接测试失败，请检查配置${NC}"
        fi
    fi
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
    echo -e "${CYAN}7. 设置自动备份${NC}"
    echo -e "${CYAN}8. 配置 R2 自动上传${NC}"
    echo -e "${RED}9. 退出${NC}"
    
    read -p "请输入选项 (1-9): " choice < /dev/tty
    
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
            setup_auto_backup
            ;;
        8)
            configure_r2
            ;;
        9)
            echo -e "${RED}正在退出...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}无效的选项，请重新输入。${NC}"
            ;;
    esac
    
    echo
done
