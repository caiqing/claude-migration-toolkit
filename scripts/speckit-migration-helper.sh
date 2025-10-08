#!/usr/bin/env bash

# specify-cli 到 speckit 命令格式迁移助手
# 帮助用户平滑过渡到新的 speckit.* 命令格式

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
specify-cli 命令格式迁移助手

用法: $0 [选项] [命令]

选项:
  --check-only        仅检查兼容性，不执行任何操作
  --migrate-commands  迁移命令文件到新格式
  --backup-old        备份旧命令文件
  --help, -h          显示此帮助信息

命令:
  check               检查当前项目的命令格式兼容性
  migrate             执行完整的迁移流程
  status              显示迁移状态

示例:
  $0 check                           # 检查兼容性
  $0 migrate --backup-old            # 迁移并备份旧文件
  $0 --check-only status             # 仅显示状态

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

# 检查命令格式兼容性
check_compatibility() {
    log_step "检查命令格式兼容性"

    local old_commands_found=0
    local new_commands_found=0
    local total_commands=0

    # 检查旧格式命令
    local old_format=("specify.md" "clarify.md" "plan.md" "tasks.md" "implement.md" "constitution.md" "analyze.md")
    local new_format=("speckit.specify.md" "speckit.clarify.md" "speckit.plan.md" "speckit.tasks.md" "speckit.implement.md" "speckit.constitution.md" "speckit.analyze.md")

    echo
    echo -e "${CYAN}📊 命令格式检查结果:${NC}"

    # 检查.claude/commands目录
    if [ -d "$PROJECT_ROOT/.claude/commands" ]; then
        for cmd in "${old_format[@]}"; do
            if [ -f "$PROJECT_ROOT/.claude/commands/$cmd" ]; then
                echo -e "  ${YELLOW}🔸${NC} 发现旧格式: $cmd"
                ((old_commands_found++))
            fi
        done

        for cmd in "${new_format[@]}"; do
            if [ -f "$PROJECT_ROOT/.claude/commands/$cmd" ]; then
                echo -e "  ${GREEN}🔹${NC} 发现新格式: $cmd"
                ((new_commands_found++))
            fi
        done

        total_commands=$((old_commands_found + new_commands_found))

        echo
        echo -e "${CYAN}📈 统计信息:${NC}"
        echo -e "  旧格式命令: $old_commands_found"
        echo -e "  新格式命令: $new_commands_found"
        echo -e "  总命令数: $total_commands"

        if [ $old_commands_found -gt 0 ] && [ $new_commands_found -gt 0 ]; then
            echo -e "  ${YELLOW}状态: 混合格式${NC}"
            log_warning "发现新旧格式命令共存，建议完成迁移"
        elif [ $old_commands_found -gt 0 ]; then
            echo -e "  ${YELLOW}状态: 需要迁移${NC}"
            log_warning "需要迁移到新的 speckit.* 格式"
        elif [ $new_commands_found -gt 0 ]; then
            echo -e "  ${GREEN}状态: 已完成迁移${NC}"
            log_success "已使用新的 speckit.* 格式"
        else
            echo -e "  ${RED}状态: 未找到命令文件${NC}"
            log_error "未找到任何 specify 相关命令文件"
        fi
    else
        log_error "未找到 .claude/commands 目录"
        return 1
    fi

    echo
    return 0
}

# 备份旧命令文件
backup_old_commands() {
    log_step "备份旧命令文件"

    local backup_dir="$PROJECT_ROOT/.claude-commands-backup-$(date +%Y%m%d-%H%M%S)"
    local old_format=("specify.md" "clarify.md" "plan.md" "tasks.md" "implement.md" "constitution.md" "analyze.md")
    local files_backed_up=0

    mkdir -p "$backup_dir"

    for cmd in "${old_format[@]}"; do
        if [ -f "$PROJECT_ROOT/.claude/commands/$cmd" ]; then
            cp "$PROJECT_ROOT/.claude/commands/$cmd" "$backup_dir/"
            log_info "备份: $cmd"
            ((files_backed_up++))
        fi
    done

    if [ $files_backed_up -gt 0 ]; then
        log_success "备份完成: $backup_dir ($files_backed_up 个文件)"
        echo "$backup_dir" > "$PROJECT_ROOT/.claude-backup-path"
    else
        log_warning "没有找到需要备份的旧命令文件"
        rmdir "$backup_dir" 2>/dev/null || true
    fi
}

