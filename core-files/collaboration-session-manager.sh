#!/bin/bash

# 协作会话管理工具
# 用于跟踪和管理AI协作会话的状态

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 配置
SESSION_STATE_FILE=".collaboration-session.state"
COLLABORATION_DIR="docs/collaboration"
CONTENT_BUFFER_FILE=".collaboration-content.tmp"

# 显示帮助信息
show_help() {
    echo -e "${BLUE}协作会话管理工具${NC}"
    echo
    echo "用法: $0 [命令] [参数]"
    echo
    echo "命令:"
    echo "  start <paradigm> [topic]  - 开始新的协作会话"
    echo "  add-content <content>     - 添加会话内容"
    echo "  add-insight <insight>     - 添加关键洞察"
    echo "  add-output <output>       - 添加产出成果"
    echo "  add-action <action>       - 添加行动要点"
    echo "  status                    - 显示当前会话状态"
    echo "  save                      - 保存当前会话"
    echo "  list                      - 列出所有会话"
    echo "  help                      - 显示此帮助信息"
    echo
    echo "示例:"
    echo "  $0 start first-principles \"数据库性能优化\""
    echo "  $0 add-content \"讨论了索引优化策略\""
    echo "  $0 add-insight \"索引是空间换时间的权衡\""
    echo "  $0 save"
}

# 开始新的协作会话
start_session() {
    local paradigm="$1"
    local topic="${2:-untitled}"

    if [ -z "$paradigm" ]; then
        echo -e "${RED}错误: 请指定协作范式${NC}"
        show_help
        exit 1
    fi

    # 保存会话状态
    cat > "$SESSION_STATE_FILE" << EOF
COLLABORATE_PARADIGM="$paradigm"
COLLABORATE_TOPIC="$topic"
COLLABORATE_START_TIME="$(date)"
COLLABORATE_CONTENT=""
COLLABORATE_INSIGHTS=""
COLLABORATE_OUTPUTS=""
COLLABORATE_ACTIONS=""
EOF

    # 清空内容缓冲区
    > "$CONTENT_BUFFER_FILE"

    echo -e "${GREEN}✅ 协作会话已开始${NC}"
    echo -e "${CYAN}范式: $paradigm${NC}"
    echo -e "${CYAN}主题: $topic${NC}"
    echo -e "${YELLOW}💡 提示: 使用 'add-*' 命令添加内容，最后用 'save' 保存会话${NC}"
}

# 添加会话内容
add_content() {
    local content="$1"
    if [ -z "$content" ]; then
        echo -e "${RED}错误: 请提供要添加的内容${NC}"
        exit 1
    fi

    echo "### $(date '+%H:%M:%S')" >> "$CONTENT_BUFFER_FILE"
    echo "$content" >> "$CONTENT_BUFFER_FILE"
    echo "" >> "$CONTENT_BUFFER_FILE"

    echo -e "${GREEN}✅ 内容已添加${NC}"
}

# 添加关键洞察
add_insight() {
    local insight="$1"
    if [ -z "$insight" ]; then
        echo -e "${RED}错误: 请提供洞察内容${NC}"
        exit 1
    fi

    if [ -f "$SESSION_STATE_FILE" ]; then
        # 读取当前状态
        source "$SESSION_STATE_FILE"

        # 更新洞察
        if [ -n "$COLLABORATION_INSIGHTS" ]; then
            COLLABORATION_INSIGHTS="$COLLABORATION_INSIGHTS\n- $insight"
        else
            COLLABORATION_INSIGHTS="- $insight"
        fi

        # 保存更新后的状态
        sed -i.bak "s|^COLLABORATION_INSIGHTS=.*|COLLABORATION_INSIGHTS=\"$COLLABORATION_INSIGHTS\"|" "$SESSION_STATE_FILE"
        rm -f "$SESSION_STATE_FILE.bak"

        echo -e "${GREEN}✅ 关键洞察已添加${NC}"
    else
        echo -e "${RED}错误: 没有活跃的会话${NC}"
        echo -e "${YELLOW}请先使用 'start' 命令开始会话${NC}"
        exit 1
    fi
}

# 添加产出成果
add_output() {
    local output="$1"
    if [ -z "$output" ]; then
        echo -e "${RED}错误: 请提供产出内容${NC}"
        exit 1
    fi

    if [ -f "$SESSION_STATE_FILE" ]; then
        source "$SESSION_STATE_FILE"

        if [ -n "$COLLABORATION_OUTPUTS" ]; then
            COLLABORATION_OUTPUTS="$COLLABORATION_OUTPUTS\n- $output"
        else
            COLLABORATION_OUTPUTS="- $output"
        fi

        sed -i.bak "s|^COLLABORATION_OUTPUTS=.*|COLLABORATION_OUTPUTS=\"$COLLABORATION_OUTPUTS\"|" "$SESSION_STATE_FILE"
        rm -f "$SESSION_STATE_FILE.bak"

        echo -e "${GREEN}✅ 产出成果已添加${NC}"
    else
        echo -e "${RED}错误: 没有活跃的会话${NC}"
        exit 1
    fi
}

