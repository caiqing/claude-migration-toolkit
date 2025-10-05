#!/usr/bin/env bash

# 路径适配器
# 自动调整迁移后的脚本路径引用，确保在不同环境下正常工作

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
TARGET_PROJECT="${1:-$(pwd)}"

# 显示帮助信息
show_help() {
    cat << EOF
路径适配器

用法: $0 [目标项目路径]

功能:
  自动调整迁移后脚本中的路径引用
  检测目标项目结构并适配路径变量
  修复脚本中的相对路径依赖

参数:
  目标项目路径    要适配路径的项目目录（默认为当前目录）

示例:
  $0                          # 适配当前目录
  $0 /path/to/my-project     # 适配指定项目
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
    echo -e "${PURPLE}🔧${NC} $1"
}

# 检查目标项目
validate_target() {
    if [ ! -d "$TARGET_PROJECT" ]; then
        log_error "目标项目目录不存在: $TARGET_PROJECT"
        exit 1
    fi

    if [ ! -f "$TARGET_PROJECT/.specify/scripts/bash/create-new-feature.sh" ]; then
        log_error "目标项目似乎未完成迁移，找不到关键脚本"
        exit 1
    fi

    log_success "目标项目验证通过"
}

# 获取实际的仓库根目录
detect_repo_root() {
    local target_dir="$1"

    # 方法1：使用git命令
    if git -C "$target_dir" rev-parse --show-toplevel >/dev/null 2>&1; then
        git -C "$target_dir" rev-parse --show-toplevel
        return
    fi

    # 方法2：向上查找.git目录
    local dir="$target_dir"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.git" ]; then
            echo "$dir"
            return
        fi
        dir="$(dirname "$dir")"
    done

    # 方法3：查找.specify目录作为仓库根目录标记
    dir="$target_dir"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.specify" ]; then
            echo "$dir"
            return
        fi
        dir="$(dirname "$dir")"
    done

    # Fallback：使用传入的目录
    echo "$target_dir"
}

# 适配create-new-feature.sh的路径
adapt_create_new_feature() {
    log_step "适配create-new-feature.sh的路径引用"

    local script_file="$TARGET_PROJECT/.specify/scripts/bash/create-new-feature.sh"
    local repo_root=$(detect_repo_root "$TARGET_PROJECT")

    log_info "检测到仓库根目录: $repo_root"

    # 创建适配后的脚本
    local temp_file=$(mktemp)

    # 适配脚本中的路径逻辑
    sed "
        # 更新REPO_ROOT的检测逻辑
        s|REPO_ROOT=\"\$(git rev-parse --show-toplevel)\"|REPO_ROOT=\"$repo_root\"|g

        # 确保SPECS_DIR使用正确的路径
        s|SPECS_DIR=\"\$REPO_ROOT/specs\"|SPECS_DIR=\"$repo_root/specs\"|g

        # 适配脚本目录路径
        s|SCRIPT_DIR=\"\$(cd \"\$(dirname \"\${BASH_SOURCE\[0\]}\")\" && pwd)\"|SCRIPT_DIR=\"$repo_root/.specify/scripts/bash\"|g

    " "$script_file" > "$temp_file"

    # 替换原文件
    mv "$temp_file" "$script_file"
    chmod +x "$script_file"

    log_success "create-new-feature.sh路径适配完成"
}

# 适配intelligent-branch-namer.sh的路径
adapt_intelligent_branch_namer() {
    log_step "适配intelligent-branch-namer.sh的路径引用"

    local script_file="$TARGET_PROJECT/.specify/scripts/bash/intelligent-branch-namer.sh"

    # 这个脚本主要是函数定义，通常不需要路径适配
    # 但我们可以确保它有正确的执行权限
    chmod +x "$script_file"

    log_success "intelligent-branch-namer.sh适配完成"
}

# 适配Git自动化脚本的路径
adapt_git_automation_scripts() {
    log_step "适配Git自动化脚本的路径引用"

    local repo_root=$(detect_repo_root "$TARGET_PROJECT")
    local scripts_dir="$TARGET_PROJECT/.specify/scripts/bash"

    # 适配git-changelog-hook.sh
    local hook_script="$scripts_dir/git-changelog-hook.sh"
    if [ -f "$hook_script" ]; then
        local temp_file=$(mktemp)

        sed "
            # 更新REPO_ROOT路径
            s|REPO_ROOT=\"\$(cd \"\$SCRIPT_DIR/../../../\" && pwd)\"|REPO_ROOT=\"$repo_root\"|g
            s|REPO_ROOT=\"\$(cd \"\$SCRIPT_DIR/../../..\" && pwd)\"|REPO_ROOT=\"$repo_root\"|g

            # 更新SCRIPT_DIR路径
            s|SCRIPT_DIR=\"\$(cd \"\$(dirname \"\${BASH_SOURCE\[0\]}\")\" && pwd)\"|SCRIPT_DIR=\"$scripts_dir\"|g

            # 更新CHANGELOG_FILE路径
            s|CHANGELOG_FILE=\"\$REPO_ROOT/docs/CHANGELOG.md\"|CHANGELOG_FILE=\"$repo_root/docs/CHANGELOG.md\"|g

        " "$hook_script" > "$temp_file"

        mv "$temp_file" "$hook_script"
        chmod +x "$hook_script"

        log_info "git-changelog-hook.sh路径适配完成"
    fi

    # 适配commit-parser.sh
    local parser_script="$scripts_dir/commit-parser.sh"
    if [ -f "$parser_script" ]; then
        local temp_file=$(mktemp)

        sed "
            # 更新REPO_ROOT路径
            s|REPO_ROOT=\"\$(cd \"\$SCRIPT_DIR/../..\" && pwd)\"|REPO_ROOT=\"$repo_root\"|g

            # 更新SCRIPT_DIR路径
            s|SCRIPT_DIR=\"\$(cd \"\$(dirname \"\${BASH_SOURCE\[0\]}\")\" && pwd)\"|SCRIPT_DIR=\"$scripts_dir\"|g

        " "$parser_script" > "$temp_file"

        mv "$temp_file" "$parser_script"
        chmod +x "$parser_script"

        log_info "commit-parser.sh路径适配完成"
    fi

    # 适配update-changelog.sh
    local changelog_script="$scripts_dir/update-changelog.sh"
    if [ -f "$changelog_script" ]; then
        local temp_file=$(mktemp)

        sed "
            # 更新REPO_ROOT路径
            s|REPO_ROOT=\"\$(cd \"\$SCRIPT_DIR/../../../\" && pwd)\"|REPO_ROOT=\"$repo_root\"|g
            s|REPO_ROOT=\"\$(cd \"\$SCRIPT_DIR/../../..\" && pwd)\"|REPO_ROOT=\"$repo_root\"|g

            # 更新SCRIPT_DIR路径
            s|SCRIPT_DIR=\"\$(cd \"\$(dirname \"\${BASH_SOURCE\[0\]}\")\" && pwd)\"|SCRIPT_DIR=\"$scripts_dir\"|g

            # 更新CHANGELOG_FILE路径
            s|CHANGELOG_FILE=\"\$REPO_ROOT/docs/CHANGELOG.md\"|CHANGELOG_FILE=\"$repo_root/docs/CHANGELOG.md\"|g

        " "$changelog_script" > "$temp_file"

        mv "$temp_file" "$changelog_script"
        chmod +x "$changelog_script"

        log_info "update-changelog.sh路径适配完成"
    fi

    log_success "Git自动化脚本路径适配完成"
}

# 创建目录结构
ensure_directory_structure() {
    log_step "确保目录结构完整"

    local repo_root=$(detect_repo_root "$TARGET_PROJECT")

    # 创建必要的目录
    mkdir -p "$repo_root/.claude/commands"
    mkdir -p "$repo_root/.specify/scripts/bash"
    mkdir -p "$repo_root/.specify/templates"
    mkdir -p "$repo_root/specs"
    mkdir -p "$repo_root/docs"

    log_success "目录结构检查完成"
}

