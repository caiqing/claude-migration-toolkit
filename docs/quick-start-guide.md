# 快速开始指南

**版本**: v0.1.2
**更新日期**: 2025-10-22

## 🚀 5分钟完成Claude AI协作功能迁移

本指南将帮助您快速将Claude AI协作功能和自定义状态栏配置迁移到您的项目中。

### 前置条件

确保您的系统已安装以下工具：

```bash
# 检查必要工具
git --version          # 需要 2.0+
bash --version         # 大多数系统内置
jq --version          # JSON处理工具
bc --version          # 计算器工具

# macOS 安装缺失工具
brew install jq bc

# Ubuntu/Debian 安装缺失工具
sudo apt-get update
sudo apt-get install jq bc git
```

---

## ⚡ 一键迁移（推荐）

### Step 1: 克隆工具包

```bash
git clone https://github.com/caiqing/claude-migration-toolkit.git
cd claude-migration-toolkit
```

### Step 2: 执行迁移

```bash
# 迁移到您的项目目录
./scripts/migrate.sh /path/to/your/project

# 或者迁移到当前目录
./scripts/migrate.sh .
```

**迁移过程中您将看到**：
```
🚀 Claude标准迁移工具
✅ AI协作核心迁移完成
✅ 智能分支命名系统迁移完成
✅ Git自动化系统迁移完成
✅ AI协作指南迁移完成
✅ 系统优化组件迁移完成
✅ 状态栏配置迁移完成
✅ 路径适配完成
```

### Step 3: 验证迁移

```bash
# 验证迁移结果
./scripts/validator.sh /path/to/your/project
```

### Step 4: 开始使用

```bash
# 切换到您的项目
cd /path/to/your/project

# 体验AI协作功能
/ai.collab help

# 测试状态栏配置
# 重启 Claude Code，查看状态栏显示
```

---

## 🎯 迁移后您将获得

### 1. AI协作系统 v2.0
- **12种协作范式**：创意激发、批判性思考、可视化分析等
- **会话管理**：自动保存和索引协作内容
- **简化命令**：`/ai.collab creative "主题"`

### 2. 自定义状态栏
- **模型信息**：显示当前使用的AI模型
- **项目目录**：显示当前工作目录
- **Git分支**：显示当前分支（如果是Git仓库）
- **Token使用情况**：显示上下文使用百分比

```
[Claude-3.5-Sonnet] 📁 my-project | 🌿 main | 📊 上下文: 15.2% (30480/200000)
```

### 3. 智能开发工具
- **智能分支命名**：`create-new-feature.sh "实现用户认证"`
- **Git自动化**：自动更新CHANGELOG
- **系统优化**：错误诊断和内容验证

---

## 🔧 迁移选项

### 完整迁移（默认）
```bash
./scripts/migrate.sh /path/to/project
```
包含所有组件：AI协作、状态栏配置、开发工具等

### 跳过状态栏配置
```bash
./scripts/migrate.sh --skip-statusbar /path/to/project
```
如果您不需要自定义状态栏功能

### 预览迁移操作
```bash
./scripts/migrate.sh --dry-run /path/to/project
```
查看将要进行的操作，不实际执行

---

## 🎨 状态栏配置自定义

迁移完成后，您可以自定义状态栏显示：

### 编辑状态栏脚本
```bash
# 编辑状态栏脚本
vim .claude/scripts/status_line_script.sh
```

### 常见自定义示例

**简化版本**：
```bash
echo "[$MODEL] 📁 $DIR_NAME$BRANCH"
```

**添加时间显示**：
```bash
echo "[$MODEL] $DIR_NAME$BRANCH | $(date +%H:%M)"
```

**项目类型标识**：
```bash
PROJECT_TYPE=$(detect_project_type "$DIR")
echo "[$MODEL] 📁 $DIR_NAME [$PROJECT_TYPE]$BRANCH"
```

### 重启生效
修改完成后，重启 Claude Code 以应用新配置。

---

## 🚨 常见问题

### Q: 迁移失败怎么办？
```bash
# 检查依赖工具
jq --version
bc --version
git --version

# 查看详细错误信息
./scripts/migrate.sh --verbose /path/to/project
```

### Q: 状态栏不显示？
1. 检查 `.claude/settings.local.json` 格式是否正确
2. 确认 `.claude/scripts/status_line_script.sh` 有执行权限
3. 重启 Claude Code 应用

### Q: 如何单独迁移状态栏配置？
```bash
# 独立迁移状态栏配置
./scripts/migrate-statusbar-config.sh /path/to/project
```

### Q: 如何回滚迁移？
```bash
# 恢复备份（如果存在）
# 备份位置：.claude/backup-YYYYMMDD-HHMMSS/
```

---

## 📚 下一步学习

1. **[AI协作指南](ai-collaboration-guide.md)** - 深入了解12种协作范式
2. **[状态栏配置指南](statusbar-migration-guide.md)** - 详细的自定义配置说明
3. **[完整文档](README.md)** - 所有功能的详细说明

### 快速命令参考

```bash
# AI协作功能
/ai.collab creative "产品创新头脑风暴"
/ai.collab critical "技术方案批判性思考"
/ai.collab visual "系统架构可视化设计"
/ai.collab save                    # 保存协作会话

# 开发工具
./.specify/scripts/bash/create-new-feature.sh "新功能描述"
./.specify/optimization/enhanced-collaboration.sh health

# 规格驱动开发
/speckit.specify "用户认证系统"
/speckit.plan "实现方案"
/speckit.tasks "开发任务"
```

---

## 🎉 恭喜！

您已成功完成Claude AI协作功能的迁移！现在可以：

✅ 使用12种AI协作范式提升开发效率
✅ 享受自定义状态栏的实时信息显示
✅ 利用智能开发工具简化工作流程
✅ 通过规格驱动开发提升代码质量

如有问题，请查看[完整文档](README.md)或提交Issue。

---

**需要帮助？**
- 📖 [完整文档](README.md)
- 🐛 [报告问题](https://github.com/caiqing/claude-migration-toolkit/issues)
- 💬 [讨论区](https://github.com/caiqing/claude-migration-toolkit/discussions)

**版本**: v0.1.2 | **更新**: 2025-10-22