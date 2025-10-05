#!/usr/bin/env bash

# 智能Git提交信息解析器
# 用于自动解析提交信息并生成CHANGELOG记录

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 脚本信息
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# 提交类型映射到CHANGELOG类型
declare -A COMMIT_TYPE_MAP=(
    # 标准类型
    ["feat"]="feat"
    ["feature"]="feat"
    ["fix"]="fix"
    ["docs"]="docs"
    ["doc"]="docs"
    ["style"]="refactor"
    ["refactor"]="refactor"
    ["perf"]="performance"
    ["test"]="test"
    ["chore"]="improvement"

    # 扩展类型
    ["improvement"]="improvement"
    ["impr"]="improvement"
    ["build"]="improvement"
    ["ci"]="improvement"
    ["example"]="example"
    ["security"]="security"
)

# 提交类型图标
declare -A TYPE_ICONS=(
    ["feat"]="🚀"
    ["fix"]="🐛"
    ["docs"]="📚"
    ["refactor"]="🔄"
    ["performance"]="⚡"
    ["test"]="🧪"
    ["improvement"]="🔧"
    ["example"]="💡"
    ["security"]="🔒"
)

# 解析提交信息
parse_commit_message() {
    local commit_message="$1"

    echo -e "${CYAN}🔍 解析提交信息:${NC}"
    echo "  📝 原始信息: $commit_message"
    echo

    # 提取类型
    local type=$(echo "$commit_message" | grep -oE '^[a-zA-Z]+(\([^)]*\))?:' | sed 's/[:()].*//')

    # 提取范围
    local scope=$(echo "$commit_message" | grep -oE '^[a-zA-Z]+\(([^)]*)\):' | sed 's/^[^(]*(//;s/).*$//')

    # 提取描述
    local description=$(echo "$commit_message" | sed -E 's/^[a-zA-Z]+(\([^)]*\))?: *//' | sed 's/\n.*$//')

    # 提取详细描述
    local body=$(echo "$commit_message" | sed -n '/^$/,$p' | sed '1d' | grep -v '^#' | grep -v '^$' | head -1)

    # 映射到CHANGELOG类型
    local changelog_type="${COMMIT_TYPE_MAP[$type]:-$type}"

    # 如果没有映射，尝试智能推断
    if [ -z "${COMMIT_TYPE_MAP[$type]}" ]; then
        changelog_type=$(infer_type_from_message "$commit_message")
    fi

    echo -e "${BLUE}📋 解析结果:${NC}"
    echo "  🏷️  类型: $type → $changelog_type"
    [ -n "$scope" ] && echo "  📁 范围: $scope"
    echo "  📄 描述: $description"
    [ -n "$body" ] && echo "  📝 详细: $body"
    echo

    # 输出结构化结果
    echo "TYPE=$changelog_type"
    echo "SCOPE=$scope"
    echo "DESCRIPTION=$description"
    echo "BODY=$body"
    echo "ORIGINAL_TYPE=$type"
}

# 智能推断变更类型
infer_type_from_message() {
    local message="$1"

    # 关键词匹配
    if echo "$message" | grep -iqE "(新增|添加|创建|实现|开发|支持)"; then
        echo "feat"
    elif echo "$message" | grep -iqE "(修复|解决|处理|更正|订正)"; then
        echo "fix"
    elif echo "$message" | grep -iqE "(文档|说明|指南|readme|changelog)"; then
        echo "docs"
    elif echo "$message" | grep -iqE "(优化|改进|提升|增强|改善)"; then
        echo "improvement"
    elif echo "$message" | grep -iqE "(重构|重写|整理|优化结构)"; then
        echo "refactor"
    elif echo "$message" | grep -iqE "(性能|速度|效率|内存|cpu)"; then
        echo "performance"
    elif echo "$message" | grep -iqE "(测试|单元测试|集成测试)"; then
        echo "test"
    elif echo "$message" | grep -iqE "(安全|漏洞|权限|认证)"; then
        echo "security"
    elif echo "$message" | grep -iqE "(示例|demo|模板)"; then
        echo "example"
    else
        echo "improvement"  # 默认类型
    fi
}

# 生成CHANGELOG记录
generate_changelog_entry() {
    local type="$1"
    local scope="$2"
    local description="$3"
    local body="$4"

    # 构建完整的描述
    local full_description="$description"
    if [ -n "$scope" ]; then
        full_description="[$scope] $description"
    fi

    if [ -n "$body" ]; then
        full_description="$full_description: $body"
    fi

    echo "CHANGELOG_ENTRY=$full_description"
}

# 显示帮助信息
show_help() {
    cat << EOF
智能Git提交信息解析器

用法: $0 [选项] <提交信息>

选项:
  --format <格式>    输出格式 (text|json|changelog)
  --auto             自动推断类型
  --help             显示此帮助信息

示例:
  $0 "feat: 添加用户登录功能"
  $0 "fix: 修复文件上传bug"
  $0 "docs: 更新API文档"

支持的提交类型:
  feat, fix, docs, style, refactor, perf, test, chore
  improvement, build, ci, example, security

输出格式:
  text    - 人类可读的解析结果 (默认)
  json    - JSON格式的结构化数据
  changelog - 直接用于CHANGELOG的格式
EOF
}

# 主程序
main() {
    local format="text"
    local auto_infer=false

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --format)
                format="$2"
                shift 2
                ;;
            --auto)
                auto_infer=true
                shift
                ;;
            --help|--help|-h)
                show_help
                exit 0
                ;;
            -*)
                echo "未知选项: $1" >&2
                show_help
                exit 1
                ;;
            *)
                break
                ;;
        esac
    done

    local commit_message="$*"

    if [ -z "$commit_message" ]; then
        echo "错误: 请提供提交信息" >&2
        show_help
        exit 1
    fi

    # 解析提交信息
    local parse_result=$(parse_commit_message "$commit_message")

    # 提取解析结果
    local type=$(echo "$parse_result" | grep "^TYPE=" | cut -d'=' -f2)
    local scope=$(echo "$parse_result" | grep "^SCOPE=" | cut -d'=' -f2)
    local description=$(echo "$parse_result" | grep "^DESCRIPTION=" | cut -d'=' -f2)
    local body=$(echo "$parse_result" | grep "^BODY=" | cut -d'=' -f2)

    # 生成CHANGELOG记录
    local changelog_entry=$(generate_changelog_entry "$type" "$scope" "$description" "$body")
    local entry_text=$(echo "$changelog_entry" | cut -d'=' -f2)

    case "$format" in
        "json")
            echo "{"
            echo "  \"type\": \"$type\","
            echo "  \"scope\": \"$scope\","
            echo "  \"description\": \"$description\","
            echo "  \"body\": \"$body\","
            echo "  \"changelog_entry\": \"$entry_text\""
            echo "}"
            ;;
        "changelog")
            echo "$entry_text"
            ;;
        "text"|*)
            if [ "$auto_infer" = true ]; then
                echo -e "${GREEN}✅ 建议的CHANGELOG记录:${NC}"
                echo -e "${TYPE_ICONS[$type]:-📝} $entry_text"
            else
                echo "$parse_result"
                echo "$changelog_entry"
            fi
            ;;
    esac
}

# 如果直接运行脚本
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi