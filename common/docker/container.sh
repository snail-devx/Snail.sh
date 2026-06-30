#!/usr/bin/env bash
#***********************************************************************************************************
# docker 容器执行操作
#   1、容器创建、启动、停止、删除
#   2、容器导入、导出等
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
#   是否存在指定容器
#   示例：hasContainer 容器名称
function hasContainer() {
    # sudo docker inspect postgres 2>/dev/null |grep  \"Name\"": \"/postgres\""
    # ["$(docker inspect [容器名] 2> /dev/null | grep '"Name": "/[容器名]"')"!=""
    [ "$(sudo docker inspect "$1" 2>/dev/null | grep "\"Name\": \"/$1\"")" != "" ] && return 0 || return 1
}

#   启动容器，执行docker start 操作
#   示例：startContainer "容器名"
function startContainer() {
    #   后期判断容器是否存在
    runCommand "sudo docker start $1"
}
#   停止容器，执行docker stop 操作
#   示例：stopContainer "容器名"
function stopContainer() {
    #   后期判断容器是否存在
    runCommand "sudo docker stop $1"
}
#   重启容器，执行docker restart 操作
#   示例：restartContainer "容器名"
function restartContainer() {
    #   后期判断容器是否存在
    runCommand "sudo docker restart $1"
}
#   重启容器，执行docker rm 操作
#   示例：removeContainer "容器名"
function removeContainer() {
    #   后期判断容器是否存在
    runCommand "sudo docker rm $1"
}
