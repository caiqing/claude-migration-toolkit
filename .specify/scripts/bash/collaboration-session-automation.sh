#!/bin/bash

# AI协作会话自动化管理工具
# 提供协作会话的创建、保存、索引更新等自动化功能

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
CONTENT_BUFFER_FILE=".collaboration-content.tmp"
CONVERSATION_BUFFER_FILE=".collaboration-conversation.tmp"
TEMPLATE_FILE=".specify/templates/collaboration-session-template.md"

# 显示帮助信息
show_help() {
    echo -e "${BLUE}AI协作会话自动化管理工具${NC}"
    echo
    echo "用法: $0 [命令] [参数]"
    echo
    echo "命令:"
    echo "  start <paradigm> [topic]     - 开始新的协作会话"
    echo "  add-message <role> <content> - 添加对话消息 (user/assistant)"
    echo "  add-content <content>        - 添加会话内容"
    echo "  add-insight <insight>        - 添加关键洞察"
    echo "  add-output <output>          - 添加产出成果"
    echo "  add-action <action>          - 添加行动要点"
    echo "  save                         - 保存当前会话"
    echo "  status                       - 显示当前会话状态"
    echo "  list                         - 列出所有会话"
    echo "  update-index                 - 更新索引文件"
    echo "  init                         - 初始化协作环境"
    echo "  help                         - 显示此帮助信息"
    echo
    echo "示例:"
    echo "  $0 start first-principles \"数据库性能优化\""
    echo "  $0 add-message user \"请用第一性原理分析数据库查询优化\""
    echo "  $0 add-message assistant \"让我们从基础原理开始分析...\""
    echo "  $0 add-content \"讨论了索引优化策略\""
    echo "  $0 add-insight \"索引是空间换时间的权衡\""
    echo "  $0 save"
}

# 初始化协作环境
init_environment() {
    echo -e "${CYAN}初始化AI协作环境...${NC}"

    # 创建必要的目录
    mkdir -p "$COLLABORATION_DIR"
    mkdir -p ".specify/templates"

    # 创建协作会话模板
    create_session_template

    # 创建基础索引文件
    if [ ! -f "$INDEX_FILE" ]; then
        create_index_file
    fi

    echo -e "${GREEN}✅ 协作环境初始化完成${NC}"
}

# 创建协作会话模板
create_session_template() {
    cat > "$TEMPLATE_FILE" << 'EOF'
# AI协作会话记录

## 会话元信息

**会话ID**: {{SESSION_ID}}
**时间**: {{SESSION_DATE}} {{SESSION_TIME}}
**协作范式**: {{PARADIGM_NAME}} ({{PARADIGM_DESC}})
**参与者**: AI Assistant, User
**主题**: {{TOPIC}}

## 范式说明

**{{PARADIGM_NAME}}**：
{{PARADIGM_EXPLANATION}}

## 完整对话记录

{{CONVERSATION_RECORD}}

## 讨论内容

{{DISCUSSION_CONTENT}}

## 关键洞察

{{KEY_INSIGHTS}}

## 产出成果

{{OUTPUTS}}

## 行动要点

{{ACTIONS}}

## AI智能总结

{{AI_SUMMARY}}

## 关键词提取

{{KEYWORDS}}

---

*本会话记录保存于: {{FILE_PATH}}*
*协作范式: {{PARADIGM_NAME}} | 技术主题: {{TOPIC}}*
EOF
}

# 创建基础索引文件
create_index_file() {
    cat > "$INDEX_FILE" << 'EOF'
# AI协作会话索引

## 会话记录总览

本目录包含所有AI协作会话的详细记录，按"时间+主题"格式命名，便于查阅和管理。

## 会话列表

{{SESSION_LIST}}

---

## 索引说明

### 命名规范

- **格式**: `YYYYMMDD-主题描述.md`
- **示例**: `20251006-Claude-Code自定义Commands技术原理分析.md`
- **时间**: 基于会话开始日期（年月日）
- **主题**: 简洁明确描述协作内容的核心主题

### 协作范式说明

| 范式 | 名称 | 描述 | 适用场景 |
|------|------|------|----------|
| first-principles | 第一性原理思维 | 从基础要素分解复杂现象 | 技术原理分析、架构设计 |
| progressive | 渐进式沟通 | 从类比到深入的逐步说明 | 概念解释、知识传授 |
| visual | 可视化呈现 | 通过图表直观展示 | 架构设计、流程说明 |
| creative | 创意激发 | 头脑风暴和创意思维 | 方案设计、问题解决 |
| critical | 批判性思考 | 深度分析和质疑 | 方案评估、风险识别 |
| feynman | 双向费曼学习 | 互相提问检验理解 | 知识学习、概念掌握 |
| smart | SMART结构化表达 | 结构化分析和表达 | 目标制定、计划规划 |
| optimize | 流程优化 | 工作流程分析和改进 | 效率提升、流程重构 |
| ears | EARS需求描述 | 事件-条件-行动-响应 | 需求分析、规格说明 |
| evolve | 持续进化反馈 | 迭代改进和优化 | 持续改进、反馈循环 |
| fusion | 跨界知识融合 | 多领域知识整合 | 创新设计、跨领域应用 |
| learning | 个性化学习 | 定制化学习路径 | 技能提升、知识拓展 |

### 文档结构标准

每个协作会话文档包含以下标准化结构：

1. **会话元信息**: ID、时间、范式、参与者、主题
2. **范式说明**: 所用协作范式的核心要点
3. **完整对话记录**: 所有用户消息和AI回复的完整记录
4. **讨论内容**: 手动添加的结构化内容和分析过程
5. **关键洞察**: 提炼出的核心知识点和发现
6. **产出成果**: 具体的解决方案、架构图、代码等
7. **行动要点**: 后续执行的任务列表和建议
8. **AI智能总结**: 基于实际内容生成的智能分析总结
9. **关键词提取**: 自动提取的关键技术词汇和概念

### 使用指南

1. **查阅**: 根据时间或主题快速定位所需会话记录
2. **学习**: 参考不同协作范式的应用实例
3. **复用**: 提取有价值的方法论和实践经验
4. **索引**: 通过标签和关键词建立知识关联

### 更新日志

- **{{UPDATE_DATE}}**: 创建索引文件，建立协作知识管理体系

---

*最后更新: {{UPDATE_DATE}}*
*维护者: AI协作系统*
EOF
}

# 开始新的协作会话
start_session() {
    local paradigm="$1"
    local topic="${2:-未指定主题}"

    if [ -z "$paradigm" ]; then
        echo -e "${RED}错误: 请指定协作范式${NC}"
        echo "可用范式: first-principles, progressive, visual, creative, critical, feynman, smart, optimize, ears, evolve, fusion, learning"
        return 1
    fi

    # 生成会话ID和文件名
    local session_date=$(date +"%Y%m%d")
    local session_time=$(date +"%H:%M:%S")
    local session_id="session-$session_date-$(date +%s)"
    local safe_topic=$(echo "$topic" | sed 's/[^a-zA-Z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
    local filename="$session_date-${safe_topic}.md"
    local filepath="$COLLABORATION_DIR/$filename"

    # 获取范式信息
    local paradigm_info=$(get_paradigm_info "$paradigm")
    local paradigm_name=$(echo "$paradigm_info" | cut -d'|' -f1)
    local paradigm_desc=$(echo "$paradigm_info" | cut -d'|' -f2)
    local paradigm_explanation=$(echo "$paradigm_info" | cut -d'|' -f3)

    # 保存会话状态
    cat > "$SESSION_STATE_FILE" << EOF
SESSION_ID=$session_id
SESSION_DATE=$session_date
SESSION_TIME=$session_time
PARADIGM=$paradigm
PARADIGM_NAME=$paradigm_name
PARADIGM_DESC=$paradigm_desc
PARADIGM_EXPLANATION=$paradigm_explanation
TOPIC="$topic"
FILENAME=$filename
FILEPATH=$filepath
DISCUSSION_CONTENT=
KEY_INSIGHTS=
OUTPUTS=
ACTIONS=
KNOWLEDGE_SUMMARY=
CONVERSATION_RECORD=
AI_SUMMARY=
KEYWORDS=
EOF

    echo -e "${GREEN}✅ 协作会话已开始${NC}"
    echo -e "${CYAN}会话ID: $session_id${NC}"
    echo -e "${CYAN}协作范式: $paradigm_name${NC}"
    echo -e "${CYAN}主题: $topic${NC}"
    echo -e "${CYAN}文件: $filename${NC}"

    # 初始化缓冲区
    echo "" > "$CONTENT_BUFFER_FILE"
    echo "" > "$CONVERSATION_BUFFER_FILE"
}

# 获取范式信息
get_paradigm_info() {
    local paradigm="$1"

    case "$paradigm" in
        "first-principles")
            echo "第一性原理思维分析|第一性原理思维|从基础要素分解复杂现象，透过表面看本质，回归问题本源" ;;
        "progressive")
            echo "渐进式沟通|渐进式沟通|由易到难，先用通俗易懂的类比法举例，再逐步过渡到深入洞见" ;;
        "visual")
            echo "可视化呈现|可视化呈现|整合思维导图、架构图、流程图等Mermaid图表进行直观讲解" ;;
        "creative")
            echo "创意激发|创意激发|进行头脑风暴，提出创新观点和解决方案" ;;
        "critical")
            echo "批判性思考|批判性思考|深度分析和质疑，发现盲点，提升思辨能力" ;;
        "feynman")
            echo "双向费曼学习法|双向费曼学习|互相提问、解释，检验自己是否真正理解知识" ;;
        "smart")
            echo "SMART结构化表达|SMART结构化表达|运用SMART、RIDE、PREP等方法进行结构化表达" ;;
        "optimize")
            echo "流程优化|流程优化|分析并优化工作流程，提升效率和质量" ;;
        "ears")
            echo "EARS需求描述|EARS需求描述|使用EARS语法（事件、条件、行动、响应）描述需求" ;;
        "evolve")
            echo "持续进化反馈|持续进化反馈|通过反馈循环持续改进和优化" ;;
        "fusion")
            echo "跨界知识融合|跨界知识融合|把不同领域的知识串联起来，产生新洞见" ;;
        "learning")
            echo "个性化学习|个性化学习|根据兴趣和短板，定制学习路径" ;;
        *)
            echo "$paradigm|$paradigm|$paradigm" ;;
    esac
}

# 添加对话消息到当前会话
add_message() {
    local role="$1"
    local content="$2"

    if [ -z "$role" ] || [ -z "$content" ]; then
        echo -e "${RED}错误: 请指定角色和内容${NC}"
        echo "用法: $0 add-message <user|assistant> \"消息内容\""
        return 1
    fi

    if [ "$role" != "user" ] && [ "$role" != "assistant" ]; then
        echo -e "${RED}错误: 角色必须是 'user' 或 'assistant'${NC}"
        return 1
    fi

    if [ ! -f "$SESSION_STATE_FILE" ]; then
        echo -e "${RED}错误: 没有活跃的协作会话${NC}"
        echo "请先使用 'start' 命令开始新会话"
        return 1
    fi

    # 添加消息到对话缓冲区
    local timestamp=$(date +"%H:%M:%S")
    echo "### [$timestamp] $role" >> "$CONVERSATION_BUFFER_FILE"
    echo "$content" >> "$CONVERSATION_BUFFER_FILE"
    echo "" >> "$CONVERSATION_BUFFER_FILE"

    echo -e "${GREEN}✅ 对话消息已记录${NC}"
}

# 添加内容到当前会话
add_content() {
    local content="$1"

    if [ ! -f "$SESSION_STATE_FILE" ]; then
        echo -e "${RED}错误: 没有活跃的协作会话${NC}"
        echo "请先使用 'start' 命令开始新会话"
        return 1
    fi

    echo "$content" >> "$CONTENT_BUFFER_FILE"
    echo -e "${GREEN}✅ 内容已添加到会话${NC}"
}

# 添加关键洞察
add_insight() {
    local insight="$1"

    if [ ! -f "$SESSION_STATE_FILE" ]; then
        echo -e "${RED}错误: 没有活跃的协作会话${NC}"
        return 1
    fi

    # 更新状态文件中的洞察
    source "$SESSION_STATE_FILE"
    if [ -n "$KEY_INSIGHTS" ]; then
        KEY_INSIGHTS="$KEY_INSIGHTS\n- $insight"
    else
        KEY_INSIGHTS="- $insight"
    fi

    # 更新状态文件
    sed -i '' "s|^KEY_INSIGHTS=.*|KEY_INSIGHTS=\"$KEY_INSIGHTS\"|" "$SESSION_STATE_FILE"

    echo -e "${GREEN}✅ 关键洞察已记录${NC}"
}

# 添加产出成果
add_output() {
    local output="$1"

    if [ ! -f "$SESSION_STATE_FILE" ]; then
        echo -e "${RED}错误: 没有活跃的协作会话${NC}"
        return 1
    fi

    source "$SESSION_STATE_FILE"
    if [ -n "$OUTPUTS" ]; then
        OUTPUTS="$OUTPUTS\n- $output"
    else
        OUTPUTS="- $output"
    fi

    sed -i '' "s|^OUTPUTS=.*|OUTPUTS=\"$OUTPUTS\"|" "$SESSION_STATE_FILE"

    echo -e "${GREEN}✅ 产出成果已记录${NC}"
}

# 添加行动要点
add_action() {
    local action="$1"

    if [ ! -f "$SESSION_STATE_FILE" ]; then
        echo -e "${RED}错误: 没有活跃的协作会话${NC}"
        return 1
    fi

    source "$SESSION_STATE_FILE"
    if [ -n "$ACTIONS" ]; then
        ACTIONS="$ACTIONS\n- $action"
    else
        ACTIONS="- $action"
    fi

    sed -i '' "s|^ACTIONS=.*|ACTIONS=\"$ACTIONS\"|" "$SESSION_STATE_FILE"

    echo -e "${GREEN}✅ 行动要点已记录${NC}"
}

# 显示当前会话状态
show_status() {
    if [ ! -f "$SESSION_STATE_FILE" ]; then
        echo -e "${YELLOW}当前没有活跃的协作会话${NC}"
        return 0
    fi

    source "$SESSION_STATE_FILE"

    echo -e "${BLUE}当前协作会话状态${NC}"
    echo -e "${CYAN}会话ID: $SESSION_ID${NC}"
    echo -e "${CYAN}时间: $SESSION_DATE $SESSION_TIME${NC}"
    echo -e "${CYAN}协作范式: $PARADIGM_NAME${NC}"
    echo -e "${CYAN}主题: $TOPIC${NC}"
    echo -e "${CYAN}文件: $FILENAME${NC}"

    if [ -n "$KEY_INSIGHTS" ]; then
        echo -e "${YELLOW}关键洞察:${NC}"
        echo -e "$KEY_INSIGHTS"
    fi

    if [ -n "$OUTPUTS" ]; then
        echo -e "${YELLOW}产出成果:${NC}"
        echo -e "$OUTPUTS"
    fi

    if [ -n "$ACTIONS" ]; then
        echo -e "${YELLOW}行动要点:${NC}"
        echo -e "$ACTIONS"
    fi
}

# 保存当前会话
save_session() {
    if [ ! -f "$SESSION_STATE_FILE" ]; then
        echo -e "${RED}错误: 没有活跃的协作会话${NC}"
        return 1
    fi

    source "$SESSION_STATE_FILE"

    # 读取内容缓冲区
    local discussion_content=""
    if [ -f "$CONTENT_BUFFER_FILE" ]; then
        discussion_content=$(cat "$CONTENT_BUFFER_FILE")
    fi

    # 读取对话缓冲区
    local conversation_record=""
    if [ -f "$CONVERSATION_BUFFER_FILE" ]; then
        conversation_record=$(cat "$CONVERSATION_BUFFER_FILE")
    fi

    # 生成智能总结和关键词
    local ai_summary=$(generate_ai_summary "$conversation_record" "$discussion_content")
    local keywords=$(extract_keywords "$conversation_record" "$discussion_content")

    # 创建临时变量处理多行内容 - 修复多行内容处理
    local safe_conversation=$(printf '%s\n' "$conversation_record" | sed ':a;N;$!ba;s/\n/\\n/g')
    local safe_discussion=$(printf '%s\n' "$discussion_content" | sed ':a;N;$!ba;s/\n/\\n/g')
    local safe_insights=$(printf '%s\n' "$KEY_INSIGHTS" | sed ':a;N;$!ba;s/\n/\\n/g')
    local safe_outputs=$(printf '%s\n' "$OUTPUTS" | sed ':a;N;$!ba;s/\n/\\n/g')
    local safe_actions=$(printf '%s\n' "$ACTIONS" | sed ':a;N;$!ba;s/\n/\\n/g')
    local safe_summary=$(printf '%s\n' "$ai_summary" | sed ':a;N;$!ba;s/\n/\\n/g')
    local safe_keywords=$(printf '%s\n' "$keywords" | sed ':a;N;$!ba;s/\n/\\n/g')

    # 使用模板生成会话文档
    sed -e "s|{{SESSION_ID}}|$SESSION_ID|g" \
        -e "s|{{SESSION_DATE}}|$SESSION_DATE|g" \
        -e "s|{{SESSION_TIME}}|$SESSION_TIME|g" \
        -e "s|{{PARADIGM_NAME}}|$PARADIGM_NAME|g" \
        -e "s|{{PARADIGM_DESC}}|$PARADIGM_DESC|g" \
        -e "s|{{PARADIGM_EXPLANATION}}|$PARADIGM_EXPLANATION|g" \
        -e "s|{{TOPIC}}|$TOPIC|g" \
        -e "s|{{CONVERSATION_RECORD}}|$safe_conversation|g" \
        -e "s|{{DISCUSSION_CONTENT}}|$safe_discussion|g" \
        -e "s|{{KEY_INSIGHTS}}|$safe_insights|g" \
        -e "s|{{OUTPUTS}}|$safe_outputs|g" \
        -e "s|{{ACTIONS}}|$safe_actions|g" \
        -e "s|{{AI_SUMMARY}}|$safe_summary|g" \
        -e "s|{{KEYWORDS}}|$safe_keywords|g" \
        -e "s|{{FILE_PATH}}|$FILEPATH|g" \
        "$TEMPLATE_FILE" > "$FILEPATH"

    echo -e "${GREEN}✅ 协作会话已保存${NC}"
    echo -e "${CYAN}文件路径: $FILEPATH${NC}"

    # 清理状态文件
    rm -f "$SESSION_STATE_FILE" "$CONTENT_BUFFER_FILE" "$CONVERSATION_BUFFER_FILE"

    # 更新索引
    update_index
}

