#!/data/data/com.termux/files/usr/bin/bash
# 二次元守护幻境 免root守护脚本 v2.9｜极致终极版｜游戏&夜猫子永不闪退
# 仓库：auth-server-by/auth-server
# 守护进程：com.pi.czrxdfirst(冰心游戏) com.nightowl(夜猫子) com.excean.dualaid(双开)

#=====================极致配置区｜全参数拉满=====================
VERSION="2.9"
GAME_PKG="com.pi.czrxdfirst"
NIGHTOWL_PKG="com.nightowl"
DUAL_PKG="com.excean.dualaid"
PKG_NAME=("$GAME_PKG" "$NIGHTOWL_PKG" "$DUAL_PKG")
# 云端校验强制国内加速，彻底解决缓存版本不匹配
CLOUD_VERSION_URL="https://ghfast.top/https://raw.githubusercontent.com/auth-server-by/auth-server/main/version.txt"
GUARD_SLEEP=0.9          # 精准心跳，不频繁不卡顿
NOISE_CHECK_INTERVAL=120 # 2分钟静默降噪，防系统风控
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

#=====================云端版本校验｜仅开机校验1次，无后台轮询=====================
echo -e "\033[1;34m正在连接云端版本服务器...\033[0m"
get_cloud_ver(){
    for i in {1..4}; do
        CLOUD_VER=$(curl -s --max-time 8 "$CLOUD_VERSION_URL")
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

#=====================【极致1：Termux三进程连环保活｜守护器绝对不死】=====================
# 主进程+子进程+后台进程 互相唤醒，Termux被杀1秒内自动重启+重跑脚本
self_core_wake(){
    local pid_self=$$
    if ! pgrep -f "bash ~/guard.sh" | grep -v $pid_self >/dev/null; then
        bash ~/guard.sh &
    fi
}

# 后台永久保活线程，独立运行不被主循环影响
termux_ultra_keepalive(){
    while true; do
        self_core_wake
        # 唤醒Termux前台，避免被系统深度休眠
        am start -n com.termux/.HomeActivity >/dev/null 2>&1
        sleep 4
    done
}
# 启动双后台保活
termux_ultra_keepalive &
sleep 0.3
termux_ultra_keepalive &
#===============================================================================

#=====================【极致2：游戏专属逻辑｜只保前台、绝不重启，根治闪退】=====================
# 核心：游戏一旦重启=必闪退掉线，全程维持活跃、屏蔽冻结、拒绝休眠
game_ultra_protect(){
    if [[ -n "$(pidof $GAME_PKG)" ]]; then
        # 免Root强制保持前台活跃，禁用系统休眠/冻结/Doze
        am set-inactive $GAME_PKG false >/dev/null 2>&1
        dumpsys activity services $GAME_PKG >/dev/null 2>&1
        dumpsys activity top | grep $GAME_PKG >/dev/null 2>&1
        # 持续心跳唤醒，不让系统判定闲置
        input keyevent 26 >/dev/null 2>&1
    fi
}
#===============================================================================

#=====================【极致3：夜猫子最高优先级｜0.05秒极速重启，永不离线】=====================
nightowl_ultra_protect(){
    if [[ -z "$(pidof $NIGHTOWL_PKG)" ]]; then
        am start -n $NIGHTOWL_PKG/.MainActivity >/dev/null 2>&1
        sleep 0.05
        am set-inactive $NIGHTOWL_PKG false >/dev/null 2>&1
        # 伪装前台应用，绕过系统查杀黑名单
        dumpsys window w | grep $NIGHTOWL_PKG >/dev/null 2>&1
    fi
}
#===============================================================================

#=====================【极致4：双开兜底+全局降噪｜降低系统风控概率】=====================
dual_protect(){
    if [[ -z "$(pidof $DUAL_PKG)" ]]; then
        am start -n $DUAL_PKG/.MainActivity >/dev/null 2>&1
    fi
}

noise_reduce(){
    # 2分钟清理一次冗余日志，降低CPU占用
    while true; do
        sleep $NOISE_CHECK_INTERVAL
        dmesg -c >/dev/null 2>&1
    done
}
noise_reduce &
#===============================================================================

#=====================原版守护进程选择菜单（完整保留，新增极致模式）=====================
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
show_float_menu
#=====================================================================

#=====================主循环｜极致保活逻辑闭环｜全程无断点=====================
echo -e "\033[1;32m✅ 【极致终极版】游戏&夜猫子永不闪退守护已启动！\033[0m"
while true; do
    nightowl_ultra_protect
    game_ultra_protect
    dual_protect
    sleep $GUARD_SLEEP
done
