#!/bin/bash
set -e

## 克隆仓库到本地
echo "clone repository..."
git clone --depth=1 https://github.com/xiaomifengD/ai-mirror-all-in-one.git ai-mirror-all-in-one


## 进入目录
cd ai-mirror-all-in-one

chmod +x mirror.sh
./mirror.sh




