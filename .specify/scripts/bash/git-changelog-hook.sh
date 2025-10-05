#!/usr/bin/env bash

# Git Changelog 自动更新 Hook
# 在Git提交时自动更新CHANGELOG

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
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
COMMIT_PARSER="$SCRIPT_DIR/commit-parser.sh"
CHANGELOG_SCRIPT="$SCRIPT_DIR/update-changelog.sh"
CHANGELOG_FILE="$REPO_ROOT/docs/CHANGELOG.md"

# 配置文件
CONFIG_FILE="$REPO_ROOT/.git/changelog-config"

# 默认配置
DEFAULT_AUTO_UPDATE=true
DEFAULT_INTERACTIVE=false
DEFAULT_SKIP_PATTERNS="^changelog|^docs|^style|^refactor.*changelog"

# 读取配置
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        AUTO_UPDATE=$DEFAULT_AUTO_UPDATE
        INTERACTIVE=$DEFAULT_INTERACTIVE
        SKIP_PATTERNS=$DEFAULT_SKIP_PATTERNS
    fi
}

# 检查是否应该跳过更新
should_skip_update() {
    local commit_message="$1"

    # 检查跳过模式
    for pattern in $SKIP_PATTERNS; do
        if echo "$commit_message" | grep -iqE "$pattern"; then
            return 0
        fi
    done

    # 检查特殊标记
    if echo "$commit_message" | grep -iq "\[skip changelog\]\|\[no changelog\]"; then
        return 0
    fi

    return 1
}

# 获取最新提交信息
get_latest_commit() {
    git log -1 --pretty=format:"%s%n%b" HEAD
}

# 提示用户确认
prompt_user() {
    local message="$1"
    local default="${2:-y}"

    if [ "$INTERACTIVE" != "true" ]; then
        return 0
    fi

    echo -e "${YELLOW}🤔 $message${NC}"
    read -p "确认? (Y/n): " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Nn]$ ]]; then
        return 1
    else
        return 0
    fi
}

# 自动更新CHANGELOG
auto_update_changelog() {
    local commit_message="$1"
    local hook_type="$2"  # pre-commit, post-commit, manual

    echo -e "${CYAN}🔄 Git Changelog Hook ($hook_type)${NC}"
    echo

    # 检查必要工具
    if [ ! -f "$COMMIT_PARSER" ]; then
        echo -e "${RED}❌ 提交解析器不存在: $COMMIT_PARSER${NC}"
        return 1
    fi

    if [ ! -f "$CHANGELOG_SCRIPT" ]; then
        echo -e "${RED}❌ 更新日志脚本不存在: $CHANGELOG_SCRIPT${NC}"
        return 1
    fi

    # 检查CHANGELOG文件
    if [ ! -f "$CHANGELOG_FILE" ]; then
        echo -e "${YELLOW}⚠️  CHANGELOG文件不存在，尝试初始化...${NC}"
        "$CHANGELOG_SCRIPT" init
    fi

    # 解析提交信息
    echo -e "${BLUE}📝 解析提交信息...${NC}"
    local parse_result=$("$COMMIT_PARSER" --format json "$commit_message")

    local type=$(echo "$parse_result" | grep '"type":' | cut -d'"' -f4)
    local description=$(echo "$parse_result" | grep '"description":' | cut -d'"' -f4)
    local changelog_entry=$(echo "$parse_result" | grep '"changelog_entry":' | cut -d'"' -f4)

    if [ -z "$type" ] || [ -z "$changelog_entry" ]; then
        echo -e "${YELLOW}⚠️  无法解析提交信息，跳过自动更新${NC}"
        return 1
    fi

    echo -e "${BLUE}📋 解析结果:${NC}"
    echo -e "  🏷️  类型: $type"
    echo -e "  📄 描述: $changelog_entry"
    echo

    # 检查是否应该跳过
    if should_skip_update "$commit_message"; then
        echo -e "${YELLOW}⏭️  根据配置跳过CHANGELOG更新${NC}"
        return 0
    fi

    # 询问用户确认
    if ! prompt_user "是否自动更新CHANGELOG?"; then
        echo -e "${YELLOW}❌ 用户取消更新${NC}"
        return 1
    fi

    # 执行更新
    echo -e "${BLUE}📝 更新CHANGELOG...${NC}"
    if "$CHANGELOG_SCRIPT" add "$type" "$changelog_entry"; then
        echo -e "${GREEN}✅ CHANGELOG已更新${NC}"

        # 提示用户提交CHANGELOG
        if [ "$hook_type" = "post-commit" ]; then
            echo -e "${YELLOW}💡 请记得提交CHANGELOG的变更:${NC}"
            echo -e "   ${CYAN}git add docs/CHANGELOG.md && git commit -m 'docs: 更新CHANGELOG'${NC}"
        fi

        return 0
    else
        echo -e "${RED}❌ CHANGELOG更新失败${NC}"
        return 1
    fi
}

