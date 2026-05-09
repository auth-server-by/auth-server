#!/data/data/com.termux/files/usr/bin/bash
# 二次元守护幻境 免root守护脚本 v2.9｜极致终极版｜修复跳过菜单无限循环
# 仓库：auth-server-by/auth-server
# 守护进程：com.pi.czrxdfirst(冰心游戏) com.nightowl(夜猫子) com.excean.dualaid(双开)

#=====================极致配置区｜全参数拉满=====================
VERSION="2.9"
GAME_PKG="com.pi.czrxdfirst"
NIGHTOWL_PKG="com.nightowl"
DUAL_PKG="com.excean.dualaid"
PKG_NAME=("$GAME_PKG" "$NIGHTOWL_PKG" "$DUAL_PKG")
CLOUD_VERSION_URL="https://ghfast.top/https://raw.githubusercontent.com/auth-server-by/auth-server/main/version.txt"
GUARD_SLEEP=0.9
NOISE_CHECK_INTERVAL=120
#==========================================================

#=====================原版二次元UI 1:1完整复刻=====================
clear
echo -e "\033[1;35m
┌─────────────────────────────────────────────────────────────┐
│ ✨二次元守护幻境 ✨ | 多游戏云控 · 免root守护              │
├─────────────────────────────────────────────────────────────┤
│  监控目标: ${PKG_NAME[*]}
│  版本: $VERSION | 云端校验已开启 | 极致终极防闪退加固
└─────────────────────────────────────────────────────────────┘
\033[0m"
#=================================================================

#=====================云端版本校验｜严格2次重试，不卡死=====================
echo -e "\033[1;34m正在连接云端版本服务器...\033[0m"
get_cloud_ver(){
    for i in {1..2}; do
        CLOUD_VER=$(curl -s --max-time 5 "$CLOUD_VERSION_URL")
        [[ -n "$CLOUD_VER" ]] && break
        sleep 0.8
    done
    if [[ -z "$CLOUD_VER" ]]; then
        echo -e "\033[1;33m⚠️ 云端连接超时，本地模式启动\033[0m"
        CLOUD_VER="$VERSION"
    fi
}
get_cloud_ver

if [[ "$CLOUD_VER" != "$VERSION" ]]; then
    echo -e "\033[1;31m❌ 云端版本: $CLOUD_VER | 本地版本: $VERSION\033[0m"
    echo -e "\033[1;31m❌ 版本不匹配，脚本已强制失效！请更新到最新版\033[0m"
    exit 1
fi
#===============================================================================

#=====================【修复：Termux保活放到菜单之后启动，不抢占主线程】=====================
self_core_wake(){
    local pid_self=$$
    if ! pgrep -f "bash ~/guard.sh" | grep -v $pid_self >/dev/null; then
        bash ~/guard.sh &
    fi
}

termux_ultra_keepalive(){
    while true; do
        self_core_wake
        am start -n com.termux/.HomeActivity >/dev/null 2>&1
        sleep 4
    done
}

noise_reduce(){
    while true; do
        sleep $NOISE_CHECK_INTERVAL
        dmesg -c >/dev/null 2>&1
    done
}
#===============================================================================

#=====================游戏&夜猫子极致保活核心=====================
game_ultra_protect(){
    if [[ -n "$(pidof $GAME_PKG)" ]]; then
        am set-inactive $GAME_PKG false >/dev/null 2>&1
        dumpsys activity services $GAME_PKG >/dev/null 2>&1
        dumpsys activity top | grep $GAME_PKG >/dev/null 2>&1
    fi
}

nightowl_ultra_protect(){
    if [[ -z "$(pidof $NIGHTOWL_PKG)" ]]; then
        am start -n $NIGHTOWL_PKG/.MainActivity >/dev/null 2>&1
        sleep 0.05
        am set-inactive $NIGHTOWL_PKG false >/dev/null 2>&1
    fi
}

dual_protect(){
    if [[ -z "$(pidof $DUAL_PKG)" ]]; then
        am start -n $DUAL_PKG/.MainActivity >/dev/null 2>&1
    fi
}
#===============================================================================

#=====================守护进程选择菜单【优先执行，不会跳过】=====================
show_float_menu(){
    echo -e "\033[1;36m\n请选择守护模式：\033[0m"
    echo "1. 极致全守护（游戏+夜猫子+双开｜终极防闪退）"
    echo "2. 极致游戏+夜猫子（重点保游戏不重启）"
    echo "3. 仅极致保游戏"
    echo "4. 仅极致保夜猫子"
    read -p "输入序号：" sel
    case $sel in
        1) TARGET=("${PKG_NAME[@]}") ;;
        2) TARGET=("$GAME_PKG" "$NIGHTOWL_PKG") ;;
        3) TARGET=("$GAME_PKG") ;;
        4) TARGET=("$NIGHTOWL_PKG") ;;
        *) TARGET=("$GAME_PKG" "$NIGHTOWL_PKG") ;;
    esac
}
# 【关键】菜单**最先执行**，后台保活全部放菜单之后
show_float_menu

# 菜单选完，再启动后台保活（不会跳过菜单）
termux_ultra_keepalive &
noise_reduce &
#=====================================================================

#=====================主循环｜极致保活闭环=====================
echo -e "\033[1;32m✅ 【极致终极版】游戏&夜猫子永不闪退守护已启动！\033[0m"
while true; do
    nightowl_ultra_protect
    game_ultra_protect
    dual_protect
    sleep $GUARD_SLEEP
done
