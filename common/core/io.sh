#!/usr/bin/env bash
# shellcheck disable=SC2155     # local 定义变量并赋值时，提示赋值和定义分开，没啥用？

#***********************************************************************************************************
#   io相关操作；依赖./base.sh脚本
#       1、标准输入输出相关
#       2、文件、目录相关
#***********************************************************************************************************


# ------------------------------------------【准备工作】----------------------------------------------------
echo "--加载${BASH_SOURCE[0]} ..."
{
    __dir=$(dirname "${BASH_SOURCE[0]}")
    # shellcheck source="${__dir}/base.sh"
    [ ! -f "${__dir}/base.sh" ] && echo "依赖脚本[base.sh]不存在，请检查！" && exit 1
    # shellcheck disable=SC1091
    source "${__dir}/base.sh" 
}
#   引入依赖脚本

# ------------------------------------------【彩色输出】----------------------------------------------------
#   echo输出彩色文本
#       参数：第一个参数为 颜色信息（颜色数组[;风格]）；后续参数为输出的文本
#   示例：colorEcho 31 "红色文本";colorEcho "31;1" "红色高亮文本";
#       颜色信息详细参照：https://www.cnblogs.com/unclemac/p/12783387.html#21__40
#           风格：0=默认, 1=高亮, 4=下划线, 5=闪烁, 7=反显
#           前景色：30=黑色	  31=红色 32=绿色   33=黄色   34=蓝色 35=品红     36=青色   37=浅灰  39=默认
#                  90=深灰色 91=红灯 92=浅绿色 93=淡黄色 94=浅蓝 95=浅洋红色 96=浅青色 97=白色
#           背景色：40=黑色    41=红色  42=绿色    43=黄色    44=蓝色  45=品红      46=青色    47=浅灰  49=默认背景颜色
#                  100=深灰色 101=红灯 102=浅绿色 103=淡黄色 104=浅蓝 105=浅洋红色 106=浅青色 107=白色
function colorEcho() {
    local color="$1"
    shift
    echo -e "\033[${color}m$*\033[0m"
}
#   printf输出彩色文本
#       参数：第一个参数为 颜色信息（颜色数组[;风格]）；后续参数为输出的文本
#   示例：colorPrintf 31 "红色文本\n";colorPrintf "31;1" "红色高亮文本\n";
#       颜色信息详细参照：https://www.cnblogs.com/unclemac/p/12783387.html#21__40
#           风格：0=默认, 1=高亮, 4=下划线, 5=闪烁, 7=反显
#           前景色：30=黑色	  31=红色 32=绿色   33=黄色   34=蓝色 35=品红     36=青色   37=浅灰  39=默认
#                  90=深灰色 91=红灯 92=浅绿色 93=淡黄色 94=浅蓝 95=浅洋红色 96=浅青色 97=白色
#           背景色：40=黑色    41=红色  42=绿色    43=黄色    44=蓝色  45=品红      46=青色    47=浅灰  49=默认背景颜色
#                  100=深灰色 101=红灯 102=浅绿色 103=淡黄色 104=浅蓝 105=浅洋红色 106=浅青色 107=白色
function colorPrintf() {
    local color="$1"
    shift
    printf "\033[%sm$*\033[0m" "${color}"
}

# ------------------------------------------【信息清理】----------------------------------------------------
#   清理以前的所有输出信息
#   示例：clearAll
function clearAll() {
    # windterm终端执行清理时，一次清理不够，需要clear两次，这里做一下兼容
    clear
    sleep 0.1
    clear
}

