#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 Docker 是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose 未安装，请先安装 Docker Compose"
        exit 1
    fi
}

# 创建必要的目录
create_directories() {
    print_message "创建必要的目录..."
    mkdir -p ./data/mysql
    mkdir -p ./data/redis
    mkdir -p ./data/grok-share-server
    mkdir -p ./data/dddd-share-server
    mkdir -p ./data/chatgpt-share-server
}

# 生成 docker-compose.yml 文件
generate_docker_compose() {
    print_message "生成 docker-compose.yml 文件..."
    cat > docker-compose.yml << 'EOL'
version: '3.8'
services:
  mysql:
    image: mysql:8.0
    command:  --default-authentication-plugin=mysql_native_password --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
    volumes:
      - ./data/mysql/:/var/lib/mysql/
      - ./docker-entrypoint-initdb.d/:/docker-entrypoint-initdb.d/
    environment:
      TZ: Asia/Shanghai
      MYSQL_ROOT_PASSWORD: "123456"
  redis:
    image: redis
    restart: always
    environment:
      TZ: Asia/Shanghai
    volumes:
      - ./data/redis/:/data/
EOL

    # 添加选中的服务
    if [ "$INSTALL_GROK" = true ]; then
        cat >> docker-compose.yml << 'EOL'
  grok-share-server:
    image: lyy0709/grok-share-server:dev
    restart: always
    ports:
      - 8301:8001
    environment:
      TZ: Asia/Shanghai
      PROXY_URL: "http://proxy:8080/proxy"
      ORIGIN: "http://localhost:8300"
      CHATPROXY: "http://chatproxy:8080/proxy"
    volumes:
      - ./grok_config.yaml:/app/config.yaml
      - ./data/grok-share-server/:/app/data/
EOL
    fi

    if [ "$INSTALL_DDD" = true ]; then
        cat >> docker-compose.yml << 'EOL'
  dddd-share-server:
    image: lyy0709/dddd-share-server:dev
    restart: always
    ports:
      - 8302:8001
    environment:
      TZ: Asia/Shanghai
      PROXY_URL: "http://proxy:8080/proxy"
      ORIGIN: "http://localhost:8300"
      CHATPROXY: "https://chatproxy.com"
    volumes:
      - ./claude_config.yaml:/app/config.yaml
      - ./data/dddd-share-server/:/app/data/
EOL
    fi

    if [ "$INSTALL_GPT" = true ]; then
        cat >> docker-compose.yml << 'EOL'
  chatgpt-share-server:
    image: xyhelper/chatgpt-share-server:latest
    restart: always
    ports:
      - 8300:8001
    environment:
      TZ: Asia/Shanghai
      CHATPROXY: "https://demo.xyhelper.cn"
      AUTHKEY: "xyhelper"
    volumes:
      - ./gpt_config.yaml:/app/config.yaml
      - ./data/chatgpt-share-server/:/app/data/
EOL
    fi
}

# 主函数
main() {
    print_message "开始安装 AI 服务..."
    
    # 检查 Docker
    check_docker
    
    # 初始化变量
    INSTALL_GROK=false
    INSTALL_DDD=false
    INSTALL_GPT=false
    
    # 用户选择要安装的服务
    while true; do
        read -p "是否安装 Grok 服务? (y/n): " yn
        case $yn in
            [Yy]* ) INSTALL_GROK=true; break;;
            [Nn]* ) break;;
            * ) print_warning "请输入 y 或 n";;
        esac
    done
    
    while true; do
        read -p "是否安装 Claude (DDD) 服务? (y/n): " yn
        case $yn in
            [Yy]* ) INSTALL_DDD=true; break;;
            [Nn]* ) break;;
            * ) print_warning "请输入 y 或 n";;
        esac
    done
    
    while true; do
        read -p "是否安装 GPT 服务? (y/n): " yn
        case $yn in
            [Yy]* ) INSTALL_GPT=true; break;;
            [Nn]* ) break;;
            * ) print_warning "请输入 y 或 n";;
        esac
    done
    
    # 创建目录
    create_directories
    
    # 生成 docker-compose.yml
    generate_docker_compose
    
    # 启动服务
    print_message "正在启动服务..."
    docker-compose up -d
    
    print_message "安装完成！"
    print_message "服务状态："
    docker-compose ps
}

# 执行主函数
main 