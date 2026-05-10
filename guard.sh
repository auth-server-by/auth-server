#!/system/bin/sh
VERSION="v2.7"
# 版本校验同样使用加速镜像，防止云端校验超时
VERIFY_URL="https://mirror.ghproxy.com/https://raw.githubusercontent.com/auth-server-by/auth-server-by/main/version.txt"

echo -e "\033[1;38;5;213m
╭━━━━━━━━━━━━━━━━━━━━━━━━━╮
│  ✧二次元守护·冰心虚拟容器✧│
│        v2.7 正式版        │
│ 守护：游戏+夜猫子(虚拟内) │
╰━━━━━━━━━━━━━━━━━━━━━━━━━╯
\033[0m"
sleep 1

check_version(){
    remote_ver=$(curl -s --connect-timeout 5 $VERIFY_URL | tr -d '\n\r')
    if [ "$remote_ver" != "$VERSION" ];then
        echo -e "\033[1;31m💔版本已失效，请更新二次元正式版\033[0m"
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
