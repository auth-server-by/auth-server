#!/data/data/com.termux/files/usr/bin/sh
# 守护脚本V2.1 二次元启动画面｜防闪退｜强制版本锁死 完整版
AUTH_KEY="群主大78"
SELF_VER="2.1"
VER_URL="https://raw.githubusercontent.com/auth-server-by/auth-server/main/version.txt"

clear

# 二次元启动画面
echo "      /\_/\ "
echo "     ( oωo )"
echo "     > 🛡️  <  守护系统已唤醒"
echo ""
echo "════════════════════════════════"
echo "        专业进程守护 V2.1"
echo "     防闪退 • 强版本校验"
echo "════════════════════════════════"
echo "        正在校验版本..."
echo "════════════════════════════════"

# 版本校验带超时容错
get_latest_ver() {
    curl -s --max-time 10 "$VER_URL"
}

LATEST_VER=$(get_latest_ver)

if [ -z "$LATEST_VER" ]; then
    echo "❌ 网络异常，无法校验版本，请重试"
    exit 1
fi

if [ "$SELF_VER" != "$LATEST_VER" ]; then
    echo "❌ 脚本已过期，请使用最新指令重新拉取"
    exit 1
fi

if [ "$AUTH_KEY" != "群主大78" ]; then
    echo "❌ 授权失败"
    exit 1
fi

# 三包名配置
FRAMEWORK="com.excean.dualaid"
GAME="com.pi.czrxdfirst"
OWL="com.night.owl"

echo "✅ 版本校验通过，守护已成功启动"
echo "════════════════════════════════"

# 主守护循环 完全没变
while true; do
    if ! pgrep -f "$FRAMEWORK" >/dev/null 2>&1; then
        am start -n "$FRAMEWORK/.MainActivity" >/dev/null 2>&1
    fi

    if ! pgrep -f "$GAME" >/dev/null 2>&1; then
        am start -n "$GAME/.MainActivity" >/dev/null 2>&1
    fi

    pgrep -f "$OWL" >/dev/null 2>&1

    sleep 15
done
