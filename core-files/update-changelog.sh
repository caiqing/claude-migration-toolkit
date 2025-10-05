#!/usr/bin/env bash

# 自动更新CHANGELOG脚本
# 用于在提交后自动更新项目更新日志

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 脚本信息
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
CHANGELOG_FILE="$REPO_ROOT/docs/CHANGELOG.md"

# 显示帮助信息
show_help() {
    cat << EOF
更新日志自动更新工具

用法: $0 [选项] [操作]

操作:
  add <类型> <描述>     添加新的变更记录
  release <版本号>     发布新版本
  init                 初始化更新日志
  validate             验证更新日志格式
  help                 显示此帮助信息

变更类型:
  feat, feature        新功能
  impr, improvement    改进
  fix                  修复
  docs, doc            文档
  perf, performance    性能
  example, ex          示例
  refactor             重构
  test                 测试
  security             安全

选项:
  --dry-run           预览变更，不实际写入文件
  --verbose           详细输出
  --version <版本>    指定版本号
  --date <日期>       指定日期 (YYYY-MM-DD)
  --author <作者>     指定作者

示例:
  $0 add feat "新增智能分支命名功能"
  $0 add docs "更新SDD方法论文档"
  $0 release 1.1.0
  $0 init
EOF
}

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 验证更新日志文件存在
validate_changelog_file() {
    if [ ! -f "$CHANGELOG_FILE" ]; then
        log_error "CHANGELOG文件不存在: $CHANGELOG_FILE"
        log_info "请先运行: $0 init"
        exit 1
    fi
}

# 获取当前日期
get_current_date() {
    date '+%Y-%m-%d'
}

# 获取当前版本号
get_current_version() {
    if [ -f "$CHANGELOG_FILE" ]; then
        grep -m1 '^## \[' "$CHANGELOG_FILE" | sed 's/^## \[\([^]]*\)\].*/\1/' | head -1
    else
        echo "0.0.0"
    fi
}

# 初始化更新日志
init_changelog() {
    log_info "初始化更新日志..."

    if [ -f "$CHANGELOG_FILE" ]; then
        log_warning "CHANGELOG文件已存在: $CHANGELOG_FILE"
        read -p "是否覆盖? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "取消初始化"
            exit 0
        fi
    fi

    # 确保目录存在
    mkdir -p "$(dirname "$CHANGELOG_FILE")"

    # 创建默认更新日志
    cat > "$CHANGELOG_FILE" << 'EOF'
# 更新日志 (CHANGELOG)

本文件记录了项目的所有重要变更，遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/) 格式规范。

## [未发布] - Unreleased

### 🚀 Features
- *[待添加的新功能]*

### 🔧 Improvements
- *[待添加的改进]*

### 🐛 Fixes
- *[待添加的修复]*

---

## [0.1.0] - $(date '+%Y-%m-%d')

### 🚀 Features
- **初始版本**: 项目基础结构和配置

### 📚 Documentation
- **更新日志**: 初始化CHANGELOG文档
- **项目指南**: 基础项目文档

---

*最后更新: $(date '+%Y-%m-%d')*
EOF

    log_success "更新日志已初始化: $CHANGELOG_FILE"
}

# 添加变更记录
add_change() {
    local type="$1"
    local description="$2"

    if [ -z "$type" ] || [ -z "$description" ]; then
        log_error "缺少必要参数: 类型和描述"
        show_help
        exit 1
    fi

    validate_changelog_file

    # 映射变更类型到图标和分类
    local icon=""
    local category=""
    case "$type" in
        feat|feature)
            icon="🚀"
            category="Features"
            ;;
        impr|improvement)
            icon="🔧"
            category="Improvements"
            ;;
        fix)
            icon="🐛"
            category="Fixes"
            ;;
        docs|doc)
            icon="📚"
            category="Documentation"
            ;;
        perf|performance)
            icon="⚡"
            category="Performance"
            ;;
        example|ex)
            icon="💡"
            category="Examples"
            ;;
        refactor)
            icon="🔄"
            category="Refactoring"
            ;;
        test)
            icon="🧪"
            category="Testing"
            ;;
        security)
            icon="🔒"
            category="Security"
            ;;
        *)
            log_error "未知的变更类型: $type"
            log_info "支持的类型: feat, improvement, fix, docs, performance, example, refactor, test, security"
            exit 1
            ;;
    esac

    # 检查未发布部分是否存在对应分类
    if ! grep -q "### $icon $category" "$CHANGELOG_FILE"; then
        log_info "添加新的分类: $category"
        # 在未发布部分添加新分类
        sed -i.bak '/## \[未发布\]/a\\n### '"$icon $category"'' "$CHANGELOG_FILE"
    fi

    # 添加变更记录
    local entry="- **$description**"
    if [ "$DRY_RUN" = "true" ]; then
        log_info "[预览] 将添加到 $category: $entry"
        return
    fi

    # 在对应分类下添加新条目
    local temp_file=$(mktemp)
    awk -v category="$icon $category" -v entry="$entry" '
    /^### '"$icon $category"'/ {
        print
        print "    " entry
        next
    }
    { print }
    ' "$CHANGELOG_FILE" > "$temp_file"

    mv "$temp_file" "$CHANGELOG_FILE"

    log_success "已添加变更记录: $category - $description"
}

