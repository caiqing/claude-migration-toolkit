#!/usr/bin/env bash

# specify-cli 兼容性检查脚本
# 检查specify-cli版本和命令格式兼容性

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 specify-cli 兼容性检查${NC}"
echo

# 检查specify命令是否可用
check_specify_command() {
    echo -e "${BLUE}检查 specify 命令...${NC}"

    if command -v specify &> /dev/null; then
        echo -e "${GREEN}✅${NC} specify 命令已安装"
        SPECIFY_CMD="specify"
        return 0
    elif command -v speckit &> /dev/null; then
        echo -e "${GREEN}✅${NC} speckit 命令已安装"
        SPECIFY_CMD="speckit"
        return 0
    else
        echo -e "${RED}❌${NC} 未找到 specify 或 speckit 命令"
        echo -e "${YELLOW}请先安装 specify-cli:${NC}"
        echo "  uv tool install specify-cli --from git+https://github.com/github/spec-kit.git"
        return 1
    fi
}

# 检查命令格式
check_command_format() {
    echo -e "${BLUE}检查命令格式...${NC}"

    # 尝试不同的命令格式
    if command -v specify &> /dev/null; then
        if specify --help &> /dev/null; then
            echo -e "${GREEN}✅${NC} 使用 'specify' 命令格式"
            COMMAND_FORMAT="specify"
        fi
    elif command -v speckit &> /dev/null; then
        if speckit --help &> /dev/null; then
            echo -e "${GREEN}✅${NC} 使用 'speckit' 命令格式"
            COMMAND_FORMAT="speckit"
        elif speckit specify --help &> /dev/null; then
            echo -e "${GREEN}✅${NC} 使用 'speckit specify' 命令格式"
            COMMAND_FORMAT="speckit specify"
        fi
    fi
}

# 检查版本信息
check_version() {
    echo -e "${BLUE}检查版本信息...${NC}"

    if [ -n "$SPECIFY_CMD" ]; then
        echo -e "${BLUE}执行: $SPECIFY_CMD --version${NC}"
        $SPECIFY_CMD --version 2>/dev/null || echo "版本信息不可用"
    fi
}

# 生成兼容性报告
generate_compatibility_report() {
    echo -e "${BLUE}📊 兼容性报告${NC}"
    echo
    echo "命令格式: ${COMMAND_FORMAT:-'未检测到'}"
    echo "安装路径: $(which $SPECIFY_CMD 2>/dev/null || echo '未找到')"
    echo

    if [ "$COMMAND_FORMAT" = "speckit specify" ]; then
        echo -e "${YELLOW}⚠️${NC} 检测到新的命令格式！"
        echo "需要更新文档和脚本中的命令引用"
        echo
        echo -e "${BLUE}建议的更新操作:${NC}"
        echo "1. 更新 README.md 中的安装说明"
        echo "2. 检查所有脚本中的命令调用"
        echo "3. 更新用户文档"
    elif [ "$COMMAND_FORMAT" = "specify" ]; then
        echo -e "${GREEN}✅${NC} 兼容当前格式，无需更新"
    else
        echo -e "${RED}❌${NC} 未知的命令格式，需要手动检查"
    fi
}

# 主函数
main() {
    if check_specify_command; then
        check_command_format
        check_version
        generate_compatibility_report
    else
        echo -e "${RED}❌${NC} 兼容性检查失败"
        exit 1
    fi
}

main "$@"