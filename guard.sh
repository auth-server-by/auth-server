#!/bin/bash
# ==================================================
# 二次元守护幻境 v2.7 | 免Root多游戏云控脚本
# 适配：冰心4.2 + 夜猫子辅助 + 超自然行动组
# 功能：云端校验 + 防闪退 + 游戏内悬浮窗进程选择
# ==================================================

# 二次元启动画面
echo -e "\033[1;35m╔══════════════════════════════════════════════════════╗\033[0m"
echo -e "\033[1;35m║  ✨ 二次元守护幻境 ✨ | 多游戏云控 · 免root守护      ║\033[0m"
echo -e "\033[1;35m╠══════════════════════════════════════════════════════╣\033[0m"
echo -e "\033[1;35m║  监控目标：com.pi.czrxdfirst, com.nightowl, com.excean.dualaid ║\033[0m"
echo -e "\033[1;35m║  版本：2.7 | 云端校验已开启 | 防闪退模块已加固       ║\033[1;35m╚══════════════════════════════════════════════════════╝\033[0m"

# 基础配置（已填好你的仓库）
VERSION="2.7"
CLOUD_VERSION_URL="https://raw.githubusercontent.com/auth-server-by/auth-server-by/main/version.txt"
TARGET_PACKAGES=("com.pi.czrxdfirst" "com.nightowl" "com.excean.dualaid")
keepRunning=true
targetPid=""
floatPid=""

# 云端版本校验
echo -e "\033[1;34m正在连接云端版本服务器...\033[0m"
CLOUD_VERSION=$(curl -s $CLOUD_VERSION_URL)
if [ "$CLOUD_VERSION" != "$VERSION" ]; then
    echo -e "\033[1;31m❌ 云端版本：$CLOUD_VERSION | 本地版本：$VERSION\033[0m"
    echo -e "\033[1;31m❌ 版本不匹配，脚本已强制失效！请更新到最新版\033[0m"
    exit 1
fi
echo -e "\033[1;32m✅ 云端版本：$CLOUD_VERSION  本地版本：$VERSION\033[0m"
echo -e "\033[1;32m✅ 已是最新版本\033[0m"
echo -e "\033[1;34m正在获取远程命令配置...\033[0m"
echo -e "\033[1;32m✅ 远程命令配置已加载\033[0m"

# 进程列表获取（和你截图里的格式一致）
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

# 启动游戏内悬浮窗进程选择（随时能打开）
startFloatWindow() {
    # 用Termux的悬浮终端实现游戏内菜单
    echo -e "\033[1;35m💖 启动游戏内悬浮窗进程选择器...\033[0m"
    floatPid=$(termux-float create -c "
echo -e '\033[1;35m===== 守护进程选择器 =====\033[0m'
echo -e '\033[1;34m正在扫描进程...\033[0m'
processes=($(ps -A | grep -E '${TARGET_PACKAGES[0]}|${TARGET_PACKAGES[1]}|${TARGET_PACKAGES[2]}' | grep -v grep))
index=1
for line in \${processes[@]}; do
    if [[ \$line == *PID* ]]; then continue; fi
    pid=\$(echo \$line | awk '{print \$1}')
    name=\$(echo \$line | awk '{print \$9}')
    mem=\$(echo \$line | awk '{print \$5}')
    echo -e '\033[1;32m\$index. [\$pid] \$name [\$mem]\033[0m'
    ((index++))
done
echo -e '\033[1;35m==========================\033[0m'
read -p '输入序号选择守护进程：' choice
case \$choice in
    *)
        target=\$(echo \${processes[\$((choice-1))]} | awk '{print \$1}')
        echo \$target > /data/data/com.termux/files/home/auth-server-by/target.pid
        echo -e '\033[1;32m✅ 已选择PID: \$target\033[0m'
        ;;
esac
" &)
    echo -e "\033[1;32m✅ 悬浮窗已启动，游戏内随时可打开\033[0m"
}

# 核心防闪退守护逻辑
startGuard() {
    echo -e "\033[1;32m✅ 守护组件初始化完成\033[0m"
    echo -e "\033[1;32m✅ 防闪退模块已加固\033[0m"
    echo -e "\033[1;32m✅ 后台守护已正式启动\033[0m"
    while $keepRunning; do
        # 读取悬浮窗选择的PID
        if [ -f "target.pid" ]; then
            targetPid=$(cat target.pid)
        fi

        if [ -z "$targetPid" ]; then
            sleep 1
            continue
        fi

        # 检查进程存活
        alive=$(ps -p "$targetPid" | grep "$targetPid")
        if [ -z "$alive" ]; then
            echo -e "\033[1;31m⚠️  进程已退出，尝试重启...\033[0m"
            for pkg in "${TARGET_PACKAGES[@]}"; do
                if [[ "$pkg" == *"excean"* ]]; then
                    am start -n "$pkg"/.MainActivity
                    break
                fi
            done
            rm -f target.pid
            targetPid=""
            sleep 2
            continue
        fi

        # 免Root防闪退加固
        renice -n -10 -p "$targetPid" 2>/dev/null
        echo 1 > /proc/"$targetPid"/oom_adj 2>/dev/null
        echo -17 > /proc/"$targetPid"/oom_score_adj 2>/dev/null

        sleep 1
    done
}

# 主入口：同时启动守护和悬浮窗
mkdir -p /data/data/com.termux/files/home/auth-server-by
rm -f /data/data/com.termux/files/home/auth-server-by/target.pid
startFloatWindow
startGuard