# 发布新版本
release_version() {
    local version="$1"

    if [ -z "$version" ]; then
        log_error "请指定版本号"
        show_help
        exit 1
    fi

    validate_changelog_file

    # 验证版本号格式
    if ! echo "$version" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
        log_error "无效的版本号格式: $version (应该是 x.y.z 格式)"
        exit 1
    fi

    local current_date=$(get_current_date)

    if [ "$DRY_RUN" = "true" ]; then
        log_info "[预览] 将发布版本: $version ($current_date)"
        return
    fi

    # 备份原文件
    cp "$CHANGELOG_FILE" "$CHANGELOG_FILE.bak"

    # 创建新版本部分
    local temp_file=$(mktemp)
    awk -v version="[$version]" -v date="$current_date" '
    /^## \[未发布\]/ {
        print "## " version " - " date
        print ""
        next
    }
    /^## \[.*\]/ && !printed {
        print "## [未发布] - Unreleased"
        print ""
        print "### 🚀 Features"
        print "- *[待添加的新功能]*"
        print ""
        print "### 🔧 Improvements"
        print "- *[待添加的改进]*"
        print ""
        print "### 🐛 Fixes"
        print "- *[待添加的修复]*"
        print ""
        print "---"
        print ""
        printed=1
    }
    { print }
    ' "$CHANGELOG_FILE" > "$temp_file"

    mv "$temp_file" "$CHANGELOG_FILE"

    # 更新最后更新时间
    sed -i.bak2 "s/\*最后更新: .*/\*最后更新: $current_date/" "$CHANGELOG_FILE"
    rm "$CHANGELOG_FILE.bak2"

    log_success "已发布版本: $version ($current_date)"
}

# 验证更新日志格式
validate_changelog() {
    validate_changelog_file

    local errors=0

    log_info "验证更新日志格式..."

    # 检查基本结构
    if ! grep -q "^# 更新日志" "$CHANGELOG_FILE"; then
        log_error "缺少标题"
        ((errors++))
    fi

    if ! grep -q "^## \[" "$CHANGELOG_FILE"; then
        log_error "缺少版本部分"
        ((errors++))
    fi

    # 检查版本格式
    local versions=$(grep "^## \[" "$CHANGELOG_FILE")
    while IFS= read -r line; do
        if ! echo "$line" | grep -qE '^## \[[0-9]+\.[0-9]+\.[0-9]+\] - [0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
            if ! echo "$line" | grep -q "未发布"; then
                log_error "版本格式错误: $line"
                ((errors++))
            fi
        fi
    done <<< "$versions"

    if [ $errors -eq 0 ]; then
        log_success "更新日志格式验证通过"
    else
        log_error "发现 $errors 个格式错误"
        exit 1
    fi
}

# 获取最近的变更
get_recent_changes() {
    validate_changelog_file

    local days="${1:-7}"
    local since_date=$(date -d "$days days ago" '+%Y-%m-%d' 2>/dev/null || date -v-${days}d '+%Y-%m-%d')

    log_info "显示最近 $days 天的变更 (since $since_date):"
    echo

    awk -v since="$since_date" '
    /^## \[/ {
        if (match($0, /\[([0-9]{4}-[0-9]{2}-[0-9]{2})\]/, date)) {
            current_date = date[1]
            if (current_date >= since) {
                print_section = 1
                print $0
            } else {
                print_section = 0
            }
        }
        next
    }
    print_section && $0 != "" { print }
    ' "$CHANGELOG_FILE"
}

# 默认参数处理
DRY_RUN="false"
VERBOSE="false"

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN="true"
            shift
            ;;
        --verbose)
            VERBOSE="true"
            shift
            ;;
        --version)
            VERSION="$2"
            shift 2
            ;;
        --date)
            DATE="$2"
            shift 2
            ;;
        --author)
            AUTHOR="$2"
            shift 2
            ;;
        add)
            ACTION="add"
            shift
            break
            ;;
        release)
            ACTION="release"
            shift
            break
            ;;
        init)
            ACTION="init"
            shift
            break
            ;;
        validate)
            ACTION="validate"
            shift
            break
            ;;
        recent)
            ACTION="recent"
            shift
            break
            ;;
        help|--help|-h)
            show_help
            exit 0
            ;;
        *)
            log_error "未知参数: $1"
            show_help
            exit 1
            ;;
    esac
done

# 执行操作
case "${ACTION:-help}" in
    add)
        add_change "$@"
        ;;
    release)
        release_version "$@"
        ;;
    init)
        init_changelog
        ;;
    validate)
        validate_changelog
        ;;
    recent)
        get_recent_changes "$@"
        ;;
    help)
        show_help
        ;;
    *)
        log_error "未知的操作: ${ACTION:-none}"
        show_help
        exit 1
        ;;
esac