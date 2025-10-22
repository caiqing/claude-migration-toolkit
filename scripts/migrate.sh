#!/usr/bin/env bash

# Claude标准迁移脚本
# 将AI协作功能和智能开发工作流迁移到目标项目

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
MIGRATION_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_PROJECT="${1:-$(pwd)}"
DRY_RUN=false
VERBOSE=false
SKIP_GIT_HOOKS=false
SKIP_STATUSBAR=false

# 显示帮助信息
show_help() {
    cat << EOF
Claude标准迁移工具

用法: $0 [选项] [目标项目路径]

选项:
  --dry-run          预览迁移操作，不实际执行
  --verbose          显示详细输出
  --skip-git-hooks   跳过Git hooks安装
  --skip-statusbar   跳过状态栏配置迁移
  --help, -h         显示此帮助信息

参数:
  目标项目路径        要迁移到的项目目录（默认为当前目录）

示例:
  $0                                          # 迁移到当前目录
  $0 /path/to/my-project                     # 迁移到指定项目
  $0 --dry-run /path/to/my-project           # 预览迁移操作
  $0 --verbose --skip-git-hooks ./new-project # 详细输出，跳过hooks
  $0 --skip-statusbar ./project              # 迁移但跳过状态栏配置

迁移组件:
  ✅ AI协作核心 (CLAUDE.md + /collaborate + /enhance + /save命令)
  ✅ 智能分支命名系统 (2个脚本)
  ✅ Git自动化系统 (3个脚本)
  ✅ AI协作指南 (1个模板)
  ✅ 增强版协作系统 (优化功能和错误处理)
  ✅ Claude Code状态栏配置 (自定义状态栏显示)

EOF
}

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --skip-git-hooks)
                SKIP_GIT_HOOKS=true
                shift
                ;;
            --skip-statusbar)
                SKIP_STATUSBAR=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            -*)
                echo "未知选项: $1" >&2
                show_help
                exit 1
                ;;
            *)
                TARGET_PROJECT="$1"
                shift
                ;;
        esac
    done
}

# 日志函数
log_info() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}[INFO]${NC} $1"
    fi
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

# 检查目标项目
validate_target_project() {
    log_step "检查目标项目: $TARGET_PROJECT"

    if [ ! -d "$TARGET_PROJECT" ]; then
        log_error "目标项目目录不存在: $TARGET_PROJECT"
        exit 1
    fi

    # 检查是否已有Claude配置
    if [ -f "$TARGET_PROJECT/CLAUDE.md" ]; then
        log_warning "目标项目已存在CLAUDE.md，将被覆盖"
    fi

    if [ -d "$TARGET_PROJECT/.claude" ]; then
        log_warning "目标项目已存在.claude目录，将被覆盖"
    fi

    if [ -d "$TARGET_PROJECT/.specify" ]; then
        log_warning "目标项目已存在.specify目录，将被覆盖"
    fi

    log_success "目标项目验证通过"
}

# 创建备份
create_backup() {
    log_step "创建现有配置的备份"

    local backup_dir="$TARGET_PROJECT/.claude-migration-backup-$(date +%Y%m%d-%H%M%S)"

    if [ -f "$TARGET_PROJECT/CLAUDE.md" ]; then
        mkdir -p "$backup_dir"
        cp "$TARGET_PROJECT/CLAUDE.md" "$backup_dir/"
        log_info "备份CLAUDE.md"
    fi

    if [ -d "$TARGET_PROJECT/.claude" ]; then
        mkdir -p "$backup_dir"
        cp -r "$TARGET_PROJECT/.claude" "$backup_dir/"
        log_info "备份.claude目录"
    fi

    if [ -d "$TARGET_PROJECT/.specify" ]; then
        mkdir -p "$backup_dir"
        cp -r "$TARGET_PROJECT/.specify" "$backup_dir/"
        log_info "备份.specify目录"
    fi

    log_success "备份完成: $backup_dir"
}

# 执行文件操作（支持dry-run）
execute_file_operation() {
    local operation="$1"
    local src="$2"
    local dest="$3"

    if [ "$DRY_RUN" = true ]; then
        case $operation in
            "copy")
                echo -e "${CYAN}[DRY-RUN]${NC} 复制: $src -> $dest"
                ;;
            "mkdir")
                echo -e "${CYAN}[DRY-RUN]${NC} 创建目录: $dest"
                ;;
            "chmod")
                echo -e "${CYAN}[DRY-RUN]${NC} 设置权限: $dest"
                ;;
        esac
        return 0
    fi

    case $operation in
        "copy")
            # 确保目标目录存在
            local dest_dir=$(dirname "$dest")
            if [ ! -d "$dest_dir" ]; then
                mkdir -p "$dest_dir"
                log_info "创建目录: $dest_dir"
            fi
            cp "$src" "$dest"
            log_info "复制文件: $(basename "$src")"
            ;;
        "mkdir")
            if [ -n "$dest" ]; then
                mkdir -p "$dest"
                log_info "创建目录: $dest"
            fi
            ;;
        "chmod")
            chmod +x "$dest"
            log_info "设置权限: $(basename "$dest")"
            ;;
    esac
}

# 迁移AI协作核心
migrate_ai_collaboration_core() {
    log_step "迁移AI协作核心"

    # 复制CLAUDE.md
    execute_file_operation "mkdir" "$TARGET_PROJECT"
    execute_file_operation "copy" "$MIGRATION_ROOT/core-files/CLAUDE.md" "$TARGET_PROJECT/CLAUDE.md"

    # 创建.claude/commands目录
    execute_file_operation "mkdir" "$TARGET_PROJECT/.claude/commands"

    # 复制ai.collab命令（统一AI协作系统）
    if [ -f "$MIGRATION_ROOT/core-files/ai.collab.md" ]; then
        execute_file_operation "copy" "$MIGRATION_ROOT/core-files/ai.collab.md" "$TARGET_PROJECT/.claude/commands/ai.collab.md"
        log_info "复制ai.collab.md统一AI协作命令"
    else
        log_warning "ai.collab.md文件不存在，跳过AI协作命令安装"
    fi

    # 复制新的speckit.*命令文件（specify-cli最新格式）
    if [ -d "$MIGRATION_ROOT/.claude/commands" ]; then
        for speckit_cmd in "$MIGRATION_ROOT/.claude/commands"/speckit.*.md; do
            if [ -f "$speckit_cmd" ]; then
                cmd_name=$(basename "$speckit_cmd")
                execute_file_operation "copy" "$speckit_cmd" "$TARGET_PROJECT/.claude/commands/$cmd_name"
                log_info "复制speckit命令文件: $cmd_name"
            fi
        done
    else
        log_warning "speckit命令文件目录不存在，跳过speckit命令安装"
    fi

    log_success "AI协作核心迁移完成"
}

# 迁移智能分支命名系统
migrate_intelligent_branch_naming() {
    log_step "迁移智能分支命名系统"

    # 创建scripts目录
    execute_file_operation "mkdir" "$TARGET_PROJECT/.specify/scripts/bash"

    # 复制脚本文件
    execute_file_operation "copy" "$MIGRATION_ROOT/core-files/create-new-feature.sh" "$TARGET_PROJECT/.specify/scripts/bash/create-new-feature.sh"
    execute_file_operation "copy" "$MIGRATION_ROOT/core-files/intelligent-branch-namer.sh" "$TARGET_PROJECT/.specify/scripts/bash/intelligent-branch-namer.sh"

    # 设置执行权限
    if [ "$DRY_RUN" = false ]; then
        chmod +x "$TARGET_PROJECT/.specify/scripts/bash/create-new-feature.sh"
        chmod +x "$TARGET_PROJECT/.specify/scripts/bash/intelligent-branch-namer.sh"
    fi

    log_success "智能分支命名系统迁移完成"
}

