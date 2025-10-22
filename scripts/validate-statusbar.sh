#!/bin/bash

# Claude Code 状态栏配置验证脚本
# 用于验证状态栏配置是否正确设置

set -euo pipefail

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
Claude Code 状态栏配置验证脚本

用法: $0 [项目路径]

参数:
  项目路径        要验证的项目目录（默认为当前目录）

示例:
  $0                                    # 验证当前目录
  $0 /path/to/my-project               # 验证指定项目
EOF
}

# 获取项目路径
PROJECT_PATH="${1:-$(pwd)}"

if [ ! -d "$PROJECT_PATH" ]; then
    log_error "项目路径不存在: $PROJECT_PATH"
    exit 1
fi

# 配置文件路径
SETTINGS_FILE="$PROJECT_PATH/.claude/settings.local.json"
SCRIPT_FILE="$PROJECT_PATH/.claude/scripts/status_line_script.sh"

echo -e "${BLUE}🔍 验证 Claude Code 状态栏配置${NC}"
echo "项目路径: $PROJECT_PATH"
echo

# 检查1: 配置文件是否存在
log_info "检查配置文件..."
if [ ! -f "$SETTINGS_FILE" ]; then
    log_error "配置文件不存在: $SETTINGS_FILE"
    echo -e "${YELLOW}💡 提示: 请运行迁移脚本先生成配置文件${NC}"
    exit 1
fi
log_success "配置文件存在: $SETTINGS_FILE"

# 检查2: 配置文件是否包含statusLine配置
log_info "检查statusLine配置..."
if ! jq -e '.statusLine' "$SETTINGS_FILE" >/dev/null 2>&1; then
    log_error "配置文件中未找到statusLine配置"
    echo -e "${YELLOW}💡 提示: 配置文件可能未正确生成${NC}"
    exit 1
fi
log_success "找到statusLine配置"

# 检查3: statusLine配置类型是否正确
log_info "检查statusLine配置类型..."
STATUS_TYPE=$(jq -r '.statusLine.type // ""' "$SETTINGS_FILE")
if [ "$STATUS_TYPE" != "command" ]; then
    log_error "statusLine类型不正确: $STATUS_TYPE (期望: command)"
    exit 1
fi
log_success "statusLine类型正确: command"

# 检查4: 命令路径是否正确
log_info "检查statusLine命令..."
STATUS_COMMAND=$(jq -r '.statusLine.command // ""' "$SETTINGS_FILE")
if [ -z "$STATUS_COMMAND" ]; then
    log_error "statusLine命令为空"
    exit 1
fi
log_success "statusLine命令: $STATUS_COMMAND"

# 检查5: 脚本文件是否存在
log_info "检查状态栏脚本文件..."
if [ ! -f "$SCRIPT_FILE" ]; then
    log_error "状态栏脚本文件不存在: $SCRIPT_FILE"
    exit 1
fi
log_success "状态栏脚本文件存在: $SCRIPT_FILE"

# 检查6: 脚本文件是否有执行权限
log_info "检查脚本执行权限..."
if [ ! -x "$SCRIPT_FILE" ]; then
    log_warning "脚本文件没有执行权限，正在添加..."
    chmod +x "$SCRIPT_FILE"
    if [ $? -eq 0 ]; then
        log_success "执行权限已添加"
    else
        log_error "无法添加执行权限"
        exit 1
    fi
else
    log_success "脚本文件已有执行权限"
fi

# 检查7: 测试脚本是否能正常执行
log_info "测试状态栏脚本执行..."
TEST_INPUT='{"model":{"display_name":"Test-Model"},"workspace":{"current_dir":"'$PROJECT_PATH'"}}'

if ! echo "$TEST_INPUT" | "$SCRIPT_FILE" >/dev/null 2>&1; then
    log_error "状态栏脚本执行失败"
    echo -e "${YELLOW}💡 提示: 检查脚本语法和依赖工具${NC}"
    exit 1
fi
log_success "状态栏脚本执行正常"

# 检查8: 显示实际输出
log_info "状态栏脚本输出示例:"
SCRIPT_OUTPUT=$(echo "$TEST_INPUT" | "$SCRIPT_FILE")
echo -e "${GREEN}$SCRIPT_OUTPUT${NC}"

# 检查9: 验证依赖工具
log_info "检查依赖工具..."
MISSING_TOOLS=()

for tool in jq git bc; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        MISSING_TOOLS+=("$tool")
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    log_warning "缺少依赖工具: ${MISSING_TOOLS[*]}"
    echo -e "${YELLOW}💡 安装建议:${NC}"
    echo "  macOS: brew install ${MISSING_TOOLS[*]}"
    echo "  Ubuntu: sudo apt-get install ${MISSING_TOOLS[*]}"
else
    log_success "所有依赖工具已安装"
fi

# 检查10: 诊断可能的问题
log_info "诊断常见问题..."

# 检查配置文件JSON格式
if ! jq empty "$SETTINGS_FILE" >/dev/null 2>&1; then
    log_error "配置文件JSON格式无效"
    exit 1
fi

# 检查脚本中的常见错误
if grep -q "echo \$" "$SCRIPT_FILE"; then
    log_warning "脚本中可能存在未引用的变量"
fi

# 总结
echo
echo -e "${GREEN}✅ 状态栏配置验证通过！${NC}"
echo
echo -e "${BLUE}📋 配置摘要:${NC}"
echo "  配置文件: $SETTINGS_FILE"
echo "  脚本文件: $SCRIPT_FILE"
echo "  命令类型: $STATUS_TYPE"
echo "  执行命令: $STATUS_COMMAND"
echo "  测试输出: $SCRIPT_OUTPUT"
echo
echo -e "${YELLOW}💡 下一步:${NC}"
echo "1. 重启 Claude Code 应用"
echo "2. 检查状态栏是否显示正确信息"
echo "3. 如果仍有问题，请检查 Claude Code 的日志输出"
echo
echo -e "${BLUE}🔧 故障排除:${NC}"
echo "- 如果状态栏不显示，请重启 Claude Code"
echo "- 如果显示异常，请检查脚本输出格式"
echo "- 如果有错误，请查看 Claude Code 的控制台输出"

exit 0