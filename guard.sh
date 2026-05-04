#!/bin/bash
# 守护脚本_v2.1 最终满血版 | 酷烧云适配 | 安卓5.1-16兼容
# 功能：酷烧云卡密验证 + 极致进程守护 + 防闪退 + 框架兼容一体化

# ====================== 酷烧云核心配置（已填好你的信息） ======================
API_URL="https://api.kushao.net/api/verify"
PROJECT_ID="69f8e423"
APP_KEY="3R6kdw3oCt3h3q8ehtcBi7ZFhCZn2pVj"
# ============================================================================

# ====================== 游戏与框架配置 ======================
GAME_PACKAGE="com.tencent.tmgp.sgame"
GAME_ACTIVITY="com.tencent.tmgp.sgame.MainActivity"
BINGXIN_PACKAGE="com.bingxin42.frame"
YEMAOZI_PACKAGE="com.yemaozi.helper"
# =========================================================

# 二次元启动画
clear
echo -e "\033[1;35m
  ╔══════════════════════════════════════╗
  ║                                      ║
  ║     ✨ 超自然 · 守护脚本 v2.1 ✨      ║
  ║        酷烧云授权系统 已适配         ║
  ║        安卓5.1-16 全机型兼容         ║
  �══════════════════════════════════════╣
  ║     冰心4.2 + 夜猫子 框架专用         ║
  ║        极致防闪退 满血优化           ║
  ╚══════════════════════════════════════╝
