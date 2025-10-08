#!/bin/bash

# 简化的AI协作命令测试脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 测试计数
TESTS=0
PASSED=0

# 测试函数
test_command() {
    local test_name="$1"
    local command="$2"

    TESTS=$((TESTS + 1))
    echo -e "${BLUE}测试 $TESTS: $test_name${NC}"

    if eval "$command" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 通过${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}❌ 失败${NC}"
    fi
    echo
}

echo -e "${BLUE}🧪 AI协作命令简化测试${NC}"
echo

# 重置会话
echo "y" | ./core-files/collaboration-enhanced.sh reset >/dev/null 2>&1

# 测试基本命令
test_command "help 命令" "./core-files/collaboration-enhanced.sh help"
test_command "version 命令" "./core-files/collaboration-enhanced.sh version"
test_command "health 命令" "./core-files/collaboration-enhanced.sh health"

# 测试简化格式（需要重置会话）
echo "y" | ./core-files/collaboration-enhanced.sh reset >/dev/null 2>&1
test_command "简化格式 creative" 'echo "test" | timeout 2s ./core-files/collaboration-enhanced.sh creative "测试"'

echo "y" | ./core-files/collaboration-enhanced.sh reset >/dev/null 2>&1
test_command "简化格式 first-principles" 'echo "test" | timeout 2s ./core-files/collaboration-enhanced.sh first-principles "测试"'

# 测试传统格式（需要重置会话）
echo "y" | ./core-files/collaboration-enhanced.sh reset >/dev/null 2>&1
test_command "传统格式 start visual" 'echo "test" | timeout 2s ./core-files/collaboration-enhanced.sh start visual "测试"'

echo "y" | ./core-files/collaboration-enhanced.sh reset >/dev/null 2>&1
test_command "传统格式 start critical" 'echo "test" | timeout 2s ./core-files/collaboration-enhanced.sh start critical "测试"'

# 显示结果
echo -e "${BLUE}📊 测试结果${NC}"
echo -e "总测试数: $TESTS"
echo -e "${GREEN}通过: $PASSED${NC}"

if [ $PASSED -eq $TESTS ]; then
    echo -e "${GREEN}🎉 所有测试通过！简化命令格式实现成功！${NC}"
else
    echo -e "${RED}❌ 有 $((TESTS - PASSED)) 个测试失败${NC}"
fi