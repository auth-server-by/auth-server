#!/data/data/com.termux/files/usr/bin/bash
# 从云端拉取守护，支持离线缓存和超时跳过
URL="https://raw.githubusercontent.com/auth-server-by/auth-server/main"
守卫="$HOME/guard.sh"

回声"⬇️ 拉取云端最新配置..."
# 尝试下载，超时5秒
卷曲-skL--连接-超时5"$URL/guard.sh" -o "$GUARD.tmp" 2>/dev/null
如果[-s"$GUARD.tmp" ]; 然后
  # 校验完整性
如果grep-q"二次元守护" "$GUARD.tmp"; 然后
MV"$GUARD.tmp" "$GUARD"
chmod+x"$GUARD"
回声"✅ 已更新到最新云端版"
  其他
回声"⚠️ 云端文件损坏，使用本地缓存"
RM-f"$GUARD.tmp"
Fi
其他
回声"⚠️ 网络超时，使用本地缓存"
Fi

如果[！-x"$GUARD" ]; 然后
回声"❌ 未找到守护脚本，请检查网络后重试"
  出口 1
Fi

回声"🛡️ 后台启动守护"
nohup bash"$GUARD">/dev/null2>&1&
睡1
回声"✅守护已启，可关Termux"