# 添加行动要点
add_action() {
    local action="$1"
    if [ -z "$action" ]; then
        echo -e "${RED}错误: 请提供行动要点${NC}"
        exit 1
    fi

    if [ -f "$SESSION_STATE_FILE" ]; then
        source "$SESSION_STATE_FILE"

        if [ -n "$COLLABORATION_ACTIONS" ]; then
            COLLABORATION_ACTIONS="$COLLABORATION_ACTIONS\n- [ ] $action"
        else
            COLLABORATION_ACTIONS="- [ ] $action"
        fi

        sed -i.bak "s|^COLLABORATION_ACTIONS=.*|COLLABORATION_ACTIONS=\"$COLLABORATION_ACTIONS\"|" "$SESSION_STATE_FILE"
        rm -f "$SESSION_STATE_FILE.bak"

        echo -e "${GREEN}✅ 行动要点已添加${NC}"
    else
        echo -e "${RED}错误: 没有活跃的会话${NC}"
        exit 1
    fi
}

# 显示当前会话状态
show_status() {
    if [ -f "$SESSION_STATE_FILE" ]; then
        echo -e "${BLUE}📊 当前会话状态${NC}"
        echo "────────────────────────────────────"

        source "$SESSION_STATE_FILE"

        echo -e "${CYAN}范式:${NC} $COLLABORATE_PARADIGM"
        echo -e "${CYAN}主题:${NC} $COLLABORATE_TOPIC"
        echo -e "${CYAN}开始时间:${NC} $COLLABORATE_START_TIME"

        if [ -f "$CONTENT_BUFFER_FILE" ] && [ -s "$CONTENT_BUFFER_FILE" ]; then
            local content_lines=$(wc -l < "$CONTENT_BUFFER_FILE")
            echo -e "${CYAN}内容条数:${NC} $content_lines"
        fi

        echo "────────────────────────────────────"
    else
        echo -e "${YELLOW}⚠️  当前没有活跃的会话${NC}"
        echo -e "${YELLOW}使用 'start' 命令开始新会话${NC}"
    fi
}

# 保存当前会话
save_session() {
    if [ ! -f "$SESSION_STATE_FILE" ]; then
        echo -e "${RED}错误: 没有活跃的会话${NC}"
        exit 1
    fi

    echo -e "${BLUE}💾 正在保存协作会话...${NC}"

    # 读取会话状态
    source "$SESSION_STATE_FILE"

    # 设置环境变量供保存脚本使用
    export COLLABORATE_PARADIGM
    export COLLABORATE_TOPIC
    export COLLABORATION_INSIGHTS
    export COLLABORATION_OUTPUTS
    export COLLABORATION_ACTIONS
    export COLLABORATION_CONTENT_FILE="$CONTENT_BUFFER_FILE"

    # 调用保存脚本
    if [ -f ".specify/scripts/bash/save-collaboration-session.sh" ]; then
        .specify/scripts/bash/save-collaboration-session.sh

        # 清理会话状态
        rm -f "$SESSION_STATE_FILE" "$CONTENT_BUFFER_FILE"

        echo -e "${GREEN}✅ 会话保存成功${NC}"
    else
        echo -e "${RED}错误: 保存脚本不存在${NC}"
        exit 1
    fi
}

# 列出所有会话
list_sessions() {
    echo -e "${BLUE}📚 协作会话列表${NC}"
    echo "────────────────────────────────────"

    if [ -f "$COLLABORATION_DIR/index.md" ]; then
        # 显示索引内容（跳过表头）
        tail -n +4 "$COLLABORATION_DIR/index.md" | head -n -2
    else
        echo -e "${YELLOW}还没有保存的会话${NC}"
    fi
}

# 主程序
main() {
    case "$1" in
        "start")
            start_session "$2" "$3"
            ;;
        "add-content")
            add_content "$2"
            ;;
        "add-insight")
            add_insight "$2"
            ;;
        "add-output")
            add_output "$2"
            ;;
        "add-action")
            add_action "$2"
            ;;
        "status")
            show_status
            ;;
        "save")
            save_session
            ;;
        "list")
            list_sessions
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

main "$@"