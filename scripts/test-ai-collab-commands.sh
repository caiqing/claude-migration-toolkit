#!/bin/bash

# AI协作命令测试脚本
# 测试简化格式和传统格式的兼容性

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 测试配置
TEST_DIR="test_ai_collab"
COLLAB_SCRIPT="$TEST_DIR/collaboration-enhanced.sh"

# 测试计数器
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# 日志函数
log_test() {
    local status="$1"
    local test_name="$2"
    local message="$3"

    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    case "$status" in
        "PASS")
            echo -e "${GREEN}✅ PASS${NC} $test_name"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            ;;
        "FAIL")
            echo -e "${RED}❌ FAIL${NC} $test_name"
            echo -e "${RED}   $message${NC}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️ INFO${NC} $test_name - $message"
            ;;
        "SKIP")
            echo -e "${YELLOW}⏭️ SKIP${NC} $test_name - $message"
            ;;
    esac
}

# 创建测试环境
setup_test_env() {
    echo -e "${BLUE}🚀 设置测试环境${NC}"

    # 创建测试目录
    mkdir -p "$TEST_DIR"

    # 复制协作脚本到测试目录
    cp core-files/collaboration-enhanced.sh "$COLLAB_SCRIPT"
    chmod +x "$COLLAB_SCRIPT"

    # 创建测试用的子目录结构
    mkdir -p "$TEST_DIR/docs/collaboration"
    mkdir -p "$TEST_DIR/.specify/templates"

    # 设置测试环境变量
    export COLLABORATION_DIR="$TEST_DIR/docs/collaboration"
    export INDEX_FILE="$TEST_DIR/docs/collaboration/index.md"
    export SESSION_STATE_FILE="$TEST_DIR/.collaboration-session.state"
    export CONVERSATION_BUFFER_FILE="$TEST_DIR/.collaboration-conversation.tmp"
    export TEMPLATE_FILE="$TEST_DIR/.specify/templates/collaboration-session-template.md"
    export ENHANCED_LOG_FILE="$TEST_DIR/.collaboration-enhanced.log"

    cd "$TEST_DIR"
    log_test "INFO" "测试环境" "已在 $PWD 设置完成"
}

# 清理测试环境
cleanup_test_env() {
    echo -e "${BLUE}🧹 清理测试环境${NC}"
    cd ..
    rm -rf "$TEST_DIR"
    log_test "INFO" "清理" "测试环境已清理"
}

# 测试简化格式命令
test_simplified_commands() {
    echo -e "${PURPLE}🧪 测试简化格式命令${NC}"
    echo

    # 测试 creative 范式
    if echo "测试主题" | timeout 5s "$COLLAB_SCRIPT" creative "测试创意头脑风暴" >/dev/null 2>&1; then
        log_test "PASS" "简化格式-creative" "成功启动 creative 范式"
    else
        log_test "FAIL" "简化格式-creative" "无法启动 creative 范式"
    fi

    # 测试 first-principles 范式
    if echo "测试主题" | timeout 5s "$COLLAB_SCRIPT" first-principles "第一性原理分析" >/dev/null 2>&1; then
        log_test "PASS" "简化格式-first-principles" "成功启动 first-principles 范式"
    else
        log_test "FAIL" "简化格式-first-principles" "无法启动 first-principles 范式"
    fi

    # 测试 visual 范式
    if echo "测试主题" | timeout 5s "$COLLAB_SCRIPT" visual "可视化设计" >/dev/null 2>&1; then
        log_test "PASS" "简化格式-visual" "成功启动 visual 范式"
    else
        log_test "FAIL" "简化格式-visual" "无法启动 visual 范式"
    fi

    echo
}

# 测试传统格式命令
test_traditional_commands() {
    echo -e "${PURPLE}🧪 测试传统格式命令${NC}"
    echo

    # 测试 start creative 格式
    if echo "测试主题" | timeout 5s "$COLLAB_SCRIPT" start creative "传统创意头脑风暴" >/dev/null 2>&1; then
        log_test "PASS" "传统格式-start-creative" "成功启动传统 start creative 格式"
    else
        log_test "FAIL" "传统格式-start-creative" "无法启动传统 start creative 格式"
    fi

    # 测试 start first-principles 格式
    if echo "测试主题" | timeout 5s "$COLLAB_SCRIPT" start first-principles "传统第一性原理分析" >/dev/null 2>&1; then
        log_test "PASS" "传统格式-start-first-principles" "成功启动传统 start first-principles 格式"
    else
        log_test "FAIL" "传统格式-start-first-principles" "无法启动传统 start first-principles 格式"
    fi

    echo
}

