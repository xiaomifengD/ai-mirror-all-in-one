#!/bin/bash

# 定义颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo -e "${BLUE}开始安装 AWS CLI...${NC}"

# 检查是否已安装 unzip
if ! command -v unzip &> /dev/null; then
    echo -e "${YELLOW}未检测到 unzip，正在安装...${NC}"
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y unzip
    elif command -v yum &> /dev/null; then
        sudo yum install -y unzip
    else
        echo -e "${RED}无法安装 unzip，请手动安装后重试${NC}"
        exit 1
    fi
fi

# 检查是否已安装 gpg
if ! command -v gpg &> /dev/null; then
    echo -e "${YELLOW}未检测到 gpg，正在安装...${NC}"
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y gnupg
    elif command -v yum &> /dev/null; then
        sudo yum install -y gnupg2
    else
        echo -e "${RED}无法安装 gpg，请手动安装后重试${NC}"
        exit 1
    fi
fi

# 创建临时目录
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# 下载 AWS CLI
echo -e "${BLUE}下载 AWS CLI 安装包...${NC}"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# 下载签名文件
echo -e "${BLUE}下载签名文件...${NC}"
curl -o awscliv2.sig https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip.sig

# 创建并导入 AWS CLI 公钥
echo -e "${BLUE}导入 AWS CLI 公钥...${NC}"
cat > aws_cli_public_key.asc << 'EOF'
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBF2Cr7UBEADJZHcgusOJl7ENSyumXh85z0TRV0xJorM2B/JL0kHOyigQluUG
ZMLhENaG0bYatdrKP+3H91lvK050pXwnO/R7fB/FSTouki4ciIx5OuLlnJZIxSzx
PqGl0mkxImLNbGWoi6Lto0LYxqHN2iQtzlwTVmq9733zd3XfcXrZ3+LblHAgEt5G
TfNxEKJ8soPLyWmwDH6HWCnjZ/aIQRBTIQ05uVeEoYxSh6wOai7ss/KveoSNBbYz
gbdzoqI2Y8cgH2nbfgp3DSasaLZEdCSsIsK1u05CinE7k2qZ7KgKAUIcT/cR/grk
C6VwsnDU0OUCideXcQ8WeHutqvgZH1JgKDbznoIzeQHJD238GEu+eKhRHcz8/jeG
94zkcgJOz3KbZGYMiTh277Fvj9zzvZsbMBCedV1BTg3TqgvdX4bdkhf5cH+7NtWO
lrFj6UwAsGukBTAOxC0l/dnSmZhJ7Z1KmEWilro/gOrjtOxqRQutlIqG22TaqoPG
fYVN+en3Zwbt97kcgZDwqbuykNt64oZWc4XKCa3mprEGC3IbJTBFqglXmZ7l9ywG
EEUJYOlb2XrSuPWml39beWdKM8kzr1OjnlOm6+lpTRCBfo0wa9F8YZRhHPAkwKkX
XDeOGpWRj4ohOx0d2GWkyV5xyN14p2tQOCdOODmz80yUTgRpPVQUtOEhXQARAQAB
tCFBV1MgQ0xJIFRlYW0gPGF3cy1jbGlAYW1hem9uLmNvbT6JAlQEEwEIAD4CGwMF
CwkIBwIGFQoJCAsCBBYCAwECHgECF4AWIQT7Xbd/1cEYuAURraimMQrMRnJHXAUC
ZqFYbwUJCv/cOgAKCRCmMQrMRnJHXKYuEAC+wtZ611qQtOl0t5spM9SWZuszbcyA
0xBAJq2pncnp6wdCOkuAPu4/R3UCIoD2C49MkLj9Y0Yvue8CCF6OIJ8L+fKBv2DI
yWZGmHL0p9wa/X8NCKQrKxK1gq5PuCzi3f3SqwfbZuZGeK/ubnmtttWXpUtuU/Iz
VR0u/0sAy3j4uTGKh2cX7XnZbSqgJhUk9H324mIJiSwzvw1Ker6xtH/LwdBeJCck
bVBdh3LZis4zuD4IZeBO1vRvjot3Oq4xadUv5RSPATg7T1kivrtLCnwvqc6L4LnF
0OkNysk94L3LQSHyQW2kQS1cVwr+yGUSiSp+VvMbAobAapmMJWP6e/dKyAUGIX6+
2waLdbBs2U7MXznx/2ayCLPH7qCY9cenbdj5JhG9ibVvFWqqhSo22B/URQE/CMrG
+3xXwtHEBoMyWEATr1tWwn2yyQGbkUGANneSDFiTFeoQvKNyyCFTFO1F2XKCcuDs
19nj34PE2TJilTG2QRlMr4D0NgwLLAMg2Los1CK6nXWnImYHKuaKS9LVaCoC8vu7
IRBik1NX6SjrQnftk0M9dY+s0ZbAN1gbdjZ8H3qlbl/4TxMdr87m8LP4FZIIo261
Eycv34pVkCePZiP+dgamEiQJ7IL4ZArio9mv6HbDGV6mLY45+l6/0EzCwkI5IyIf
BfWC9s/USgxchg==
=ptgS
-----END PGP PUBLIC KEY BLOCK-----
EOF

gpg --import aws_cli_public_key.asc

# 验证签名
echo -e "${BLUE}验证安装包签名...${NC}"
if gpg --verify awscliv2.sig awscliv2.zip; then
    echo -e "${GREEN}签名验证成功${NC}"
else
    echo -e "${RED}签名验证失败，终止安装${NC}"
    cd "$SCRIPT_DIR"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 解压安装包
echo -e "${BLUE}解压安装包...${NC}"
unzip -q awscliv2.zip

# 检查是否已安装 AWS CLI
if command -v aws &> /dev/null; then
    echo -e "${YELLOW}检测到已安装 AWS CLI，执行更新...${NC}"
    # 获取现有安装路径
    current_bin_path=$(dirname $(which aws))
    current_install_path=$(dirname $(dirname $(readlink -f $(which aws))))
    
    sudo ./aws/install --bin-dir "$current_bin_path" --install-dir "$current_install_path" --update
else
    echo -e "${BLUE}执行新安装...${NC}"
    sudo ./aws/install
fi

# 清理临时文件
cd "$SCRIPT_DIR"
rm -rf "$TEMP_DIR"

# 验证安装
if aws --version; then
    echo -e "${GREEN}AWS CLI 安装/更新成功！${NC}"
else
    echo -e "${RED}AWS CLI 安装/更新失败，请检查错误信息${NC}"
    exit 1
fi 