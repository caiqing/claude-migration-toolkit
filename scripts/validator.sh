#!/usr/bin/env bash

# Claude迁移验证脚本
# 验证迁移后的功能完整性和可用性

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
VERBOSE=false
QUICK_MODE=false

# 显示帮助信息
show_help() {
    cat << EOF
Claude迁移验证工具

用法: $0 [选项] [目标项目路径]

选项:
  --verbose          显示详细验证信息
  --quick            快速验证模式（跳过耗时测试）
  --help, -h         显示此帮助信息

参数:
  目标项目路径        要验证的项目目录（默认为当前目录）

验证项目:
  ✅ 文件完整性检查
  ✅ 路径引用验证
  ✅ 脚本可执行性测试
  ✅ 依赖关系检查
  ✅ 功能可用性测试

示例:
  $0                                          # 验证当前目录
  $0 /path/to/my-project                     # 验证指定项目
  $0 --quick /path/to/my-project             # 快速验证模式
  $0 --verbose ./new-project                 # 详细验证输出

EOF
}

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --verbose)
                VERBOSE=true
                shift
                ;;
            --quick)
                QUICK_MODE=true
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

# 验证结果统计
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# 验证函数
check_pass() {
    ((PASSED_CHECKS++))
    ((TOTAL_CHECKS++))
    if [ "$VERBOSE" = true ]; then
        echo -e "${GREEN}  ✓${NC} $1"
    fi
}

check_fail() {
    ((FAILED_CHECKS++))
    ((TOTAL_CHECKS++))
    echo -e "${RED}  ✗${NC} $1"
}

check_warning() {
    ((WARNING_CHECKS++))
    ((TOTAL_CHECKS++))
    echo -e "${YELLOW}  ⚠${NC} $1"
}

# 日志函数
log_info() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}[INFO]${NC} $1"
    fi
}

log_step() {
    echo -e "${PURPLE}🔍${NC} $1"
}

# 检查目标项目
validate_target_project() {
    log_step "检查目标项目"

    if [ ! -d "$TARGET_PROJECT" ]; then
        echo -e "${RED}❌ 目标项目目录不存在: $TARGET_PROJECT${NC}"
        exit 1
    fi

    if [ ! -f "$TARGET_PROJECT/CLAUDE.md" ]; then
        check_fail "CLAUDE.md文件不存在"
    else
        check_pass "CLAUDE.md文件存在"
    fi

    log_info "目标项目路径: $TARGET_PROJECT"
}

