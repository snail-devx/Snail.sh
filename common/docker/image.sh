#!/usr/bin/env bash
#***********************************************************************************************************
# docker 镜像操作
#   1、镜像创建、启动、停止、删除
#   2、镜像导入、导出等
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
#   本地是否有指定镜像
#   示例：hasImage 镜像名 [镜像tag]
function hasImage() {
    local image
    [ "$#" == 1 ] && image="$1" || image="$1:$2"
    [ "$(sudo docker images -q "${image}" 2>/dev/null)" != "" ] && return 0 || return 1
}

#   构建镜像；执行docker pull操作
#   示例：pullImage "镜像名" "镜像tag"
function pullImage() {
    #   后期判断镜像已经存在了，则不用再pull了
    # name=$(docker images | grep mispt-documentserver | grep 7.5.0)
    runCommand "sudo docker pull $1:$2"
}
#   构建镜像；执行docker build操作
#   示例：buildImage "镜像名" "镜像tag" “Dockerfile文件路径" ["build支持的其他参数"]
function buildImage() {
    runCommand "sudo docker build -t $1:$2 ${4:-} $3"
}
#   导出镜像；执行docker save操作
#   示例：saveImage "镜像名" "镜像tag" "归档文件全路径"
function saveImage() {
    #   后期判断镜像是否存在，不存在则报错
    runCommand "sudo docker save -o $3 $1:$2"
}
#   导入镜像，执行docker load操作
#   示例：loadImage "归档文件全路径"
function loadImage() {
    [ ! -f "$1" ] && {
        logError "文件不存在" "要导入的镜像归档文件不存在 $1"
        return 1
    }
    runCommand "sudo docker load -i $1"
}
#   删除镜像，执行docker rmi 操作
#   示例：removeImage "镜像名" "镜像tag"
function removeImage() {
    #   后续判断一下镜像是否真的存在
    runCommand "sudo docker rmi $1:$2"
}
