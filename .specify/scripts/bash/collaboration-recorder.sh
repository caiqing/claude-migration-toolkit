#!/bin/bash

# AI协作会话自动记录器
# 在用户使用 /collaborate 命令时自动记录完整的对话过程

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 配置
SESSION_STATE_FILE=".collaboration-session.state"
COLLABORATION_AUTOMATION_SCRIPT=".specify/scripts/bash/collaboration-session-automation.sh"

# 检查是否有活跃的协作会话
check_active_session() {
    if [ ! -f "$SESSION_STATE_FILE" ]; then
        echo -e "${RED}❌ 当前没有活跃的协作会话${NC}"
        echo -e "${YELLOW}💡 请先使用 /collaborate [范式] [主题] 开始协作会话${NC}"
        return 1
    fi
    return 0
}

# 记录用户消息
record_user_message() {
    local message="$1"

    if ! check_active_session; then
        return 1
    fi

    if [ -z "$message" ]; then
        echo -e "${RED}❌ 消息内容不能为空${NC}"
        return 1
    fi

    "$COLLABORATION_AUTOMATION_SCRIPT" add-message "user" "$message"
    echo -e "${GREEN}✅ 用户消息已记录${NC}"
}

# 记录AI回复
record_ai_message() {
    local message="$1"

    if ! check_active_session; then
        return 1
    fi

    if [ -z "$message" ]; then
        echo -e "${RED}❌ 消息内容不能为空${NC}"
        return 1
    fi

    "$COLLABORATION_AUTOMATION_SCRIPT" add-message "assistant" "$message"
    echo -e "${GREEN}✅ AI回复已记录${NC}"
}

# 显示会话状态
show_status() {
    if check_active_session; then
        "$COLLABORATION_AUTOMATION_SCRIPT" status
    fi
}

# 保存会话
save_session() {
    if check_active_session; then
        "$COLLABORATION_AUTOMATION_SCRIPT" save
    fi
}

# 添加内容（手动）
add_content() {
    local content="$1"

    if check_active_session; then
        "$COLLABORATION_AUTOMATION_SCRIPT" add-content "$content"
    fi
}

# 添加洞察（手动）
add_insight() {
    local insight="$1"

    if check_active_session; then
        "$COLLABORATION_AUTOMATION_SCRIPT" add-insight "$insight"
    fi
}

# 添加产出（手动）
add_output() {
    local output="$1"

    if check_active_session; then
        "$COLLABORATION_AUTOMATION_SCRIPT" add-output "$output"
    fi
}

# 添加行动（手动）
add_action() {
    local action="$1"

    if check_active_session; then
        "$COLLABORATION_AUTOMATION_SCRIPT" add-action "$action"
    fi
}

# 显示帮助信息
show_help() {
    echo -e "${BLUE}🤖 AI协作会话自动记录器${NC}"
    echo
    echo "用法: $0 [命令] [参数]"
    echo
    echo "命令:"
    echo "  user <message>     - 记录用户消息"
    echo "  ai <message>       - 记录AI回复"
    echo "  status             - 显示会话状态"
    echo "  save               - 保存当前会话"
    echo "  content <text>     - 添加讨论内容"
    echo "  insight <text>     - 添加关键洞察"
    echo "  output <text>      - 添加产出成果"
    echo "  action <text>      - 添加行动要点"
    echo "  help               - 显示此帮助信息"
    echo
    echo "示例:"
    echo "  $0 user \"请用第一性原理分析数据库性能优化\""
    echo "  $0 ai \"让我们从基础原理开始分析...\""
    echo "  $0 status"
    echo "  $0 save"
    echo
    echo "注意：此工具需要先通过 /collaborate 命令启动协作会话"
}

# 主程序
main() {
    case "$1" in
        "user")
            record_user_message "$2"
            ;;
        "ai")
            record_ai_message "$2"
            ;;
        "status")
            show_status
            ;;
        "save")
            save_session
            ;;
        "content")
            add_content "$2"
            ;;
        "insight")
            add_insight "$2"
            ;;
        "output")
            add_output "$2"
            ;;
        "action")
            add_action "$2"
            ;;
        "help"|"--help"|"-h"|"")
            show_help
            ;;
        *)
            echo -e "${RED}错误: 未知命令 '$1'${NC}"
            show_help
            exit 1
            ;;
    esac
}

# 执行主程序
main "$@"