# 验证文件完整性
validate_file_integrity() {
    log_step "验证文件完整性"

    # 核心文件列表
    declare -A core_files=(
        ["CLAUDE.md"]="AI协作指导原则"
        [".claude/commands/collaborate.md"]="协作范式激活器"
        [".specify/scripts/bash/create-new-feature.sh"]="智能功能创建脚本"
        [".specify/scripts/bash/intelligent-branch-namer.sh"]="智能分支命名脚本"
        [".specify/scripts/bash/git-changelog-hook.sh"]="Git hooks主脚本"
        [".specify/scripts/bash/commit-parser.sh"]="提交解析器"
        [".specify/scripts/bash/update-changelog.sh"]="CHANGELOG更新器"
        ["docs/ai-collaboration-guide.md"]="AI协作指南"
        [".specify/templates/spec-template.md"]="功能规格模板"
    )

    local missing_files=()

    for file_path in "${!core_files[@]}"; do
        local full_path="$TARGET_PROJECT/$file_path"
        if [ -f "$full_path" ]; then
            # 检查文件是否为空
            if [ -s "$full_path" ]; then
                check_pass "${core_files[$file_path]} ($file_path)"
            else
                check_fail "${core_files[$file_path]} 文件为空 ($file_path)"
                missing_files+=("$file_path")
            fi
        else
            check_fail "${core_files[$file_path]} 文件缺失 ($file_path)"
            missing_files+=("$file_path")
        fi
    done

    # 检查目录结构
    local required_dirs=(
        ".claude"
        ".claude/commands"
        ".specify"
        ".specify/scripts"
        ".specify/scripts/bash"
        ".specify/templates"
        "docs"
    )

    for dir in "${required_dirs[@]}"; do
        local full_path="$TARGET_PROJECT/$dir"
        if [ -d "$full_path" ]; then
            check_pass "目录结构完整 ($dir)"
        else
            check_fail "目录缺失 ($dir)"
        fi
    done

    return ${#missing_files[@]}
}

# 验证脚本可执行性
validate_script_executability() {
    log_step "验证脚本可执行性"

    local scripts=(
        ".specify/scripts/bash/create-new-feature.sh"
        ".specify/scripts/bash/intelligent-branch-namer.sh"
        ".specify/scripts/bash/git-changelog-hook.sh"
        ".specify/scripts/bash/commit-parser.sh"
        ".specify/scripts/bash/update-changelog.sh"
    )

    local failed_scripts=()

    for script in "${scripts[@]}"; do
        local full_path="$TARGET_PROJECT/$script"
        if [ -f "$full_path" ]; then
            if [ -x "$full_path" ]; then
                check_pass "脚本可执行 ($script)"
            else
                check_fail "脚本无执行权限 ($script)"
                failed_scripts+=("$script")
            fi
        else
            check_fail "脚本文件不存在 ($script)"
            failed_scripts+=("$script")
        fi
    done

    return ${#failed_scripts[@]}
}

# 验证脚本语法
validate_script_syntax() {
    log_step "验证脚本语法"

    local scripts=(
        ".specify/scripts/bash/create-new-feature.sh"
        ".specify/scripts/bash/intelligent-branch-namer.sh"
        ".specify/scripts/bash/git-changelog-hook.sh"
        ".specify/scripts/bash/commit-parser.sh"
        ".specify/scripts/bash/update-changelog.sh"
    )

    local syntax_errors=()

    for script in "${scripts[@]}"; do
        local full_path="$TARGET_PROJECT/$script"
        if [ -f "$full_path" ]; then
            if bash -n "$full_path" 2>/dev/null; then
                check_pass "脚本语法正确 ($script)"
            else
                check_fail "脚本语法错误 ($script)"
                syntax_errors+=("$script")
            fi
        fi
    done

    return ${#syntax_errors[@]}
}

# 验证路径引用
validate_path_references() {
    log_step "验证路径引用"

    # 检查关键路径引用
    local repo_root="$TARGET_PROJECT"

    # 检查create-new-feature.sh中的路径
    local create_script="$TARGET_PROJECT/.specify/scripts/bash/create-new-feature.sh"
    if [ -f "$create_script" ]; then
        # 检查脚本是否包含正确的路径引用
        if grep -q "SPECS_DIR=" "$create_script"; then
            check_pass "create-new-feature.sh包含SPECS_DIR定义"
        else
            check_fail "create-new-feature.sh缺少SPECS_DIR定义"
        fi

        if grep -q "SCRIPT_DIR=" "$create_script"; then
            check_pass "create-new-feature.sh包含SCRIPT_DIR定义"
        else
            check_fail "create-new-feature.sh缺少SCRIPT_DIR定义"
        fi
    fi

    # 检查Git脚本中的路径
    local git_scripts=(
        "git-changelog-hook.sh"
        "commit-parser.sh"
        "update-changelog.sh"
    )

    for script in "${git_scripts[@]}"; do
        local script_path="$TARGET_PROJECT/.specify/scripts/bash/$script"
        if [ -f "$script_path" ]; then
            if grep -q "REPO_ROOT=" "$script_path"; then
                check_pass "$script包含REPO_ROOT定义"
            else
                check_fail "$script缺少REPO_ROOT定义"
            fi
        fi
    done
}

# 验证依赖关系
validate_dependencies() {
    log_step "验证系统依赖"

    # 检查必要的系统命令
    local required_commands=("git" "bash" "sed" "grep" "mkdir" "chmod")
    local missing_commands=()

    for cmd in "${required_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            check_pass "系统命令可用 ($cmd)"
        else
            check_fail "系统命令缺失 ($cmd)"
            missing_commands+=("$cmd")
        fi
    done

    # 检查脚本间的依赖关系
    local branch_namer="$TARGET_PROJECT/.specify/scripts/bash/intelligent-branch-namer.sh"
    local create_script="$TARGET_PROJECT/.specify/scripts/bash/create-new-feature.sh"

    if [ -f "$create_script" ] && [ -f "$branch_namer" ]; then
        if grep -q "intelligent-branch-namer.sh" "$create_script"; then
            check_pass "智能分支命名依赖正确"
        else
            check_warning "智能分支命名依赖可能存在问题"
        fi
    fi

    return ${#missing_commands[@]}
}

# 功能测试
validate_functionality() {
    if [ "$QUICK_MODE" = true ]; then
        log_step "跳过功能测试（快速模式）"
        return 0
    fi

    log_step "执行功能测试"

    # 测试智能分支命名
    local branch_namer="$TARGET_PROJECT/.specify/scripts/bash/intelligent-branch-namer.sh"
    if [ -f "$branch_namer" ] && [ -x "$branch_namer" ]; then
        log_info "测试智能分支命名功能..."
        if timeout 10s bash "$branch_namer" >/dev/null 2>&1; then
            check_pass "智能分支命名功能正常"
        else
            check_warning "智能分支命名功能异常"
        fi
    fi

    # 测试create-new-feature.sh的help功能
    local create_script="$TARGET_PROJECT/.specify/scripts/bash/create-new-feature.sh"
    if [ -f "$create_script" ] && [ -x "$create_script" ]; then
        log_info "测试功能创建脚本..."
        if timeout 10s bash "$create_script" --help >/dev/null 2>&1; then
            check_pass "功能创建脚本响应正常"
        else
            check_warning "功能创建脚本响应异常"
        fi
    fi

    # 测试Git自动化脚本
    local git_hook="$TARGET_PROJECT/.specify/scripts/bash/git-changelog-hook.sh"
    if [ -f "$git_hook" ] && [ -x "$git_hook" ]; then
        log_info "测试Git hooks脚本..."
        if timeout 10s bash "$git_hook" --help >/dev/null 2>&1; then
            check_pass "Git hooks脚本响应正常"
        else
            check_warning "Git hooks脚本响应异常"
        fi
    fi

    # 测试commit-parser.sh
    local parser="$TARGET_PROJECT/.specify/scripts/bash/commit-parser.sh"
    if [ -f "$parser" ] && [ -x "$parser" ]; then
        log_info "测试提交解析器..."
        if timeout 10s bash "$parser" --help >/dev/null 2>&1; then
            check_pass "提交解析器响应正常"
        else
            check_warning "提交解析器响应异常"
        fi
    fi

    # 测试update-changelog.sh
    local changelog="$TARGET_PROJECT/.specify/scripts/bash/update-changelog.sh"
    if [ -f "$changelog" ] && [ -x "$changelog" ]; then
        log_info "测试CHANGELOG更新器..."
        if timeout 10s bash "$changelog" --help >/dev/null 2>&1; then
            check_pass "CHANGELOG更新器响应正常"
        else
            check_warning "CHANGELOG更新器响应异常"
        fi
    fi
}

# 验证协作命令
validate_collaboration_command() {
    log_step "验证协作命令"

    local collaborate_cmd="$TARGET_PROJECT/.claude/commands/collaborate.md"
    if [ -f "$collaborate_cmd" ]; then
        # 检查协作命令文件内容
        if grep -q "激活特定的AI协作范式" "$collaborate_cmd"; then
            check_pass "协作命令内容正确"
        else
            check_fail "协作命令内容异常"
        fi

        # 检查是否包含必要的协作范式
        local patterns=("first-principles" "visual" "feynman" "ears")
        for pattern in "${patterns[@]}"; do
            if grep -q "$pattern" "$collaborate_cmd"; then
                log_info "协作范式包含: $pattern"
            else
                check_warning "协作范式缺失: $pattern"
            fi
        done
    else
        check_fail "协作命令文件不存在"
    fi
}

# 验证文档完整性
validate_documentation() {
    log_step "验证文档完整性"

    # 检查AI协作指南
    local ai_guide="$TARGET_PROJECT/docs/ai-collaboration-guide.md"
    if [ -f "$ai_guide" ]; then
        if grep -q "AI协作实践指南" "$ai_guide"; then
            check_pass "AI协作指南内容正确"
        else
            check_fail "AI协作指南内容异常"
        fi

        # 检查是否包含12种协作范式
        local collaboration_count=$(grep -c "### [0-9]*\." "$ai_guide" 2>/dev/null || echo "0")
        if [ "$collaboration_count" -ge 10 ]; then
            check_pass "AI协作指南包含足够多的协作范式 ($collaboration_count个)"
        else
            check_warning "AI协作指南协作范式数量较少 ($collaboration_count个)"
        fi
    else
        check_fail "AI协作指南不存在"
    fi

    # 检查CHANGELOG
    local changelog="$TARGET_PROJECT/docs/CHANGELOG.md"
    if [ -f "$changelog" ]; then
        if grep -q "# 更新日志" "$changelog"; then
            check_pass "CHANGELOG格式正确"
        else
            check_warning "CHANGELOG格式可能不标准"
        fi
    else
        check_warning "CHANGELOG不存在（将自动创建）"
    fi
}

# 生成验证报告
generate_validation_report() {
    log_step "生成验证报告"

    local report_file="$TARGET_PROJECT/.claude-validation-report.md"
    local status="通过"
    local status_color="${GREEN}"

    if [ "$FAILED_CHECKS" -gt 0 ]; then
        status="失败"
        status_color="${RED}"
    elif [ "$WARNING_CHECKS" -gt 0 ]; then
        status="警告"
        status_color="${YELLOW}"
    fi

    cat > "$report_file" << EOF
# Claude迁移验证报告

**生成时间**: $(date)
**目标项目**: $TARGET_PROJECT
**验证状态**: $status_color$status${NC}

## 验证统计

- **总检查项**: $TOTAL_CHECKS
- **通过项**: $PASSED_CHECKS
- **失败项**: $FAILED_CHECKS
- **警告项**: $WARNING_CHECKS

- **成功率**: $(( PASSED_CHECKS * 100 / TOTAL_CHECKS ))%

## 验证结果摘要

### ✅ 通过的检查
$(if [ "$PASSED_CHECKS" -gt 0 ]; then
    echo "- 文件完整性验证"
    echo "- 脚本可执行性检查"
    echo "- 路径引用验证"
    echo "- 系统依赖检查"
else
    echo "- 无"
fi)

### ⚠️ 警告项
$(if [ "$WARNING_CHECKS" -gt 0 ]; then
    echo "- 部分功能可能需要手动配置"
    echo "- 建议检查具体警告内容"
else
    echo "- 无"
fi)

### ❌ 失败项
$(if [ "$FAILED_CHECKS" -gt 0 ]; then
    echo "- 需要修复的关键问题"
    echo "- 请重新运行迁移脚本"
else
    echo "- 无"
fi)

## 快速修复建议

### 如果验证失败：
1. 重新运行迁移: \`./claude-migration-toolkit/scripts/migrate.sh "$TARGET_PROJECT"\`
2. 运行路径适配: \`./claude-migration-toolkit/scripts/path-adapter.sh "$TARGET_PROJECT"\`
3. 设置脚本权限: \`chmod +x .specify/scripts/bash/*.sh\`

### 如果有警告：
1. 检查系统依赖是否完整
2. 验证Git仓库配置
3. 查看详细验证日志: \`$0 --verbose "$TARGET_PROJECT"\`

## 功能测试

如果验证通过，可以尝试以下功能测试：

\`\`\`bash
# 测试AI协作
/collaborate help

# 测试智能分支命名
./.specify/scripts/bash/create-new-feature.sh "测试新功能"

# 测试Git自动化（如果需要）
./.specify/scripts/bash/git-changelog-hook.sh status
\`\`\`

---

*此报告由Claude迁移验证工具自动生成*
EOF

    echo -e "${CYAN}📋 验证报告已生成: $report_file${NC}"
}

# 显示验证摘要
show_validation_summary() {
    log_step "验证摘要"

    echo
    echo -e "${CYAN}📊 验证统计:${NC}"
    echo -e "  📁 目标项目: $TARGET_PROJECT"
    echo -e "  ✅ 通过项: $PASSED_CHECKS/$TOTAL_CHECKS"
    echo -e "  ⚠️ 警告项: $WARNING_CHECKS"
    echo -e "  ❌ 失败项: $FAILED_CHECKS"
    echo -e "  📈 成功率: $(( PASSED_CHECKS * 100 / TOTAL_CHECKS ))%"

    # 显示总体状态
    echo
    if [ "$FAILED_CHECKS" -eq 0 ]; then
        if [ "$WARNING_CHECKS" -eq 0 ]; then
            echo -e "${GREEN}🎉 验证完全通过！迁移成功${NC}"
        else
            echo -e "${YELLOW}⚠️ 验证基本通过，但有少量警告${NC}"
        fi
    else
        echo -e "${RED}❌ 验证失败，需要修复问题${NC}"
        echo
        echo -e "${CYAN}💡 修复建议:${NC}"
        echo -e "  1. 重新运行迁移: ./scripts/migrate.sh $TARGET_PROJECT"
        echo -e "  2. 运行路径适配: ./scripts/path-adapter.sh $TARGET_PROJECT"
        echo -e "  3. 查看详细报告: $TARGET_PROJECT/.claude-validation-report.md"
    fi
}

# 主函数
main() {
    echo -e "${CYAN}🔍 Claude迁移验证工具${NC}"
    echo -e "${CYAN}验证迁移后的功能完整性和可用性${NC}"
    echo

    # 解析参数
    parse_args "$@"

    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}🔧 详细模式已启用${NC}"
    fi

    if [ "$QUICK_MODE" = true ]; then
        echo -e "${YELLOW}⚡ 快速模式已启用${NC}"
    fi
    echo

    # 执行验证步骤
    validate_target_project
    validate_file_integrity
    validate_script_executability
    validate_script_syntax
    validate_path_references
    validate_dependencies
    validate_functionality
    validate_collaboration_command
    validate_documentation
    generate_validation_report
    show_validation_summary

    # 返回适当的退出码
    if [ "$FAILED_CHECKS" -gt 0 ]; then
        exit 1
    elif [ "$WARNING_CHECKS" -gt 0 ]; then
        exit 2
    else
        exit 0
    fi
}

# 如果直接运行脚本
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi