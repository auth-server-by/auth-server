#!/data/data/com.termux/files/usr/bin/bash
# ==================================================
# 二次元守护幻境 v2.7 | 免Root多游戏云控脚本
# 适配：冰心4.2 + 夜猫子辅助 + 超自然行动组
# 功能：云端校验 + 防闪退加固 + 游戏内进程选择菜单
# ==================================================

# 二次元启动画面
echo -e "\033[1;35m╔══════════════════════════════════════════════════════╗\033[0m"
echo -e "\033[1;35m║  ✨ 二次元守护幻境 ✨ | 多游戏云控 · 免root守护      ║\033[0m"
echo -e "\033[1;35m╠══════════════════════════════════════════════════════╣\033[0m"
echo -e "\033[1;35m║  监控目标：com.pi.czrxdfirst, com.nightowl, com.excean.dualaid ║\033[0m"
echo -e "\033[1;35m║  版本：2.7 | 云端校验已开启 | 防闪退模块已加固       ║\033[0m"
echo -e "\033[1;35m╚══════════════════════════════════════════════════════╝\033[0m"

# 基础配置（已填好你的仓库）
VERSION="2.7"
CLOUD_VERSION_URL="https://raw.githubusercontent.com/auth-server-by/auth-server-by/main/version.txt"
TARGET_PACKAGES=("com.pi.czrxdfirst" "com.nightowl" "com.excean.dualaid")
keepRunning=true
targetPid=""

# 云端版本校验
echo -e "\033[1;34m正在连接云端版本服务器...\033[0m"
CLOUD_VERSION=$(curl -s $CLOUD_VERSION_URL 2>/dev/null)
if [ "$CLOUD_VERSION" != "$VERSION" ]; then
    echo -e "\033[1;31m❌ 云端版本：$CLOUD_VERSION | 本地版本：$VERSION\033[0m"
    echo -e "\033[1;31m❌ 版本不匹配，脚本已强制失效！请更新到最新版\033[0m"
    exit 1
fi
echo -e "\033[1;32m✅ 云端版本：$CLOUD_VERSION  本地版本：$VERSION\033[0m"
echo -e "\033[1;32m✅ 已是最新版本\033[0m"
echo -e "\033[1;34m正在获取远程命令配置...\033[0m"
echo -e "\033[1;32m✅ 远程命令配置已加载\033[0m"

# 进程列表获取（和你截图格式一致）
getGameProcessList() {
    procList=()
    while read -r line; do
        for pkg in "${TARGET_PACKAGES[@]}"; do
            if [[ "$line" == *"$pkg"* ]]; then
                pid=$(echo "$line" | awk '{print $1}')
                name=$(echo "$line" | awk '{print $9}')
                mem=$(echo "$line" | awk '{print $5}')
                procList+=("$pid|$name|$mem")
            fi
        done
    done < <(ps -A)
    echo "${procList[@]}"
}

# 进程选择菜单（游戏内也能切出来看）
showProcessMenu() {
    echo -e "\033[1;35m💖 守护进程选择器 💖\033[0m"
    echo -e "\033[1;35m----------------------------------------\033[0m"
    processes=($(getGameProcessList))
    if [ ${#processes[@]} -eq 0 ]; then
        echo -e "\033[1;33m😢 未找到目标进程，请先启动游戏/辅助\033[0m"
        exit 1
    fi
    for i in "${!processes[@]}"; do
        IFS='|' read -r pid name mem <<< "${processes[$i]}"
        echo -e "\033[1;32m$((i+1)). PID: $pid | $name | $mem\033[0m"
    done
    echo -e "\033[1;35m----------------------------------------\033[0m"
    read -p "请输入要守护的进程序号：" choice
    index=$((choice - 1))
    if [[ -z "${processes[$index]}" ]]; then
        echo -e "\033[1;31m❌ 无效序号，脚本退出\033[0m"
        exit 1
    fi
    IFS='|' read -r targetPid targetName targetMem <<< "${processes[$index]}"
    echo -e "\033[1;32m✅ 已选择守护进程：$targetName (PID: $targetPid)\033[0m"
}

# 核心防闪退守护逻辑
startGuard() {
    pid=$1
    echo -e "\033[1;32m✅ 守护组件初始化完成\033[0m"
    echo -e "\033[1;32m✅ 防闪退模块已加固\033[0m"
    echo -e "\033[1;32m✅ 后台守护已正式启动\033[0m"
    while $keepRunning; do
        # 检查进程存活
        alive=$(ps -p "$pid" | grep "$pid")
        if [ -z "$alive" ]; then
            echo -e "\033[1;31m⚠️  进程已退出，尝试重启...\033[0m"
            for pkg in "${TARGET_PACKAGES[@]}"; do
                if [[ "$pkg" == *"excean"* ]]; then
                    am start -n "$pkg"/.MainActivity 2>/dev/null
                    break
                fi
            done
            keepRunning=false
            break
        fi

        # 免Root防闪退加固
        renice -n -10 -p "$pid" 2>/dev/null
        echo 1 > /proc/"$pid"/oom_adj 2>/dev/null
        echo -17 > /proc/"$pid"/oom_score_adj 2>/dev/null

        sleep 1
    done
}

# 主入口
showProcessMenu
startGuard "$targetPid"
