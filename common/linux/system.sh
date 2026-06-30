#!/usr/bin/env bash
# shellcheck disable=SC1091             # source动态引入文件的警告

#***********************************************************************************************************
# linux 系统脚本
#   1、用户权限配置、快捷方式管理
#   2、环境变量管理
#***********************************************************************************************************


# ------------------------------------------【准备工作】----------------------------------------------------
echo "--加载${BASH_SOURCE[0]} ..."
{
    __dir=$(dirname "${BASH_SOURCE[0]}")
    # shellcheck source="${__dir}/base.sh"
    [ ! -f "${__dir}/../core/base.sh" ] && echo "依赖脚本[../core/base.sh]不存在，请检查！" && exit 1
    # shellcheck disable=SC1091
    source "${__dir}/../core/base.sh" 
}

# ------------------------------------------【软件相关】----------------------------------------------------
#   使用root账号安装的软件
#   useRootApp 软件所在目录全目录 [软件可执行程序全路径]
function useRootApp() {
    #   分配权限；这种权限分配有点问题，最后都需要针对执行文件，重新分配755；后续再研究以下

    #   将整个目录设置为root用户所有；其他用于给定权限
    if [ -d "$1" ]; then
        runCommand sudo chown root -R "$1"
        runCommand sudo chmod -R 755 "$1"
    fi
    #   可执行程序再给权限
    [ -f "$2" ] && runCommand sudo chmod 755 "$2"
}
#   分享软件；将软件快捷方式copy到 /usr/share/applications/ 目录下
#   示例：shareApp 软件快捷方式路径 ...
function shareApp() {
    for item in "$@"; do
        [ -f "$item" ] && runCommand sudo cp "$item" "/usr/share/applications/"
    done
}
#   取消分享软件；删除分享到  /usr/share/applications/ 目录下的快捷方式
#   示例：unshareApp [xxx.desktop]....
function unshareApp() {
    for item in "$@"; do
        local file="/usr/share/applications/$item"
        [ -f "$file" ] && runCommand sudo rm "$file"
    done
}
#   支持AppImage格式软件，自动安装相关依赖
#   示例：supportAppImage
function supportAppImage() {
    runCommand sudo apt install -y libfuse2
}
#   注册软件带的mimetype配置
#   示例：registerMime 软件mimetype配置文件路径
function registerMime() {
    #   后续支持多个mimetype文件配置
    [ -f "$1" ] && runCommand sudo cp "$1" "/usr/share/mime/packages/"
}
function unregisterMime() {
    #   后续支持多个mimetype文件配置
    [ -f "$1" ] && runCommand sudo cp "$1" "/usr/share/mime/packages/"
}

# ------------------------------------------【环境变量】----------------------------------------------------
#   注册环境变量文件
#   示例：registerEnvProfile 环境变量文件原始路径 [环境变量文件别名]
#   备注：将传入的 $1 copy到 /etc/profile.d/ 目录下，若传入了 $2 则将文件重命名
function registerEnvProfile() {
    [ ! -f "$1" ] && return 1
    #   计算实际文件名称；若文件存在，则不用重复配置了
    local target
    if [ "$2" == "" ]; then
        target="/etc/profile.d/$(basename "$1")"
    else
        target="/etc/profile.d/$2"
    fi
    [ -f "$target" ] && return 0
    #   copy并设置执行权限，并更新环境变量
    sudo cp "$1" "$target"  # copy文件
    sudo chmod +x "$target" # 设置可执行权限
    source "/etc/profile"   # 更新环境变量

    return 0
}
#   取消注册的环境变量文件
#   示例：unregisterEnvProfile 环境变量文件名称
function unregisterEnvProfile() {
    local target="/etc/profile.d/$1"
    [ ! -f "$target" ] && return 1
    #   移除，先不刷新source,这样是有问题的，会不停给Path追加数据， 除非/etc/profile.d下的每个sh文件能够把自己的环境变量做增量模式
    sudo rm "$target"
    # source "/etc/profile" # 更新环境变量
    return 0
}