# Pre-commit hook
pre_commit_hook() {
    # 获取即将提交的信息（从暂存区）
    local commit_message=""

    # 尝试从各种来源获取提交信息
    if [ -f ".git/COMMIT_EDITMSG" ]; then
        commit_message=$(cat .git/COMMIT_EDITMSG)
    else
        # 对于pre-commit，我们无法确定最终的提交信息
        echo -e "${YELLOW}⚠️  Pre-commit hook无法确定提交信息，建议使用post-commit hook${NC}"
        return 0
    fi

    auto_update_changelog "$commit_message" "pre-commit"
}

# Post-commit hook
post_commit_hook() {
    local commit_message=$(get_latest_commit)
    auto_update_changelog "$commit_message" "post-commit"
}

# Manual mode (手动触发)
manual_mode() {
    local commit_hash="${1:-HEAD}"
    local commit_message=$(git log -1 --pretty=format:"%s%n%b" "$commit_hash")

    echo -e "${CYAN}🔧 手动模式 - 处理提交: $commit_hash${NC}"
    auto_update_changelog "$commit_message" "manual"
}

# 安装hooks
install_hooks() {
    local hook_dir="$REPO_ROOT/.git/hooks"

    echo -e "${BLUE}🔧 安装Git hooks...${NC}"

    # 创建post-commit hook
    cat > "$hook_dir/post-commit" << EOF
#!/bin/bash
# 自动更新CHANGELOG hook
cd "$REPO_ROOT" && "$SCRIPT_DIR/git-changelog-hook.sh" post-commit
EOF

    # 创建pre-commit hook (可选)
    if prompt_user "是否安装pre-commit hook?"; then
        cat > "$hook_dir/pre-commit" << EOF
#!/bin/bash
# 自动更新CHANGELOG hook
cd "$REPO_ROOT" && "$SCRIPT_DIR/git-changelog-hook.sh" pre-commit
EOF
        chmod +x "$hook_dir/pre-commit"
        echo -e "${GREEN}✅ Pre-commit hook已安装${NC}"
    fi

    chmod +x "$hook_dir/post-commit"
    echo -e "${GREEN}✅ Post-commit hook已安装${NC}"

    echo
    echo -e "${BLUE}📋 已安装的hooks:${NC}"
    echo -e "  📝 post-commit - 提交后自动更新CHANGELOG"
    echo -e "  ✏️  pre-commit - 提交前检查 (可选)"
    echo
    echo -e "${YELLOW}💡 配置文件位置: $CONFIG_FILE${NC}"
}

# 创建配置文件
create_config() {
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "${YELLOW}⚠️  配置文件已存在: $CONFIG_FILE${NC}"
        if ! prompt_user "是否覆盖配置文件?"; then
            return 0
        fi
    fi

    mkdir -p "$(dirname "$CONFIG_FILE")"

    cat > "$CONFIG_FILE" << 'EOF'
# Git Changelog Hook 配置文件

# 是否自动更新CHANGELOG
AUTO_UPDATE=true

# 是否交互式确认
INTERACTIVE=true

# 跳过更新的提交模式 (用空格分隔)
SKIP_PATTERNS="^changelog ^docs ^style ^refactor.*changelog"

# 支持的提交类型自动映射
# feat → feat, fix → fix, docs → docs, 等等...

# 特殊标记 (在提交信息中添加这些标记来跳过更新)
# [skip changelog]
# [no changelog]
EOF

    echo -e "${GREEN}✅ 配置文件已创建: $CONFIG_FILE${NC}"
}

