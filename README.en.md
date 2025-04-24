# ai-mirror-all-in-one

<div align="right">
  <a href="README.md">
    <img src="https://img.shields.io/badge/-简体中文-red?style=for-the-badge&logo=markdown"/>
  </a>
</div>

## Description
**ai-mirror-allinone** is an integrated solution that combines GPT, Claude, and Grok mirrors into a single system.
These three mirrors can share MySQL and Redis instances to reduce memory usage. The project also provides bash scripts for unified management.

> Original repository addresses:
- https://github.com/xyhelper/chatgpt-share-server-deploy
- https://github.com/dddd-dddd-dddd/dddd-deploy
- https://github.com/lyy0709/grok-share-server-deploy

> **Tips for Newcomers** 🌟
> If you're new to this project, it's recommended to first check the documentation and instructions in the original repositories listed above.
> This will help you better understand the basic usage of each mirror and make the most of this integrated solution.

## Special Thanks
Thanks to **栋哥** and **傻傻大佬** for their contributions to the GPT, Claude, and Grok mirrors.

## Feature List
    - Docker installation
    - AI mirror installation (optional)
    - Database backup
    - Database restoration
    - Automatic daily database backup
    - Automatic file backup to Cloudflare R2 storage

## Quick Installation Script

```
curl -sSfL https://raw.githubusercontent.com/xiaomifengD/ai-mirror-all-in-one/refs/heads/main/quick_install.sh | bash
```
![Interface](menu.png)

After installation, you can maintain the project using:
```
bash mirror.sh
```

## Admin Dashboard URLs

| Service | Dashboard URL | Default Username | Default Password |
|---------|--------------|------------------|------------------|
| **Grok** | `http://domain/lyy0709` | `admin` | `123456` |
| **Claude** | `http://domain/lyy0709` | `admin` | `123456` |
| **GPT** | `http://domain/xyhelper` | `admin` | `123456` |

> Please change the default password after logging in to ensure security

## Contact
Telegram: [Join ai-mirror-allinone group](https://t.me/+okyKNxjR3_U1MDM1)

<table>
  <tr>
    <td><img src="https://raw.githubusercontent.com/xiaomifengD/xiaomifengD/refs/heads/main/img/qun.jpg" width="300"/></td>
    <td><img src="https://raw.githubusercontent.com/xiaomifengD/xiaomifengD/refs/heads/main/img/contactme.jpg" width="300"/></td>
  </tr>
</table> 