# 迁移Git自动化系统
migrate_git_automation() {
    log_step "迁移Git自动化系统"

    # 复制Git自动化脚本
    execute_file_operation "copy" "$MIGRATION_ROOT/core-files/git-changelog-hook.sh" "$TARGET_PROJECT/.specify/scripts/bash/git-changelog-hook.sh"
    execute_file_operation "copy" "$MIGRATION_ROOT/core-files/commit-parser.sh" "$TARGET_PROJECT/.specify/scripts/bash/commit-parser.sh"
    execute_file_operation "copy" "$MIGRATION_ROOT/core-files/update-changelog.sh" "$TARGET_PROJECT/.specify/scripts/bash/update-changelog.sh"

    # 设置执行权限
    if [ "$DRY_RUN" = false ]; then
        chmod +x "$TARGET_PROJECT/.specify/scripts/bash/git-changelog-hook.sh"
        chmod +x "$TARGET_PROJECT/.specify/scripts/bash/commit-parser.sh"
        chmod +x "$TARGET_PROJECT/.specify/scripts/bash/update-changelog.sh"
    fi

    # 创建docs目录和CHANGELOG
    execute_file_operation "mkdir" "$TARGET_PROJECT/docs"

    if [ "$DRY_RUN" = false ]; then
        if [ ! -f "$TARGET_PROJECT/docs/CHANGELOG.md" ]; then
            # 确保目录存在
            mkdir -p "$TARGET_PROJECT/docs"
            cat > "$TARGET_PROJECT/docs/CHANGELOG.md" << 'EOF'
# 更新日志

## [未发布]

### 新增
- Claude AI协作功能迁移
- 智能分支命名系统
- Git自动化CHANGELOG更新

EOF
            log_info "创建默认CHANGELOG.md"
        fi
    else
        echo -e "${CYAN}[DRY-RUN]${NC} 创建文件: $TARGET_PROJECT/docs/CHANGELOG.md"
    fi

    log_success "Git自动化系统迁移完成"
}

# 迁移AI协作指南
migrate_ai_collaboration_guide() {
    log_step "迁移AI协作指南"

    # 复制AI协作指南
    execute_file_operation "copy" "$MIGRATION_ROOT/core-files/ai-collaboration-guide.md" "$TARGET_PROJECT/docs/ai-collaboration-guide.md"

    log_success "AI协作指南迁移完成"
}

# 复制模板文件
migrate_templates() {
    log_step "复制模板文件"

    # 创建模板目录
    execute_file_operation "mkdir" "$TARGET_PROJECT/.specify/templates"

    # 复制模板（如果存在的话）
    if [ -f "$MIGRATION_ROOT/templates/spec-template.md" ]; then
        execute_file_operation "copy" "$MIGRATION_ROOT/templates/spec-template.md" "$TARGET_PROJECT/.specify/templates/spec-template.md"
    fi

    log_success "模板文件迁移完成"
}