# ------------------------------------------【选项展示】----------------------------------------------------
#   显示标题；一行一个标题，标题居中，前后用占位符填充
#   示例：showTitle title 占位符
function showTitle() {
    #   参数定义
    {
        #   标题信息
        local title=$1
        [ "$title" == '' ] && title=""
        readonly title
        #   标题长度
        local len_title
        len_title=$(echo "$title" | wc -L)
        readonly len_title
        #   终端一行的长度；最大120，太长了没有意义
        local len_row
        len_row=$(tput cols)
        [ "${len_row}" -gt 120 ] && len_row=120
        readonly len_row
        #   占位符，做默认值处理，后续判断占位符长度只能为1
        local char_ph=$2
        [ "$char_ph" == '' ] && char_ph="-"
        readonly char_ph
        #   标题的前后空白字符
        local char_title_wrap="${char_ph}${char_ph}"
        [ "$len_title" -gt 0 ] && char_title_wrap="  "
        readonly char_title_wrap
    }
    #   输出标题前半部分占位符
    local len_ph_tmp
    len_ph_tmp=$((("${len_row}" - "${len_title}" - 4) / 2))
    for ((i = 0; i < "$len_ph_tmp"; i++)); do printf "\033[32;1m%s\033[0m" "$char_ph"; done
    #   输出标题
    printf "\033[32;1m%s%s%s\033[0m" "$char_title_wrap" "$title" "$char_title_wrap"
    #   输出标题的后半部分占位符
    len_ph_tmp=$(("$len_row" - "$len_ph_tmp" - "$len_title" - 4))
    for ((i = 0; i < "$len_ph_tmp"; i++)); do printf "\033[32;1m%s\033[0m" "$char_ph"; done
    #   输出换行符
    printf "\n"
}
#   显示操作头部
#   示例：showActionHeader 操作名称 --keep-pre(保留以前输出)
function showActionHeader() {
    #   清理以前输出
    [ "$2" != "--keep-pre" ] && clearAll
    #   输出操作信息
    local title="$1"
    [ "$title" != "" ] && title="${title} "
    showTitle "" "-"
    logInfo "工作目录" "$(pwd)"
    # shellcheck disable=SC2154
    logInfo "执行操作" "${title}"
}
#   显示传入选项
#   示例：showItems 标题 添加序号(true、false) 每行选项数量 选项1 [\n] [...选项n]
#   备注：内部自动计算最大选项长度，其他的做自动补全操作
#   备注：若需要自动添加序号，则会针对每个选项追加从1开始的索引，方便展示选择
function showItems() {
    #   变量
    local tmp_title="$1"
    local need_index="$2"
    local -i row_count="$3"
    shift && shift && shift
    local tmp_items=("$@")
    #   追加序号；1-9选项，追加前空格
    if [ "$need_index" != "false" ]; then
        for ((i = 0; i < ${#tmp_items[@]}; i++)); do
            [ "${tmp_items[i]}" == '\n' ] && continue
            tmp_items[i]="$((i + 1)) : ${tmp_items[i]}"
            [ "$i" -lt 9 ] && tmp_items[i]=" ${tmp_items[i]}"
        done
    fi
    #   计算选项最大值；然后做补偿措施
    local max_len=$(calcMaxStrsLen "${tmp_items[@]}") && readonly max_len
    for ((i = 0; i < ${#tmp_items[@]}; i++)); do
        [ "${tmp_items[i]}" == '\n' ] && continue
        tmp_items[i]=$(fixStrLen "${tmp_items[i]}" "$max_len")
    done
    #   做输出，供用户选择
    local tmp_index=0
    showTitle "$tmp_title" "-"
    for ((i = 0; i < ${#tmp_items[@]}; i++)); do
        local item="${tmp_items[i]}"
        local needBreakWrap="false"
        #   打印输出选项
        if [ "$item" == '\n' ]; then
            needBreakWrap="true"
        else
            colorPrintf "32;1" "    %s" "$item"
            ((tmp_index += 1))
            { [ $(("$tmp_index" % "$row_count")) == 0 ] || [ $(("$i" + 1)) == "${#tmp_items[@]}" ]; } &&
                needBreakWrap="true"
        fi
        #   打印折行
        if [ "$needBreakWrap" == "true" ]; then
            printf "\n"
            tmp_index=0
        fi
    done
    showTitle "" "-"
}
#   输出选项，一行一个
#   示例：echoItems 选项1 选项2 。。。
function echoItems() {
    #   不直接使用echo，可能导致 * 会被识别为文件通配符，也个使用 set -f 禁用
    for item in "$@"; do
        printf "%s\n" "$item"
    done
}
# ------------------------------------------【文件目录相关】----------------------------------------------------
#   获取指定目录下的所有文件
#   示例：getAllFiles 父级目录路径 是否需要递归查找
#   备注：外部通过  readarray -t arr < <(getAllFiles) 得到组装好的文件数据
function getAllFiles() {
    [ ! -d "$1" ] && return
    # shellcheck disable=SC2045
    for file in $(ls "$1"); do
        local path="$1/${file}"
        #   目录；是否需要递归
        if [ -d "$path" ]; then
            [ "$2" != "true" ] && continue
            local -a fi_arrs
            getAllFiles "$path" "$2"
            # readarray -t fi_arrs < <(getAllFiles "$path" "$2")
            echoItems "${fi_arrs[@]}"
        #   文件
        elif [ -f "$path" ]; then
            printf "%s\n" "$path"
        fi
    done
}