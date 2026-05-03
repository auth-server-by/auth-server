#!/data/data/com.termux/files/usr/bin/sh
# 守护脚本_v2.1 公益授权版 | 冰心优先启动
# 仓库：https://github.com/auth-server-by/auth-server

# ========== 配置区 ==========
AUTH_KEY="群主大78"
# 包名
APP_PKG="com.pi.czrxdfirst"          # 《超自然》游戏包名
FRAMEWORK_PKG="com.excean.dualaid"   # 冰心框架包名
NIGHTOWL_PKG="com.night.owl"         # 夜猫子辅助包名（仅监控，不主动拉起）

# ========== 自动授权模块 ==========
echo "========================================"
echo "守护脚本 V2.1 公益授权版（冰心优先）"
echo "========================================"
echo "✅ 正在自动授权..."

if [ "$AUTH_KEY" = "群主大78" ]; then
    echo "✅ 授权成功！准备启动守护进程..."
else
    echo "❌ 授权失败，请使用正确的公益卡密"
    exit 1
fi

# ========== 进程守护核心逻辑（冰心优先） ==========
echo "🔍 开始监控进程（仅守护冰心+游戏，夜猫子由框架内启动）..."
while true; do
    # 1. 优先检查并拉起冰心框架（核心依赖）
    if ! pgrep -f "$FRAMEWORK_PKG" > /dev/null; then
        echo "⚠️  冰心框架进程已退出，正在唤醒..."
        am start -n "$FRAMEWORK_PKG/.MainActivity" > /dev/null 2>&1
        sleep 3
    fi

    # 2. 再检查游戏进程，确保框架启动后再唤醒游戏
    if ! pgrep -f "$APP_PKG" > /dev/null; then
        echo "⚠️  游戏进程已退出，正在唤醒..."
        am start -n "$APP_PKG/.MainActivity" > /dev/null 2>&1
        sleep 3
    fi

    # 3. 仅监控夜猫子进程状态，不主动拉起（由框架内启动）
    if ! pgrep -f "$NIGHTOWL_PKG" > /dev/null; then
        echo "ℹ️  夜猫子未运行，请在冰心框架内手动启动（非脚本拉起）"
    fi

    sleep 10
done