# 生成AI智能总结
generate_ai_summary() {
    local conversation="$1"
    local discussion="$2"

    source "$SESSION_STATE_FILE"

    # 统计对话信息
    local message_count=$(echo "$conversation" | grep -c "^### \[" || echo "0")
    local user_messages=$(echo "$conversation" | grep -c "user$" || echo "0")
    local ai_messages=$(echo "$conversation" | grep -c "assistant$" || echo "0")

    # 分析内容长度和复杂度
    local total_content="${conversation}${discussion}"
    local content_length=$(echo "$total_content" | wc -c | tr -d ' ')
    local line_count=$(echo "$total_content" | wc -l | tr -d ' ')

    cat << EOF
## 会话统计分析

**对话规模**:
- 总消息数: ${message_count}
- 用户消息: ${user_messages}
- AI回复: ${ai_messages}
- 内容规模: ${content_length} 字符, ${line_count} 行

**协作范式应用**:
本次采用${PARADIGM_NAME}方式进行协作，通过${PARADIGM_DESC}的方法，系统性地探讨了${TOPIC}相关议题。

**核心内容概要**:
$(generate_content_summary "$total_content")

**关键洞察提炼**:
$(extract_key_insights "$total_content")

**协作价值评估**:
- 知识深度: $(evaluate_knowledge_depth "$total_content")
- 实践指导: $(evaluate_practical_guidance "$total_content")
- 创新思维: $(evaluate_innovative_thinking "$total_content")

**后续建议**:
基于本次协作内容和${PARADIGM_NAME}的特点，建议继续深入相关领域的学习和实践。
EOF
}

# 生成内容总结
generate_content_summary() {
    local content="$1"

    # 提取关键主题词
    local key_topics=$(echo "$content" | grep -oE '\b(优化|分析|设计|实现|架构|性能|安全|数据|算法|系统)\b' | sort | uniq -c | sort -nr | head -3 | awk '{print $2}')

    if [ -n "$key_topics" ]; then
        echo "- 主要议题涵盖: $(echo "$key_topics" | tr '\n' ', ' | sed 's/,$//')"
        echo "- 通过${PARADIGM_DESC}方法进行了系统性探讨"
        echo "- 形成了多层次的理解和解决方案"
    else
        echo "- 围绕${TOPIC}进行了深入讨论"
        echo "- 采用了${PARADIGM_NAME}的协作方法"
        echo "- 获得了全面的问题认知和解决方案"
    fi
}

# 提取关键洞察
extract_key_insights() {
    local content="$1"

    # 寻找包含观点、结论、原理的句子
    echo "$content" | grep -E "(本质|核心|关键|重要|原理|结论|发现|洞察)" | head -3 | sed 's/^/- /' || echo "- 获得了对问题的深层次理解"
}

# 评估知识深度
evaluate_knowledge_depth() {
    local content="$1"
    local depth_score=$(echo "$content" | grep -cE "(原理|本质|深入|底层|根本)" 2>/dev/null || echo "0")

    if [ "$depth_score" -gt 3 ]; then
        echo "深入 - 涉及了底层原理和本质分析"
    elif [ "$depth_score" -gt 1 ]; then
        echo "中等 - 包含了一定的深度分析"
    else
        echo "基础 - 主要关注表面现象和应用"
    fi
}

# 评估实践指导
evaluate_practical_guidance() {
    local content="$1"
    local guidance_score=$(echo "$content" | grep -cE "(实践|操作|步骤|方法|工具|实施)" 2>/dev/null || echo "0")

    if [ "$guidance_score" -gt 3 ]; then
        echo "强 - 提供了详细的实践指导和操作步骤"
    elif [ "$guidance_score" -gt 1 ]; then
        echo "中 - 包含了一定的实践建议"
    else
        echo "弱 - 主要是理论探讨，缺乏实践指导"
    fi
}

# 评估创新思维
evaluate_innovative_thinking() {
    local content="$1"
    local innovation_score=$(echo "$content" | grep -cE "(创新|新颖|独特|创意|突破)" 2>/dev/null || echo "0")

    if [ "$innovation_score" -gt 2 ]; then
        echo "高 - 包含了创新性思维和独特见解"
    elif [ "$innovation_score" -gt 0 ]; then
        echo "中 - 有一定的新颖性思考"
    else
        echo "标准 - 主要是常规性分析"
    fi
}

# 提取关键词
extract_keywords() {
    local conversation="$1"
    local discussion="$2"
    local total_content="${conversation}${discussion}"

    # 技术关键词
    local tech_keywords=$(echo "$total_content" | grep -oE '\b(Cloud|AI|ML|DevOps|Microservices|API|Database|Frontend|Backend|Security|Performance|Architecture|Design|System|Data|Algorithm|Optimization|Analysis|Implementation)\b' | sort | uniq -c | sort -nr | head -5 | awk '{print $2}' | tr '\n' ', ' | sed 's/,$//')

    # 通用关键词
    local general_keywords=$(echo "$total_content" | grep -oE '\b(分析|设计|开发|优化|架构|性能|安全|数据|算法|系统|方法|原理|实践|方案|策略|技术|工具|流程|管理|创新)\b' | sort | uniq -c | sort -nr | head -5 | awk '{print $2}' | tr '\n' ', ' | sed 's/,$//')

    # 范式相关关键词
    local paradigm_keyword="$PARADIGM_NAME"

    cat << EOF
**核心技术关键词**: ${tech_keywords:-技术探讨}
**通用概念关键词**: ${general_keywords:-方法论讨论}
**协作范式关键词**: ${paradigm_keyword}

**关键词云**:
$(echo "$total_content" | grep -oE '\b[a-zA-Z]{4,}\b' | sort | uniq -c | sort -nr | head -10 | awk '{print $1 "× " $2}' | sed 's/^/- /')
EOF
}

# 更新索引文件
update_index() {
    # 使用Python脚本安全地更新索引
    local python_script=".specify/scripts/bash/update-collaboration-index.py"

    if [ -f "$python_script" ]; then
        python3 "$python_script"
    else
        echo -e "${RED}错误: 找不到索引更新脚本${NC}"
        return 1
    fi
}

# 列出所有会话
list_sessions() {
    echo -e "${BLUE}所有协作会话${NC}"
    echo

    if [ ! -d "$COLLABORATION_DIR" ]; then
        echo -e "${YELLOW}协作会话目录不存在${NC}"
        return 0
    fi

    local count=0
    for file in "$COLLABORATION_DIR"/*.md; do
        if [ "$file" != "$INDEX_FILE" ] && [ -f "$file" ]; then
            local basename=$(basename "$file" .md)
            local file_date=$(echo "$basename" | cut -d'-' -f1)
            local topic=$(echo "$basename" | cut -d'-' -f2-)
            local paradigm=$(grep "协作范式:" "$file" | sed 's/.*协作范式: //' | sed 's/ (.*$//')

            echo -e "${CYAN}$basename${NC}"
            echo -e "  日期: $file_date"
            echo -e "  主题: $topic"
            echo -e "  范式: $paradigm"
            echo
            ((count++))
        fi
    done

    if [ $count -eq 0 ]; then
        echo -e "${YELLOW}暂无协作会话记录${NC}"
    else
        echo -e "${GREEN}总计: $count 个会话${NC}"
    fi
}

# 主程序
main() {
    case "$1" in
        "init")
            init_environment
            ;;
        "start")
            start_session "$2" "$3"
            ;;
        "add-message")
            add_message "$2" "$3"
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
        "save")
            save_session
            ;;
        "status")
            show_status
            ;;
        "list")
            list_sessions
            ;;
        "update-index")
            update_index
            ;;
        "help"|"")
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