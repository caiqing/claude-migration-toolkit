#!/bin/bash

# Claude Code 状态栏配置迁移脚本
# 用于将状态栏配置从源项目迁移到目标项目

set -euo pipefail

# 脚本版本
VERSION="1.0.0"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# 显示帮助信息
show_help() {
    cat << EOF
Claude Code 状态栏配置迁移脚本 v${VERSION}

用法:
    $0 [选项] <目标项目路径>

选项:
    -s, --source <路径>     源项目路径 (默认: 当前目录)
    -m, --mode <模式>       迁移模式:
                            - copy: 完整复制配置
                            - adapt: 适配模式 (默认)
                            - template: 生成模板
    -f, --force             强制覆盖现有配置
    -d, --dry-run           预演模式，不执行实际操作
    -v, --verbose           详细输出
    -h, --help              显示此帮助信息

示例:
    $0 /path/to/target/project                    # 适配模式迁移
    $0 -m copy /path/to/target/project            # 完整复制模式
    $0 -m template /path/to/new/project           # 生成模板
    $0 --dry-run /path/to/target/project          # 预演迁移
EOF
}

# 检查依赖工具
check_dependencies() {
    log_info "检查依赖工具..."

    local missing_tools=()

    for tool in jq git bc; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "缺少必要工具: ${missing_tools[*]}"
        log_info "请安装缺少的工具："
        for tool in "${missing_tools[@]}"; do
            case $tool in
                jq)
                    echo "  - jq: brew install jq (macOS) 或 apt-get install jq (Ubuntu)"
                    ;;
                bc)
                    echo "  - bc: brew install bc (macOS) 或 apt-get install bc (Ubuntu)"
                    ;;
                git)
                    echo "  - git: brew install git (macOS) 或 apt-get install git (Ubuntu)"
                    ;;
            esac
        done
        return 1
    fi

    log_success "所有依赖工具已安装"
    return 0
}

# 检测源项目配置
detect_source_config() {
    local source_dir="$1"

    log_info "检测源项目配置..."

    local settings_file="$source_dir/.claude/settings.local.json"
    local script_file="$source_dir/.claude/scripts/status_line_script.sh"

    if [[ ! -f "$settings_file" ]]; then
        log_error "源项目中未找到 .claude/settings.local.json"
        return 1
    fi

    # 检查是否有statusLine配置
    if ! jq -e '.statusLine' "$settings_file" >/dev/null 2>&1; then
        log_warning "源项目中未找到statusLine配置"
        return 1
    fi

    # 检查脚本文件
    if [[ ! -f "$script_file" ]]; then
        local script_command
        script_command=$(jq -r '.statusLine.command // ""' "$settings_file")
        if [[ -n "$script_command" && -f "$source_dir/$script_command" ]]; then
            script_file="$source_dir/$script_command"
        else
            log_warning "未找到状态栏脚本文件"
            return 1
        fi
    fi

    log_success "找到源项目配置"
    echo "SETTINGS_FILE=$settings_file"
    echo "SCRIPT_FILE=$script_file"
    return 0
}

# 检查目标项目状态
check_target_project() {
    local target_dir="$1"

    log_info "检查目标项目状态..."

    if [[ ! -d "$target_dir" ]]; then
        log_error "目标项目目录不存在: $target_dir"
        return 1
    fi

    # 检查是否是Git仓库
    if ! git -C "$target_dir" rev-parse --git-dir >/dev/null 2>&1; then
        log_warning "目标项目不是Git仓库，某些功能可能受限"
    fi

    # 检查现有配置
    local target_settings="$target_dir/.claude/settings.local.json"
    local target_script_dir="$target_dir/.claude/scripts"
    local target_script="$target_dir/.claude/scripts/status_line_script.sh"

    if [[ -f "$target_settings" ]]; then
        if jq -e '.statusLine' "$target_settings" >/dev/null 2>&1; then
            log_warning "目标项目已有statusLine配置"
            return 2  # 表示有现有配置
        fi
    fi

    log_success "目标项目检查完成"
    return 0
}

# 创建备份
create_backup() {
    local target_dir="$1"
    local backup_dir="$target_dir/.claude/backup-$(date +%Y%m%d-%H%M%S)"

    log_info "创建配置备份..."

    mkdir -p "$backup_dir"

    local target_settings="$target_dir/.claude/settings.local.json"
    local target_script_dir="$target_dir/.claude/scripts"

    if [[ -f "$target_settings" ]]; then
        cp "$target_settings" "$backup_dir/settings.local.json"
        log_info "已备份 settings.local.json"
    fi

    if [[ -d "$target_script_dir" ]]; then
        cp -r "$target_script_dir" "$backup_dir/"
        log_info "已备份 scripts 目录"
    fi

    log_success "备份已保存到: $backup_dir"
    echo "BACKUP_DIR=$backup_dir"
}

# 适配权限配置
adapt_permissions() {
    local source_settings="$1"
    local target_dir="$2"
    local mode="$3"

    log_info "适配权限配置..."

    local source_perms
    source_perms=$(jq -r '.permissions.allow[]?' "$source_settings" 2>/dev/null || true)

    if [[ -z "$source_perms" ]]; then
        log_warning "源项目中未找到权限配置"
        return 0
    fi

    # 根据模式处理权限
    case "$mode" in
        "copy")
            echo "$source_perms" > "$target_dir/.claude/temp_permissions.txt"
            ;;
        "adapt"|"template")
            # 过滤项目特定的权限，保留通用权限
            echo "$source_perms" | grep -E "(git |bash |npm |npx|chmod|mv|tree|mkdir)" > "$target_dir/.claude/temp_permissions.txt" || true
            ;;
    esac
}

# 生成状态栏脚本
generate_status_script() {
    local target_dir="$1"
    local mode="$2"

    log_info "生成状态栏脚本..."

    local script_dir="$target_dir/.claude/scripts"
    local script_file="$script_dir/status_line_script.sh"

    mkdir -p "$script_dir"

    if [[ "$mode" == "template" ]]; then
        # 生成简化模板
        cat > "$script_file" << 'EOF'
#!/bin/bash

# Claude Code 状态栏脚本 - 简化模板
# 可根据项目需求自定义此脚本

input=$(cat)

# 获取基本信息
MODEL=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // "Unknown"')

# 获取Git分支信息
BRANCH=""
if git rev-parse --git-dir >/dev/null 2>&1; then
    BRANCH=" | 🌿 $(git branch --show-current 2>/dev/null)"
fi

# 获取目录名
DIR_NAME=$(basename "$DIR")

# 输出状态栏内容
echo "[$MODEL] 📁 $DIR_NAME$BRANCH"
EOF
    else
        # 复制或适配现有脚本
        if [[ -f "$SOURCE_SCRIPT_FILE" ]]; then
            if [[ "$mode" == "copy" ]]; then
                cp "$SOURCE_SCRIPT_FILE" "$script_file"
            else
                # 适配模式：移除项目特定的逻辑
                sed '/# 项目特定逻辑/,/# 结束项目特定逻辑/d' "$SOURCE_SCRIPT_FILE" > "$script_file" || \
                cp "$SOURCE_SCRIPT_FILE" "$script_file"
            fi
        fi
    fi

    chmod +x "$script_file"
    log_success "状态栏脚本已生成: $script_file"
}

# 生成目标配置文件
generate_target_config() {
    local target_dir="$1"
    local mode="$2"

    log_info "生成目标配置文件..."

    local target_settings="$target_dir/.claude/settings.local.json"
    local temp_perms_file="$target_dir/.claude/temp_permissions.txt"

    # 确保目录存在
    mkdir -p "$(dirname "$target_settings")"

    # 构建配置JSON
    local config_json="{\"permissions\":{\"allow\":[],\"deny\":[],\"ask\":[]},\"statusLine\":{\"type\":\"command\",\"command\":\"bash .claude/scripts/status_line_script.sh\"}}"

    # 添加权限配置
    if [[ -f "$temp_perms_file" && -s "$temp_perms_file" ]]; then
        # 将权限列表转换为JSON数组
        local perms_json
        perms_json=$(jq -R -s 'split("\n") | map(select(length > 0))' "$temp_perms_file")
        config_json=$(echo "$config_json" | jq --argjson perms "$perms_json" '.permissions.allow = $perms')
    fi

    # 如果目标文件已存在，合并配置
    if [[ -f "$target_settings" ]]; then
        # 备份现有配置的输出样式
        local output_style
        output_style=$(jq -r '.outputStyle // "default"' "$target_settings")

        # 更新配置
        echo "$config_json" | jq --arg style "$output_style" '.outputStyle = $style' > "$target_settings.new"

        if [[ "$FORCE_OVERWRITE" == "true" ]]; then
            mv "$target_settings.new" "$target_settings"
        else
            log_warning "目标配置文件已存在，使用 --force 强制覆盖"
            rm "$target_settings.new"
            return 1
        fi
    else
        # 创建新配置文件
        echo "$config_json" > "$target_settings"
    fi

    log_success "目标配置文件已生成: $target_settings"

    # 清理临时文件
    rm -f "$temp_perms_file"
}

# 执行迁移
perform_migration() {
    local source_dir="$1"
    local target_dir="$2"
    local mode="$3"

    log_info "开始迁移配置..."

    # 1. 检测源配置
    local source_config
    if ! source_config=$(detect_source_config "$source_dir"); then
        return 1
    fi

    eval "$source_config"

    # 2. 检查目标项目
    local target_status
    target_status=$(check_target_project "$target_dir")
    local target_code=$?

    if [[ $target_code -eq 2 ]]; then
        if [[ "$FORCE_OVERWRITE" != "true" ]]; then
            log_error "目标项目已有配置，使用 --force 强制覆盖"
            return 1
        fi
    fi

    # 3. 创建备份
    if [[ "$DRY_RUN" != "true" ]]; then
        create_backup "$target_dir"
    fi

    # 4. 适配权限配置
    if [[ "$DRY_RUN" != "true" ]]; then
        adapt_permissions "$SETTINGS_FILE" "$target_dir" "$mode"
    fi

    # 5. 生成状态栏脚本
    if [[ "$DRY_RUN" != "true" ]]; then
        generate_status_script "$target_dir" "$mode"
    fi

    # 6. 生成目标配置
    if [[ "$DRY_RUN" != "true" ]]; then
        generate_target_config "$target_dir" "$mode"
    fi

    log_success "迁移完成！"

    # 7. 显示后续步骤
    if [[ "$DRY_RUN" != "true" ]]; then
        show_next_steps "$target_dir"
    else
        echo
        log_info "预演模式 - 实际迁移时的后续步骤："
        echo "1. 检查配置文件: $target_dir/.claude/settings.local.json"
        echo "2. 检查状态栏脚本: $target_dir/.claude/scripts/status_line_script.sh"
        echo "3. 根据项目需求自定义状态栏显示内容"
        echo "4. 重启 Claude Code 以应用新配置"
        echo "5. 检查状态栏是否正常显示"
    fi
}

# 显示后续步骤
show_next_steps() {
    local target_dir="$1"

    echo
    log_info "后续步骤："
    echo "1. 检查配置文件: $target_dir/.claude/settings.local.json"
    echo "2. 检查状态栏脚本: $target_dir/.claude/scripts/status_line_script.sh"
    echo "3. 根据项目需求自定义状态栏显示内容"
    echo "4. 重启 Claude Code 以应用新配置"
    echo "5. 检查状态栏是否正常显示"
}

# 主函数
main() {
    # 默认参数
    SOURCE_DIR="$(pwd)"
    TARGET_DIR=""
    MODE="adapt"
    FORCE_OVERWRITE="false"
    DRY_RUN="false"
    VERBOSE="false"

    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--source)
                SOURCE_DIR="$2"
                shift 2
                ;;
            -m|--mode)
                MODE="$2"
                if [[ ! "$MODE" =~ ^(copy|adapt|template)$ ]]; then
                    log_error "无效的迁移模式: $MODE"
                    exit 1
                fi
                shift 2
                ;;
            -f|--force)
                FORCE_OVERWRITE="true"
                shift
                ;;
            -d|--dry-run)
                DRY_RUN="true"
                shift
                ;;
            -v|--verbose)
                VERBOSE="true"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -*)
                log_error "未知选项: $1"
                show_help
                exit 1
                ;;
            *)
                if [[ -z "$TARGET_DIR" ]]; then
                    TARGET_DIR="$1"
                else
                    log_error "多余的参数: $1"
                    exit 1
                fi
                shift
                ;;
        esac
    done

    # 检查必需参数
    if [[ -z "$TARGET_DIR" ]]; then
        log_error "缺少目标项目路径"
        show_help
        exit 1
    fi

    # 转换为绝对路径
    SOURCE_DIR="$(realpath "$SOURCE_DIR")"
    TARGET_DIR="$(realpath "$TARGET_DIR")"

    # 导出全局变量供子函数使用
    export SOURCE_SETTINGS_FILE="$SOURCE_DIR/.claude/settings.local.json"
    export SOURCE_SCRIPT_FILE="$SOURCE_DIR/.claude/scripts/status_line_script.sh"
    export FORCE_OVERWRITE
    export DRY_RUN
    export VERBOSE

    # 显示迁移信息
    log_info "Claude Code 状态栏配置迁移 v${VERSION}"
    echo "源项目: $SOURCE_DIR"
    echo "目标项目: $TARGET_DIR"
    echo "迁移模式: $MODE"
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "模式: 预演（不会执行实际操作）"
    fi
    echo

    # 检查依赖
    if ! check_dependencies; then
        exit 1
    fi

    # 执行迁移
    if perform_migration "$SOURCE_DIR" "$TARGET_DIR" "$MODE"; then
        log_success "迁移成功完成！"
        exit 0
    else
        log_error "迁移失败"
        exit 1
    fi
}

# 如果脚本被直接执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi