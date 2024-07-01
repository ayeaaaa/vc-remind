#!/bin/bash

# 设置系统时区为东八区
echo "设置时区为东八区"
sudo timedatectl set-timezone Asia/Shanghai

# 获取当前脚本所在的目录
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# 安装 NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# 使 NVM 在当前 Shell 中生效
source ~/.bashrc

# 安装最新版本的 Node.js
nvm install node

# 进入项目目录
cd "$DIR"

# 安装 Node.js 依赖
npm install express sqlite3 path axios telegraf node-schedule

# 输出安装完成信息
echo "依赖安装完成。"

# 询问用户是否启动服务
read -p "是否启动服务？(y/n): " choice

if [ "$choice" = "y" ]; then
    # 启动 Node.js 服务，并后台运行
    nohup node server.js > server.log &
    echo "Node.js 服务已启动，日志文件：$DIR/server.log"

    # 添加自动启动服务的功能
    read -p "是否设置为系统启动时自动启动？(y/n): " auto_start_choice
    if [ "$auto_start_choice" = "y" ]; then
        # 创建 systemd 服务文件
        cat << EOF > /etc/systemd/system/node-app.service
[Unit]
Description=Node.js Application
Documentation=https://your-documentation-url.com
After=network.target

[Service]
Environment=NODE_ENV=production
Type=simple
ExecStart=$DIR/server.js
Restart=always
RestartSec=10
User=$USER
Group=$USER
WorkingDirectory=$DIR

[Install]
WantedBy=multi-user.target
EOF

        # 重新加载 systemd 配置文件
        systemctl daemon-reload

        # 启用服务，使其开机自启动
        systemctl enable node-app

        echo "已设置为系统启动时自动启动。"
    else
        echo "未设置为系统启动时自动启动。"
    fi
else
    echo "未启动服务。"
fi
