# ai-mirror-all-in-one

<div align="right">
  <a href="README.en.md">
    <img src="https://img.shields.io/badge/-English-blue?style=for-the-badge&logo=markdown"/>
  </a>
</div>

## 说明
**ai-mirror-allinone** 是集成了  gpt,克劳德,grok 三种镜像为一体的缝合怪，
三个镜像可以共享 mysql 和 redis实例,减少了内存占用，还提供了bash脚本方便统一管理

> 三个仓库原版地址:
- https://github.com/xyhelper/chatgpt-share-server-deploy
- https://github.com/dddd-dddd-dddd/dddd-deploy
- https://github.com/lyy0709/grok-share-server-deploy

> **新手提示** 🌟
> 如果你是新手，建议先查看上述原仓库的使用说明和文档，了解各个镜像的基本使用方法。
> 这将帮助你更好地理解和使用本项目的集成功能。

## 特别感谢
感谢**栋哥**和**傻傻大佬**在gpt,克劳德,grok 镜像上面的奉献

## 功能清单
    - 安装docker
    - 安装ai镜像(可选)
    - 备份数据库
    - 还原数据库
    - 每天自动备份数据库
    - 自动备份文件上传到cloudflare R2 文件存储
## 快速安装脚本

```
curl -sSfL https://raw.githubusercontent.com/xiaomifengD/ai-mirror-all-in-one/refs/heads/main/quick_install.sh | bash
```
![使用界面](menu.png)

后续可以用
```
bash mirror.sh
```
维护项目

## 后台管理地址

| 服务 | 后台地址 | 默认账号 | 默认密码 |
|------|---------|---------|---------|
| **Grok** | `http://域名/lyy0709` | `admin` | `123456` |
| **Claude** | `http://域名/lyy0709` | `admin` | `123456` |
| **GPT** | `http://域名/xyhelper` | `admin` | `123456` |

> 请登录后及时修改默认密码以确保安全

## 联系我
Telegram: [加入 ai-mirror-allinone 群组](https://t.me/+okyKNxjR3_U1MDM1)

<table>
  <tr>
    <td><img src="https://raw.githubusercontent.com/xiaomifengD/xiaomifengD/refs/heads/main/img/qun.jpg" width="300"/></td>
    <td><img src="https://raw.githubusercontent.com/xiaomifengD/xiaomifengD/refs/heads/main/img/contactme.jpg" width="300"/></td>
  </tr>
</table>