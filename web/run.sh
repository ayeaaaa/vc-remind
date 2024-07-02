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