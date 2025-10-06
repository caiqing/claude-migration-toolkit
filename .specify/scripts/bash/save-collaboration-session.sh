#!/bin/bash

# 协作会话自动保存脚本
# 用于将AI协作过程中的知识保存到docs目录

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
COLLABORATION_DIR="docs/collaboration"
TEMPLATE_DIR=".specify/templates"

# 创建协作会话目录
mkdir -p "$COLLABORATION_DIR"

# 获取当前时间戳
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
SESSION_ID="session-$TIMESTAMP"

# 获取环境变量
PARADIGM="${COLLABORATE_PARADIGM:-general}"
TOPIC="${COLLABORATE_TOPIC:-untitled}"
USER_NAME="${USER:-anonymous}"

# 创建会话文件
SESSION_FILE="$COLLABORATION_DIR/$SESSION_ID.md"

echo -e "${BLUE}🤝 正在保存协作会话...${NC}"
echo -e "${YELLOW}范式: $PARADIGM | 主题: $TOPIC | 用户: $USER_NAME${NC}"

# 创建会话文档
cat > "$SESSION_FILE" << EOF
# 协作会话记录

## 会话信息

- **会话ID**: $SESSION_ID
- **时间**: $(date +"%Y-%m-%d %H:%M:%S")
- **协作范式**: $PARADIGM
- **主题**: $TOPIC
- **用户**: $USER_NAME
- **项目根目录**: $(pwd)

## 协作范式说明

### $PARADIGM 范式

EOF

# 根据范式添加说明
case "$PARADIGM" in
    "creative")
        cat >> "$SESSION_FILE" << 'EOF'
**创意激发头脑风暴** - 通过AI协作激发创新思维和多元化观点，适用于需要创意解决方案的场景。
EOF
        ;;
    "critical")
        cat >> "$SESSION_FILE" << 'EOF'
**批判性思考分析** - 通过AI的质疑和分析，发现方案中的盲点和潜在问题，提升决策质量。
EOF
        ;;
    "feynman")
        cat >> "$SESSION_FILE" << 'EOF'
**双向费曼学习法** - 通过互相提问和解释来检验理解程度，确保真正掌握核心概念。
EOF
        ;;
    "first-principles")
        cat >> "$SESSION_FILE" << 'EOF'
**第一性原理思维分析** - 透过现象看本质，从最基础的原理出发推导解决方案，避免经验主义陷阱。
EOF
        ;;
    "optimize")
        cat >> "$SESSION_FILE" << 'EOF'
**流程优化建议** - 分析现有工作流程，识别瓶颈和改进机会，提升效率和效果。
EOF
        ;;
    "progressive")
        cat >> "$SESSION_FILE" << 'EOF'
**渐进式沟通** - 从简单的类比开始，逐步过渡到深入的技术细节，确保理解的层次性。
EOF
        ;;
    "smart")
        cat >> "$SESSION_FILE" << 'EOF'
**SMART结构化表达** - 使用具体、可衡量、可达成、相关性强、有时限的结构化方法进行沟通。
EOF
        ;;
    "visual")
        cat >> "$SESSION_FILE" << 'EOF'
**可视化呈现** - 通过图表、流程图等可视化工具将复杂概念变得直观易懂。
EOF
        ;;
    "ears")
        cat >> "$SESSION_FILE" << 'EOF'
**EARS需求描述方法** - 使用事件(Event)、条件(Action)、行动(Action)、响应(Response)格式精确描述需求。
EOF
        ;;
    "evolve")
        cat >> "$SESSION_FILE" << 'EOF'
**持续进化反馈** - 通过迭代反馈不断改进和优化方案，实现持续学习和进步。
EOF
        ;;
    "fusion")
        cat >> "$SESSION_FILE" << 'EOF'
**跨界知识融合** - 将不同领域的知识和方法结合起来，产生创新的解决方案。
EOF
        ;;
    "learning")
        cat >> "$SESSION_FILE" << 'EOF'
