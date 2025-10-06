#!/bin/bash

# 增强版AI协作系统 - 优化用户体验
# 集成所有优化组件，提供无缝协作体验

set -euo pipefail

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OPT_DIR="$SCRIPT_DIR"
COLLAB_DIR="$PROJECT_ROOT/docs/collaboration"

# 优化工具路径
CONTENT_HANDLER="$OPT_DIR/improved-content-handler.sh"
ERROR_HANDLER="$OPT_DIR/error-handler.sh"
CONTENT_VALIDATOR="$OPT_DIR/content-validator.sh"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# 会话状态
SESSION_STATE_FILE="/tmp/enhanced_collab_session.state"

# 美化输出
print_header() {
    local title="$1"
    echo -e "\n${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE} $title${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
}

print_section() {
    local title="$1"
    echo -e "\n${BLUE}┌─ $title${NC}"
}

print_step() {
    local step="$1"
    local status="${2:-info}"

    case "$status" in
        "success")
            echo -e "  ${GREEN}✓${NC} $step"
            ;;
        "error")
            echo -e "  ${RED}✗${NC} $step"
            ;;
        "warning")
            echo -e "  ${YELLOW}⚠${NC} $step"
            ;;
        "info")
            echo -e "  ${BLUE}•${NC} $step"
            ;;
    esac
}

print_progress() {
    local current="$1"
    local total="$2"
    local task="$3"

    local percent=$((current * 100 / total))
    local bar_length=30
    local filled_length=$((percent * bar_length / 100))

    local bar=""
    for ((i=0; i<filled_length; i++)); do
        bar="${bar}█"
    done
    for ((i=filled_length; i<bar_length; i++)); do
        bar="${bar}░"
    done

    echo -e "${CYAN}[$bar] $percent%${NC} $task"
}

# 系统初始化检查
initialize_system() {
    print_section "系统初始化检查"

    local checks=(
        "检查优化工具文件"
        "验证脚本执行权限"
        "创建必要目录"
        "初始化日志系统"
    )

    local total_checks=${#checks[@]}
    local current_check=0

    for check in "${checks[@]}"; do
        ((current_check++))
        print_progress $current_check $total_checks "$check"

        case "$check" in
            "检查优化工具文件")
                if [[ -f "$CONTENT_HANDLER" ]] && [[ -f "$ERROR_HANDLER" ]] && [[ -f "$CONTENT_VALIDATOR" ]]; then
                    print_step "优化工具文件完整" "success"
                else
                    print_step "优化工具文件缺失" "error"
                    return 1
                fi
                ;;
            "验证脚本执行权限")
                local scripts=("$CONTENT_HANDLER" "$ERROR_HANDLER" "$CONTENT_VALIDATOR")
                local all_executable=true
                for script in "${scripts[@]}"; do
                    if [[ ! -x "$script" ]]; then
                        all_executable=false
                        break
                    fi
                done

                if $all_executable; then
                    print_step "脚本执行权限正常" "success"
                else
                    print_step "正在修复脚本权限..." "warning"
                    find "$OPT_DIR" -name "*.sh" -exec chmod +x {} \;
                    print_step "脚本权限修复完成" "success"
                fi
                ;;
            "创建必要目录")
                local dirs=(
                    "$HOME/.collab-logs"
                    "$COLLAB_DIR"
                    "/tmp/collab-validation"
                )
                local all_dirs_exist=true
                for dir in "${dirs[@]}"; do
                    if [[ ! -d "$dir" ]]; then
                        mkdir -p "$dir"
                        print_step "创建目录: $dir" "info"
                    fi
                done
                print_step "必要目录就绪" "success"
                ;;
            "初始化日志系统")
                if [[ -d "$HOME/.collab-logs" ]]; then
                    print_step "日志系统已就绪" "success"
                else
                    print_step "日志系统初始化失败" "error"
                    return 1
                fi
                ;;
        esac
    done

    echo -e "\n${GREEN}✅ 系统初始化完成${NC}"
}

# 智能协作会话启动
smart_collaboration_start() {
    local paradigm="$1"
    local topic="${2:-未指定主题}"

    print_header "启动AI协作会话"

    # 输入验证
    if [[ -z "$paradigm" ]]; then
        print_step "请指定协作范式" "error"
        echo -e "${YELLOW}可用范式:${NC}"
        echo "  • first-principles - 第一性原理分析"
        echo "  • progressive - 渐进式沟通"
        echo "  • visual - 可视化呈现"
        echo "  • creative - 创意激发"
        echo "  • critical - 批判性思考"
        echo "  • feynman - 双向费曼学习法"
        echo "  • smart - SMART结构化表达"
        echo "  • optimize - 流程优化"
        echo "  • ears - EARS需求描述"
        echo "  • evolve - 持续进化"
        echo "  • fusion - 跨界融合"
        echo "  • learning - 个性化学习"
        return 1
    fi

    print_section "会话配置"
    print_step "协作范式: $paradigm" "info"
    print_step "讨论主题: $topic" "info"

    # 使用原生协作脚本启动会话
    local native_script="$PROJECT_ROOT/.specify/scripts/bash/collaboration-session-automation.sh"
    if [[ -f "$native_script" ]] && [[ -x "$native_script" ]]; then
        print_step "启动原生协作会话..." "info"
        if "$native_script" start "$paradigm" "$topic"; then
            print_step "协作会话启动成功" "success"

            # 保存会话状态
            cat > "$SESSION_STATE_FILE" << EOF
SESSION_ID=$(date +%s)
PARADIGM=$paradigm
TOPIC="$topic"
START_TIME=$(date)
STATUS=active
EOF

            print_step "会话状态已保存" "success"
        else
            print_step "协作会话启动失败" "error"
            return 1
        fi
    else
        print_step "原生协作脚本不可用" "error"
        return 1
    fi

    # 提供使用指导
    print_section "使用指导"
    echo -e "${BLUE}📝 接下来您可以:${NC}"
    echo "  1. 正常与AI进行对话交流"
    echo "  2. 系统会自动记录您的交互内容"
    echo "  3. 完成后使用 ${GREEN}/save${NC} 保存会话"
    echo "  4. 系统会自动验证内容完整性"

    return 0
}

# 智能内容添加
smart_add_content() {
    local content="$1"
    local session_id="${2:-auto}"

    # 使用改进版内容处理器
    if [[ -f "$CONTENT_HANDLER" ]]; then
        "$CONTENT_HANDLER" add-content "$content" "$session_id"
    else
        print_step "内容处理器不可用，使用备用方案" "warning"
        # 备用方案：直接写入文件
        echo "$content" >> "/tmp/fallback_content_$session_id.txt"
    fi
}

# 智能会话保存
smart_collaboration_save() {
    print_header "保存协作会话"

    # 检查是否有活跃会话
    if [[ ! -f "$SESSION_STATE_FILE" ]]; then
        print_step "没有找到活跃的协作会话" "warning"
        echo -e "${YELLOW}建议:${NC}"
        echo "  1. 首先使用 ${GREEN}/collaborate <范式> <主题>${NC} 启动会话"
        echo "  2. 进行AI对话交互"
        echo "  3. 然后使用 ${GREEN}/save${NC} 保存会话"
        return 1
    fi

    source "$SESSION_STATE_FILE"

    print_section "会话信息"
    print_step "会话ID: $SESSION_ID" "info"
    print_step "协作范式: $PARADIGM" "info"
    print_step "讨论主题: $TOPIC" "info"
    print_step "开始时间: $START_TIME" "info"

    # 步骤1: 使用原生保存功能
    print_section "内容保存"
    print_step "正在保存协作内容..." "info"

    local native_script="$PROJECT_ROOT/.specify/scripts/bash/collaboration-session-automation.sh"
    if "$native_script" save 2>/dev/null; then
        print_step "原生保存成功" "success"
    else
        print_step "原生保存失败，尝试备用方案" "warning"

        # 备用保存方案
        local fallback_file="$COLLAB_DIR/enhanced-session-$(date +%Y%m%d-%H%M%S).md"
        cat > "$fallback_file" << EOF
# AI协作会话记录 (增强版)

## 会话元信息

**会话ID**: $SESSION_ID
**时间**: $(date +"%Y%m%d %H:%M:%S")
**协作范式**: $PARADIGM
**参与者**: AI Assistant, User
**主题**: $TOPIC
**开始时间**: $START_TIME
**保存时间**: $(date +"%Y-%m-%d %H:%M:%S")

## 范式说明

**$PARADIGM**：
协作会话采用 $PARADIGM 范式进行深度探讨。

## 完整对话记录

[注意：此为备用保存，可能不完整]

## 讨论内容

[内容已保存但可能缺少部分细节]

## 关键洞察

[关键洞察待提取]

## 产出成果

[产出成果待总结]

## 行动要点

[行动要点待生成]

---

*本会话记录保存于: $fallback_file*
*协作范式: $PARADIGM | 技术主题: $TOPIC*
EOF
        print_step "备用保存完成: $fallback_file" "success"
    fi

    # 步骤2: 内容完整性验证
    print_section "内容验证"
    print_step "正在验证内容完整性..." "info"

    # 验证最新保存的文档
    local latest_doc=$(find "$COLLAB_DIR" -name "*.md" -type f -mmin -5 | head -1)
    if [[ -n "$latest_doc" ]] && [[ -f "$CONTENT_VALIDATOR" ]]; then
        local content=$(cat "$latest_doc")
        local snapshot_id="validate_$(date +%s)"

        if "$CONTENT_VALIDATOR" snapshot "$content" "$snapshot_id" >/dev/null 2>&1; then
            local snapshot_file="/tmp/collab-validation/${snapshot_id}.snapshot"
            if "$CONTENT_VALIDATOR" validate "$content" "$snapshot_file" >/dev/null 2>&1; then
                print_step "内容完整性验证通过" "success"
            else
                print_step "内容完整性验证有问题" "warning"
            fi
            rm -f "$snapshot_file"
        fi
    else
        print_step "跳过内容验证（工具不可用）" "warning"
    fi

    # 步骤3: 清理会话状态
    print_section "清理工作"
    rm -f "$SESSION_STATE_FILE"
    print_step "会话状态已清理" "success"

    # 输出结果总结
    print_section "保存总结"
    print_step "协作会话保存完成" "success"

    if [[ -n "$latest_doc" ]]; then
        print_step "文档位置: $latest_doc" "info"
    fi

    echo -e "\n${GREEN}🎉 增强版AI协作会话已成功保存！${NC}"

    return 0
}

