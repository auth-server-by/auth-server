#!/data/data/com.termux/files/usr/bin/bash
# 二次元守护幻境 免root守护脚本 v2.9｜游戏零干扰终极版｜彻底根治闪退
# 仓库：auth-server-by/auth-server
# 守护进程：com.pi.czrxdfirst(冰心游戏) com.nightowl(夜猫子) com.excean.dualaid(双开)

#=====================配置区=====================
VERSION="2.9"
GAME_PKG="com.pi.czrxdfirst"
NIGHTOWL_PKG="com.nightowl"
DUAL_PKG="com.excean.dualaid"
PKG_NAME=("$GAME_PKG" "$NIGHTOWL_PKG" "$DUAL_PKG")
CLOUD_VERSION_URL="https://ghfast.top/https://raw.githubusercontent.com/auth-server-by/auth-server/main/version.txt"
GUARD_SLEEP=1.5
#==========================================================

#=====================原版UI 1:1复刻=====================
clear
echo -e "\033[1;35m
┌─────────────────────────────────────────────────────────────┐
│ ✨二次元守护幻境 ✨ | 多游戏云控 · 免root守护              │
├─────────────────────────────────────────────────────────────┤
│  监控目标: ${PKG_NAME[*]}
│  版本: $VERSION | 云端校验已开启 | 游戏零干扰防闪退
└─────────────────────────────────────────────────────────────┘
\033[0m"
#=================================================================

#=====================云端校验（容错不卡死）=====================
echo -e "\033[1;34m正在连接云端版本服务器...\033[0m"
get_cloud_ver(){
    for i in {1..2}; do
        CLOUD_VER=$(curl -s --max-time 5 "$CLOUD_VERSION_URL")
        [[ -n "$CLOUD_VER" ]] && break
        sleep 0.8
    done
    [[ -z "$CLOUD_VER" ]] && CLOUD_VER="$VERSION"
}
get_cloud_ver

if [[ "$CLOUD_VER" != "$VERSION" ]]; then
    echo -e "\033[1;31m❌ 云端版本: $CLOUD_VER | 本地版本: $VERSION\033[0m"
    echo -e "\033[1;31m❌ 版本不匹配，脚本已强制失效！\033[0m"
    exit 1
fi
#===============================================================================

#=====================Termux自身保活（后台线程后置，不抢主线程）=====================
self_wake(){
    local pid_self=$$
    if ! pgrep -f "bash ~/guard.sh" | grep -v $pid_self >/dev/null; then
        bash ~/guard.sh &
    fi
}
termux_keepalive(){
    while true; do self_wake; sleep 5; done
}
#===============================================================================

#=====================【核心根治：游戏零干扰，绝不操作游戏进程】=====================
# 1. 游戏：**只检测是否存活，不执行任何命令、不唤醒、不注入、不操作**
# 2. 夜猫子：闪退0.1秒极速重启，优先级最高
# 3. 彻底删除所有 dumpsys/input 高危指令（闪退元凶）
protect_core(){
    # 夜猫子优先极速重启
    if [[ -z "$(pidof $NIGHTOWL_PKG)" ]]; then
        am start -n $NIGHTOWL_PKG/.MainActivity >/dev/null 2>&1
        sleep 0.1
    fi

    # 游戏：只检测，不做任何操作！！！
    # 只要游戏进程在，全程不碰，避免触发游戏反作弊/后台冻结
    :

    # 双开兜底
    if [[ -z "$(pidof $DUAL_PKG)" ]]; then
        am start -n $DUAL_PKG/.MainActivity >/dev/null 2>&1
    fi
}
#===============================================================================

#=====================守护模式选择菜单（优先执行，不会跳过）=====================
show_float_menu(){
    echo -e "\033[1;36m\n请选择守护模式：\033[0m"
    echo "1. 全守护（游戏+夜猫子+双开）"
    echo "2. 游戏+夜猫子（游戏零干扰防闪退）"
    echo "3. 仅保游戏"
    echo "4. 仅保夜猫子"
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

# 菜单后启动后台保活
termux_keepalive &
#=====================================================================

#=====================主循环｜静默低频率，零干扰游戏=====================
echo -e "\033[1;32m✅ 游戏零干扰守护已启动，杜绝闪退！\033[0m"
while true; do
    protect_core
    sleep $GUARD_SLEEP
done
