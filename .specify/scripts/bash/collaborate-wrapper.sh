#!/bin/bash

# /collaborate 命令包装脚本
# 用于启动协作会话并设置自动保存

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 解析命令行参数
PARADIGM="$1"
TOPIC="$2"

# 验证范式参数
VALID_PARADIGMS=("creative" "critical" "feynman" "first-principles" "optimize" "progressive" "smart" "visual" "ears" "evolve" "fusion" "learning")

if [ -z "$PARADIGM" ]; then
    echo -e "${BLUE}🤝 AI协作范式${NC}"
    echo
    echo "可用的协作范式："
    echo

    # 分组显示范式
    echo -e "${CYAN}基础协作范式：${NC}"
    for p in "creative" "critical" "feynman" "first-principles" "optimize" "progressive" "smart" "visual"; do
        echo "  • $p"
    done

    echo
    echo -e "${CYAN}高级协作范式：${NC}"
    for p in "ears" "evolve" "fusion" "learning"; do
        echo "  • $p"
    done

    echo
    echo -e "${YELLOW}使用方法：${NC}"
    echo "  /collaborate <范式> [主题]"
    echo
    echo -e "${YELLOW}示例：${NC}"
    echo "  /collaborate first-principles \"分析数据库性能优化\""
    echo "  /collaborate visual \"设计系统架构图\""
    echo "  /collaborate creative \"头脑风暴新功能点子\""

    exit 0
fi

# 检查范式是否有效
valid=false
for p in "${VALID_PARADIGMS[@]}"; do
    if [ "$p" = "$PARADIGM" ]; then
        valid=true
        break
    fi
done

if [ "$valid" = false ]; then
    echo -e "${RED}错误: 未知的协作范式 '$PARADIGM'${NC}"
    echo -e "${YELLOW}请使用以下范式之一：${NC}"
    printf '%s\n' "${VALID_PARADIGMS[@]}" | tr ' ' '\n' | sed 's/^/  • /'
    exit 1
fi

# 设置默认主题
if [ -z "$TOPIC" ]; then
    TOPIC="untitled"
fi

# 启动协作会话
echo -e "${PURPLE}🚀 启动AI协作会话${NC}"
echo "────────────────────────────────────"
echo -e "${CYAN}协作范式:${NC} $PARADIGM"
echo -e "${CYAN}会话主题:${NC} $TOPIC"
echo -e "${CYAN}开始时间:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
echo "────────────────────────────────────"

# 启动会话管理器
if [ -f ".specify/scripts/bash/collaboration-session-manager.sh" ]; then
    .specify/scripts/bash/collaboration-session-manager.sh start "$PARADIGM" "$TOPIC"

    echo
    echo -e "${GREEN}✅ 协作会话已启动${NC}"
    echo -e "${BLUE}💡 会话内容将在结束时自动保存到 docs/collaboration/${NC}"
    echo
    echo -e "${YELLOW}📝 现在您可以开始与AI协作了！${NC}"

    # 根据范式给出使用建议
    case "$PARADIGM" in
        "creative")
            echo -e "${CYAN}💭 创意模式提示：${NC}"
            echo "  • 提出开放性问题激发创新思维"
            echo "  • 鼓励多元化观点和非常规想法"
            echo "  • 使用头脑风暴技巧探索可能性"
            ;;
        "first-principles")
            echo -e "${CYAN}🔬 第一性原理提示：${NC}"
            echo "  • 从最基础的原理出发分析问题"
            echo "  • 质疑假设和传统做法"
            echo "  • 寻找问题的本质和根本原因"
            ;;
        "visual")
            echo -e "${CYAN}🎨 可视化模式提示：${NC}"
            echo "  • 请求AI创建图表、流程图、架构图"
            echo "  • 使用Mermaid语法绘制各种图表"
            echo "  • 将复杂概念转换为直观的视觉呈现"
            ;;
        "critical")
            echo -e "${CYAN}🤔 批判性思考提示：${NC}"
            echo "  • 主动质疑和挑战观点"
            echo "  • 寻找潜在的问题和风险"
            echo "  • 考虑不同的角度和替代方案"
            ;;
    esac

    echo
    echo -e "${GREEN}🎯 开始您的协作吧！${NC}"

else
    echo -e "${RED}错误: 协作会话管理器不存在${NC}"
    exit 1
fi