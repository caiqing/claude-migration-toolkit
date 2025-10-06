#!/usr/bin/env bash

# 智能中文语义分支命名系统
# 用于替代 create-new-feature.sh 中的分支命名逻辑

set -e

# 中文关键词到英文的智能映射
declare -A SEMANTIC_MAP=(
    # 功能相关
    ["脚本"]="script"
    ["代码"]="code"
    ["语义"]="semantic"
    ["解释"]="explain"
    ["分析"]="analysis"
    ["处理"]="process"
    ["生成"]="generate"
    ["管理"]="manage"
    ["系统"]="system"

    # 用户交互
    ["用户"]="user"
    ["登录"]="login"
    ["注册"]="register"
    ["认证"]="auth"
    ["权限"]="permission"
    ["角色"]="role"

    # 文件操作
    ["文件"]="file"
    ["上传"]="upload"
    ["下载"]="download"
    ["导入"]="import"
    ["导出"]="export"
    ["存储"]="storage"

    # 数据处理
    ["数据"]="data"
    ["数据库"]="database"
    ["报表"]="report"
    ["统计"]="stats"
    ["可视化"]="visual"
    ["图表"]="chart"

    # 界面显示
    ["界面"]="ui"
    ["页面"]="page"
    ["组件"]="component"
    ["显示"]="display"
    ["渲染"]="render"
    ["布局"]="layout"

    # API和服务
    ["接口"]="api"
    ["服务"]="service"
    ["请求"]="request"
    ["响应"]="response"
    ["调用"]="call"

    # 通用词汇
    ["功能"]="feature"
    ["工具"]="tool"
    ["助手"]="assistant"
    ["平台"]="platform"
    ["应用"]="app"
    ["模块"]="module"
)

# 停用词列表（不参与分支命名）
declare -a STOP_WORDS=(
    "的" "和" "与" "或" "支持" "实现" "创建" "一个" "功能" "系统" "方式"
    "导入" "需" "等" "对" "通过" "进行" "提供" "用于" "基于" "包含"
    "可以" "能够" "允许" "帮助" "方便" "优化" "提升" "改善" "增强"
    "多种" "各种" "不同" "相关" "主要" "核心" "关键" "重要" "基本"
    "基于" "面向" "针对" "适用于" "专门用于" "设计用于"
)

# 智能语义关键词提取
extract_semantic_keywords() {
    local description="$1"

    # 1. 分割中文词汇（简单实现，实际可使用jieba等分词库）
    local words=$(echo "$description" | grep -o -E '[一-龯]{2,}' | sort -u)

    # 2. 过滤停用词
    local filtered_words=""
    while IFS= read -r word; do
        if [ -n "$word" ]; then
            is_stop_word=false
            for stop_word in "${STOP_WORDS[@]}"; do
                if [[ "$word" == "$stop_word" ]]; then
                    is_stop_word=true
                    break
                fi
            done

            if [ "$is_stop_word" = false ]; then
                filtered_words="$filtered_words $word"
            fi
        fi
    done <<< "$words"

    echo "$filtered_words"
}

# 语义映射转换
semantic_mapping() {
    local keywords="$1"
    local mapped_words=""

    while IFS= read -r word; do
        if [ -n "$word" ]; then
            # 查找语义映射
            if [[ -v SEMANTIC_MAP["$word"] ]]; then
                mapped_words="$mapped_words ${SEMANTIC_MAP[$word]}"
            else
                # 对于没有映射的词，使用简单的启发式规则
                heuristic_result=$(heuristic_mapping "$word")
                if [ -n "$heuristic_result" ]; then
                    mapped_words="$mapped_words $heuristic_result"
                fi
            fi
        fi
    done <<< "$(echo "$keywords" | tr ' ' '\n')"

    echo "$mapped_words" | sed 's/^ *//' | sed 's/ *$//'
}

# 启发式映射（处理未预定义的词汇）
heuristic_mapping() {
    local word="$1"

    # 基于字符的启发式规则
    case "$word" in
        *编辑*|*修改*) echo "edit" ;;
        *删除*|*移除*) echo "delete" ;;
        *查看*|*浏览*) echo "view" ;;
        *搜索*|*查找*) echo "search" ;;
        *配置*|*设置*) echo "config" ;;
        *测试*|*验证*) echo "test" ;;
        *监控*|*检测*) echo "monitor" ;;
        *同步*|*更新*) echo "sync" ;;
        *备份*|*恢复*) echo "backup" ;;
        *计算*|*运算*) echo "compute" ;;
        *转换*|*格式化*) echo "convert" ;;
        *发送*|*推送*) echo "send" ;;
        *接收*|*获取*) echo "receive" ;;
        *验证*|*校验*) echo "validate" ;;
        *压缩*|*解压*) echo "compress" ;;
        *加密*|*解密*) echo "encrypt" ;;
        *缓存*) echo "cache" ;;
        *队列*) echo "queue" ;;
        *日志*) echo "log" ;;
        *消息*) echo "message" ;;
        *通知*) echo "notify" ;;
        *定时*|*计划*) echo "schedule" ;;
        *权限*|*授权*) echo "permission" ;;
        *模板*) echo "template" ;;
        *插件*) echo "plugin" ;;
        *主题*) echo "theme" ;;
        *语言*) echo "lang" ;;
        *国际化*) echo "i18n" ;;
        *本地化*) echo "l10n" ;;
        *) echo "" ;;
    esac
}

