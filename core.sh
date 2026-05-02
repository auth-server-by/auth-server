#!/system/bin/sh

# ==========================================
# 🛡️ 终极守护脚本 (冰心/超自然/夜猫子)
# 版本: 1.0
# ==========================================

# --- 【配置区】 ---

# 1. 本地脚本版本号
LOCAL_VERSION="1.0"

# 2. 目标应用包名 (已配置好)
PKG_BINGXIN="com.pi.czrxdfirst"   # 冰心框架
PKG_GAME="com.night.owl"          # 手游超自然
PKG_YEMAOZI="com.excean.dualaid"  # 夜猫子

# 3. 云端仓库配置 (已填入你的真实地址)
BASE_URL="https://raw.githubusercontent.com/auth-server-by/auth-server-by/main"
URL_KEY="$BASE_URL/keys.json"
URL_VER="$BASE_URL/version.txt"
URL_SCRIPT="$BASE_URL/core.sh"

# 4. 临时文件路径
TMP_DIR="/data/local/tmp/auth_check"
KEY_FILE="$TMP_DIR/keys.json"
VER_FILE="$TMP_DIR/version.txt"
TMP_SCRIPT="$TMP_DIR/core_new.sh"

# ==========================================
# 【核心逻辑区】 (下面不要动)
#==========================================

# 创建临时目录
mkdir-p $TMP_DIR

# 颜色定义
RED='\033[0；31m'
GREEN='\033[0；32m'
黄色的='\033[33m'
北卡罗来纳州='\033[0m' #无颜色

echo_yellow(){
回声-e"${YELLOW}$1${NC}"
}

echo_green(){
回声-e"${绿色}$1${NC}"
}

echo_red(){
回声-e"${RED}$1${NC}"
}

# 检查网络
check_network(){
echo_yellow"正在检查网络连接..."
如果！Ping-c1raw.githubusercontent.com&>/dev/null；然后
echo_red"错误：无法连接到GitHub！请检查网络。"
        出口 1
Fi
}

# 自动更新脚本
check_update(){
echo_yellow"正在检查脚本更新..."
    # 下载云端版本号
卷曲-sSf "$URL_VER" -o "$VER_FILE"
如果 [$? -ne 0 ]; 然后
echo_red"警告：无法获取云端版本信息，跳过更新检查。"
返回
Fi

    remote_VERSION=$(cat"$VER_FILE")

如果 ["$REMOTE_VERSION"!="$LOCAL_VERSION" ]; 然后
echo_yellow"发现新版本 ($REMOTE_VERSION)，正在更新..."
卷曲-sSf "$URL_SCRIPT" -o "$TMP_SCRIPT"
如果 [$? -eq 0 ]; 然后
echo_green"更新成功！正在重启脚本..."
chmod+x"$TMP_SCRIPT"
嘘"$TMP_SCRIPT"
            出口 0
        其他
echo_red"更新失败，继续运行旧版本..."
Fi
Fi
}

# 获取云端卡密列表
fetch_keys(){
echo_yellow"正在从云端拉取卡密列表..."
卷曲-sSf "$URL_KEY" -o "$KEY_FILE"
如果 [$? -ne 0 ]; 然后
echo_red"错误：无法下载卡密文件 (keys.json)，请检查链接是否正确。"
        出口 1
Fi
}

# 验证卡密
verify_key(){
    # 简单的读取文件匹配逻辑
    #假设keys.json格式为["key1"，"KEY2"]
    
读-p"请输入您的卡密: "INPUT_KEY
    
    # 在文件中查找输入的卡密
    # 使用 grep 精确匹配字符串
grep-Fq"\"$INPUT_KEY\"" "$KEY_FILE"
    
如果[$？-eq0]；然后$? -eq 0 ]; 然后
echo_green"✅ 验证成功！欢迎使用。""✅ 验证成功！欢迎使用。"
        # 验证成功后，启动目标应用
启动应用程序(_A)
    其他
echo_red"❌ 验证失败！卡密无效或已过期。""❌ 验证失败！卡密无效或已过期。"
        出口 1
Fi
}

# 启动应用
启动应用程序(_apps){
echo_yellow"正在尝试启动应用...""正在尝试启动应用..."
    
    # 尝试启动冰心
如果PM列表包|grep-q"$PKG_冰心"；然后"$PKG_冰心"; 然后
猴子-p$PKG_冰心-烛光.intent.category.Launcher1&>/dev/null&$PKG_冰心 -烛光.intent.category.Launcher1&>/dev/null&
echo_green"已发送启动指令：冰心框架"
Fi
    
    # 尝试启动超自然
如果PM列表包|grep-q"$PKG_GAME"；然后
monkey-p$PKG_GAME-烛光。intent.category.Launcher1&>/dev/null&
echo_green"已发送启发指令：手游超自然""已发送启发指令：手游超自然"
Fi

    # 尝试启动夜猫子
如果PM列表包|grep-q"$PKG_YEMAOZI"；然后
猴子-p$PKG_YEMAOZI-烛光.intent.category.Launcher1&>/dev/null&
echo_green"已发送启动指令：夜猫子""已发送启动指令：夜猫子"
Fi

echo_green"所有操作已完成。""所有操作已完成。"
}

# 主程序
主要的(){
检查网络(_N)
check_update
fetch_keys
验证密钥(_K)
}

# 运行
主要的