# 测试特殊命令
test_special_commands() {
    echo -e "${PURPLE}🧪 测试特殊命令${NC}"
    echo

    # 测试 help 命令
    if "$COLLAB_SCRIPT" help >/dev/null 2>&1; then
        log_test "PASS" "特殊命令-help" "help 命令正常工作"
    else
        log_test "FAIL" "特殊命令-help" "help 命令无法正常工作"
    fi

    # 测试 version 命令
    if "$COLLAB_SCRIPT" version >/dev/null 2>&1; then
        log_test "PASS" "特殊命令-version" "version 命令正常工作"
    else
        log_test "FAIL" "特殊命令-version" "version 命令无法正常工作"
    fi

    # 测试 health 命令
    if "$COLLAB_SCRIPT" health >/dev/null 2>&1; then
        log_test "PASS" "特殊命令-health" "health 命令正常工作"
    else
        log_test "FAIL" "特殊命令-health" "health 命令无法正常工作"
    fi

    # 测试 status 命令
    if "$COLLAB_SCRIPT" status >/dev/null 2>&1; then
        log_test "PASS" "特殊命令-status" "status 命令正常工作"
    else
        log_test "FAIL" "特殊命令-status" "status 命令无法正常工作"
    fi

    echo
}

# 测试错误处理
test_error_handling() {
    echo -e "${PURPLE}🧪 测试错误处理${NC}"
    echo

    # 测试无效范式
    if ! "$COLLAB_SCRIPT" invalid-paradigm "测试" >/dev/null 2>&1; then
        log_test "PASS" "错误处理-无效范式" "正确拒绝无效范式"
    else
        log_test "FAIL" "错误处理-无效范式" "未能正确拒绝无效范式"
    fi

    # 测试 start 加无效范式
    if ! "$COLLAB_SCRIPT" start invalid-paradigm "测试" >/dev/null 2>&1; then
        log_test "PASS" "错误处理-start-无效范式" "正确拒绝 start 加无效范式"
    else
        log_test "FAIL" "错误处理-start-无效范式" "未能正确拒绝 start 加无效范式"
    fi

    # 测试未知命令
    if ! "$COLLAB_SCRIPT" unknown-command "测试" >/dev/null 2>&1; then
        log_test "PASS" "错误处理-未知命令" "正确拒绝未知命令"
    else
        log_test "FAIL" "错误处理-未知命令" "未能正确拒绝未知命令"
    fi

    echo
}

# 测试范式识别功能
test_paradigm_detection() {
    echo -e "${PURPLE}🧪 测试范式识别功能${NC}"
    echo

    # 所有12种范式
    local paradigms="creative critical feynman first-principles optimize progressive smart visual ears evolve fusion learning"

    for paradigm in $paradigms; do
        if echo "测试" | timeout 3s "$COLLAB_SCRIPT" "$paradigm" "测试$paradigm" >/dev/null 2>&1; then
            log_test "PASS" "范式识别-$paradigm" "成功识别并启动 $paradigm 范式"
        else
            log_test "FAIL" "范式识别-$paradigm" "无法识别 $paradigm 范式"
        fi
    done

    echo
}

# 显示测试结果
show_test_results() {
    echo -e "${CYAN}📊 测试结果汇总${NC}"
    echo
    echo -e "${BLUE}总测试数: $TESTS_TOTAL${NC}"
    echo -e "${GREEN}通过: $TESTS_PASSED${NC}"
    echo -e "${RED}失败: $TESTS_FAILED${NC}"

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}🎉 所有测试通过！${NC}"
        echo -e "${GREEN}✨ 简化命令格式实现成功${NC}"
        return 0
    else
        echo -e "${RED}❌ 有 $TESTS_FAILED 个测试失败${NC}"
        echo -e "${YELLOW}需要检查实现${NC}"
        return 1
    fi
}

# 主测试函数
main() {
    echo -e "${BLUE}🧪 AI协作命令测试套件${NC}"
    echo -e "${BLUE}测试简化格式和传统格式的兼容性${NC}"
    echo

    # 设置测试环境
    setup_test_env

    # 运行测试
    test_simplified_commands
    test_traditional_commands
    test_special_commands
    test_error_handling
    test_paradigm_detection

    # 显示结果
    local test_result=$?
    show_test_results

    # 清理环境
    cleanup_test_env

    return $test_result
}

# 运行测试
main "$@"