#!/system/bin/sh
nohup am startservice \
-n com.termux.gui/.FloatWindowService \
--ei mode 1 \
--es title "💖虚拟容器守护v2.7💖" \
--es content "🌸开启守护｜✨内存优化｜💮停止服务" \
--ei textcolor 0xFFFFB6C1 \
--ei bgcolor 0xCC100020 \
--ei size 15 \
> /dev/null 2>&1
