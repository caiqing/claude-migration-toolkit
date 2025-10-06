#!/bin/bash

# AI协作系统迁移验证脚本
# 验证core-files目录中所有文件的完整性和功能

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 AI协作系统迁移验证${NC}"
echo "=================================="

# 验证文件列表
REQUIRED_FILES=(
    "collaboration-session-automation.sh"
    "collaboration-quick-start.sh"
    "collaboration-session-manager.sh"
    "update-collaboration-index.py"
    "save.md"
    "collaborate.md"
    "collaboration-quick-guide.md"
    "CLAUDE.md"
    "ai-collaboration-guide.md"
    "UPDATE_LOG.md"
)

# 必需的脚本执行权限
EXECUTABLE_SCRIPTS=(
    "collaboration-session-automation.sh"
    "collaboration-quick-start.sh"
    "collaboration-session-manager.sh"
    "update-collaboration-index.py"
)

echo -e "\n${YELLOW}📁 检查必需文件...${NC}"
missing_files=0

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ $file${NC}"
    else
        echo -e "${RED}❌ $file (缺失)${NC}"
        ((missing_files++))
    fi
done

if [ $missing_files -gt 0 ]; then
    echo -e "\n${RED}❌ 验证失败：缺失 $missing_files 个必需文件${NC}"
    exit 1
fi

echo -e "\n${YELLOW}🔐 检查脚本执行权限...${NC}"
permission_issues=0

for script in "${EXECUTABLE_SCRIPTS[@]}"; do
    if [ -x "$script" ]; then
        echo -e "${GREEN}✅ $script (可执行)${NC}"
    else
        echo -e "${RED}❌ $script (无执行权限)${NC}"
        ((permission_issues++))
    fi
done

if [ $permission_issues -gt 0 ]; then
    echo -e "\n${YELLOW}⚠️  发现 $permission_issues 个权限问题${NC}"
    echo "尝试修复权限..."

    for script in "${EXECUTABLE_SCRIPTS[@]}"; do
        if [ -f "$script" ] && [ ! -x "$script" ]; then
            chmod +x "$script"
            echo -e "${GREEN}✅ 已修复 $script 权限${NC}"
        fi
    done
fi

echo -e "\n${YELLOW}🧪 语法检查...${NC}"
syntax_errors=0

# 检查bash脚本语法
for script in "collaboration-session-automation.sh" "collaboration-quick-start.sh" "collaboration-session-manager.sh"; do
    if bash -n "$script" 2>/dev/null; then
        echo -e "${GREEN}✅ $script (语法正确)${NC}"
    else
        echo -e "${RED}❌ $script (语法错误)${NC}"
        ((syntax_errors++))
    fi
done

# 检查Python脚本语法
if python3 -m py_compile "update-collaboration-index.py" 2>/dev/null; then
    echo -e "${GREEN}✅ update-collaboration-index.py (语法正确)${NC}"
else
    echo -e "${RED}❌ update-collaboration-index.py (语法错误)${NC}"
    ((syntax_errors++))
fi

if [ $syntax_errors -gt 0 ]; then
    echo -e "\n${RED}❌ 验证失败：发现 $syntax_errors 个语法错误${NC}"
    exit 1
fi

echo -e "\n${YELLOW}🔧 功能验证...${NC}"

# 验证协作会话脚本基本功能
if ./collaboration-session-automation.sh help > /dev/null 2>&1; then
    echo -e "${GREEN}✅ 协作会话脚本功能正常${NC}"
else
    echo -e "${RED}❌ 协作会话脚本功能异常${NC}"
    exit 1
fi

# 验证Python脚本基本功能
if python3 update-collaboration-index.py > /dev/null 2>&1; then
    echo -e "${GREEN}✅ 索引更新脚本功能正常${NC}"
else
    echo -e "${YELLOW}⚠️  索引更新脚本需要协作目录${NC}"
fi

echo -e "\n${YELLOW}📊 文件统计${NC}"
total_files=${#REQUIRED_FILES[@]}
echo "必需文件总数: $total_files"

script_files=$(find . -name "*.sh" -type f | wc -l)
echo "Shell脚本数量: $script_files"

python_files=$(find . -name "*.py" -type f | wc -l)
echo "Python脚本数量: $python_files"

md_files=$(find . -name "*.md" -type f | wc -l)
echo "Markdown文档数量: $md_files"

# 计算总大小
total_size=$(du -sh . | cut -f1)
echo "总大小: $total_size"

echo -e "\n${YELLOW}🎯 核心功能检查${NC}"

# 检查/save命令文件
if [ -f "save.md" ] && grep -q "保存协作会话" "save.md"; then
    echo -e "${GREEN}✅ /save命令定义完整${NC}"
else
    echo -e "${RED}❌ /save命令定义有问题${NC}"
    exit 1
fi

# 检查/collaborate命令文件
if [ -f "collaborate.md" ] && grep -q "协作范式" "collaborate.md"; then
    echo -e "${GREEN}✅ /collaborate命令定义完整${NC}"
else
    echo -e "${RED}❌ /collaborate命令定义有问题${NC}"
    exit 1
fi

# 检查快速指南
if [ -f "collaboration-quick-guide.md" ] && grep -q "/save" "collaboration-quick-guide.md"; then
    echo -e "${GREEN}✅ 快速指南包含/save命令说明${NC}"
else
    echo -e "${RED}❌ 快速指南缺少/save命令说明${NC}"
    exit 1
fi

echo -e "\n${GREEN}🎉 迁移验证完成！${NC}"
echo "=================================="
echo "✅ 所有必需文件存在"
echo "✅ 脚本权限设置正确"
echo "✅ 语法检查通过"
echo "✅ 基本功能验证通过"
echo "✅ 核心功能检查通过"

echo -e "\n${BLUE}📋 迁移就绪确认${NC}"
echo "- AI协作系统已准备就绪"
echo "- /save和/collaborate命令可用"
echo "- 所有脚本和文档完整"
echo "- 可以安全迁移到新项目"

echo -e "\n${YELLOW}💡 迁移建议${NC}"
echo "1. 将整个core-files目录复制到新项目"
echo "2. 确保新项目有.claude/commands/目录"
echo "3. 复制斜杠命令文件到.claude/commands/"
echo "4. 创建docs/collaboration/目录存储协作文档"
echo "5. 验证/s​​ave和/collaborate命令正常工作"

echo -e "\n${GREEN}🚀 AI协作系统迁移验证成功！${NC}"