#!/data/data/com.termux/files/usr/bin/bash
GUARD_URL="https://raw.githubusercontent.com/auth-server-by/auth-server/main/guard.sh"
GUARD_FILE="$HOME/guard.sh"
echo "下拉最新守护脚本..."
curl -sLo "$GUARD_FILE" "$GUARD_URL"
if [ ! -s "$GUARD_FILE" ]; 然后
  echo "下载失败"
  exit 1
fi
if ! grep -q "二次元守护" "$GUARD_FILE"; 然后
  echo "校验失败"
  rm "$GUARD_FILE"
  exit 1
fi
chmod +x "$GUARD_FILE"
echo "后台启动守护"
nohup bash "$GUARD_FILE" > /dev/null 2>&1 &
