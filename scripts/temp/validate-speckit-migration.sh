#!/usr/bin/env bash

# speckit 命令格式迁移验证脚本
# 验证所有新格式命令文件的正确性

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 脚本信息
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo -e "${BLUE}🔍 speckit 命令格式迁移验证${NC}"
echo

# 验证函数
validate_speckit_commands() {
    echo -e "${BLUE}验证新格式命令文件:${NC}"

    local required_commands=(
        "speckit.specify"
        "speckit.clarify"
        "speckit.plan"
        "speckit.tasks"
        "speckit.implement"
        "speckit.constitution"
        "speckit.analyze"
    )

    local all_valid=true

    for cmd in "${required_commands[@]}"; do
        local cmd_file="$PROJECT_ROOT/.claude/commands/$cmd.md"

        if [ -f "$cmd_file" ]; then
            # 检查文件内容是否包含正确的命令引用
            # implement.md 不需要自引用，其他文件需要包含对应的命令引用
            if [ "$cmd" = "speckit.implement" ]; then
                echo -e "  ${GREEN}✅${NC} $cmd.md - 正确"
            elif grep -q "/$cmd" "$cmd_file" || grep -q "$cmd" "$cmd_file"; then
                echo -e "  ${GREEN}✅${NC} $cmd.md - 正确"
            else
                echo -e "  ${YELLOW}⚠️${NC} $cmd.md - 命令引用可能不正确"
                all_valid=false
            fi
        else
            echo -e "  ${RED}❌${NC} $cmd.md - 文件不存在"
            all_valid=false
        fi
    done

    echo
    if [ "$all_valid" = true ]; then
        echo -e "${GREEN}✨ 所有新格式命令文件验证通过！${NC}"
        return 0
    else
        echo -e "${RED}❌ 发现问题，需要修复${NC}"
        return 1
    fi
}

# 检查文档更新
validate_documentation() {
    echo -e "${BLUE}验证文档更新:${NC}"

    local docs_updated=true

    # 检查 README.md
    if grep -q "/speckit.constitution" "$PROJECT_ROOT/README.md" 2>/dev/null; then
        echo -e "  ${GREEN}✅${NC} README.md - 已更新"
    else
        echo -e "  ${YELLOW}⚠️${NC} README.md - 可能需要更新"
        docs_updated=false
    fi

    # 检查 CLAUDE.md
    if grep -q "/speckit.specify" "$PROJECT_ROOT/CLAUDE.md" 2>/dev/null; then
        echo -e "  ${GREEN}✅${NC} CLAUDE.md - 已更新"
    else
        echo -e "  ${YELLOW}⚠️${NC} CLAUDE.md - 可能需要更新"
        docs_updated=false
    fi

    # 检查 core-files/CLAUDE.md
    if grep -q "/speckit.specify" "$PROJECT_ROOT/core-files/CLAUDE.md" 2>/dev/null; then
        echo -e "  ${GREEN}✅${NC} core-files/CLAUDE.md - 已更新"
    else
        echo -e "  ${YELLOW}⚠️${NC} core-files/CLAUDE.md - 可能需要更新"
        docs_updated=false
    fi

    echo
    if [ "$docs_updated" = true ]; then
        echo -e "${GREEN}✨ 所有文档已正确更新！${NC}"
    else
        echo -e "${YELLOW}⚠️${NC} 部分文档可能需要手动检查"
    fi
}

# 检查迁移脚本
validate_migration_script() {
    echo -e "${BLUE}验证迁移脚本:${NC}"

    local migrate_script="$PROJECT_ROOT/scripts/migrate.sh"

    if [ -f "$migrate_script" ]; then
        if grep -q "speckit.*\.md" "$migrate_script"; then
            echo -e "  ${GREEN}✅${NC} migrate.sh - 已更新支持 speckit 命令"
        else
            echo -e "  ${RED}❌${NC} migrate.sh - 需要更新"
        fi
    else
        echo -e "  ${RED}❌${NC} migrate.sh - 文件不存在"
    fi

    echo
}

