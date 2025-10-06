#!/bin/bash

# 改进版内容处理器 - 解决特殊字符和格式丢失问题
# 作者：AI优化系统
# 版本：2.0

set -euo pipefail

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMP_DIR="/tmp/collab-content-$$"
CONTENT_LOCK_FILE="/tmp/collab-content.lock"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 创建临时工作目录
create_temp_workspace() {
    mkdir -p "$TEMP_DIR"
    chmod 700 "$TEMP_DIR"  # 安全：只有用户可访问
    log_info "创建临时工作目录: $TEMP_DIR"
}

# 清理临时文件
cleanup_temp_workspace() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
        log_info "清理临时工作目录"
    fi
}

# 检测内容类型
detect_content_type() {
    local content="$1"

    if echo "$content" | grep -q '```mermaid'; then
        echo "mermaid"
    elif echo "$content" | grep -q '```'; then
        echo "code"
    elif echo "$content" | grep -q '\$\$.*\$\$'; then
        echo "latex"
    elif echo "$content" | grep -q '!\[.*\]('; then
        echo "markdown_with_images"
    else
        echo "text"
    fi
}

# 安全的内容转义
safe_escape_content() {
    local content="$1"
    local content_type="$2"

    case "$content_type" in
        "mermaid")
            # 保护Mermaid代码块
            echo "$content" | sed 's/```mermaid/<!-- MERMAID_BLOCK_START -->/g' | sed 's/```/<!-- MERMAID_BLOCK_END -->/g'
            ;;
        "code")
            # 保护一般代码块
            echo "$content" | sed 's/```/<!-- CODE_BLOCK -->/g'
            ;;
        *)
            # 基本转义
            echo "$content" | sed 's/`/\\`/g' | sed 's/\$/\\$/g'
            ;;
    esac
}

# 恢复内容格式
restore_content_format() {
    local content="$1"
    local content_type="$2"

    case "$content_type" in
        "mermaid")
            echo "$content" | sed 's/<!-- MERMAID_BLOCK_START -->/```mermaid/g' | sed 's/<!-- MERMAID_BLOCK_END -->/```/g'
            ;;
        "code")
            echo "$content" | sed 's/<!-- CODE_BLOCK -->/```/g'
            ;;
        *)
            echo "$content"
            ;;
    esac
}

# 生成内容校验和
generate_content_hash() {
    local content="$1"
    echo "$content" | sha256sum | cut -d' ' -f1
}

# 验证内容完整性
verify_content_integrity() {
    local original_file="$1"
    local processed_file="$2"

    if [[ ! -f "$original_file" ]] || [[ ! -f "$processed_file" ]]; then
        log_error "文件不存在，无法验证完整性"
        return 1
    fi

    local original_hash=$(generate_content_hash "$(cat "$original_file")")
    local processed_hash=$(generate_content_hash "$(cat "$processed_file")")

    if [[ "$original_hash" == "$processed_hash" ]]; then
        log_success "内容完整性验证通过"
        return 0
    else
        log_error "内容完整性验证失败"
        log_error "原始内容校验和: $original_hash"
        log_error "处理后校验和: $processed_hash"
        return 1
    fi
}

# 安全添加内容
safe_add_content() {
    local content="$1"
    local session_id="${2:-unknown}"
    local content_file="$TEMP_DIR/content_$session_id.txt"
    local processed_file="$TEMP_DIR/processed_content_$session_id.txt"

    # 检测内容类型
    local content_type=$(detect_content_type "$content")
    log_info "检测到内容类型: $content_type"

    # 保存原始内容
    echo "$content" > "$content_file"

    # 安全转义
    local escaped_content=$(safe_escape_content "$content" "$content_type")
    echo "$escaped_content" > "$processed_file"

    # 验证处理后的内容是否可以恢复
    local restored_content=$(restore_content_format "$escaped_content" "$content_type")
    echo "$restored_content" > "$TEMP_DIR/restored_content_$session_id.txt"

    # 比较原始内容和恢复内容
    if ! verify_content_integrity "$content_file" "$TEMP_DIR/restored_content_$session_id.txt"; then
        log_warning "内容恢复验证失败，尝试备用方案"
        # 使用备用方案：直接文件操作
        echo "$content" > "$processed_file"
    fi

    log_success "内容安全处理完成"
    echo "$processed_file"
}

# 获取协作会话路径
get_collaboration_session_path() {
    local session_id="$1"

    # 查找会话文件
    local collab_dir="$SCRIPT_DIR/../../docs/collaboration"
    if [[ -d "$collab_dir" ]]; then
        find "$collab_dir" -name "*$session_id*" -type f | head -1
    else
        echo ""
    fi
}

# 智能内容注入
smart_content_injection() {
    local content_file="$1"
    local target_file="$2"
    local marker="${3:-## 讨论内容}"

    if [[ ! -f "$content_file" ]] || [[ ! -f "$target_file" ]]; then
        log_error "文件不存在，无法注入内容"
        return 1
    fi

    local content=$(cat "$content_file")
    local temp_file=$(mktemp)

    # 在指定标记后插入内容
    awk -v marker="$marker" -v content="$content" '
    $0 ~ marker {
        print
        print ""
        print content
        print ""
        next
    }
    { print }
    ' "$target_file" > "$temp_file"

    # 替换原文件
    mv "$temp_file" "$target_file"
    log_success "内容已智能注入到: $target_file"
}

# 主要功能：安全内容添加
main_add_content() {
    local content="$1"
    local session_id="${2:-$(date +%s)}"

    # 设置清理陷阱
    trap cleanup_temp_workspace EXIT

    # 创建工作空间
    create_temp_workspace

    # 安全处理内容
    local processed_file=$(safe_add_content "$content" "$session_id")

    # 查找目标会话文件
    local session_file=$(get_collaboration_session_path "$session_id")
    if [[ -z "$session_file" ]]; then
        log_error "找不到会话文件: $session_id"
        return 1
    fi

    # 智能注入内容
    smart_content_injection "$processed_file" "$session_file"

    log_success "内容添加完成"
}

# 显示帮助信息
show_help() {
    cat << EOF
改进版内容处理器 v2.0

用法: $0 <命令> [参数]

命令:
    add-content <content> [session_id]    - 安全添加内容到协作会话
    detect-type <content>                 - 检测内容类型
    verify <file1> <file2>                - 验证文件内容一致性
    help                                  - 显示此帮助信息

示例:
    $0 add-content "包含Mermaid图表的内容" session-123
    $0 detect-type "\`\`\`mermaid graph LR"
    $0 verify original.txt processed.txt

特性:
    - 安全处理特殊字符和代码块
    - 自动检测内容类型
    - 完整性验证
    - 智能错误恢复
    - 详细日志记录
EOF
}

# 主程序
main() {
    case "${1:-}" in
        "add-content")
            if [[ -z "${2:-}" ]]; then
                log_error "请提供内容"
                show_help
                exit 1
            fi
            main_add_content "$2" "${3:-}"
            ;;
        "detect-type")
            if [[ -z "${2:-}" ]]; then
                log_error "请提供内容"
                exit 1
            fi
            detect_content_type "$2"
            ;;
        "verify")
            if [[ -z "${2:-}" ]] || [[ -z "${3:-}" ]]; then
                log_error "请提供两个文件路径"
                exit 1
            fi
            verify_content_integrity "$2" "$3"
            ;;
        "help"|"")
            show_help
            ;;
        *)
            log_error "未知命令: $1"
            show_help
            exit 1
            ;;
    esac
}

# 执行主程序
main "$@"