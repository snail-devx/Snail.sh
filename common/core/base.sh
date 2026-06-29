#!/usr/bin/env bash
# shellcheck disable=SC2155     # local 定义变量并赋值时，提示赋值和定义分开，没啥用？

#***********************************************************************************************************
# 基础脚本  基础方法
#   1、命令判断、执行
#   2、方法存在性判断
#   3、变量相关操作
#***********************************************************************************************************


# ------------------------------------------【准备工作】----------------------------------------------------
echo "--加载${BASH_SOURCE[0]} ..."

# ------------------------------------------【日志信息】----------------------------------------------------
#   输出【跟踪】级别日志信息
#   示例：logTrace [日志标题] 日志信息 [日志信息]
function logTrace() {
    local title=
    if [ $# -gt 1 ]; then
        title="$1"
        shift
    fi
    [ "${title}" == '' ] && title="TRACE"
    printf '\033[90m%s: \033[0m\033[90m%s\033[0m\n' "$title" "$*"
}
#   输出【信息】级别日志信息
#   示例：logInfo [日志标题] 日志信息 [日志信息]
function logInfo() {
    local title=
    if [ $# -gt 1 ]; then
        title="$1"
        shift
    fi
    [ "${title}" == '' ] && title="INFO"
    printf "\033[34;1m%s: \033[0m\033[96m%s\033[0m\n" "$title" "$*"
}
#   输出【警告】级别日志信息
#   示例：logError [日志标题] 日志信息 [日志信息]
function logWarn() {
    local title=
    if [ $# -gt 1 ]; then
        title="$1"
        shift
    fi
    [ "${title}" == '' ] && title="WARN"
    local msg="$*"
    printf "\033[33m%s: \033[0m\033[90m%s\033[0m\n" "$title" "$msg"
}
#   输出【错误】级别日志信息
#   示例：logError [日志标题] 日志信息 [日志信息]
function logError() {
    local title=
    if [ $# -gt 1 ]; then
        title="$1"
        shift
    fi
    [ "${title}" == '' ] && title="ERROR"
    printf "\033[31m%s: \033[0m\033[90m%s\033[0m\n" "$title" "$*"
}

# ------------------------------------------【命令相关】----------------------------------------------------
#   是否存在传入命令；存在返回0，否则返回1
#   示例：hasCommand 要判断的命令名称
function hasCommand() {
    local ret='0'
    command -v "$1" >/dev/null 2>&1 || { local ret='1'; }
    #   参照：https://blog.csdn.net/butterfly5211314/article/details/84766207
    # fail on non-zero return value
    if [ "$ret" -ne 0 ]; then
        return 1
    fi

    return 0
}
#   打印要执行的命令
#   实例：printCommand 命令 [参数]...
function printCommand() {
    printf "\033[92;1m执行命令:%s\033[0m\n" "$*"
}
#   运行指定命令，将命令输出到屏幕
#   示例：runCommand [--no-quote] 要执行的命令 [命令参数]...
#   备注：参数将一行输出；适用于执行命令参数较少的情况使用
#   备注："--no-quote"的影响
#       不传入时，命令后面跟每个参数都会被视为单独的字符串（即使参数包含空格）传递，保留了原始的参数边界；使用"$@"，带双引号展开
#       传入时，命令后面跟随的所有参数会将作为一个整体看待，参数之间默认使用空格分隔，若参数自身包含空格，则会被分割成两个参数；使用$*，不带双引号展开
function runCommand() {
    #   选项参数整理，并从移除
    local no_quote
    [ "$1" == "--no-quote" ] && {
        no_quote="--no-quote"
        shift
    }
    #   输出执行命令
    printCommand "$@"
    #   执行命令;特别注意cmd不能使用"$cmd"，否则会提示命令找不到；一般会在命令上加上sudo，加上命令后，就会直接将"sudo 命令"识别为一个整体
    {
        local cmd="$1"
        shift
        #   $cmd $* 会给警告，这里是正常逻辑，忽略掉；两次判断做分支，if、else代码不简洁，采用此种方式
        # shellcheck disable=SC2048
        # shellcheck disable=SC2086
        [ "$no_quote" == "--no-quote" ] && $cmd $*   # 参数直接展开，若参数项自身存在空格，则会被分割成多个参数
        [ "$no_quote" == "--no-quote" ] || $cmd "$@" # 参数独立展开，即使参数项自身存在空格，也会被多为一个独立整体参数
    }
}
#   运行指定的长命令，将命令输出到屏幕
#   示例：runCommand [--no-quote] 要执行的命令 [命令参数]...
#   备注：参数将换行输出；适用于参数特别长的情况使用
#   备注："--no-quote"的影响
#       不传入时，命令后面跟每个参数都会被视为单独的字符串（即使参数包含空格）传递，保留了原始的参数边界；使用"$@"，带双引号展开
#       传入时，命令后面跟随的所有参数会将作为一个整体看待，参数之间默认使用空格分隔，若参数自身包含空格，则会被分割成两个参数；使用$*，不带双引号展开
function runLongCommand() {
    #   选项参数整理，并从移除
    local no_quote
    [ "$1" == "--no-quote" ] && {
        no_quote="--no-quote"
        shift
    }
    #   输出执行命令
    local -i cmd_index=0
    printf "\033[92;1m执行命令:\033[0m"
    for cmd_item in "$@"; do
        [ $cmd_index -gt 0 ] && printf "    "
        printf "\033[92;1m%s\033[0m" "${cmd_item}"
        ((cmd_index += 1))
        [ $cmd_index != "$#" ] && printf " \\"
        printf "\n"
    done
    #   执行命令;特别注意cmd不能使用"$cmd"，否则会提示命令找不到；一般会在命令上加上sudo，加上命令后，就会直接将"sudo 命令"识别为一个整体
    {
        local cmd="$1"
        shift
        #   $cmd $* 会给警告，这里是正常逻辑，忽略掉；两次判断做分支，if、else代码不简洁，采用此种方式
        # shellcheck disable=SC2048
        # shellcheck disable=SC2086
        [ "$no_quote" == "--no-quote" ] && $cmd $*   # 参数直接展开，若参数项自身存在空格，则会被分割成多个参数
        [ "$no_quote" == "--no-quote" ] || $cmd "$@" # 参数独立展开，即使参数项自身存在空格，也会被多为一个独立整体参数
    }
}

# ------------------------------------------【值验证】----------------------------------------------------
#   传入值无效时抛出异常
#   示例：throwInvalid 要判断的值 无效时的输出信息
function throwInvalid() {
    if [ "$1" == '' ]; then
        local msg=$2
        [ "${msg}" == '' ] && msg="无效值，但调用【throwInvalid】时未传入更详细的错误信息"
        logError "" "${msg}"
        exit 1
    fi
}

# ------------------------------------------【字符串处理】----------------------------------------------------
#   填充字符串长度；确保指定字符串够传入长度
#   示例：fixStrLen 字符串 最大长度
#   备注：传入字符串不够最大长度，则使用追加空格
#   备注：外部可 str=$(fixStrLen) 接收填充好的字符串
function fixStrLen() {
    local tmp_str=$1
    for ((i = $(echo "$tmp_str" | wc -L); i < $2; i++)); do
        tmp_str="${tmp_str} "
    done
    echo "${tmp_str}"
}
#   计算出数组中最大的的字符串长度
#   示例：calcMaxStrsLen str1 str2 ....
#   备注：基于  wc -L 判断长度，一个中文两个长度
#   备注：外部可 max=$(calcMaxStrsLen) 接收最大长度计算结果
function calcMaxStrsLen() {
    local max_len=0
    local tmp_len=0
    for item in "$@"; do
        tmp_len=$(echo "$item" | wc -L)
        [ "$tmp_len" -gt "$max_len" ] && max_len="$tmp_len"
    done
    echo "$max_len"
}
#   移除空白字符（空格、制表符、换行、、、）
#   示例：removeSpaceChar 要操作的字符串
#   备注：外部使用 str=$(removeSpaceChar)接收返回值
function removeSpaceChar() {
    # 拆分行数据时，最后一个元素会存在换行符，封装成公共方法对外提供
    #   IFS=' ' read -rd '' -a arr <<<"$line"

    local str=$(printf '%s' "$1" | tr -d '[:space:]')
    printf "%s" "$str"
}
#   是否以指定字符串开始
#   示例：startWithStr 原始字符串 判断字符串
#   返回：以判断字符串开始，则返回0；否则返回1
#   备注：区分大小写
function startWithStr() {
    # 空没有意义，直接返回1
    { [ "$1" == "" ] || [ "$2" == "" ]; } && return 1

    local -i ret
    [[ "$1" == "${2}"* ]] && ret=0 || ret=1
    return $ret

    # local str="$1"
    # local search="$2"
    # #   任意为空， 或者原始字符串长度小，则肯定为false
    # { [ "$str" == "" ] || [ "$search" == "" ] || [ "${#str}" -lt "${#search}" ]; } && return 1
    # #   从开始位置截取指定长度字符串做判断
    # str="${str:0:${#search}}"
    # [ "$str" == "$search" ] && return 0 || return 1
}
#   是否以指定字符串结尾
#   示例：endWithStr 原始字符串 判断字符串
#   返回：以判断字符串结尾，则返回0；否则返回1
#   备注：区分大小写
function endWithStr() {
    # 空没有意义，直接返回1
    { [ "$1" == "" ] || [ "$2" == "" ]; } && return 1

    local -i ret
    [[ "$1" == *"${2}" ]] && ret=0 || ret=1
    return $ret

    # local str="$1"
    # local search="$2"
    # #   任意为空， 或者原始字符串长度小，则肯定为false
    # { [ "$str" == "" ] || [ "$search" == "" ] || [ "${#str}" -lt "${#search}" ]; } && return 1
    # #   从开始位置截取指定长度字符串做判断
    # str="${str:0:${#search}}"
    # [ "$str" == "$search" ] && return 0 || return 1
}
#   是否包含指定字符串
#   示例：containsStr 原始字符串 判断字符串
#   返回：包含判断字符串，则返回0；否则返回1
#   备注：区分大小写
function containsStr() {
    # 空没有意义，直接返回1
    { [ "$1" == "" ] || [ "$2" == "" ]; } && return 1
    local -i ret
    [[ "$1" == *"${2}"* ]] && ret=0 || ret=1
    return $ret
}

# ------------------------------------------【数组操作】----------------------------------------------------
#   获取数组中指定的选项数据
#   示例：getArrayItems 数组变量名称 索引下标偏移量 数组下标1 [...数组下标n]
#   备注：偏移量，数组下标应从0开始，若传入的下标是从1开始，则偏移量传入-1
#   备注：若传入下标不在数组有效范围内，则自动忽略
#   备注：外部通过 readarray -t arr < <(getArrayItems) 读取取到的数据结果
function getArrayItems() {
    local -n arr="$1"
    local -i offset=$2
    shift && shift
    for item in "$@"; do
        ((item += "$offset"))
        { [ $item -lt 0 ] || [ $item -gt "${#arr[@]}" ]; } && continue
        printf "%s\n" "${arr[$item]}"
    done
}