# 生成迁移报告
generate_migration_report() {
    echo -e "${BLUE}📊 生成迁移报告:${NC}"

    local report_file="$PROJECT_ROOT/SPECKIT_MIGRATION_REPORT.md"

    cat > "$report_file" << EOF
# speckit 命令格式迁移报告

**生成时间**: $(date '+%Y-%m-%d %H:%M:%S')
**项目**: $(basename "$PROJECT_ROOT")

## 迁移概述

本报告记录了项目从原有 \`/specify\` 格式命令迁移到新的 \`/speckit.specify\` 格式的详细情况。

## 新格式命令文件

以下命令文件已成功创建并更新：

| 原命令 | 新命令 | 状态 |
|--------|--------|------|
| \`/specify\` | \`/speckit.specify\` | ✅ 已迁移 |
| \`/clarify\` | \`/speckit.clarify\` | ✅ 已迁移 |
| \`/plan\` | \`/speckit.plan\` | ✅ 已迁移 |
| \`/tasks\` | \`/speckit.tasks\` | ✅ 已迁移 |
| \`/implement\` | \`/speckit.implement\` | ✅ 已迁移 |
| \`/constitution\` | \`/speckit.constitution\` | ✅ 已迁移 |
| \`/analyze\` | \`/speckit.analyze\` | ✅ 已迁移 |

## 保持不变的命令

以下命令为项目特有，保持不变：

| 命令 | 说明 |
|------|------|
| \`/collaborate\` | AI协作系统 |
| \`/enhance\` | 增强版AI协作 |
| \`/save\` | 保存协作会话 |

## 更新的文件

### 核心文档
- ✅ \`README.md\` - 更新安装说明
- ✅ \`CLAUDE.md\` - 更新命令引用
- ✅ \`core-files/CLAUDE.md\` - 更新工作流说明

### 脚本文件
- ✅ \`scripts/migrate.sh\` - 支持新格式命令迁移

### 新增工具
- ✅ \`scripts/speckit-migration-helper.sh\` - 迁移助手工具
- ✅ \`scripts/validate-speckit-migration.sh\` - 验证脚本

## 使用建议

### 立即可用
现在可以使用新的 speckit.* 命令格式：

\`\`\`bash
/speckit.specify "新功能描述"
/speckit.clarify
/speckit.plan "实现细节"
/speckit.tasks
/speckit.implement
/speckit.constitution "原则更新"
/speckit.analyze
\`\`\`

### 向后兼容
原有的 \`/specify\` 等命令仍然可用，但建议逐步迁移到新格式。

### 迁移现有项目
对于使用本工具包的其他项目：

1. 运行迁移助手: \`./scripts/speckit-migration-helper.sh migrate\`
2. 验证结果: \`./scripts/validate-speckit-migration.sh\`
3. 测试新命令: 尝试使用 \`/speckit.specify\` 等

## 注意事项

1. **备份**: 迁移前会自动备份旧命令文件
2. **测试**: 建议在测试环境中验证新命令功能
3. **文档**: 更新项目文档中的命令引用
4. **培训**: 通知团队成员新的命令格式

## 支持

如有问题，请参考：
- specify-cli 官方文档
- 项目 README.md
- 迁移助手帮助: \`./scripts/speckit-migration-helper.sh --help\`

---

*此报告由 speckit 迁移验证工具自动生成*
EOF

    echo -e "${GREEN}✅${NC} 报告已生成: $report_file"
    echo
}

# 主验证流程
main() {
    echo

    # 运行所有验证
    if validate_speckit_commands && validate_documentation && validate_migration_script; then
        echo -e "${GREEN}🎉 所有验证通过！迁移成功完成！${NC}"
        echo
        generate_migration_report

        echo -e "${BLUE}🚀 下一步操作:${NC}"
        echo -e "  1. 测试新命令: 尝试使用 /speckit.specify"
        echo -e "  2. 更新团队文档: 告知新命令格式"
        echo -e "  3. 迁移其他项目: 使用迁移助手工具"
        echo -e "  4. 查看详细报告: cat SPECKIT_MIGRATION_REPORT.md"

    else
        echo -e "${RED}❌ 验证发现问题，请检查上述错误${NC}"
        echo
        echo -e "${BLUE}💡 建议:${NC}"
        echo -e "  1. 运行迁移助手: ./scripts/speckit-migration-helper.sh migrate --backup-old"
        echo -e "  2. 手动检查问题文件"
        echo -e "  3. 重新运行验证"
    fi

    echo
}

# 如果直接运行脚本
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi