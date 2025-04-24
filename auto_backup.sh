#!/bin/bash

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 切换到脚本所在目录
cd "$SCRIPT_DIR"

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