# 迁移系统优化组件
migrate_optimization_components() {
    log_step "迁移系统优化组件"

    # 创建optimization目录
    execute_file_operation "mkdir" "$TARGET_PROJECT/.specify/optimization"

    # 复制optimization脚本
    if [ -d "$MIGRATION_ROOT/core-files/optimization" ]; then
        for opt_file in "$MIGRATION_ROOT/core-files/optimization"/*; do
            if [ -f "$opt_file" ]; then
                filename=$(basename "$opt_file")
                execute_file_operation "copy" "$opt_file" "$TARGET_PROJECT/.specify/optimization/$filename"
                # 如果是脚本文件，设置执行权限
                if [[ "$filename" == *.sh ]]; then
                    if [ "$DRY_RUN" = false ]; then
                        chmod +x "$TARGET_PROJECT/.specify/optimization/$filename"
                    fi
                    execute_file_operation "chmod" "$opt_file" "$TARGET_PROJECT/.specify/optimization/$filename"
                fi
                log_info "复制optimization组件: $filename"
            fi
        done
        log_success "系统优化组件迁移完成"
    else
        log_warning "optimization组件目录不存在，跳过迁移"
    fi
}

# 迁移Claude Code状态栏配置
migrate_statusbar_config() {
    if [ "$SKIP_STATUSBAR" = true ]; then
        log_info "跳过状态栏配置迁移（用户选择）"
        return
    fi

    log_step "迁移Claude Code状态栏配置"

    # 检查状态栏迁移脚本是否存在
    local statusbar_migrate_script="$SCRIPT_DIR/migrate-statusbar-config.sh"
    if [ ! -f "$statusbar_migrate_script" ]; then
        log_warning "状态栏迁移脚本不存在，跳过状态栏配置迁移"
        return
    fi

    # 检查源项目是否有状态栏配置
    local source_settings="$MIGRATION_ROOT/.claude/settings.local.json"
    if [ ! -f "$source_settings" ]; then
        log_info "源项目未找到状态栏配置，跳过迁移"
        return
    fi

    # 检查源项目是否启用了状态栏配置
    if ! jq -e '.statusLine' "$source_settings" >/dev/null 2>&1; then
        log_info "源项目未启用状态栏配置，跳过迁移"
        return
    fi

    # 构建迁移命令参数
    local migrate_args=""
    if [ "$DRY_RUN" = true ]; then
        migrate_args="$migrate_args --dry-run"
    fi
    if [ "$VERBOSE" = true ]; then
        migrate_args="$migrate_args --verbose"
    fi
    migrate_args="$migrate_args -s \"$MIGRATION_ROOT\" -m adapt \"$TARGET_PROJECT\""

    # 执行状态栏迁移
    if [ "$DRY_RUN" = false ]; then
        log_info "执行状态栏配置迁移..."
        if bash "$statusbar_migrate_script" -s "$MIGRATION_ROOT" -m adapt "$TARGET_PROJECT" >/dev/null 2>&1; then
            log_success "状态栏配置迁移完成"
        else
            log_warning "状态栏配置迁移失败，但不影响其他功能"
            log_info "可以手动运行: $statusbar_migrate_script -s \"$MIGRATION_ROOT\" \"$TARGET_PROJECT\""
        fi
    else
        echo -e "${CYAN}[DRY-RUN]${NC} 执行状态栏配置迁移: $statusbar_migrate_script $migrate_args"
    fi
}

# 运行路径适配器
run_path_adapter() {
    log_step "运行路径适配器"

    if [ -f "$SCRIPT_DIR/path-adapter.sh" ]; then
        if [ "$DRY_RUN" = false ]; then
            "$SCRIPT_DIR/path-adapter.sh" "$TARGET_PROJECT"
        else
            echo -e "${CYAN}[DRY-RUN]${NC} 运行路径适配器: $TARGET_PROJECT"
        fi
        log_success "路径适配完成"
    else
        log_warning "路径适配器不存在，跳过路径适配"
    fi
}

# 可选：安装Git hooks
install_git_hooks() {
    if [ "$SKIP_GIT_HOOKS" = true ]; then
        log_info "跳过Git hooks安装（用户选择）"
        return
    fi

    log_step "安装Git hooks（可选）"

    # 检查是否为Git仓库
    if [ ! -d "$TARGET_PROJECT/.git" ]; then
        log_warning "目标项目不是Git仓库，跳过hooks安装"
        return
    fi

    if [ "$DRY_RUN" = false ]; then
        # 运行Git hooks安装脚本
        if [ -f "$TARGET_PROJECT/.specify/scripts/bash/git-changelog-hook.sh" ]; then
            cd "$TARGET_PROJECT"
            ./.specify/scripts/bash/git-changelog-hook.sh install --non-interactive
            log_success "Git hooks安装完成"
        else
            log_warning "Git hooks脚本不存在，跳过安装"
        fi
    else
        echo -e "${CYAN}[DRY-RUN]${NC} 安装Git hooks"
    fi
}

# 显示迁移摘要
show_migration_summary() {
    log_step "迁移摘要"

    echo
    echo -e "${CYAN}📊 迁移统计:${NC}"
    echo -e "  📁 目标项目: $TARGET_PROJECT"
    echo -e "  📄 复制文件: 8个核心文件（ai.collab.md + speckit.*命令）"
    echo -e "  📂 创建目录: .claude/, .specify/, docs/"
    echo -e "  🔧 设置权限: 脚本执行权限"
    echo -e "  ⚡ 系统优化: 5个optimization组件"

    if [ "$SKIP_STATUSBAR" = false ]; then
        echo -e "  📊 状态栏配置: 自定义Claude Code状态栏"
    else
        echo -e "  📊 状态栏配置: 已跳过"
    fi

    if [ "$SKIP_GIT_HOOKS" = false ]; then
        echo -e "  🎣 Git hooks: 已安装"
    else
        echo -e "  🎣 Git hooks: 已跳过"
    fi

    echo
    echo -e "${CYAN}🚀 迁移后功能:${NC}"
    echo -e "  🤖 统一AI协作: /ai.collab [start|save|health|status]"
    echo -e "  📋 规格驱动开发: /speckit.specify, /speckit.plan, /speckit.tasks"
    echo -e "  🔍 一致性分析: /speckit.analyze"
    echo -e "  🌱 智能分支命名: create-new-feature.sh [描述]"
    echo -e "  📝 自动CHANGELOG: Git提交时自动更新"
    echo -e "  📚 AI协作指南: docs/ai-collaboration-guide.md"
    echo -e "  ⚡ 系统优化: 增强版协作、错误处理、内容验证"

    if [ "$SKIP_STATUSBAR" = false ]; then
        echo -e "  📊 状态栏显示: 自定义模型信息、Git分支、Token使用情况"
    fi

    echo
    echo -e "${GREEN}✨ 迁移完成！现在可以使用Claude AI协作功能了${NC}"
}

# 主函数
main() {
    echo -e "${CYAN}🚀 Claude标准迁移工具${NC}"
    echo -e "${CYAN}将AI协作功能和智能开发工作流迁移到目标项目${NC}"
    echo

    # 解析参数
    parse_args "$@"

    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}🔍 DRY-RUN模式 - 不会实际执行任何操作${NC}"
        echo
    fi

    # 执行迁移步骤
    validate_target_project
    create_backup
    migrate_ai_collaboration_core
    migrate_intelligent_branch_naming
    migrate_git_automation
    migrate_ai_collaboration_guide
    migrate_templates
    migrate_optimization_components
    migrate_statusbar_config
    run_path_adapter
    install_git_hooks
    show_migration_summary

    if [ "$DRY_RUN" = false ]; then
        echo
        echo -e "${CYAN}💡 下一步:${NC}"
        echo -e "  1. 验证迁移结果: $SCRIPT_DIR/validator.sh $TARGET_PROJECT"
        echo -e "  2. 体验AI协作: cd $TARGET_PROJECT && /ai.collab help"
        echo -e "  3. 启动创意协作: cd $TARGET_PROJECT && /ai.collab start creative '产品创新'"
        echo -e "  4. 测试规格驱动: cd $TARGET_PROJECT && /speckit.specify '用户认证系统'"
        echo -e "  5. 创建智能分支: cd $TARGET_PROJECT && ./.specify/scripts/bash/create-new-feature.sh '实现新功能'"
        echo -e "  6. 系统优化工具: cd $TARGET_PROJECT && ./.specify/optimization/enhanced-collaboration.sh health"

        if [ "$SKIP_STATUSBAR" = false ]; then
            echo -e "  7. 状态栏配置: 检查 $TARGET_PROJECT/.claude/settings.local.json 中的statusLine配置"
            echo -e "  8. 重启Claude Code以应用状态栏配置"
        else
            echo -e "  7. 手动迁移状态栏: $SCRIPT_DIR/migrate-statusbar-config.sh $TARGET_PROJECT"
        fi
    fi
}

# 如果直接运行脚本
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi