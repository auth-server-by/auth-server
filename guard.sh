#!/system/bin/sh
VERSION="v2.7"
VERIFY_URL="https://cdn.jsdelivr.net/gh/auth-server-by/auth-server-by/version.txt"

echo -e "\033[1;38;5;213m
╭━━━━━━━━━━━━━━━━━━━━━━━━━╮
│  ✧二次元守护·冰心虚拟容器✧│
│        v2.7 正式版        │
│ 守护：游戏+夜猫子(虚拟内) │
╰━━━━━━━━━━━━━━━━━━━━━━━━━╯
\033[0m"
sleep 1

check_version(){
    remote_ver=$(curl -s --connect-timeout 8 $VERIFY_URL | tr -d '\n\r')
    if [ "$remote_ver" != "$VERSION" ];then
        echo -e "\033[1;31m💔版本已永久失效，请更新正式版\033[0m"
        exit 1
    fi
}

float_check(){
    if ! dumpsys window | grep -q "SYSTEM_ALERT_WINDOW granted";then
        echo -e "\033[1;35m💜请开启悬浮窗权限~\033[0m"
        am start -a android.settings.action.MANAGE_OVERLAY_PERMISSION
        exit 1
    fi
}

check_version
float_check
bash bootstrap.sh
