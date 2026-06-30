#!/usr/bin/env bash
# shellcheck disable=SC1091             # source动态引入文件的警告

#***********************************************************************************************************
# gnome 桌面环境通用脚本
#   1、自定义图标
#   2、gnome插件管理
#***********************************************************************************************************


# ------------------------------------------【准备工作】----------------------------------------------------
echo "--加载${BASH_SOURCE[0]} ..."

# ------------------------------------------【桌面相关】----------------------------------------------------
#   设置自定义图标；支持批量
#   示例：图标全路径 [要设置自定义图标的全路径]...
function setCustomIcon() {
    [ ! -f "$1" ] && return
    local icon_path="$1"
    shift
    #   遍历传入参数，路径存在，设置自定义图标
    for item in "$@"; do
        [ ! -d "$item" ] && [ ! -f "$item" ] && continue
        # gio set 要设置图标的路径 metadata::custom-icon "file://图标路径"
        gio set "$item" metadata::custom-icon "file://$icon_path"
    done
}

# #   设置自定义图标
# #   示例：setCustomIcon 要设置自定义图标的全路径 图标全路径
# function setCustomIcon() {
#     if [ -d "$1" ] || [ -f "$1" ]; then
#         runCommand "gio set $1 metadata::custom-icon file://$2"
#         # gio set "$1" metadata::custom-icon "file://$2"
#     fi
# }

# ------------------------------------------【插件相关】----------------------------------------------------
#   是否存在指定的Gnome扩展
#   示例：hasGnomeExt 插件名
function hasGnomeExt() {
    [ "$(gnome-extensions list 2>/dev/null | grep "$1")" != '' ] && return 0 || return 1
    # [ "$(sudo docker inspect "$1" 2>/dev/null | grep "\"Name\": \"/$1\"")" != "" ] && return 0 || return 1
}