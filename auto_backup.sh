#!/bin/bash

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 切换到脚本所在目录
cd "$SCRIPT_DIR"

# 检查是否启用了 R2 上传
if [ -f "config.env" ]; then
    source config.env
fi

# 获取当前时间戳
timestamp=$(date +%Y%m%d-%H%M%S)

# 创建本次备份的目录
backup_dir="./backups/sql/backup-${timestamp}"
mkdir -p "${backup_dir}"

echo "开始自动备份数据库..."
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

echo "自动备份完成！"
echo "备份文件保存在: ${backup_dir}"

# 如果配置了 R2，则上传备份
if [ -n "$R2_ENDPOINT" ] && [ -n "$R2_ACCESS_KEY_ID" ] && [ -n "$R2_SECRET_ACCESS_KEY" ] && [ -n "$R2_BUCKET" ]; then
    echo "检测到 R2 配置，开始上传备份..."
    chmod +x r2_upload.sh
    ./r2_upload.sh "$backup_dir"
fi 