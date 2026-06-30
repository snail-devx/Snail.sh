#!/usr/bin/env bash
#***********************************************************************************************************
# apt 软件管理
#   1、软件安装、卸载、、、
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

# ------------------------------------------【通用方法】----------------------------------------------------
#   是否已安装指定软件包
#   示例：hasSoft 软件包名称
function hasSoft() {
    #  [ "$(sudo docker inspect "$1" 2>/dev/null | grep "\"Name\": \"/$1\"")" != "" ] && return 0 || return 1
    [ "$(apt list --installed "$1" 2>/dev/null | grep "$1"/)" != "" ] && return 0 || return 1
}

#   安装软件；
#   示例：installSoft [-f] [安装包名称]...
#   备注：传入 -f 时，即时软件已安装，也会重装；否则自动忽略已安装软件
function installSofts() {
    local force=false
    local soft_install=()
    local soft_installed=()
    #   遍历整理出已安装和未安装软件
    for item in "$@"; do
        [ "$item" == "-f" ] && force=true && continue
        hasSoft "$item" && soft_installed+=("$item") && continue
        soft_install+=("$item")
    done
    #   执行安装操作
    #       未安装软件，执行安装操作
    [ "${#soft_install[@]}" -gt 0 ] && runCommand sudo apt install -y "${soft_install[@]}"
    #       已安装软件，根据需要重装
    if [ "${#soft_installed[@]}" -gt 0 ]; then
        if [ "$force" == "true" ]; then
            runCommand sudo apt reinstall -y "${soft_installed[@]}"
        else
            logInfo "  忽略" "已安装：${soft_installed[*]}"
        fi
    fi
}