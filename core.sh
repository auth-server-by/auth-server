#!/system/bin/sh
# 私有云端核心｜免Root 卡密+性能+三层守护
GITHUB_KEY_URL="https://raw.githubusercontent.com/auth-server-by/%E8%BA%AB%E4%BB%BD%E9%AA%8C%E8%AF%81%E6%9C%8D%E5%8A%A1%E5%99%A8/main/key.txt"
BINGXIN_PACKAGE="com.bingxin.virtual"
NIGHT_OWL_PACKAGE="com.night.owl"
GAME_PACKAGE="com.pi.czrxdfirst"
AUTH_FILE="/sdcard/MT/.auth_noroot.dat"
CHECK_INTERVAL=3

DEVICE_ID=$(settings get secure android_id)
echo "=============================="
echo "设备ID：$DEVICE_ID"
echo "=============================="

if [ -f "$AUTH_FILE" ]; then
    echo "检测本地授权记录中..."
    AUTH_INFO=$(cat "$AUTH_FILE")
    SAVED_DEV=$(echo "$AUTH_INFO" | cut -d'|' -f1)
    EXPIRE_DAY=$(echo "$AUTH_INFO" | cut -d'|' -f2)
    NOW=$(date +%Y-%m-%d)

    if [ "$SAVED_DEV" = "$DEVICE_ID" ]; then
        if [ "$EXPIRE_DAY" = "永久" ] || [ "$EXPIRE_DAY" \> "$NOW" ]; then
            echo "✅ 授权正常，进入性能+守护模式"
            goto_daemon
        else
            echo "❌ 授权已过期，重新输入卡密"
            rm -f "$AUTH_FILE"
        fi
    else
        echo "❌ 设备不匹配，清除旧授权"
        rm -f "$AUTH_FILE"
    fi
fi

echo "请输入卡密："
read -r IN_CARD

echo "正在校验云端卡密..."
KEY_RAW=$(curl -s "$GITHUB_KEY_URL")
if [ -z "$KEY_RAW" ]; then
    echo "❌ 网络错误，无法连接云端"
    exit 1
fi

VALID=0
OUT_EXPIRE=""
OUT_BIND=""

while IFS= read -r line; do
    [ -z "$line" ] && continue
    [[ "$line" =~ ^# ]] && continue
    IFS=':' read -r k e b <<< "$line"
    if [ "$k" = "$IN_CARD" ]; then
        VALID=1
        OUT_EXPIRE="$e"
        OUT_BIND="$b"
        break
    fi
done <<< "$KEY_RAW"

if [ $VALID -eq 0 ]; then
    echo "❌ 卡密无效"
    exit 1
fi

NOW=$(date +%Y-%m-%d)
if [ "$OUT_EXPIRE" != "永久" ] && [ "$OUT_EXPIRE" \< "$NOW" ]; then
    echo "❌ 卡密已过期"
    exit 1
fi

if [ -n "$OUT_BIND" ] && [ "$OUT_BIND" != "$DEVICE_ID" ]; then
    echo "❌ 卡密已绑定其他设备"
    exit 1
fi

echo "$DEVICE_ID|$OUT_EXPIRE" > "$AUTH_FILE"
echo "✅ 激活成功，有效期：$OUT_EXPIRE"

goto_daemon()
{
echo "🚀 执行免Root极致性能优化..."
settings put global window_animation_scale 0
settings put global transition_animation_scale 0
settings put global animator_duration_scale 0
settings put secure hw_overlay 0
settings put secure force_gpu_render 1
settings put system performance_mode 1
am kill-all
echo "✅ 免Root性能优化完成"
echo "🛡️ 开始后台进程守护循环"

while true
do
    if ! pgrep -f "$BINGXIN_PACKAGE" >/dev/null 2>&1; then
        echo "⚠️ 冰心已退出，自动重启"
        am start -n "$BINGXIN_PACKAGE/.MainActivity"
        sleep 4
    fi
    if ! pgrep -f "$NIGHT_OWL_PACKAGE" >/dev/null 2>&1; then
        echo "⚠️ 夜猫子已退出，自动重启"
        sleep 3
    fi
    if ! pgrep -f "$GAME_PACKAGE" >/dev/null 2>&1; then
        echo "⚠️ 游戏已闪退，自动重启"
        am start -n "$GAME_PACKAGE/.MainActivity"
        sleep 3
    fi
    sleep $CHECK_INTERVAL
done
}
