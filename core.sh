#!/system/bin/sh
GAME_PKG="com.tencent.tmgp.supernatural"
CAT_PKG="com.yemaozi.helper"
GUARD_INTERVAL=2

echo -e "\033[1;38;5;213m💜二次元守护已就绪，监听虚拟容器内进程...\033[0m"

while true;do
    GAME_PID=$(ps -A | grep -E "${GAME_PKG}|bingxin" | grep -v grep | awk '{print $2}')
    CAT_PID=$(ps -A | grep -E "${CAT_PKG}|bingxin" | grep -v grep | awk '{print $2}')

    if [ -z "$GAME_PID" ];then
        echo -e "\033[1;31m💔虚拟容器内游戏闪退，容器内重启中...\033[0m"
        am start --user 999 -n $GAME_PKG/com.tencent.tmgp.supernatural.MainActivity >/dev/null 2>&1
        sleep 3
    fi

    if [ -z "$CAT_PID" ];then
        echo -e "\033[1;31m💔虚拟容器内夜猫子闪退，容器内重启中...\033[0m"
        am start --user 999 -n $CAT_PKG/.MainActivity >/dev/null 2>&1
        sleep 3
    fi

    echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
    sleep $GUARD_INTERVAL
done