# 模式匹配（针对常见的功能模式）
pattern_matching() {
    local description="$1"
    local feature_num="$2"

    # 用户相关模式
    if [[ "$description" == *"用户"* ]]; then
        if [[ "$description" == *"登录"* ]] || [[ "$description" == *"注册"* ]]; then
            echo "${feature_num}-user-auth"
            return
        elif [[ "$description" == *"管理"* ]]; then
            echo "${feature_num}-user-manage"
            return
        elif [[ "$description" == *"权限"* ]]; then
            echo "${feature_num}-user-permission"
            return
        else
            echo "${feature_num}-user-feature"
            return
        fi
    fi

    # 文件相关模式
    if [[ "$description" == *"文件"* ]]; then
        if [[ "$description" == *"上传"* ]] || [[ "$description" == *"下载"* ]]; then
            echo "${feature_num}-file-transfer"
            return
        elif [[ "$description" == *"管理"* ]]; then
            echo "${feature_num}-file-manage"
            return
        else
            echo "${feature_num}-file-process"
            return
        fi
    fi

    # 数据相关模式
    if [[ "$description" == *"数据"* ]]; then
        if [[ "$description" == *"分析"* ]] || [[ "$description" == *"报表"* ]]; then
            echo "${feature_num}-data-analysis"
            return
        elif [[ "$description" == *"可视化"* ]] || [[ "$description" == *"图表"* ]]; then
            echo "${feature_num}-data-visual"
            return
        else
            echo "${feature_num}-data-process"
            return
        fi
    fi

    # API相关模式
    if [[ "$description" == *"接口"* ]] || [[ "$description" == *"API"* ]]; then
        echo "${feature_num}-api-feature"
        return
    fi

    # 未匹配到模式
    echo ""
}

# 智能分支名称生成（主函数）
generate_intelligent_branch_name() {
    local description="$1"
    local feature_num="$2"

    # 方法1：模式匹配（最高优先级）
    local pattern_result=$(pattern_matching "$description" "$feature_num")
    if [ -n "$pattern_result" ]; then
        echo "$pattern_result"
        return
    fi

    # 方法2：智能语义提取
    local keywords=$(extract_semantic_keywords "$description")
    if [ -n "$keywords" ]; then
        local mapped_words=$(semantic_mapping "$keywords")
        if [ -n "$mapped_words" ]; then
            # 清理和格式化
            local clean_name=$(echo "$mapped_words" | \
                tr ' ' '-' | \
                tr '[:upper:]' '[:lower:]' | \
                sed 's/[^a-z0-9-]/-/g' | \
                sed 's/-\+/-/g' | \
                sed 's/^-//' | \
                sed 's/-$//')

            # 限制单词数量和长度
            local final_name=$(echo "$clean_name" | \
                tr '-' '\n' | \
                head -4 | \
                tr '\n' '-' | \
                sed 's/-$//')

            if [ -n "$final_name" ] && [ "$final_name" != "-" ]; then
                echo "${feature_num}-${final_name}"
                return
            fi
        fi
    fi

    # 方法3：基于长度的简单提取（fallback）
    local simple_extract=$(echo "$description" | \
        grep -o -E '[一-龯]{2,}' | \
        head -2 | \
        tr '\n' '-' | \
        sed 's/-$//')

    if [ -n "$simple_extract" ]; then
        echo "${feature_num}-chinese-feature"
        return
    fi

    # 最后的fallback
    echo "${feature_num}-feature"
}

# 测试函数
test_branch_naming() {
    echo "=== 智能分支命名测试 ==="

    local test_cases=(
        "实现一个MagicScript脚本代码的语义解释功能，支持对通过代码文件上传、代码文本粘贴等方式导入需解释的MagicScript脚本代码，支持导入代码的语法高亮显示"
        "创建用户登录和注册管理系统，支持邮箱和手机号验证"
        "开发文件上传下载功能，支持多种格式文件的处理"
        "实现数据分析和报表生成系统，支持实时数据展示"
        "构建API接口管理平台，提供接口文档和测试功能"
        "设计一个智能推荐系统，基于用户行为分析"
        "实现商品库存管理和预警功能"
        "创建在线聊天室和消息推送系统"
        "开发图片压缩和格式转换工具"
        "实现定时任务调度和监控系统"
    )

    for i in "${!test_cases[@]}"; do
        local feature_num=$(printf "%03d" $((i+1)))
        local description="${test_cases[$i]}"

        echo "测试 $((i+1)):"
        echo "  描述: ${description:0:50}..."
        echo "  分支名: $(generate_intelligent_branch_name "$description" "$feature_num")"
        echo ""
    done
}

# 如果直接运行脚本，则执行测试
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    test_branch_naming
fi