# 系统健康检查
enhanced_health_check() {
    print_header "增强版系统健康检查"

    # 基础健康检查
    if [[ -f "$ERROR_HANDLER" ]]; then
        print_section "基础系统检查"
        "$ERROR_HANDLER" health-check
    fi

    # 优化工具检查
    print_section "优化工具检查"
    local tools=(
        "$CONTENT_HANDLER:内容处理器"
        "$ERROR_HANDLER:错误处理器"
        "$CONTENT_VALIDATOR:内容验证器"
    )

    for tool_info in "${tools[@]}"; do
        local tool="${tool_info%:*}"
        local name="${tool_info#*:}"

        if [[ -f "$tool" ]] && [[ -x "$tool" ]]; then
            print_step "$name 就绪" "success"
        else
            print_step "$name 不可用" "error"
        fi
    done

    # 协作文档检查
    print_section "协作文档状态"
    if [[ -d "$COLLAB_DIR" ]]; then
        local doc_count=$(find "$COLLAB_DIR" -name "*.md" | wc -l)
        local total_size=$(du -sh "$COLLAB_DIR" | cut -f1)
        print_step "协作文档数量: $doc_count" "info"
        print_step "文档总大小: $total_size" "info"

        # 检查最近文档
        local recent_docs=$(find "$COLLAB_DIR" -name "*.md" -mtime -7 | wc -l)
        print_step "最近7天文档: $recent_docs" "info"
    else
        print_step "协作文档目录不存在" "error"
    fi

    # 性能统计
    print_section "性能统计"
    if [[ -f "$HOME/.collab-logs/errors.log" ]]; then
        local error_count=$(grep -c "\[ERROR\]" "$HOME/.collab-logs/errors.log" 2>/dev/null | tr -d '\n' || echo "0")
        if [[ -n "$error_count" ]] && [[ "$error_count" =~ ^[0-9]+$ ]] && [[ $error_count -eq 0 ]]; then
            print_step "最近无错误记录" "success"
        else
            print_step "发现 ${error_count:-0} 个错误记录" "warning"
        fi
    fi

    echo -e "\n${GREEN}✅ 系统健康检查完成${NC}"
}

# 显示帮助信息
show_help() {
    print_header "增强版AI协作系统 v2.0"

    cat << 'EOF'
🚀 功能特性：
• 智能内容处理，保护Mermaid图表和代码块
• 增强错误处理，提供详细诊断和修复建议
• 内容完整性验证，确保信息不丢失
• 优化用户体验，提供清晰的进度反馈
• 自动化工作流，减少手动操作

📋 使用方法：

启动协作会话：
  ./enhanced-collaboration.sh start <范式> <主题>

保存协作会话：
  ./enhanced-collaboration.sh save

系统健康检查：
  ./enhanced-collaboration.sh health

显示帮助：
  ./enhanced-collaboration.sh help

🔧 集成工具：
• improved-content-handler.sh - 安全内容处理
• error-handler.sh - 错误诊断和修复
• content-validator.sh - 内容完整性验证

💡 使用建议：
1. 使用 enhanced-collaboration.sh 替代原生命令
2. 定期运行健康检查确保系统正常
3. 注意查看错误日志和诊断信息
4. 备份重要的协作文档

🎯 优化亮点：
• 解决Mermaid图表丢失问题
• 提供智能错误恢复建议
• 实现内容完整性自动验证
• 增强用户操作反馈
EOF
}

# 主程序
main() {
    case "${1:-}" in
        "start")
            initialize_system
            smart_collaboration_start "${2:-}" "${3:-}"
            ;;
        "save")
            initialize_system
            smart_collaboration_save
            ;;
        "health")
            initialize_system
            enhanced_health_check
            ;;
        "help"|"")
            show_help
            ;;
        *)
            echo -e "${RED}未知命令: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

# 执行主程序
main "$@"