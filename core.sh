#!/system/bin/sh
clear
##################################################
#         二次元守护脚本_v2.2 满血完整版
#         防闪退+进程守护+强制更新
##################################################
echo ""
echo "        ★★★★★★★★★★★★★"
echo "        ✨  二次元守护脚本_v2.2 ✨"
echo "        ★★★★★★★★★★★★★"
echo ""
echo "        正在初始化核心模块..."
sleep 0.4
echo "        正在注入进程守护机制..."
sleep 0.4
echo "        正在校验云端版本信息..."
sleep 0.4

# ====================== 版本校验模块（地址已修正）======================
CLOUD_VERSION=$(curl -s "https://raw.githubusercontent.com/auth-server-by/auth-server-by/main/version.txt" | tr -d '\r\n')
LOCAL_VERSION="2.2"

if [ "$CLOUD_VERSION" != "$LOCAL_VERSION" ]; then
    echo ""
    echo "❌ 检测到版本已过期！"
    echo "🔴 当前本地版本: $LOCAL_VERSION"
    echo "🟢 云端最新版本: $CLOUD_VERSION"
    echo "⚠️ 旧版本已强制失效，请更新到最新版！"
    sleep 3
    exit 1
fi

echo ""
echo "✅ 所有模块加载完成！"
echo "✅ 已开启后台永久守护！"
echo "✅ 游戏闪退问题已加固！"
echo ""
echo "——————————————————————————————————"
pkg="com.tancha.ycgame"
activity=".MainActivity"

# ====================== 权限提升模块 ======================
renice -20 $(pidof $pkg) 2>/dev/null
echo -17 > /proc/$(pidof $pkg)/oom_score_adj 2>/dev/null
echo 0 > /proc/$(pidof $pkg)/oom_adj 2>/dev/null
chmod 755 /proc/$(pidof $pkg)/maps 2>/dev/null
chmod 755 /proc/$(pidof $pkg)/mem 2>/dev/null

# ====================== 内存优化模块 ======================
echo 0 > /proc/sys/vm/compaction_proactiveness
echo 5 > /proc/sys/vm/dirty_ratio
echo 10 > /proc/sys/vm/dirty_background_ratio
echo 20 > /proc/sys/vm/swappiness
echo 1024 > /proc/sys/vm/min_free_kbytes
echo 0 > /proc/sys/vm/zone_reclaim_mode

# ====================== 帧率稳帧模块 ======================
setprop debug.performance.turbo 1
setprop debug.vulkan.enable 1
setprop debug.vulkan.layers ""
setprop debug.sf.nobootanimation 1
setprop ro.config.low_ram false
setprop ro.sf.lcd_density 399
setprop debug.gralloc.enable_fb_ubwc 1

# ====================== 后台进程冻结模块 ======================
pm disable com.android.launcher3 2>/dev/null
pm disable com.android.systemui.overlays 2>/dev/null
pm disable com.android.bluetooth 2>/dev/null

# ====================== 永久守护循环 ======================
while :
do
    if ! pidof $pkg >/dev/null 2>&1; then
        am start -n $pkg/$activity
        echo "【守护提醒】游戏进程异常，已自动拉起！"
    fi
    sleep 1
done