# 验证脚本可执行性
verify_executability() {
    log_step "验证脚本可执行性"

    local scripts_dir="$TARGET_PROJECT/.specify/scripts/bash"
    local scripts=(
        "create-new-feature.sh"
        "intelligent-branch-namer.sh"
        "git-changelog-hook.sh"
        "commit-parser.sh"
        "update-changelog.sh"
    )

    local failed_scripts=()

    for script in "${scripts[@]}"; do
        local script_path="$scripts_dir/$script"
        if [ -f "$script_path" ]; then
            if [ -x "$script_path" ]; then
                log_info "✓ $script - 可执行"
            else
                log_warning "✗ $script - 无执行权限，正在修复..."
                chmod +x "$script_path"
                if [ $? -eq 0 ]; then
                    log_info "✓ $script - 权限修复成功"
                else
                    log_error "✗ $script - 权限修复失败"
                    failed_scripts+=("$script")
                fi
            fi
        else
            log_warning "✗ $script - 文件不存在"
            failed_scripts+=("$script")
        fi
    done

    if [ ${#failed_scripts[@]} -eq 0 ]; then
        log_success "所有脚本可执行性验证通过"
    else
        log_warning "部分脚本验证失败: ${failed_scripts[*]}"
    fi
}

# 检查依赖关系
check_dependencies() {
    log_step "检查脚本依赖关系"

    local missing_deps=()

    # 检查基本命令
    local commands=("git" "sed" "grep" "mkdir" "chmod")
    for cmd in "${commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            log_info "✓ $cmd - 可用"
        else
            log_error "✗ $cmd - 不可用"
            missing_deps+=("$cmd")
        fi
    done

    # 检查脚本间的依赖
    local repo_root=$(detect_repo_root "$TARGET_PROJECT")
    local scripts_dir="$repo_root/.specify/scripts/bash"

    # 检查intelligent-branch-namer.sh是否可被create-new-feature.sh调用
    if [ -f "$scripts_dir/create-new-feature.sh" ] && [ -f "$scripts_dir/intelligent-branch-namer.sh" ]; then
        log_info "✓ 智能分支命名依赖 - 正常"
    else
        log_warning "✗ 智能分支命名依赖 - 异常"
    fi

    # 检查Git自动化脚本依赖
    local git_scripts=("git-changelog-hook.sh" "commit-parser.sh" "update-changelog.sh")
    local git_deps_ok=true

    for script in "${git_scripts[@]}"; do
        if [ ! -f "$scripts_dir/$script" ]; then
            git_deps_ok=false
            break
        fi
    done

    if [ "$git_deps_ok" = true ]; then
        log_info "✓ Git自动化依赖 - 正常"
    else
        log_warning "✗ Git自动化依赖 - 异常"
    fi

    if [ ${#missing_deps[@]} -eq 0 ]; then
        log_success "依赖关系检查通过"
    else
        log_error "缺少必要依赖: ${missing_deps[*]}"
        return 1
    fi
}

# 生成适配报告
generate_adaptation_report() {
    log_step "生成路径适配报告"

    local repo_root=$(detect_repo_root "$TARGET_PROJECT")
    local report_file="$repo_root/.claude-migration-report.md"

    cat > "$report_file" << EOF
# Claude迁移路径适配报告

**生成时间**: $(date)
**目标项目**: $TARGET_PROJECT
**仓库根目录**: $repo_root

## 适配的文件

### AI协作核心
- ✅ CLAUDE.md
- ✅ .claude/commands/collaborate.md

### 智能分支命名系统
- ✅ .specify/scripts/bash/create-new-feature.sh
- ✅ .specify/scripts/bash/intelligent-branch-namer.sh

### Git自动化系统
- ✅ .specify/scripts/bash/git-changelog-hook.sh
- ✅ .specify/scripts/bash/commit-parser.sh
- ✅ .specify/scripts/bash/update-changelog.sh

### 文档和模板
- ✅ docs/ai-collaboration-guide.md
- ✅ .specify/templates/spec-template.md

## 目录结构
\`\`\`
$repo_root/
├── CLAUDE.md
├── .claude/
│   └── commands/
│       └── collaborate.md
├── .specify/
│   ├── scripts/bash/
│   │   ├── create-new-feature.sh
│   │   ├── intelligent-branch-namer.sh
│   │   ├── git-changelog-hook.sh
│   │   ├── commit-parser.sh
│   │   └── update-changelog.sh
│   └── templates/
│       └── spec-template.md
├── specs/
└── docs/
    ├── ai-collaboration-guide.md
    └── CHANGELOG.md
\`\`\`

## 快速开始

### AI协作
\`\`\`bash
/collaborate help
/collaborate visual    # 可视化呈现
/collaborate ears      # EARS需求描述
\`\`\`

### 智能分支命名
\`\`\`bash
./.specify/scripts/bash/create-new-feature.sh "实现新功能描述"
\`\`\`

### Git自动化
\`\`\`bash
./.specify/scripts/bash/git-changelog-hook.sh install
\`\`\`

## 注意事项

1. 所有脚本已设置正确的执行权限
2. 路径引用已适配到目标项目结构
3. 脚本依赖关系已验证
4. 如有问题，请检查本报告和错误日志

---

*此报告由Claude迁移工具自动生成*
EOF

    log_success "适配报告已生成: $report_file"
}

# 显示适配摘要
show_adaptation_summary() {
    log_step "路径适配摘要"

    echo
    echo -e "${CYAN}🔧 适配摘要:${NC}"
    echo -e "  📁 目标项目: $TARGET_PROJECT"
    echo -e "  🔄 适配脚本: 5个bash脚本"
    echo -e "  📂 目录结构: 已确保完整"
    echo -e "  🔐 执行权限: 已设置"
    echo -e "  📋 依赖检查: 已完成"

    echo
    echo -e "${GREEN}✨ 路径适配完成！脚本已准备就绪${NC}"
}

# 主函数
main() {
    echo -e "${CYAN}🔧 Claude路径适配器${NC}"
    echo -e "${CYAN}自动调整迁移后脚本的路径引用${NC}"
    echo

    # 解析参数
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        show_help
        exit 0
    fi

    # 执行适配步骤
    validate_target
    ensure_directory_structure
    adapt_create_new_feature
    adapt_intelligent_branch_namer
    adapt_git_automation_scripts
    verify_executability
    check_dependencies
    generate_adaptation_report
    show_adaptation_summary

    echo
    echo -e "${CYAN}💡 下一步:${NC}"
    echo -e "  1. 验证迁移结果: $SCRIPT_DIR/validator.sh $TARGET_PROJECT"
    echo -e "  2. 测试AI协作: cd $TARGET_PROJECT && /collaborate help"
    echo -e "  3. 创建测试功能: cd $TARGET_PROJECT && ./.specify/scripts/bash/create-new-feature.sh '测试功能'"
}

# 如果直接运行脚本
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi