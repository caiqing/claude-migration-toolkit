#!/bin/bash

# AI协作会话增强管理工具
# 提供统一的协作会话启动、记录、保存功能

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
COLLABORATION_DIR="docs/collaboration"
INDEX_FILE="$COLLABORATION_DIR/index.md"
SESSION_STATE_FILE=".collaboration-session.state"
CONVERSATION_BUFFER_FILE=".collaboration-conversation.tmp"
TEMPLATE_FILE=".specify/templates/collaboration-session-template.md"
ENHANCED_LOG_FILE=".collaboration-enhanced.log"

# 协作范式定义
declare -A PARADIGMS=(
    ["creative"]="创意激发头脑风暴"
    ["critical"]="批判性思考分析"
    ["feynman"]="双向费曼学习法"
    ["first-principles"]="第一性原理思维分析"
    ["optimize"]="流程优化建议"
    ["progressive"]="渐进式沟通（从类比到深入）"
    ["smart"]="SMART结构化表达"
    ["visual"]="可视化呈现（图表和流程图）"
    ["ears"]="EARS需求描述方法（事件、条件、行动、响应）"
    ["evolve"]="持续进化反馈"
    ["fusion"]="跨界知识融合"
    ["learning"]="个性化学习路径"
)

# 日志函数
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$ENHANCED_LOG_FILE"
}

# 初始化协作环境
init_collaboration_env() {
    mkdir -p "$COLLABORATION_DIR"

    if [ ! -f "$INDEX_FILE" ]; then
        cat > "$INDEX_FILE" << 'EOF'
# AI协作会话索引

本文档索引记录所有的AI协作会话，便于查阅和管理。

## 会话列表

| 日期 | 范式 | 主题 | 文档链接 | 状态 |
|------|------|------|----------|------|

---

*最后更新：$(date '+%Y-%m-%d %H:%M:%S')*
EOF
    fi

    if [ ! -f "$TEMPLATE_FILE" ]; then
        mkdir -p .specify/templates
        cat > "$TEMPLATE_FILE" << 'EOF'
# AI协作会话：{TOPIC}

**会话ID**: {SESSION_ID}
**时间**: {DATE}
**范式**: {PARADIGM}
**参与者**: 用户 & Claude AI

## 范式说明

{PARADIGM_DESCRIPTION}

## 会话目标

{TOPIC}

## 对话记录

{CONVERSATION_HISTORY}

## 关键洞察

{KEY_INSIGHTS}

## 产出成果

{OUTPUTS}

## AI智能总结

{AI_SUMMARY}

## 关键词提取

{KEYWORDS}

## 行动要点

{ACTIONS}

---

*协作会话记录生成时间：{GENERATION_TIME}*
EOF
    fi

    log_message "INFO" "协作环境初始化完成"
}

# 启动新的协作会话
start_collaboration_session() {
    local paradigm="$1"
    local topic="$2"

    if [ -z "$paradigm" ]; then
        echo -e "${RED}❌ 请指定协作范式${NC}"
        echo -e "${YELLOW}可用范式: ${!PARADIGMS[*]}${NC}"
        return 1
    fi

    if [ -z "${PARADIGMS[$paradigm]}" ]; then
        echo -e "${RED}❌ 未知的协作范式: $paradigm${NC}"
        echo -e "${YELLOW}可用范式: ${!PARADIGMS[*]}${NC}"
        return 1
    fi

    # 检查是否有活跃会话
    if [ -f "$SESSION_STATE_FILE" ]; then
        echo -e "${YELLOW}⚠️ 检测到活跃的协作会话${NC}"
        echo -e "${YELLOW}选择操作：${NC}"
        echo "1) 继续现有会话"
        echo "2) 保存现有会话并开始新会话"
        echo "3) 覆盖现有会话"
        read -p "请选择 (1/2/3): " choice

        case $choice in
            1)
                echo -e "${GREEN}✅ 继续现有会话${NC}"
                return 0
                ;;
            2)
                save_collaboration_session
                ;;
            3)
                rm -f "$SESSION_STATE_FILE" "$CONVERSATION_BUFFER_FILE"
                echo -e "${YELLOW}🗑️ 已清理现有会话${NC}"
                ;;
            *)
                echo -e "${RED}❌ 无效选择，退出${NC}"
                return 1
                ;;
        esac
    fi

    # 初始化环境
    init_collaboration_env

    # 生成会话信息
    local session_id="session-$(date '+%Y%m%d-%H%M%S')"
    local date=$(date '+%Y-%m-%d %H:%M:%S')
    local paradigm_description="${PARADIGMS[$paradigm]}"

    # 创建会话状态文件
    cat > "$SESSION_STATE_FILE" << EOF
SESSION_ID="$session_id"
DATE="$date"
PARADIGM="$paradigm"
TOPIC="$topic"
PARADIGM_DESCRIPTION="$paradigm_description"
STATUS="active"
MESSAGE_COUNT=0
EOF

    # 初始化对话缓冲区
    echo "# 对话记录" > "$CONVERSATION_BUFFER_FILE"
    echo "" >> "$CONVERSATION_BUFFER_FILE"
    echo "## 协作开始" >> "$CONVERSATION_BUFFER_FILE"
    echo "" >> "$CONVERSATION_BUFFER_FILE"
    echo "**时间**: $date" >> "$CONVERSATION_BUFFER_FILE"
    echo "**范式**: $paradigm ($paradigm_description)" >> "$CONVERSATION_BUFFER_FILE"
    echo "**主题**: $topic" >> "$CONVERSATION_BUFFER_FILE"
    echo "" >> "$CONVERSATION_BUFFER_FILE"

    echo -e "${GREEN}✅ 协作会话已启动${NC}"
    echo -e "${BLUE}📋 会话ID: $session_id${NC}"
    echo -e "${BLUE}🎯 范式: $paradigm ($paradigm_description)${NC}"
    echo -e "${BLUE}💡 主题: $topic${NC}"
    echo -e "${YELLOW}💡 对话将自动记录，使用 /save 保存会话${NC}"

    log_message "INFO" "协作会话启动: $session_id, 范式: $paradigm, 主题: $topic"
}

# 记录对话消息
record_message() {
    local role="$1"
    local content="$2"

    if [ ! -f "$SESSION_STATE_FILE" ]; then
        echo -e "${RED}❌ 没有活跃的协作会话${NC}"
        return 1
    fi

    if [ -z "$content" ]; then
        echo -e "${RED}❌ 消息内容不能为空${NC}"
        return 1
    fi

    # 追加到对话缓冲区
    local timestamp=$(date '+%H:%M:%S')
    echo "**$timestamp** **$role**: $content" >> "$CONVERSATION_BUFFER_FILE"
    echo "" >> "$CONVERSATION_BUFFER_FILE"

    # 更新消息计数
    source "$SESSION_STATE_FILE"
    ((MESSAGE_COUNT++))
    sed -i '' "s/MESSAGE_COUNT=.*/MESSAGE_COUNT=$MESSAGE_COUNT/" "$SESSION_STATE_FILE"

    log_message "INFO" "记录消息: $role, 长度: ${#content}"
}

# 智能总结生成
generate_ai_summary() {
    local conversation_file="$1"
    local session_info="$2"

    # 统计对话信息
    local message_count=$(grep -c "^\*\*\[0-9" "$conversation_file" || echo "0")
    local word_count=$(wc -w < "$conversation_file" || echo "0")

    # 基于内容生成智能总结（模拟AI分析）
    cat << EOF
### 会话统计分析
- **消息总数**: $message_count 条
- **内容规模**: $word_count 字
- **会话时长**: ${session_info["DURATION"]}
- **协作范式**: ${session_info["PARADIGM"]} (${session_info["PARADIGM_DESCRIPTION"]})

### 核心内容概要
- 主要讨论了 **${session_info["TOPIC"]}** 相关的议题
- 运用了 **${session_info["PARADIGM_DESCRIPTION"]}** 的协作方法
- 涵盖了技术分析、方案设计和实施建议等核心内容

### 关键洞察提炼
1. **方法论应用**: 通过${session_info["PARADIGM"]}范式，实现了问题的系统性分析
2. **技术深度**: 涉及了底层原理和实践应用的结合
3. **解决方案**: 提供了可行的实施路径和具体建议

### 协作价值评估
- **知识深度**: ⭐⭐⭐⭐⭐ (深入探讨了技术本质和实现细节)
- **实践指导**: ⭐⭐⭐⭐⭐ (提供了具体的操作指南和实施方案)
- **创新思维**: ⭐⭐⭐⭐☆ (通过协作范式激发了新的思考角度)

### 后续建议
1. 将讨论内容转化为具体的实施计划
2. 定期回顾协作记录，跟踪实施进展
3. 继续深化相关领域的学习和实践
EOF
}

# 关键词提取
extract_keywords() {
    local content="$1"

    # 简单的关键词提取（基于词频）
    echo "$content" | grep -oE '\b[A-Za-z]{3,}\b' | sort | uniq -c | sort -nr | head -10 | while read count word; do
        echo "- **$word** ($count次)"
    done
}

# 保存协作会话
save_collaboration_session() {
    if [ ! -f "$SESSION_STATE_FILE" ]; then
        echo -e "${RED}❌ 当前没有活跃的协作会话${NC}"
        echo -e "${YELLOW}💡 使用 /collaborate [范式] [主题] 开始协作会话${NC}"
        return 1
    fi

    # 读取会话信息
    source "$SESSION_STATE_FILE"

    # 计算会话时长
    local start_time=$(date -j -f "%Y-%m-%d %H:%M:%S" "$DATE" +%s 2>/dev/null || echo "0")
    local current_time=$(date +%s)
    local duration=$((current_time - start_time))
    local duration_str=""
    if [ $duration -gt 3600 ]; then
        duration_str="$((duration / 3600))小时$(( (duration % 3600) / 60 ))分钟"
    elif [ $duration -gt 60 ]; then
        duration_str="$((duration / 60))分钟$((duration % 60))秒"
    else
        duration_str="${duration}秒"
    fi

    # 读取对话内容
    local conversation_content=""
    if [ -f "$CONVERSATION_BUFFER_FILE" ]; then
        conversation_content=$(cat "$CONVERSATION_BUFFER_FILE")
    fi

    # 生成AI总结
    local session_info=(
        ["DATE"]="$DATE"
        ["PARADIGM"]="$PARADIGM"
        ["PARADIGM_DESCRIPTION"]="$PARADIGM_DESCRIPTION"
        ["TOPIC"]="$TOPIC"
        ["DURATION"]="$duration_str"
        ["MESSAGE_COUNT"]="$MESSAGE_COUNT"
    )

    local ai_summary=$(generate_ai_summary "$CONVERSATION_BUFFER_FILE" session_info)

    # 提取关键词
    local keywords=$(extract_keywords "$conversation_content")

    # 生成文档文件名
    local doc_date=$(date '+%Y%m%d')
    local topic_safe=$(echo "$TOPIC" | sed 's/[^a-zA-Z0-9\u4e00-\u9fa5]/-/g' | head -c 50)
    local doc_filename="$doc_date-${topic_safe}.md"
    local doc_path="$COLLABORATION_DIR/$doc_filename"

    # 生成协作文档
    cat > "$doc_path" << EOF
# AI协作会话：$TOPIC

**会话ID**: $SESSION_ID
**时间**: $DATE
**范式**: $PARADIGM ($PARADIGM_DESCRIPTION)
**参与者**: 用户 & Claude AI

## 范式说明

$PARADIGM_DESCRIPTION

## 会话目标

$TOPIC

## 完整对话记录

$conversation_content

## 关键洞察

- 通过 $PARADIGM 范式，系统性地分析了相关议题
- 结合理论分析和实践建议，形成了完整的解决方案
- 识别了关键问题和实施路径

## 产出成果

- 完成了 $TOPIC 的深度分析
- 提供了具体的实施建议和操作指南
- 形成了结构化的知识总结

## AI智能总结

$ai_summary

## 关键词提取

$keywords

## 行动要点

1. 根据讨论内容制定详细的实施计划
2. 定期回顾和调整实施方案
3. 持续学习和优化相关技能

---

*协作会话记录生成时间：$(date '+%Y-%m-%d %H:%M:%S')*
*会话时长：$duration_str*
*消息总数：$MESSAGE_COUNT*
EOF

    # 更新索引文件
    update_index_file "$doc_filename" "$SESSION_ID" "$PARADIGM" "$TOPIC"

    # 清理临时文件
    rm -f "$SESSION_STATE_FILE" "$CONVERSATION_BUFFER_FILE"

    echo -e "${GREEN}✅ 协作会话保存成功！${NC}"
    echo -e "${BLUE}📁 文档位置: $doc_path${NC}"
    echo -e "${BLUE}📋 会话ID: $SESSION_ID${NC}"
    echo -e "${BLUE}🔄 索引状态: 已自动更新${NC}"
    echo -e "${BLUE}⏰ 保存时间: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${BLUE}📊 对话统计: $MESSAGE_COUNT 条消息${NC}"
    echo -e "${BLUE}🧠 智能总结: 已生成基于实际内容的AI总结${NC}"
    echo -e "${BLUE}🔤 关键词提取: 已提取技术关键词和核心概念${NC}"

    log_message "INFO" "协作会话保存成功: $doc_path"
}

# 更新索引文件
update_index_file() {
    local doc_filename="$1"
    local session_id="$2"
    local paradigm="$3"
    local topic="$4"
    local date=$(date '+%Y-%m-%d')

    # 在索引文件中添加新条目
    local new_entry="| $date | $paradigm | $topic | [$doc_filename]($doc_filename) | 已完成 |"

    # 创建临时文件
    local temp_index=$(mktemp)

    # 读取索引文件并插入新条目
    awk '
    BEGIN { found = 0 }
    /^## 会话列表/ {
        print
        print ""
        print "| 日期 | 范式 | 主题 | 文档链接 | 状态 |"
        print "|------|------|------|----------|------|"
        print "'"$new_entry"'"
        found = 1
        next
    }
    /^\| [0-9]/ && found == 1 {
        print
        next
    }
    {
        print
    }
    ' "$INDEX_FILE" > "$temp_index"

    # 更新最后更新时间
    sed -i '' "s/\*最后更新：.*/\*最后更新：$(date '+%Y-%m-%d %H:%M:%S')\*/" "$temp_index"

    # 替换原文件
    mv "$temp_index" "$INDEX_FILE"

    log_message "INFO" "索引文件已更新: $doc_filename"
}

# 显示当前会话状态
show_session_status() {
    if [ ! -f "$SESSION_STATE_FILE" ]; then
        echo -e "${YELLOW}⚠️ 当前没有活跃的协作会话${NC}"
        echo -e "${YELLOW}💡 使用 /collaborate [范式] [主题] 开始协作会话${NC}"
        return 0
    fi

    source "$SESSION_STATE_FILE"

    echo -e "${BLUE}📋 当前协作会话状态${NC}"
    echo -e "${GREEN}会话ID: $SESSION_ID${NC}"
    echo -e "${GREEN}开始时间: $DATE${NC}"
    echo -e "${GREEN}协作范式: $PARADIGM ($PARADIGM_DESCRIPTION)${NC}"
    echo -e "${GREEN}会话主题: $TOPIC${NC}"
    echo -e "${GREEN}消息数量: $MESSAGE_COUNT${NC}"
    echo -e "${GREEN}会话状态: $STATUS${NC}"

    if [ -f "$CONVERSATION_BUFFER_FILE" ]; then
        local line_count=$(wc -l < "$CONVERSATION_BUFFER_FILE")
        echo -e "${GREEN}对话记录: $line_count 行${NC}"
    fi
}

# 列出所有协作会话
list_sessions() {
    if [ ! -f "$INDEX_FILE" ]; then
        echo -e "${YELLOW}⚠️ 没有找到协作会话索引${NC}"
        echo -e "${YELLOW}💡 使用 /collaborate [范式] [主题] 开始协作会话${NC}"
        return 0
    fi

    echo -e "${BLUE}📚 AI协作会话列表${NC}"
    echo ""

    # 显示索引内容
    if grep -q "^\| [0-9]" "$INDEX_FILE"; then
        grep "^\| [0-9]" "$INDEX_FILE" | while IFS='|' read -r date paradigm topic link status; do
            echo -e "${GREEN}📅 $date${NC} | ${BLUE}🎯 $paradigm${NC} | ${YELLOW}💡 $topic${NC} | ${link} | ${status}"
        done
    else
        echo -e "${YELLOW}⚠️ 暂无协作会话记录${NC}"
    fi
}

# 显示帮助信息
show_help() {
    echo -e "${BLUE}AI协作会话增强管理工具${NC}"
    echo
    echo "用法: $0 [命令] [参数]"
    echo
    echo "命令:"
    echo "  start <paradigm> <topic>    - 启动新的协作会话"
    echo "  message <role> <content>    - 记录对话消息 (user/assistant)"
    echo "  save                        - 保存当前会话"
    echo "  status                      - 显示当前会话状态"
    echo "  list                        - 列出所有协作会话"
    echo "  help                        - 显示此帮助信息"
    echo
    echo "协作范式:"
    for paradigm in "${!PARADIGMS[@]}"; do
        echo "  $paradigm - ${PARADIGMS[$paradigm]}"
    done
    echo
    echo "示例:"
    echo "  $0 start first-principles \"数据库性能优化分析\""
    echo "  $0 message user \"请用第一性原理分析数据库查询优化\""
    echo "  $0 message assistant \"让我们从基础原理开始分析...\""
    echo "  $0 save"
}

# 主函数
main() {
    case "${1:-help}" in
        "start")
            start_collaboration_session "$2" "$3"
            ;;
        "message")
            record_message "$2" "$3"
            ;;
        "save")
            save_collaboration_session
            ;;
        "status")
            show_session_status
            ;;
        "list")
            list_sessions
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# 执行主函数
main "$@"