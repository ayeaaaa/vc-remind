#!/bin/bash
# 设置时区为东八区
export TZ="Asia/Shanghai"
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

# 安装 pm2
npm install -g pm2

# 输出安装完成信息
echo "依赖安装完成。"

# 询问用户操作选项
echo "请选择一个操作："
echo "1. 启动服务"
echo "2. 停止服务"
echo "3. 设置开机自启"
read -p "输入选项 (1/2/3): " choice

case "$choice" in
    1)
        # 启动 Node.js 服务，并使用 pm2 后台运行
        pm2 start server.js --name my-app
        echo "Node.js 服务已启动。"
        ;;
    2)
        # 停止 Node.js 服务
        pm2 stop my-app
        echo "Node.js 服务已停止。"
        ;;
    3)
        # 设置开机自启
        pm2 startup
        pm2 save
        echo "开机自启已设置。"
        ;;
    *)
        echo "无效选项。"
        ;;
esac
