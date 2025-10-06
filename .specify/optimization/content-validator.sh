#!/bin/bash

# 内容完整性验证系统
# 确保AI协作过程中内容不丢失、不损坏

set -euo pipefail

# 配置
VALIDATION_CACHE_DIR="/tmp/collab-validation"
VALIDATION_LOG="$HOME/.collab-logs/validation.log"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 初始化验证环境
init_validation() {
    mkdir -p "$VALIDATION_CACHE_DIR"
    mkdir -p "$(dirname "$VALIDATION_LOG")"
    touch "$VALIDATION_LOG"
}

# 生成内容指纹
generate_content_fingerprint() {
    local content="$1"

    # 多重哈希确保唯一性
    local sha256_hash=$(echo "$content" | sha256sum | cut -d' ' -f1)
    local md5_hash=$(echo "$content" | md5sum | cut -d' ' -f1)
    local content_length=$(echo "$content" | wc -c)
    local line_count=$(echo "$content" | wc -l)

    echo "sha256:$sha256_hash|md5:$md5_hash|length:$content_length|lines:$line_count"
}

# 检测内容特征
detect_content_features() {
    local content="$1"
    local features=""

    # 检测Mermaid图表
    if echo "$content" | grep -q '```mermaid'; then
        features="${features}mermaid,"
        local mermaid_count=$(echo "$content" | grep -c '```mermaid')
        features="${features}count:$mermaid_count;"
    fi

    # 检测代码块
    if echo "$content" | grep -q '```'; then
        features="${features}code_blocks,"
        local code_count=$(echo "$content" | grep -c '```')
        features="${features}count:$code_count;"
    fi

    # 检测数学公式
    if echo "$content" | grep -q '\$\$.*\$\$'; then
        features="${features}latex,"
        local latex_count=$(echo "$content" | grep -c '\$\$.*\$\$')
        features="${features}count:$latex_count;"
    fi

    # 检测链接
    if echo "$content" | grep -q '\[.*\](' ; then
        features="${features}links,"
        local link_count=$(echo "$content" | grep -o '\[.*\](' | wc -l)
        features="${features}count:$link_count;"
    fi

    # 检测中文内容
    if echo "$content" | grep -q '[\u4e00-\u9fa5]'; then
        features="${features}chinese;"
    fi

    # 检测特殊字符
    if echo "$content" | grep -q '[{}[\]()|>+-=*]'; then
        features="${features}special_chars;"
    fi

    echo "$features"
}

# 创建验证快照
create_validation_snapshot() {
    local content="$1"
    local snapshot_id="$2"
    local snapshot_file="$VALIDATION_CACHE_DIR/${snapshot_id}.snapshot"

    local fingerprint=$(generate_content_fingerprint "$content")
    local features=$(detect_content_features "$content")
    local timestamp=$(date +%s)

    cat > "$snapshot_file" << EOF
{
    "snapshot_id": "$snapshot_id",
    "timestamp": $timestamp,
    "fingerprint": "$fingerprint",
    "features": "$features",
    "content_preview": "$(echo "$content" | head -5 | tr '\n' ' ' | sed 's/"/\\"/g')",
    "content_size": $(echo "$content" | wc -c),
    "line_count": $(echo "$content" | wc -l)
}
EOF

    echo "$snapshot_file"
}

# 验证内容完整性
validate_content_integrity() {
    local content="$1"
    local snapshot_file="$2"

    if [[ ! -f "$snapshot_file" ]]; then
        echo -e "${RED}错误: 快照文件不存在 $snapshot_file${NC}"
        return 1
    fi

    # 读取快照信息
    local original_fingerprint=$(jq -r '.fingerprint' "$snapshot_file")
    local original_features=$(jq -r '.features' "$snapshot_file")
    local original_size=$(jq -r '.content_size' "$snapshot_file")

    # 生成当前内容的指纹和特征
    local current_fingerprint=$(generate_content_fingerprint "$content")
    local current_features=$(detect_content_features "$content")
    local current_size=$(echo "$content" | wc -c)

    # 验证结果
    local validation_passed=true
    local issues=()

    # 检查指纹
    if [[ "$original_fingerprint" != "$current_fingerprint" ]]; then
        validation_passed=false
        issues+=("内容指纹不匹配")
    fi

    # 检查特征
    if [[ "$original_features" != "$current_features" ]]; then
        validation_passed=false
        issues+=("内容特征不一致")
        echo -e "${YELLOW}原始特征: $original_features${NC}"
        echo -e "${YELLOW}当前特征: $current_features${NC}"
    fi

    # 检查大小
    if [[ "$original_size" != "$current_size" ]]; then
        validation_passed=false
        issues+=("内容大小不一致 (原始: $original_size, 当前: $current_size)")
    fi

    # 输出验证结果
    if $validation_passed; then
        echo -e "${GREEN}✅ 内容完整性验证通过${NC}"
        return 0
    else
        echo -e "${RED}❌ 内容完整性验证失败${NC}"
        for issue in "${issues[@]}"; do
            echo -e "  ${YELLOW}• $issue${NC}"
        done
        return 1
    fi
}

# 智能内容对比
smart_content_diff() {
    local original="$1"
    local current="$2"
    local diff_output="$3"

    echo -e "${CYAN}📊 智能内容对比分析${NC}"
    echo "=============================="

    # 基本统计
    local original_lines=$(echo "$original" | wc -l)
    local current_lines=$(echo "$current" | wc -l)
    local original_chars=$(echo "$original" | wc -c)
    local current_chars=$(echo "$current" | wc -c)

    echo -e "${BLUE}📏 统计信息${NC}"
    echo "原始内容: $original_lines 行, $original_chars 字符"
    echo "当前内容: $current_lines 行, $current_chars 字符"

    # 特征对比
    echo -e "\n${BLUE}🔍 特征对比${NC}"
    local original_features=$(detect_content_features "$original")
    local current_features=$(detect_content_features "$current")

    echo "原始特征: $original_features"
    echo "当前特征: $current_features"

    # 生成差异报告
    if command -v diff >/dev/null 2>&1; then
        echo -e "\n${BLUE}📝 详细差异${NC}"
        local original_file="/tmp/original_$(date +%s).txt"
        local current_file="/tmp/current_$(date +%s).txt"

        echo "$original" > "$original_file"
        echo "$current" > "$current_file"

        if [[ -n "$diff_output" ]]; then
            diff -u "$original_file" "$current_file" > "$diff_output" || true
            echo "差异报告已保存到: $diff_output"
        else
            diff -u "$original_file" "$current_file" || true
        fi

        rm -f "$original_file" "$current_file"
    fi
}

# 内容恢复建议
suggest_content_recovery() {
    local snapshot_file="$1"
    local corrupted_file="$2"

    echo -e "${CYAN}🔧 内容恢复建议${NC}"
    echo "======================"

    if [[ -f "$snapshot_file" ]]; then
        echo -e "${GREEN}1. 从快照恢复${NC}"
        echo "   快照文件存在，可以从验证快照中恢复原始内容"

        # 检查是否有备份
        local backup_file="${corrupted_file}.backup.$(date +%s)"
        if [[ -f "$corrupted_file" ]]; then
            echo -e "${YELLOW}2. 创建备份${NC}"
            echo "   当前文件已备份到: $backup_file"
            cp "$corrupted_file" "$backup_file"
        fi

        echo -e "${BLUE}3. 恢复步骤${NC}"
        echo "   a. 保存当前版本作为备份"
        echo "   b. 从最近的快照或缓存恢复"
        echo "   c. 重新验证内容完整性"
    else
        echo -e "${RED}❌ 无法自动恢复${NC}"
        echo "   快照文件不存在，需要手动恢复内容"
    fi
}

# 批量验证协作文档
validate_collaboration_docs() {
    local collab_dir="$(pwd)/docs/collaboration"

    if [[ ! -d "$collab_dir" ]]; then
        echo -e "${RED}协作文档目录不存在: $collab_dir${NC}"
        return 1
    fi

    echo -e "${CYAN}📚 批量验证协作文档${NC}"
    echo "========================"

    local total_docs=0
    local valid_docs=0
    local issues_found=()

    while IFS= read -r -d '' doc_file; do
        ((total_docs++))
        local doc_name=$(basename "$doc_file")

        echo -e "\n${BLUE}验证: $doc_name${NC}"

        # 读取文档内容
        local content=$(cat "$doc_file")

        # 创建验证快照
        local snapshot_id="${doc_name%.md}_$(date +%s)"
        local snapshot_file=$(create_validation_snapshot "$content" "$snapshot_id")

        # 基本内容检查
        local issues=()

        # 检查必要章节
        if ! echo "$content" | grep -q "## 会话元信息"; then
            issues+=("缺少会话元信息")
        fi

        if ! echo "$content" | grep -q "## 完整对话记录"; then
            issues+=("缺少对话记录")
        fi

        # 检查Mermaid图表完整性
        local mermaid_blocks=$(echo "$content" | grep -c '```mermaid' || echo "0")
        if [[ $mermaid_blocks -gt 0 ]]; then
            local mermaid_end_blocks=$(echo "$content" | grep -c '^```$' || echo "0")
            if [[ $mermaid_blocks -ne $mermaid_end_blocks ]]; then
                issues+=("Mermaid代码块不完整")
            fi
        fi

        # 输出验证结果
        if [[ ${#issues[@]} -eq 0 ]]; then
            echo -e "  ${GREEN}✅ 验证通过${NC}"
            ((valid_docs++))
        else
            echo -e "  ${YELLOW}⚠️  发现问题:${NC}"
            for issue in "${issues[@]}"; do
                echo -e "    • $issue"
            done
            issues_found+=("$doc_name: ${issues[*]}")
        fi

        # 清理快照文件
        rm -f "$snapshot_file"

    done < <(find "$collab_dir" -name "*.md" -print0)

    # 总结报告
    echo -e "\n${CYAN}📊 验证总结${NC}"
    echo "================"
    echo "总文档数: $total_docs"
    echo "有效文档: $valid_docs"
    echo "问题文档: $((total_docs - valid_docs))"

    if [[ ${#issues_found[@]} -gt 0 ]]; then
        echo -e "\n${YELLOW}发现的问题:${NC}"
        for issue in "${issues_found[@]}"; do
            echo "• $issue"
        done
    fi
}

# 显示帮助信息
show_help() {
    cat << EOF
内容完整性验证系统

用法: $0 <命令> [参数]

命令:
    snapshot <content> <id>              - 创建内容验证快照
    validate <content> <snapshot_file>   - 验证内容完整性
    compare <original> <current> [diff_file] - 智能内容对比
    recover <snapshot_file> <target_file> - 内容恢复建议
    batch-validate                       - 批量验证协作文档
    help                                - 显示此帮助信息

示例:
    $0 snapshot "包含图表的内容" session_123
    $0 validate "\$content" /tmp/snapshot.session_123
    $0 compare original.txt current.txt diff_report.txt
    $0 batch-validate

特性:
    - 多重哈希验证
    - 内容特征检测
    - 智能差异分析
    - 批量文档验证
    - 内容恢复建议
EOF
}

# 主程序
main() {
    # 初始化验证环境
    init_validation

    case "${1:-}" in
        "snapshot")
            if [[ -z "${2:-}" ]] || [[ -z "${3:-}" ]]; then
                echo -e "${RED}错误: 请提供内容和快照ID${NC}"
                exit 1
            fi
            create_validation_snapshot "$2" "$3"
            ;;
        "validate")
            if [[ -z "${2:-}" ]] || [[ -z "${3:-}" ]]; then
                echo -e "${RED}错误: 请提供内容和快照文件${NC}"
                exit 1
            fi
            validate_content_integrity "$2" "$3"
            ;;
        "compare")
            if [[ -z "${2:-}" ]] || [[ -z "${3:-}" ]]; then
                echo -e "${RED}错误: 请提供原始和当前内容文件${NC}"
                exit 1
            fi
            smart_content_diff "$(cat "$2")" "$(cat "$3")" "${4:-}"
            ;;
        "recover")
            if [[ -z "${2:-}" ]] || [[ -z "${3:-}" ]]; then
                echo -e "${RED}错误: 请提供快照文件和目标文件${NC}"
                exit 1
            fi
            suggest_content_recovery "$2" "$3"
            ;;
        "batch-validate")
            validate_collaboration_docs
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