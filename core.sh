#!/system/bin/sh
clear

# 云端卡密地址
CLOUD_API="https://raw.githubusercontent.com/auth-server-by/auth-server-by/main/key.txt"

# 守护包名
APP_LIST=(
com.pi.czrxdfirst
com.night.owl
com.excean.dualaid
)
PID_FILE="./guard.pid"

# 退出清理
cleanup() {
    clear
    echo "====================================="
    echo "   正在退出守护模式..."
    echo "====================================="
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE" 2>/dev/null)
        if [ -n "$PID" ]; then
            kill "$PID" 2>/dev/null
        fi
        rm -f "$PID_FILE"
    fi
    echo "✅ 已安全退出，守护进程已关闭"
    exit 0
}
trap cleanup SIGINT SIGTERM

# 云端卡密校验
cloud_key_check(){
    echo "===== 请输入云端授权卡密 ====="
    read -r INPUT_KEY
    echo "🌐 正在连接你的专属云端服务器验证..."

    KEY_VALID=$(curl -s --connect-timeout 5 "$CLOUD_API" | grep -qxF "$INPUT_KEY" && echo "valid" || echo "invalid")

    if [ "$KEY_VALID" = "valid" ]; then
        echo "✅ 云端卡密验证通过！"
        sleep 1
    else
        echo "❌ 卡密无效/过期/网络异常"
        exit 1
    fi
}

# 注意事项
show_notice(){
clear
echo "============================================="
echo "            【重要使用注意事项】            "
echo "============================================="
echo "  必须给3款软件开启以下权限："
echo "  ✅ 悬浮窗权限"
echo "  ✅ 后台弹出界面权限"
echo "  ✅ 应用自启动权限"
echo "  ✅ 关闭电池优化/允许后台活动"
echo "---------------------------------------------"
echo "  禁止一键清理后台，勿关闭终端窗口"
echo "============================================="
read -r -p "按回车键 继续执行..."
}

# 权限跳转
jump_permission(){
for pkg in "${APP_LIST[@]}"; do
    echo "🔍 正在跳转$pkg权限设置..."
    am start -a android.settings.APPLICATION_DETAILS_SETTINGS -d "package:$pkg" >/dev/null 2>&1
    sleep 2
done
}

# 性能优化
auto_optimize(){
clear
echo "====================================="
echo "   正在执行全自动性能优化..."
echo "====================================="
echo "⚙️  系统动画&后台限制优化中..."
settings put global animator_duration_scale 0
settings put global window_animation_scale 0
settings put global transition_animation_scale 0
settings put global app_process_limit 4
settings put global auto_sync 0
settings put global low_power 0 2>/dev/null

echo "🎮 游戏触控&显示优化中..."
settings put secure pointer_speed 7
settings put system screen_brightness_mode 0
settings put system accelerometer_rotation 0 2>/dev/null

echo "🧹 释放系统缓存内存..."
sync
echo 3 > /proc/sys/vm/drop_caches 2>/dev/null

echo "✅ 全部优化执行完成！"
sleep 1
}

# 守护进程
start_guard(){
    [ -f "$PID_FILE" ] && rm -f "$PID_FILE"

    (
        while true; do
            sync
            echo 2 > /proc/sys/vm/drop_caches 2>/dev/null
            for pkg in "${APP_LIST[@]}"; do
                if ! pidof "$pkg" >/dev/null 2>&1; then
                    am start -n "${pkg}/.MainActivity" >/dev/null 2>&1
                fi
            done
            sleep 5
        done
    ) &
    echo $! > "$PID_FILE"
}

# 主流程
cloud_key_check
show_notice
auto_optimize

echo "====================================="
echo "   即将自动跳转授权权限页面"
echo "====================================="
sleep 2
jump_permission

echo "====================================="
echo "授权完按回车进入守护界面"
echo "====================================="
read -r -p "授权完按回车进入守护界面"

start_guard
START_TIME=$(date +%s)

# 常驻界面
while true; do
    clear
    NOW=$(date +"%Y-%m-%d %H:%M:%S")
    RUNTIME=$(( $(date +%s) - START_TIME ))
    H=$(( RUNTIME / 3600 ))
    M=$(( (RUNTIME % 3600) / 60 ))
    S=$(( RUNTIME % 60 ))

    echo "====================================="
    echo "  🛡️  多软件防闪退实时守护已开启"
    echo "====================================="
    echo "⏰ 当前时间: $NOW"
    echo "⏱️  已稳定运行: ${H}h${M}分${S}s"
    echo "📦 守护应用列表:"
    for pkg in "${APP_LIST[@]}"; do
        echo "  - $pkg"
    done
    echo "====================================="

    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE" 2>/dev/null)
        if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
            echo "✅ 守护状态: 正常运行中"
        else
            echo "❌ 守护掉线，自动重连中..."
            start_guard
        fi
    else
        echo "❌ 守护丢失，重新启动中..."
        start_guard
    fi

    echo "====================================="
    echo "请勿关闭窗口 保持后台驻守"
    echo "Ctrl+C一键退出并清理守护"
    echo "====================================="
    sleep 1
done
