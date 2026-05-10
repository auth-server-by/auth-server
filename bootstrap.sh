#!/system/bin/sh
echo -e "\033[1;38;5;45m💫正在初始化冰心4.2虚拟容器守护环境...\033[0m"
sleep 0.7
echo -e "\033[1;38;5;45m💫适配虚拟沙盒进程捕获...\033[0m"
sleep 0.7
echo -e "\033[1;38;5;82m💚虚拟容器守护模块加载完成！\033[0m"

bash cmd.sh &
bash core.sh
