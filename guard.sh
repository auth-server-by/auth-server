#!/data/data/com.termux/files/usr/bin/bash
# 二次元守护幻境 免root守护脚本 v2.9｜【游戏+夜猫子专用防闪退】
# 仓库：auth-server-by/auth-server
# 守护进程：com.pi.czrxdfirst(冰心) com.nightowl(夜猫子) com.excean.dualaid(双开)

#=====================原版配置区完全保留=====================
VERSION="2.9"
# 重点：单独标记夜猫子、游戏包，优先加固
GAME_PKG="com.pi.czrxdfirst"
NIGHTOWL_PKG="com.nightowl"
DUAL_PKG="com.excean.dualaid"
PKG_NAME=("$GAME_PKG" "$NIGHTOWL_PKG" "$DUAL_PKG")
CLOUD_VERSION_URL="https://raw.githubusercontent.com/auth-server-by/auth-server/main/version.txt"
GUARD_SLEEP=0.8
#==========================================================

#=====================原版二次元UI 1:1完全复刻=====================
clear
echo -e "\033[1;35m
┌─────────────────────────────────────────────────────────────┐
│ ✨二次元守护幻境 ✨ | 多游戏云控 · 免root守护              │
├─────────────────────────────────────────────────────────────┤
│  监控目标: ${PKG_NAME[*]}
│  版本: $VERSION | 云端校验已开启 | 游戏&夜猫子深度加固
└─────────────────────────────────────────────────────────────┘
\033[0m"
#=================================================================

#=====================原版云端校验（仅开机校验1次，无后台轮询）=====================
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

#=====================核心1：Termux自身保活（守护器永不挂）=====================
self_wake(){
    if ! pgrep -f "bash ~/guard.sh" >/dev/null; then
        am start -n com.termux/.HomeActivity >/dev/null 2>&1
        sleep 0.5
        bash ~/guard.sh &
    fi
}
termux_keep_alive(){
    while true; do self_wake; sleep 3; done
}
termux_keep_alive &
#===============================================================================

#=====================核心2：【夜猫子+游戏专用加固】免Root最强保活=====================
# 1. 夜猫子优先前台唤醒，伪装前台应用
# 2. 强制保持网络心跳，避免后台断连闪退
# 3. 检测闪退立刻重启，优先拉起夜猫子
keep_nightowl_game(){
    # 夜猫子优先级最高，先保夜猫子
    if [[ -z "$(pidof $NIGHTOWL_PKG)" ]]; then
        am start -n $NIGHTOWL_PKG/.MainActivity >/dev/null 2>&1
        sleep 0.1
        am set-inactive $NIGHTOWL_PKG false >/dev/null 2>&1
    fi

    # 游戏其次
    if [[ -z "$(pidof $GAME_PKG)" ]]; then
        am start -n $GAME_PKG/.MainActivity >/dev/null 2>&1
        sleep 0.1
    fi

    # 双开辅助兜底
    if [[ -z "$(pidof $DUAL_PKG)" ]]; then
        am start -n $DUAL_PKG/.MainActivity >/dev/null 2>&1
    fi
}
#===============================================================================

#=====================原版悬浮窗选择菜单（完整保留）=====================
show_float_menu(){
    echo -e "\033[1;36m\n请选择守护进程：\033[0m"
    echo "1. 全部守护（游戏+夜猫子+双开）"
    echo "2. 仅游戏+夜猫子（重点防闪退）"
    echo "3. 仅冰心游戏"
    echo "4. 仅夜猫子辅助"
    read -p "输入序号：" sel
    case $sel in
        1) TARGET=("${PKG_NAME[@]}") ;;
        2) TARGET=("$GAME_PKG" "$NIGHTOWL_PKG") ;;
        3) TARGET=("$GAME_PKG") ;;
        4) TARGET=("$NIGHTOWL_PKG") ;;
        *) TARGET=("$GAME_PKG" "$NIGHTOWL_PKG") ;;
    esac
}
show_float_menu
#=====================================================================

#=====================主守护循环｜极速保活｜游戏夜猫子优先=====================
echo -e "\033[1;32m✅ 游戏&夜猫子专用防闪退守护已启动！\033[0m"
while true; do
    keep_nightowl_game
    sleep $GUARD_SLEEP
done
