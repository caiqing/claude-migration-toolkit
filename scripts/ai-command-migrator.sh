#!/usr/bin/env bash

# AI命令迁移助手
# 帮助用户从旧的 /collaborate, /enhance, /save 命令迁移到新的 /ai.collab 命令

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
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 显示帮助信息
show_help() {
    cat << EOF
AI命令迁移助手

用法: $0 [选项] [命令]

选项:
  --dry-run          预览迁移操作，不实际执行
  --backup-old       备份旧命令文件
  --remove-old       迁移后删除旧命令文件
  --help, -h         显示此帮助信息

命令:
  check              检查当前AI命令状态
  migrate            执行完整的命令迁移
  status             显示迁移后状态
  demo               演示新命令功能

示例:
  $0 check                           # 检查当前状态
  $0 migrate --backup-old            # 迁移并备份旧文件
  $0 demo                           # 演示新命令功能

EOF
}

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

log_error() {
    echo -e "${RED}❌${NC} $1"
}

log_step() {
    echo -e "${PURPLE}🚀${NC} $1"
}

# 检查AI命令状态
check_ai_commands() {
    log_step "检查AI命令状态"

    local old_commands=("collaborate.md" "enhance.md" "save.md")
    local new_commands=("ai.collab.md")

    echo
    echo -e "${CYAN}📊 AI命令状态检查:${NC}"

    # 检查新命令
    local new_found=false
    for cmd in "${new_commands[@]}"; do
        if [ -f "$PROJECT_ROOT/.claude/commands/$cmd" ]; then
            echo -e "  ${GREEN}✅${NC} 新命令: /${cmd%.md}"
            new_found=true
        else
            echo -e "  ${RED}❌${NC} 新命令缺失: /${cmd%.md}"
        fi
    done

    # 检查旧命令
    local old_found=false
    for cmd in "${old_commands[@]}"; do
        if [ -f "$PROJECT_ROOT/.claude/commands/$cmd" ]; then
            echo -e "  ${YELLOW}🔸${NC} 旧命令: /${cmd%.md}"
            old_found=true
        fi
    done

    if [ "$new_found" = true ] && [ "$old_found" = true ]; then
        echo -e "  ${BLUE}🔄${NC} 状态: 新旧命令共存，建议完成迁移"
    elif [ "$new_found" = true ]; then
        echo -e "  ${GREEN}✨${NC} 状态: 已完成迁移到新格式"
    else
        echo -e "  ${RED}❌${NC} 状态: 缺少AI命令文件"
    fi

    echo
}

# 备份旧命令文件
backup_old_commands() {
    log_step "备份旧AI命令文件"

    local backup_dir="$PROJECT_ROOT/.ai-commands-backup-$(date +%Y%m%d-%H%M%S)"
    local old_commands=("collaborate.md" "enhance.md" "save.md")
    local files_backed_up=0

    mkdir -p "$backup_dir"

    for cmd in "${old_commands[@]}"; do
        if [ -f "$PROJECT_ROOT/.claude/commands/$cmd" ]; then
            cp "$PROJECT_ROOT/.claude/commands/$cmd" "$backup_dir/"
            log_info "备份: $cmd"
            ((files_backed_up++))
        fi
    done

    if [ $files_backed_up -gt 0 ]; then
        log_success "备份完成: $backup_dir ($files_backed_up 个文件)"
        echo "$backup_dir" > "$PROJECT_ROOT/.ai-backup-path"
    else
        log_warning "没有找到需要备份的旧命令文件"
        rmdir "$backup_dir" 2>/dev/null || true
    fi
}