# 迁移命令文件
migrate_commands() {
    log_step "迁移命令文件到新格式"

    local old_format=("specify" "clarify" "plan" "tasks" "implement" "constitution" "analyze")
    local migrated_count=0

    for old_cmd in "${old_format[@]}"; do
        local old_file="$PROJECT_ROOT/.claude/commands/$old_cmd.md"
        local new_file="$PROJECT_ROOT/.claude/commands/speckit.$old_cmd.md"

        if [ -f "$old_file" ] && [ ! -f "$new_file" ]; then
            # 复制并更新内容
            cp "$old_file" "$new_file"

            # 更新文件内容中的命令引用
            sed -i.bak "s|/$old_cmd|/speckit.$old_cmd|g" "$new_file"
            rm "$new_file.bak"

            log_info "迁移: $old_cmd.md -> speckit.$old_cmd.md"
            ((migrated_count++))
        elif [ -f "$old_file" ] && [ -f "$new_file" ]; then
            log_warning "跳过 $old_cmd.md: 新格式文件已存在"
        fi
    done

    if [ $migrated_count -gt 0 ]; then
        log_success "迁移完成: $migrated_count 个文件"
    else
        log_info "没有需要迁移的文件"
    fi
}

# 显示迁移状态
show_status() {
    log_step "显示迁移状态"

    echo
    echo -e "${CYAN}📋 项目状态:${NC}"

    # 检查specify-cli版本
    if command -v specify &> /dev/null; then
        echo -e "  ${GREEN}✅${NC} specify-cli 已安装"
        echo -e "  版本: $(specify --version 2>/dev/null || echo "未知")"
    else
        echo -e "  ${RED}❌${NC} specify-cli 未安装"
    fi

    # 检查备份文件
    if [ -f "$PROJECT_ROOT/.claude-backup-path" ]; then
        local backup_path=$(cat "$PROJECT_ROOT/.claude-backup-path")
        echo -e "  ${BLUE}💾${NC} 备份位置: $backup_path"
    fi

    # 检查命令兼容性
    check_compatibility

    echo
    echo -e "${CYAN}🎯 建议操作:${NC}"
    if [ -f "$PROJECT_ROOT/.claude/commands/specify.md" ]; then
        echo -e "  1. 运行迁移: $0 migrate --backup-old"
        echo -e "  2. 测试新命令: /speckit.specify help"
    else
        echo -e "  ✨ 项目已使用最新格式！"
    fi
}

# 主函数
main() {
    echo -e "${CYAN}🔧 specify-cli 命令格式迁移助手${NC}"
    echo

    local check_only=false
    local migrate_commands_flag=false
    local backup_old_flag=false
    local action=""

    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --check-only)
                check_only=true
                shift
                ;;
            --migrate-commands)
                migrate_commands_flag=true
                shift
                ;;
            --backup-old)
                backup_old_flag=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            check|status|migrate)
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
            check_compatibility
            ;;
        status)
            show_status
            ;;
        migrate)
            if [ "$check_only" = false ]; then
                if [ "$backup_old_flag" = true ]; then
                    backup_old_commands
                fi
                if [ "$migrate_commands_flag" = true ]; then
                    migrate_commands
                fi
                check_compatibility
                log_success "迁移流程完成！"
            fi
            ;;
        "")
            # 默认显示状态
            show_status
            ;;
    esac
}

# 如果直接运行脚本
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi