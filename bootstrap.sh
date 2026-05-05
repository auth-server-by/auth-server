#!/data/data/com.termux/files/usr/bin/bash
URL="https://raw.githubusercontent.com/auth-server-by/auth-server/main"
GUARD="$HOME/guard.sh"

echo ">> Pulling latest guard..."
curl -skL --connect-timeout 8 "$URL/guard.sh" -o "$GUARD.tmp" 2>/dev/null

if [ -s "$GUARD.tmp" ]; then
  if grep -q "二次元守护" "$GUARD.tmp"; then
    mv "$GUARD.tmp" "$GUARD"
    chmod 755 "$GUARD"
    echo ">> Updated to latest cloud version"
  else
    echo "!! Cloud file broken, using local backup"
    rm -f "$GUARD.tmp"
  fi
else
  echo "!! Network timeout, using local backup"
fi

if [ ! -x "$GUARD" ]; then
  echo "!! No guard script found. Check network and retry."
  exit 1
fi

nohup bash "$GUARD" > /dev/null 2>&1 &
sleep 1
echo ">> Guard is now running in background"
