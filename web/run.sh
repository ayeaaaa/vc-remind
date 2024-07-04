export TZ="Asia/Shanghai"
# 获取当前脚本所在的目录
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


# 重新加载当前 Shell 的配置，以便使用 nvm
source ~/.bashrc

# 加载 nvm 环境设置
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# 检查 nvm 是否成功加载
if command -v nvm &> /dev/null; then
    echo "nvm 已加载。"
else
    echo "无法找到 nvm 命令，请检查安装过程中的问题。"
    exit 1  # 如果无法找到 nvm 命令，退出脚本并返回错误码
fi


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