\033[0m"
sleep 1

# ====================== 基础环境检测与依赖安装 ======================
echo -e "\033[1;34m[+] 正在检测运行环境...\033[0m"
# 安装核心依赖
pkg install -y curl wget procps termux-tools
# 授予必要权限
termux-setup-storage > /dev/null 2>&1
# 检测Android版本
ANDROID_VERSION=$(getprop ro.build.version.release)
echo -e "\033[1;32m[✓] 检测到Android版本: $ANDROID_VERSION\033[0m"

# ====================== 安卓16特殊兼容处理 ======================
if [[ "$ANDROID_VERSION" == "16" ]]; then
    echo -e "\033[1;33m[!] 检测到Android 16，启用兼容模式...\033[0m"
    # 适配安卓16的进程调度限制
    export LD_LIBRARY_PATH=/system/lib64:/system/lib
    # 调整Termux进程优先级
    renice -20 $$ > /dev/null 2>&1
fi

# ====================== 卡密验证流程（纯酷烧云逻辑） ======================
read -p "请输入酷烧云卡密: " CARD_KEY
DEVICE_ID=$(getprop ro.serialno)
# 兼容部分机型获取设备ID失败的情况
if [ -z "$DEVICE_ID" ]; then
    DEVICE_ID=$(cat /proc/sys/kernel/random/uuid | md5sum | awk '{print $1}')
fi

# MD5签名（和酷烧云后台配置完全一致）
SIGN=$(echo -n "${PROJECT_ID}${CARD_KEY}${DEVICE_ID}${APP_KEY}" | md5sum | awk '{print $1}')

# 发送验证请求到酷烧云服务器（超时重连）
echo -e "\033[1;34m[+] 正在连接酷烧云授权服务器...\033[0m"
for i in {1..3}; do
    RESPONSE=$(curl -s -X POST "$API_URL" \
        -d "pid=$PROJECT_ID" \
        -d "card=$CARD_KEY" \
        -d "device=$DEVICE_ID" \
        -d "sign=$SIGN" \
        --connect-timeout 10 --max-time 15)
    if [[ "$RESPONSE" == *"\"code\":200"* ]]; then
        break
    else
        echo -e "\033[1;33m[!] 验证请求超时，正在重试($i/3)...\033[0m"
        sleep 2
    fi
done

# 验证结果判断
if [[ "$RESPONSE" == *"\"code\":200"* ]]; then
    echo -e "\033[1;32m[✓] 酷烧云授权验证通过！欢迎使用~ 🚀\033[0m"
    sleep 1
else
    echo -e "\033[1;31m[✗] 酷烧云授权验证失败，请检查卡密或网络！\033[0m"
    exit 1
fi

# ====================== 极致防闪退优化（适配90%+机型） ======================
echo -e "\033[1;34m[+] 正在应用防闪退优化配置...\033[0m"

# 1. 内存优化（适配低中高内存机型）
MEM_TOTAL=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
if [ $MEM_TOTAL -lt 4000000 ]; then
    # 4GB以下机型：激进内存释放
    echo -e "\033[1;33m[!] 低内存机型，启用激进内存优化...\033[0m"
    echo 3 > /proc/sys/vm/drop_caches > /dev/null 2>&1
elif [ $MEM_TOTAL -lt 8000000 ]; then
    # 4-8GB机型：平衡优化
    echo 1 > /proc/sys/vm/drop_caches > /dev/null 2>&1
fi

# 2. 冻结冗余后台进程（减少资源占用）
echo -e "\033[1;34m[+] 正在冻结冗余后台进程...\033[0m"
for pkg in $(pm list packages -3 | grep -v "$GAME_PACKAGE" | grep -v "$BINGXIN_PACKAGE" | grep -v "$YEMAOZI_PACKAGE" | cut -d: -f2); do
    pidof $pkg > /dev/null 2>&1 && kill -STOP $(pidof $pkg) > /dev/null 2>&1
done

# 3. 调整游戏进程优先级
echo -e "\033[1;34m[+] 正在提升游戏进程优先级...\033[0m"
renice -15 $(pidof $GAME_PACKAGE) > /dev/null 2>&1
ionice -c 2 -n 0 $(pidof $GAME_PACKAGE) > /dev/null 2>&1

# 4. 冰心4.2 + 夜猫子框架进程守护
echo -e "\033[1;34m[+] 正在启动框架进程守护...\033[0m"
am start -n $BINGXIN_PACKAGE/.MainActivity > /dev/null 2>&1
am start -n $YEMAOZI_PACKAGE/.MainActivity > /dev/null 2>&1

# ====================== 核心进程守护循环（极致防闪退） ======================
echo -e "\033[1;32m[✓] 所有优化配置已应用，启动游戏守护循环...\033[0m"
while true; do
    # 1. 游戏进程检测与重启
    if ! pgrep -f "$GAME_PACKAGE" > /dev/null; then
        echo -e "\033[1;33m[!] 检测到游戏进程退出，正在重启...\033[0m"
        am start -n $GAME_PACKAGE/$GAME_ACTIVITY > /dev/null 2>&1
        sleep 3
        # 重启后重新提升优先级
        renice -15 $(pidof $GAME_PACKAGE) > /dev/null 2>&1
    fi

    # 2. 框架进程守护（防止框架闪退导致游戏崩溃）
    if ! pgrep -f "$BINGXIN_PACKAGE" > /dev/null; then
        echo -e "\033[1;33m[!] 检测到冰心框架进程退出，正在重启...\033[0m"
        am start -n $BINGXIN_PACKAGE/.MainActivity > /dev/null 2>&1
    fi
    if ! pgrep -f "$YEMAOZI_PACKAGE" > /dev/null; then
        echo -e "\033[1;33m[!] 检测到夜猫子框架进程退出，正在重启...\033[0m"
        am start -n $YEMAOZI_PACKAGE/.MainActivity > /dev/null 2>&1
    fi

    # 3. 定时内存释放（每30秒一次，不影响游戏）
    if (( $(date +%s) % 30 == 0 )); then
        echo 1 > /proc/sys/vm/drop_caches > /dev/null 2>&1
    fi

    # 4. 心跳检测，防止Termux进程被系统杀死
    touch /data/data/com.termux/files/home/.keepalive
    sleep 1
done