# 显示状态
show_status() {
    echo -e "${CYAN}📊 Git Changelog Hook 状态${NC}"
    echo

    load_config

    echo -e "${BLUE}⚙️  配置:${NC}"
    echo -e "  🔄 自动更新: $AUTO_UPDATE"
    echo -e "  💬 交互模式: $INTERACTIVE"
    echo -e "  📝 跳过模式: $SKIP_PATTERNS"
    echo

    echo -e "${BLUE}🔧 工具状态:${NC}"
    echo -e "  📄 提交解析器: $([ -f "$COMMIT_PARSER" ] && echo '✅ 存在' || echo '❌ 缺失')"
    echo -e "  📝 更新脚本: $([ -f "$CHANGELOG_SCRIPT" ] && echo '✅ 存在' || echo '❌ 缺失')"
    echo -e "  📋 CHANGELOG: $([ -f "$CHANGELOG_FILE" ] && echo '✅ 存在' || echo '❌ 缺失')"
    echo

    echo -e "${BLUE}🎣 Hook状态:${NC}"
    local hook_dir="$REPO_ROOT/.git/hooks"
    echo -e "  📝 post-commit: $([ -f "$hook_dir/post-commit" ] && echo '✅ 已安装' || echo '❌ 未安装')"
    echo -e "  ✏️  pre-commit: $([ -f "$hook_dir/pre-commit" ] && echo '✅ 已安装' || echo '❌ 未安装')"
    echo

    # 显示最近的提交
    echo -e "${BLUE}📅 最近提交:${NC}"
    git log -3 --oneline --pretty=format:"%h %s" 2>/dev/null || echo "  无法获取提交历史"
}

# 显示帮助信息
show_help() {
    cat << EOF
Git Changelog 自动更新 Hook

用法: $0 [命令] [参数]

命令:
  install              安装Git hooks
  uninstall            卸载Git hooks
  status               显示hook状态
  config               创建配置文件
  manual [提交hash]     手动处理指定提交
  pre-commit           Pre-commit hook
  post-commit          Post-commit hook
  help                 显示此帮助信息

示例:
  $0 install           # 安装hooks
  $0 status            # 查看状态
  $0 manual HEAD       # 手动处理最新提交
  $0 config            # 创建配置文件

配置选项:
  AUTO_UPDATE          是否自动更新 (true/false)
  INTERACTIVE          是否交互确认 (true/false)
  SKIP_PATTERNS        跳过更新的提交模式

跳过更新:
  在提交信息中添加 [skip changelog] 或 [no changelog]
  或配置SKIP_PATTERNS来匹配特定类型的提交
EOF
}

# 卸载hooks
uninstall_hooks() {
    local hook_dir="$REPO_ROOT/.git/hooks"

    echo -e "${BLUE}🗑️  卸载Git hooks...${NC}"

    [ -f "$hook_dir/post-commit" ] && rm "$hook_dir/post-commit" && echo -e "${GREEN}✅ Post-commit hook已卸载${NC}"
    [ -f "$hook_dir/pre-commit" ] && rm "$hook_dir/pre-commit" && echo -e "${GREEN}✅ Pre-commit hook已卸载${NC}"

    echo -e "${GREEN}✅ Hooks卸载完成${NC}"
}

# 主程序
main() {
    # 加载配置
    load_config

    # 检查是否启用自动更新
    if [ "$AUTO_UPDATE" != "true" ] && [ "$1" != "install" ] && [ "$1" != "uninstall" ] && [ "$1" != "config" ] && [ "$1" != "status" ] && [ "$1" != "help" ]; then
        echo -e "${YELLOW}⚠️  自动更新已禁用 (配置: AUTO_UPDATE=false)${NC}"
        exit 0
    fi

    case "${1:-help}" in
        install)
            install_hooks
            ;;
        uninstall)
            uninstall_hooks
            ;;
        status)
            show_status
            ;;
        config)
            create_config
            ;;
        manual)
            manual_mode "$2"
            ;;
        pre-commit)
            pre_commit_hook
            ;;
        post-commit)
            post_commit_hook
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo -e "${RED}❌ 未知命令: $1${NC}"
            echo
            show_help
            exit 1
            ;;
    esac
}

# 如果直接运行脚本
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi