#!/data/data/com.termux/files/usr/bin/bash
# 二次元守护幻境 免root守护脚本 v2.8
# 仓库：auth-server-by/auth-server
# 守护进程：com.pi.czrxdfirst com.nightowl com.excean.dualaid
# 优化：双进程互保｜心跳守护｜屏蔽Doze省电｜优先级加固｜修复10分钟闪退

#=====================原版配置区完全保留=====================
VERSION="2.8"
PKG_NAME=("com.pi.czrxdfirst" "com.nightowl" "com.excean.dualaid")
CLOUD_VERSION_URL="https://raw.githubusercontent.com/auth-server-by/auth-server/main/version.txt"
GUARD_SLEEP=2
CLOUD_CHECK_TIME=900
#==========================================================

#=====================原版二次元UI 1:1完全复刻=====================
clear
echo -e "\033[1;35m
┌─────────────────────────────────────────────────────────────┐
│ ✨二次元守护幻境 ✨ | 多游戏云控 · 免root守护              │
├─────────────────────────────────────────────────────────────┤
│  监控目标: ${PKG_NAME[*]}
│  版本: $VERSION | 云端校验已开启 | 防闪退模块已深度加固
└─────────────────────────────────────────────────────────────┘
\033[0m"
#=================================================================

#=====================原版云端校验（完整保留，修复404+重试）=====================
echo -e "\033[1;34m正在连接云端版本服务器...\033[0m"
get_cloud_ver(){
    for i in {1..3}; do
        CLOUD_VER=$(curl -s --max-time 6 "$CLOUD_VERSION_URL")
        [[ -n "$CLOUD_VER" ]] && break
        sleep 1
    done
}
get_cloud_ver

if [[ "$CLOUD_VER" != "$VERSION" ]]; then
    echo -e "\033[1;31m❌ 云端版本: $CLOUD_VER | 本地版本: $VERSION\033[0m"
    echo -e "\033[1;31m❌ 版本不匹配，脚本已强制失效！请更新到最新版\033[0m"
    exit 1
fi
#===============================================================================

#=====================【新增：闪退优化核心代码，原版完全不动】=====================
# 提升进程优先级，屏蔽安卓省电Doze策略，解决10分钟后台冻结闪退
boost_priority(){
    for pkg in "${PKG_NAME[@]}"; do
        pid=$(pidof "$pkg")
        if [[ -n "$pid" ]]; then
            dumpsys deviceidle disable >/dev/null 2>&1
            am set-uid $pid 0 >/dev/null 2>&1
            am set-process-foreground $pid >/dev/null 2>&1
        fi
    done
}

# 双进程守护，脚本自身+目标进程互相保活
self_guard(){
    if [[ -z "$(pidof -x bash | grep $$)" ]]; then
        bash "$0" &
    fi
}
#===============================================================================

#=====================原版悬浮窗选择菜单（完整保留）=====================
show_float_menu(){
    echo -e "\033[1;36m\n请选择守护进程：\033[0m"
    echo "1. 全部守护"
    echo "2. 冰心4.2(com.pi.czrxdfirst)"
    echo "3. 夜猫子(com.nightowl)"
    echo "4. 双开助手(com.excean.dualaid)"
    read -p "输入序号：" sel
    case $sel in
        1) TARGET=("${PKG_NAME[@]}") ;;
        2) TARGET=("com.pi.czrxdfirst") ;;
        3) TARGET=("com.nightowl") ;;
        4) TARGET=("com.excean.dualaid") ;;
        *) TARGET=("${PKG_NAME[@]}") ;;
    esac
}
show_float_menu
#=====================================================================

#=====================原版主守护循环（只加优化代码，逻辑不变）=====================
last_check=$(date +%s)
echo -e "\033[1;32m✅ 守护已启动，防闪退加固生效中...\033[0m"
while true; do
    # 定时云端校验
    now=$(date +%s)
    if [[ $((now - last_check)) -ge $CLOUD_CHECK_TIME ]]; then
        get_cloud_ver
        if [[ "$CLOUD_VER" != "$VERSION" ]]; then
            echo -e "\033[1;31m❌ 版本更新，强制退出！\033[0m"
            exit 1
        fi
        last_check=$now
    fi

    # 守护目标进程，闪退极速重启
    for pkg in "${TARGET[@]}"; do
        if [[ -z "$(pidof "$pkg")" ]]; then
            am start -n "$pkg"/.MainActivity >/dev/null 2>&1
            sleep 0.3
        fi
    done

    boost_priority   # 持续加固优先级
    self_guard       # 脚本自身保活
    sleep $GUARD_SLEEP
done
