#!/data/data/com.termux/files/usr/bin/sh
# 守护脚本_v2.1 公益授权版
# 仓库：https://github.com/auth-server-by/auth-server-by

# ========== 配置区 ==========
AUTH_KEY="群主大78"
APP_PKG="com.pi.czrxdfirst"  # 《超自然》游戏包名
FRAMEWORK_PKG="com.excean.dualaid"  # 冰心框架包名
NIGHTOWL_PKG="com.night.owl"  # 夜猫子辅助包名

# ========== 自动授权模块 ==========
echo "========================================"
echo "守护脚本 V2.1 公益授权版"
echo "========================================"
echo "✅ 正在自动授权..."

# 模拟卡密校验（兼容原有逻辑，跳过手动输入）
if [ "$AUTH_KEY" = "群主大78" ]; then
    echo "✅ 授权成功！正在启动守护进程..."
else
    echo "❌ 授权失败，请使用正确的公益卡密"
    exit 1
fi

# ========== 进程守护核心逻辑 ==========
echo "🔍 开始监控游戏与框架进程..."
while true; do
    # 检查目标进程是否存活
    if ! pgrep -f "$APP_PKG" > /dev/null; then
        echo "⚠️  游戏进程已退出，尝试唤醒..."
        am start -n "$APP_PKG/.MainActivity" > /dev/null 2>&1
    fi

    if ! pgrep -f "$FRAMEWORK_PKG" > /dev/null; then
        echo "⚠️  冰心框架进程已退出，尝试唤醒..."
        am start -n "$FRAMEWORK_PKG/.MainActivity" > /dev/null 2>&1
    fi

    if ! pgrep -f "$NIGHTOWL_PKG" > /dev/null; then
        echo "⚠️  夜猫子辅助进程已退出，尝试唤醒..."
        am start -n "$NIGHTOWL_PKG/.MainActivity" > /dev/null 2>&1
    fi

    sleep 30
done
