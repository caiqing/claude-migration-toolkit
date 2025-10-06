#!/bin/bash

# AI协作会话快速启动脚本
# 提供简化的协作会话创建和管理功能

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 显示欢迎信息
show_welcome() {
    echo -e "${BLUE}🤖 AI协作会话快速启动工具${NC}"
    echo
    echo "可用的协作范式："
    echo "  first-principles  - 第一性原理思维分析"
    echo "  progressive       - 渐进式沟通"
    echo "  visual            - 可视化呈现"
    echo "  creative          - 创意激发"
    echo "  critical          - 批判性思考"
    echo "  feynman           - 双向费曼学习法"
    echo "  smart             - SMART结构化表达"
    echo "  optimize          - 流程优化"
    echo "  ears              - EARS需求描述"
    echo "  evolve            - 持续进化反馈"
    echo "  fusion            - 跨界知识融合"
    echo "  learning          - 个性化学习"
    echo
}

# 快速开始协作会话
quick_start() {
    local paradigm="$1"
    local topic="$2"

    if [ -z "$paradigm" ]; then
        echo -e "${YELLOW}请选择协作范式：${NC}"
        echo "1) first-principles  2) progressive   3) visual"
        echo "4) creative          5) critical      6) feynman"
        echo "7) smart             8) optimize      9) ears"
        echo "10) evolve           11) fusion       12) learning"
        read -p "请输入数字选择: " choice

        case $choice in
            1) paradigm="first-principles" ;;
            2) paradigm="progressive" ;;
            3) paradigm="visual" ;;
            4) paradigm="creative" ;;
            5) paradigm="critical" ;;
            6) paradigm="feynman" ;;
            7) paradigm="smart" ;;
            8) paradigm="optimize" ;;
            9) paradigm="ears" ;;
            10) paradigm="evolve" ;;
            11) paradigm="fusion" ;;
            12) paradigm="learning" ;;
            *)
                echo -e "${YELLOW}使用默认范式: first-principles${NC}"
                paradigm="first-principles"
                ;;
        esac
    fi

    if [ -z "$topic" ]; then
        read -p "请输入协作主题: " topic
        if [ -z "$topic" ]; then
            topic="未指定主题"
        fi
    fi

    # 初始化环境（如果需要）
    if [ ! -d "docs/collaboration" ]; then
        echo -e "${YELLOW}正在初始化协作环境...${NC}"
        ./.specify/scripts/bash/collaboration-session-automation.sh init
    fi

    # 开始会话
    echo -e "${BLUE}正在启动协作会话...${NC}"
    ./.specify/scripts/bash/collaboration-session-automation.sh start "$paradigm" "$topic"

    echo
    echo -e "${GREEN}✅ 协作会话已启动！${NC}"
    echo
    echo "接下来你可以："
    echo "1. 开始与AI进行协作讨论"
    echo "2. 使用以下命令记录关键信息："
    echo "   - 添加内容: ./.specify/scripts/bash/collaboration-session-automation.sh add-content \"你的内容\""
    echo "   - 添加洞察: ./.specify/scripts/bash/collaboration-session-automation.sh add-insight \"关键洞察\""
    echo "   - 添加成果: ./.specify/scripts/bash/collaboration-session-automation.sh add-output \"产出成果\""
    echo "   - 添加行动: ./.specify/scripts/bash/collaboration-session-automation.sh add-action \"行动要点\""
    echo "   - 查看状态: ./.specify/scripts/bash/collaboration-session-automation.sh status"
    echo "   - 保存会话: ./.specify/scripts/bash/collaboration-session-automation.sh save"
    echo
}

# 显示帮助信息
show_help() {
    echo "用法: $0 [范式] [主题]"
    echo
    echo "示例:"
    echo "  $0                    # 交互式选择范式和输入主题"
    echo "  $0 first-principles   # 使用指定范式，交互式输入主题"
    echo "  $0 creative \"头脑风暴\"  # 直接指定范式和主题"
    echo
}

# 主程序
main() {
    case "$1" in
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            show_welcome
            quick_start "$1" "$2"
            ;;
    esac
}

# 执行主程序
main "$@"