**个性化学习路径** - 根据个人兴趣和能力短板，定制化的学习建议和路径规划。
EOF
        ;;
    *)
        cat >> "$SESSION_FILE" << 'EOF'
**通用协作** - 基础的AI协作模式，适用于一般性的问题讨论和解决方案。
EOF
        ;;
esac

cat >> "$SESSION_FILE" << EOF

## 会话内容

### 主要讨论点

\`\`\`markdown
$COLLABORATION_CONTENT
\`\`\`

### 关键洞察

\`\`\`markdown
$KEY_INSIGHTS
\`\`\`

### 产出成果

\`\`\`markdown
$OUTPUTS
\`\`\`

### 待办事项

\`\`\`markdown
$ACTION_ITEMS
\`\`\`

## 知识要点总结

### 核心概念

### 实践方法

### 工具技巧

## 相关资源

### 内部文档
- [AI协作指导原则](../.specify/templates/ai-collaboration-guide.md)
- [项目使用指南](../docs/usage-guide.md)

### 外部资源
- 根据具体主题添加相关链接和资源

---

*此文档由AI协作会话自动生成 - $(date +"%Y-%m-%d %H:%M:%S")*
EOF

# 如果提供了会话内容文件，则合并内容
if [ -n "$COLLABORATION_CONTENT_FILE" ] && [ -f "$COLLABORATION_CONTENT_FILE" ]; then
    echo -e "${GREEN}📝 已加载会话内容文件: $COLLABORATION_CONTENT_FILE${NC}"

    # 创建临时文件来合并内容
    TEMP_FILE=$(mktemp)

    # 复制会话文档头部
    sed -n '1,/^## 会话内容$/p' "$SESSION_FILE" > "$TEMP_FILE"

    # 添加会话内容
    echo "" >> "$TEMP_FILE"
    cat "$COLLABORATION_CONTENT_FILE" >> "$TEMP_FILE"

    # 替换原文件
    mv "$TEMP_FILE" "$SESSION_FILE"
fi

# 创建或更新索引文件
INDEX_FILE="$COLLABORATION_DIR/index.md"
if [ ! -f "$INDEX_FILE" ]; then
    cat > "$INDEX_FILE" << 'EOF'
# 协作会话索引

本目录包含了所有通过 `/collaborate` 命令进行的AI协作会话记录。

## 会话列表

| 会话ID | 时间 | 范式 | 主题 | 用户 |
|--------|------|------|------|------|

---

*索引文件由系统自动维护，最后更新：$(date +"%Y-%m-%d %H:%M:%S")*
EOF
fi

# 更新索引文件 - 在分割线前插入新记录
TEMP_INDEX=$(mktemp)
# 找到分割线的行号
SEPARATOR_LINE=$(grep -n "^---" "$INDEX_FILE" | head -1 | cut -d: -f1)
if [ -n "$SEPARATOR_LINE" ]; then
    # 在分割线前插入新记录
    head -n $((SEPARATOR_LINE - 1)) "$INDEX_FILE" > "$TEMP_INDEX"
    echo "| [$SESSION_ID]($SESSION_ID.md) | $(date +"%Y-%m-%d %H:%M") | $PARADIGM | $TOPIC | $USER_NAME |" >> "$TEMP_INDEX"
    tail -n +$SEPARATOR_LINE "$INDEX_FILE" >> "$TEMP_INDEX"
else
    # 如果没有分割线，直接追加到文件末尾
    cp "$INDEX_FILE" "$TEMP_INDEX"
    echo "| [$SESSION_ID]($SESSION_ID.md) | $(date +"%Y-%m-%d %H:%M") | $PARADIGM | $TOPIC | $USER_NAME |" >> "$TEMP_INDEX"
fi
mv "$TEMP_INDEX" "$INDEX_FILE"

echo -e "${GREEN}✅ 协作会话已保存到: $SESSION_FILE${NC}"
echo -e "${BLUE}📚 索引已更新: $INDEX_FILE${NC}"

# 返回会话文件路径，供其他脚本使用
echo "$SESSION_FILE"