# 迁移到新命令
migrate_to_new_commands() {
    log_step "迁移到新AI命令格式"

    # 确保新命令文件存在
    if [ ! -f "$PROJECT_ROOT/.claude/commands/ai.collab.md" ]; then
        if [ -f "$PROJECT_ROOT/core-files/ai.collab.md" ]; then
            cp "$PROJECT_ROOT/core-files/ai.collab.md" "$PROJECT_ROOT/.claude/commands/ai.collab.md"
            log_success "复制新命令文件: ai.collab.md"
        else
            log_error "新命令文件 ai.collab.md 不存在"
            return 1
        fi
    else
        log_info "新命令文件已存在: ai.collab.md"
    fi

    # 将旧命令转换为重定向文件
    local old_commands=("collaborate" "enhance" "save")

    for cmd in "${old_commands[@]}"; do
        local old_file="$PROJECT_ROOT/.claude/commands/$cmd.md"

        if [ -f "$old_file" ]; then
            # 创建重定向文件
            cat > "$old_file" << EOF
---
description: 向后兼容的${cmd}命令 - 自动重定向到新的 /ai.collab 命令。
---

**📢 重要通知**: 此命令已升级为 \`/ai.collab\`，提供更强大的功能和更好的用户体验。

## 快速迁移

\`\`\`bash
# 旧格式（即将弃用）
/$cmd

# 新格式（推荐使用）
EOF

            # 根据命令类型添加具体的迁移示例
            case $cmd in
                "collaborate")
                    cat >> "$old_file" << 'EOF'
/ai.collab start creative "主题"
EOF
                    ;;
                "enhance")
                    cat >> "$old_file" << 'EOF'
/ai.collab start progressive "主题"  # 或 /ai.collab save / ai.collab health
EOF
                    ;;
                "save")
                    cat >> "$old_file" << 'EOF'
/ai.collab save
EOF
                    ;;
            esac

            cat >> "$old_file" << 'EOF'
```

运行 \`/ai.collab help\` 查看完整功能列表。

---

*建议立即迁移到 \`/ai.collab\` 以获得最佳体验*
EOF

            log_info "更新重定向文件: $cmd.md"
        fi
    done

    log_success "命令迁移完成"
}

# 显示迁移后状态
show_migration_status() {
    log_step "显示AI命令迁移状态"

    echo
    echo -e "${CYAN}🎯 AI命令生态系统:${NC}"

    # 新统一命令
    echo -e "${GREEN}🤖 统一AI协作系统:${NC}"
    echo -e "  /ai.collab start [范式] \"主题\"  - 启动AI协作"
    echo -e "  /ai.collab save               - 保存会话"
    echo -e "  /ai.collab health             - 系统检查"
    echo -e "  /ai.collab status             - 查看状态"
    echo -e "  /ai.collab help               - 显示帮助"

    # 向后兼容
    echo -e "${YELLOW}🔄 向后兼容:${NC}"
    echo -e "  /collaborate [范式] \"主题\"    - → /ai.collab start [范式] \"主题\""
    echo -e "  /enhance start [范式] \"主题\"  - → /ai.collab start [范式] \"主题\""
    echo -e "  /enhance save                 - → /ai.collab save"
    echo -e "  /save                         - → /ai.collab save"

    echo
    echo -e "${CYAN}🧠 支持的协作范式:${NC}"
    local paradigms=("first-principles" "progressive" "visual" "creative" "critical" "feyman" "smart" "optimize" "ears" "evolve" "fusion" "learning")
    for i in "${!paradigms[@]}"; do
        local paradigm="${paradigms[$i]}"
        if [ $((i % 4)) -eq 0 ] && [ $i -gt 0 ]; then
            echo
            echo -n "  "
        elif [ $i -eq 0 ]; then
            echo -n "  "
        fi
        printf "%-20s" "$paradigm"
    done
    echo
    echo

    # 检查备份
    if [ -f "$PROJECT_ROOT/.ai-backup-path" ]; then
        local backup_path=$(cat "$PROJECT_ROOT/.ai-backup-path")
        echo -e "${BLUE}💾${NC} 备份位置: $backup_path"
    fi
}

# 演示新命令功能
demo_new_commands() {
    log_step "演示新AI命令功能"

    echo
    echo -e "${CYAN}🎬 新命令使用演示:${NC}"
    echo
    echo -e "${BLUE}1. 启动AI协作会话:${NC}"
    echo -e "   ${YELLOW}命令:${NC} /ai.collab start creative \"产品创新头脑风暴\""
    echo -e "   ${GREEN}效果:${NC} 启动创意激发协作范式，提供智能内容处理"
    echo
    echo -e "${BLUE}2. 保存协作会话:${NC}"
    echo -e "   ${YELLOW}命令:${NC} /ai.collab save"
    echo -e "   ${GREEN}效果:${NC} 智能保存完整对话，包含Mermaid图表和代码块"
    echo
    echo -e "${BLUE}3. 系统健康检查:${NC}"
    echo -e "   ${YELLOW}命令:${NC} /ai.collab health"
    echo -e "   ${GREEN}效果:${NC} 检查AI协作系统状态，诊断潜在问题"
    echo
    echo -e "${BLUE}4. 查看会话状态:${NC}"
    echo -e "   ${YELLOW}命令:${NC} /ai.collab status"
    echo -e "   ${GREEN}效果:${NC} 显示当前会话的详细统计信息"
    echo
    echo -e "${BLUE}5. 获取帮助信息:${NC}"
    echo -e "   ${YELLOW}命令:${NC} /ai.collab help"
    echo -e "   ${GREEN}效果:${NC} 显示完整的使用说明和范式介绍"
    echo

    echo -e "${CYAN}🚀 立即尝试:${NC}"
    echo -e "   运行: /ai.collab help 开始体验新功能"
    echo
}

# 主函数
main() {
    echo -e "${CYAN}🔧 AI命令迁移助手${NC}"
    echo

    local dry_run=false
    local backup_old=false
    local remove_old=false
    local action=""

    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                dry_run=true
                shift
                ;;
            --backup-old)
                backup_old=true
                shift
                ;;
            --remove-old)
                remove_old=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            check|migrate|status|demo)
                action="$1"
                shift
                ;;
            *)
                echo "未知选项: $1" >&2
                show_help
                exit 1
                ;;
        esac
    done

    # 执行操作
    case $action in
        check)
            check_ai_commands
            ;;
        migrate)
            if [ "$dry_run" = false ]; then
                if [ "$backup_old" = true ]; then
                    backup_old_commands
                fi
                migrate_to_new_commands
                check_ai_commands
                log_success "AI命令迁移完成！"
            else
                log_info "DRY-RUN模式：不会执行实际操作"
                check_ai_commands
            fi
            ;;
        status)
            show_migration_status
            ;;
        demo)
            demo_new_commands
            ;;
        "")
            # 默认显示状态
            check_ai_commands
            show_migration_status
            ;;
    esac
}

# 如果直接运行脚本
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi