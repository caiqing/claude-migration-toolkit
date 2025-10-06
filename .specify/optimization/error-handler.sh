#!/bin/bash

# 增强版错误处理和诊断系统
# 提供智能错误检测、诊断和恢复建议

set -euo pipefail

# 配置
LOG_DIR="$HOME/.collab-logs"
ERROR_LOG="$LOG_DIR/errors.log"
DIAGNOSTIC_CACHE="$LOG_DIR/diagnostic_cache.json"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 初始化日志目录
init_logging() {
    mkdir -p "$LOG_DIR"
    touch "$ERROR_LOG"
    if [[ ! -f "$DIAGNOSTIC_CACHE" ]]; then
        echo '{}' > "$DIAGNOSTIC_CACHE"
    fi
}

# 日志记录函数
log_error_with_context() {
    local error_msg="$1"
    local context="${2:-unknown}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "[$timestamp] [ERROR] [$context] $error_msg" >> "$ERROR_LOG"
    echo -e "${RED}[ERROR]${NC} $error_msg"
}

# 诊断常见错误模式
diagnose_error_pattern() {
    local error_output="$1"

    # Shell语法错误
    if echo "$error_output" | grep -q "syntax error\|unexpected token"; then
        echo "shell_syntax_error"
        return
    fi

    # 命令未找到
    if echo "$error_output" | grep -q "command not found\|No such file or directory"; then
        echo "command_not_found"
        return
    fi

    # 权限错误
    if echo "$error_output" | grep -q "Permission denied\|Operation not permitted"; then
        echo "permission_error"
        return
    fi

    # 编码问题
    if echo "$error_output" | grep -q "UTF-8\|codec\|encoding"; then
        echo "encoding_error"
        return
    fi

    # Mermaid相关问题
    if echo "$error_output" | grep -q "mermaid\|graph\|flowchart"; then
        echo "mermaid_error"
        return
    fi

    echo "unknown_error"
}

# 获取错误修复建议
get_fix_suggestion() {
    local error_type="$1"

    case "$error_type" in
        "shell_syntax_error")
            cat << 'EOF'
🔧 Shell语法错误修复建议：

1. 检查引号配对：
   - 确保单引号和双引号正确配对
   - 避免在双引号内使用未转义的特殊字符

2. 转义特殊字符：
   - 使用反斜杠转义：\$ \` \" \\
   - 或者使用单引号包围内容

3. 避免直接传递代码块：
   - 使用文件中转而不是参数传递
   - 考虑使用改进版内容处理器

4. 调试命令：
   - 使用 bash -x 查看详细执行过程
   - 分步骤执行复杂命令
EOF
            ;;
        "command_not_found")
            cat << 'EOF'
🔧 命令未找到修复建议：

1. 检查命令路径：
   - 使用 which/whereis 查找命令位置
   - 检查 PATH 环境变量

2. 安装缺失工具：
   - macOS: brew install <package>
   - Ubuntu: apt install <package>
   - CentOS: yum install <package>

3. 检查脚本权限：
   - chmod +x script.sh
   - 确保脚本可执行

4. 验证文件存在：
   - 检查文件路径是否正确
   - 使用绝对路径避免路径问题
EOF
            ;;
        "permission_error")
            cat << 'EOF'
🔧 权限错误修复建议：

1. 修改文件权限：
   - chmod +x script.sh (可执行)
   - chmod 644 file.txt (读写)
   - chmod 755 directory (目录)

2. 检查文件所有者：
   - ls -la 查看文件权限
   - chown user:group file

3. 使用sudo（谨慎）：
   - 仅在必要时使用sudo
   - 确认命令安全性

4. 检查目录权限：
   - 确保对目录有读写权限
   - 检查父目录权限
EOF
            ;;
        "encoding_error")
            cat << 'EOF'
🔧 编码错误修复建议：

1. 设置正确的字符编码：
   - export LANG=zh_CN.UTF-8
   - export LC_ALL=zh_CN.UTF-8

2. 转换文件编码：
   - iconv -f gbk -t utf-8 input.txt > output.txt
   - file -I filename 检查编码

3. 处理特殊字符：
   - 使用sed转义特殊字符
   - 避免直接处理二进制内容

4. 编辑器设置：
   - 确保编辑器使用UTF-8编码
   - 检查文件换行符格式
EOF
            ;;
        "mermaid_error")
            cat << 'EOF'
🔧 Mermaid图表错误修复建议：

1. 保护代码块：
   - 使用改进版内容处理器
   - 避免直接通过shell传递

2. 正确的转义方式：
   - 使用文件中转代替参数传递
   - 或者使用HEREDOC语法

3. 验证图表语法：
   - 检查Mermaid语法是否正确
   - 在线Mermaid编辑器验证

4. 使用安全命令：
   - ./improved-content-handler.sh add-content "内容"
   - 避免使用 echo "内容" | command
EOF
            ;;
        *)
            cat << 'EOF'
🔧 通用错误修复建议：

1. 查看详细错误信息：
   - 检查错误日志：tail -f ~/.collab-logs/errors.log
   - 使用详细模式：bash -x script.sh

2. 环境检查：
   - 检查工作目录权限
   - 验证依赖工具安装
   - 确认环境变量设置

3. 逐步调试：
   - 简化命令逐步测试
   - 注释掉可能有问题的部分
   - 使用echo命令验证变量

4. 获取帮助：
   - 查看命令帮助：command --help
   - 检查项目文档
   - 联系技术支持
EOF
            ;;
    esac
}

# 智能错误分析
smart_error_analysis() {
    local error_output="$1"
    local context="${2:-general}"

    # 诊断错误类型
    local error_type=$(diagnose_error_pattern "$error_output")

    # 记录错误
    log_error_with_context "检测到错误类型: $error_type" "$context"

    # 输出诊断结果
    echo -e "\n${CYAN}🔍 错误诊断结果${NC}"
    echo -e "${YELLOW}错误类型:${NC} $error_type"
    echo -e "${YELLOW}错误上下文:${NC} $context"

    # 提供修复建议
    echo -e "\n${CYAN}💡 自动修复建议${NC}"
    get_fix_suggestion "$error_type"

    # 记录到缓存
    local timestamp=$(date +%s)
    local entry=$(cat << EOF
{
  "timestamp": $timestamp,
  "error_type": "$error_type",
  "context": "$context",
  "error_sample": "$(echo "$error_output" | head -3 | tr '\n' '; ')"
}
EOF
)

    # 更新诊断缓存（简单实现）
    echo "$entry" >> "$LOG_DIR/diagnostic_history.log"
}

# 系统健康检查
system_health_check() {
    echo -e "${CYAN}🏥 AI协作系统健康检查${NC}"
    echo "=================================="

    local issues=0

    # 检查必要目录
    echo -e "\n${BLUE}📁 目录检查${NC}"
    local dirs=(
        "$HOME/.collab-logs"
        "$(pwd)/docs/collaboration"
        "$(pwd)/.specify/scripts/bash"
    )

    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            echo -e "  ${GREEN}✓${NC} $dir"
        else
            echo -e "  ${RED}✗${NC} $dir (不存在)"
            ((issues++))
        fi
    done

    # 检查关键脚本
    echo -e "\n${BLUE}📜 脚本检查${NC}"
    local scripts=(
        "$(pwd)/.specify/scripts/bash/collaboration-session-automation.sh"
        "$(pwd)/.specify/scripts/bash/collaboration-enhanced.sh"
        "$(pwd)/.specify/optimization/improved-content-handler.sh"
    )

    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]] && [[ -x "$script" ]]; then
            echo -e "  ${GREEN}✓${NC} $(basename "$script")"
        else
            echo -e "  ${RED}✗${NC} $(basename "$script") (不存在或无执行权限)"
            ((issues++))
        fi
    done

    # 检查环境变量
    echo -e "\n${BLUE}🌍 环境检查${NC}"
    if [[ -n "${LANG:-}" ]]; then
        echo -e "  ${GREEN}✓${NC} LANG: $LANG"
    else
        echo -e "  ${YELLOW}⚠${NC} LANG 未设置"
    fi

    if [[ -n "${PATH:-}" ]]; then
        echo -e "  ${GREEN}✓${NC} PATH 已设置"
    else
        echo -e "  ${RED}✗${NC} PATH 未设置"
        ((issues++))
    fi

    # 总结
    echo -e "\n${CYAN}📊 健康检查总结${NC}"
    if [[ $issues -eq 0 ]]; then
        echo -e "${GREEN}✅ 系统状态良好，未发现问题${NC}"
    else
        echo -e "${YELLOW}⚠️  发现 $issues 个问题，建议修复${NC}"
    fi

    return $issues
}

# 自动修复常见问题
auto_fix_common_issues() {
    echo -e "${CYAN}🔧 自动修复常见问题${NC}"

    local fixes=0

    # 创建日志目录
    if [[ ! -d "$HOME/.collab-logs" ]]; then
        mkdir -p "$HOME/.collab-logs"
        echo -e "${GREEN}✓${NC} 创建日志目录"
        ((fixes++))
    fi

    # 修复脚本权限
    local script_dir="$(pwd)/.specify/scripts/bash"
    if [[ -d "$script_dir" ]]; then
        find "$script_dir" -name "*.sh" -not -perm -u+x -exec chmod +x {} \;
        echo -e "${GREEN}✓${NC} 修复脚本执行权限"
        ((fixes++))
    fi

    # 设置优化脚本权限
    local opt_script="$(pwd)/.specify/optimization/improved-content-handler.sh"
    if [[ -f "$opt_script" ]] && [[ ! -x "$opt_script" ]]; then
        chmod +x "$opt_script"
        echo -e "${GREEN}✓${NC} 修复优化脚本权限"
        ((fixes++))
    fi

    echo -e "\n${GREEN}✅ 完成 $fixes 项自动修复${NC}"
}

# 显示帮助信息
show_help() {
    cat << EOF
增强版错误处理和诊断系统

用法: $0 <命令> [参数]

命令:
    analyze <error_output> [context]     - 分析错误并提供修复建议
    health-check                          - 系统健康检查
    auto-fix                             - 自动修复常见问题
    show-log                             - 显示错误日志
    clear-log                            - 清理错误日志
    help                                 - 显示此帮助信息

示例:
    $0 analyze "bash: syntax error" "script_execution"
    $0 health-check
    $0 auto-fix
    $0 show-log | tail -20

特性:
    - 智能错误模式识别
    - 详细的修复建议
    - 系统健康检查
    - 自动修复功能
    - 错误历史记录
EOF
}

# 主程序
main() {
    # 初始化日志
    init_logging

    case "${1:-}" in
        "analyze")
            if [[ -z "${2:-}" ]]; then
                echo -e "${RED}错误: 请提供错误输出内容${NC}"
                exit 1
            fi
            smart_error_analysis "$2" "${3:-general}"
            ;;
        "health-check")
            system_health_check
            ;;
        "auto-fix")
            auto_fix_common_issues
            ;;
        "show-log")
            if [[ -f "$ERROR_LOG" ]]; then
                tail -n 50 "$ERROR_LOG"
            else
                echo "错误日志文件不存在"
            fi
            ;;
        "clear-log")
            > "$ERROR_LOG"
            echo "错误日志已清理"
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