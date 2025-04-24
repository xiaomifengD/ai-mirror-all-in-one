#!/bin/bash

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 切换到脚本所在目录
cd "$SCRIPT_DIR"

# 检查配置文件是否存在
if [ ! -f "config.env" ]; then
    echo "错误：未找到配置文件 config.env"
    echo "请复制 config.env.example 为 config.env 并填写相关配置"
    exit 1
fi

# 加载配置
source config.env

# 检查必要的配置是否存在
if [ -z "$R2_ENDPOINT" ] || [ -z "$R2_ACCESS_KEY_ID" ] || [ -z "$R2_SECRET_ACCESS_KEY" ] || [ -z "$R2_BUCKET" ]; then
    echo "错误：R2 配置不完整，请检查 config.env 文件"
    exit 1
fi

# 检查是否安装了 AWS CLI
if ! command -v aws &> /dev/null; then
    echo "错误：未安装 AWS CLI"
    echo "请按照说明安装 AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

# 检查参数
if [ -z "$1" ]; then
    echo "使用方法: $0 <backup_directory>"
    exit 1
fi

BACKUP_DIR="$1"

# 检查备份目录是否存在
if [ ! -d "$BACKUP_DIR" ]; then
    echo "错误：备份目录不存在: $BACKUP_DIR"
    exit 1
fi

# 配置 AWS CLI 环境变量
export AWS_ACCESS_KEY_ID="$R2_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$R2_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="$R2_REGION"

# 上传文件到 R2
echo "开始上传备份文件到 Cloudflare R2..."

# 获取目录名称（用作 R2 中的前缀）
DIR_NAME=$(basename "$BACKUP_DIR")

# 上传所有 SQL 文件
for sql_file in "$BACKUP_DIR"/*.sql; do
    if [ -f "$sql_file" ]; then
        file_name=$(basename "$sql_file")
        echo "正在上传: $file_name"
        aws s3 cp "$sql_file" "s3://$R2_BUCKET/$DIR_NAME/$file_name" \
            --endpoint-url "$R2_ENDPOINT" \
            --quiet
        
        if [ $? -eq 0 ]; then
            echo "✓ 成功上传: $file_name"
        else
            echo "✗ 上传失败: $file_name"
        fi
    fi
done

echo "上传完成！" 