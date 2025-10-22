# Claude Code 状态栏配置迁移指南

**版本**: v1.0.0
**更新日期**: 2025-10-22

## 概述

本指南介绍如何使用状态栏配置迁移脚本，将 Claude Code 的自定义状态栏配置从一个项目迁移到其他项目。

**🎉 新功能**: 状态栏配置迁移现已集成到主迁移脚本中，支持一键迁移！

## 功能特性

### 🎯 核心能力
- **智能配置检测**：自动识别源项目中的状态栏配置
- **多模式迁移**：支持完整复制、适配和模板生成三种模式
- **依赖检查**：自动检查必要工具的安装情况
- **安全备份**：迁移前自动备份现有配置
- **权限适配**：智能适配项目特定的权限配置

### 🔧 支持的迁移模式

| 模式 | 描述 | 适用场景 |
|------|------|----------|
| `copy` | 完整复制源项目配置 | 配置完全相同的项目 |
| `adapt` | 适配模式，过滤项目特定配置 | 大多数项目，推荐使用 |
| `template` | 生成简化模板 | 新项目或需要自定义的项目 |

## 快速开始

### 方式一：使用主迁移脚本（推荐）

**🚀 一键迁移所有组件，包括状态栏配置**

```bash
# 完整迁移（包含状态栏配置）
./scripts/migrate.sh /path/to/target/project

# 跳过状态栏配置迁移
./scripts/migrate.sh --skip-statusbar /path/to/target/project

# 预览迁移操作
./scripts/migrate.sh --dry-run /path/to/target/project
```

### 方式二：独立使用状态栏迁移脚本

```bash
# 适配模式迁移（推荐）
./scripts/migrate-statusbar-config.sh /path/to/target/project

# 完整复制模式
./scripts/migrate-statusbar-config.sh -m copy /path/to/target/project

# 生成模板模式
./scripts/migrate-statusbar-config.sh -m template /path/to/new/project

# 预演模式（不执行实际操作）
./scripts/migrate-statusbar-config.sh --dry-run /path/to/target/project
```

**选择建议**：
- 新项目迁移：使用方式一，一键完成所有配置
- 已有项目更新：使用方式二，仅迁移状态栏配置
- 批量迁移：结合两种方式使用

## 详细使用说明

### 命令行选项

```bash
用法: migrate-statusbar-config.sh [选项] <目标项目路径>

选项:
  -s, --source <路径>     源项目路径 (默认: 当前目录)
  -m, --mode <模式>       迁移模式: copy | adapt | template (默认: adapt)
  -f, --force             强制覆盖现有配置
  -d, --dry-run           预演模式，不执行实际操作
  -v, --verbose           详细输出
  -h, --help              显示帮助信息
```

### 实际使用示例

#### 示例 1: 使用主迁移脚本（推荐）
```bash
# 完整迁移到新项目（包含状态栏配置）
./scripts/migrate.sh ~/projects/my-new-app

# 输出示例:
# 🚀 Claude标准迁移工具
# ✅ AI协作核心迁移完成
# ✅ 智能分支命名系统迁移完成
# ✅ Git自动化系统迁移完成
# ✅ AI协作指南迁移完成
# ✅ 模板文件迁移完成
# ✅ 系统优化组件迁移完成
# ✅ 状态栏配置迁移完成
# ✅ 路径适配完成
#
# 📊 状态栏配置: 自定义Claude Code状态栏
```

#### 示例 2: 独立状态栏迁移
```bash
# 将当前项目的状态栏配置迁移到新项目
./scripts/migrate-statusbar-config.sh ~/projects/my-new-app

# 输出示例:
# [INFO] Claude Code 状态栏配置迁移 v1.0.0
# 源项目: /Users/user/projects/source-app
# 目标项目: /Users/user/projects/my-new-app
# 迁移模式: adapt
#
# [INFO] 检查依赖工具...
# [SUCCESS] 所有依赖工具已安装
# [SUCCESS] 迁移成功完成！
```

#### 示例 3: 跳过状态栏配置
```bash
# 完整迁移但跳过状态栏配置
./scripts/migrate.sh --skip-statusbar ~/projects/existing-app

# 输出示例:
# 📊 状态栏配置: 已跳过
```

#### 示例 4: 强制覆盖现有配置
```bash
# 目标项目已有配置，强制覆盖
./scripts/migrate-statusbar-config.sh --force ~/projects/existing-app
```

#### 示例 5: 生成新项目模板
```bash
# 为新项目生成基础状态栏配置
./scripts/migrate-statusbar-config.sh -m template ~/projects/brand-new-app
```

#### 示例 6: 预演迁移
```bash
# 检查迁移计划，不执行实际操作
./scripts/migrate.sh --dry-run ~/projects/target-app
```

## 配置文件说明

### settings.local.json 结构

```json
{
  "permissions": {
    "allow": [
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(bash:*)",
      "Bash(tree:*)",
      "Bash(mkdir:*)"
    ],
    "deny": [],
    "ask": []
  },
  "statusLine": {
    "type": "command",
    "command": "bash .claude/scripts/status_line_script.sh"
  },
  "outputStyle": "ai-collaboration"
}
```

### status_line_script.sh 核心功能

脚本接收 JSON 格式的输入数据，包含以下信息：
- `model.display_name`: 模型名称
- `workspace.current_dir`: 当前工作目录
- `transcript_path`: 会话记录文件路径
- `exceeds_200k_tokens`: Token 使用量标记

## 自定义配置

### 修改状态栏显示格式

编辑目标项目中的 `.claude/scripts/status_line_script.sh` 文件：

```bash
# 原始输出格式
echo "[$MODEL] 📁 $DIR_NAME$BRANCH | 📊 上下文: ${PERCENTAGE}% ($TOKENS_USED/$MAX_TOKENS)"

# 自定义示例 1: 简化版本
echo "$MODEL | $DIR_NAME$BRANCH"

# 自定义示例 2: 添加时间
echo "[$MODEL] $DIR_NAME$BRANCH | $(date +%H:%M)"

# 自定义示例 3: 项目类型标识
PROJECT_TYPE=$(detect_project_type "$DIR")
echo "[$MODEL] 📁 $DIR_NAME [$PROJECT_TYPE]$BRANCH"
```

### 添加项目特定权限

在 `.claude/settings.local.json` 中添加项目需要的命令权限：

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run build:*)",
      "Bash(npx tsc:*)",
      "Bash(./scripts/deploy.sh:*)",
      "Bash(docker build:*)"
    ]
  }
}
```

## 故障排除

### 常见问题

#### 1. 缺少依赖工具
```bash
[ERROR] 缺少必要工具: jq bc git

# 解决方案:
# macOS
brew install jq bc git

# Ubuntu/Debian
sudo apt-get install jq bc git
```

#### 2. 目标项目已有配置
```bash
[WARNING] 目标项目已有statusLine配置
[ERROR] 目标项目已有配置，使用 --force 强制覆盖

# 解决方案:
./migrate-statusbar-config.sh --force /path/to/target
```

#### 3. 脚本权限问题
```bash
# 确保脚本有执行权限
chmod +x migrate-statusbar-config.sh

# 确保生成的状态栏脚本有执行权限
chmod +x .claude/scripts/status_line_script.sh
```

#### 4. 状态栏不显示
- 检查 `.claude/settings.local.json` 格式是否正确
- 确认 `status_line_script.sh` 有执行权限
- 重启 Claude Code 应用
- 检查脚本是否有语法错误

### 调试模式

启用详细输出进行调试：

```bash
./migrate-statusbar-config.sh --verbose /path/to/target
```

手动测试状态栏脚本：

```bash
# 创建测试输入
echo '{"model":{"display_name":"Claude-3.5-Sonnet"},"workspace":{"current_dir":"/test"}}' | \
.claude/scripts/status_line_script.sh
```

## 高级用法

### 批量迁移

创建批量迁移脚本：

```bash
#!/bin/bash
# batch-migrate.sh

SOURCE_PROJECT="/path/to/source/project"
TARGET_PROJECTS=(
    "/path/to/project1"
    "/path/to/project2"
    "/path/to/project3"
)

for target in "${TARGET_PROJECTS[@]}"; do
    echo "迁移到: $target"
    ./migrate-statusbar-config.sh -s "$SOURCE_PROJECT" "$target"
    echo "------------------------"
done
```

### 集成到项目初始化流程

在项目模板中添加迁移脚本：

```bash
# project-template/scripts/setup.sh
#!/bin/bash

echo "设置项目 Claude Code 配置..."

if [[ -n "$CLAUDE_CONFIG_SOURCE" ]]; then
    ./tools/migrate-statusbar-config.sh -s "$CLAUDE_CONFIG_SOURCE" .
else
    echo "使用默认配置模板"
    ./tools/migrate-statusbar-config.sh -m template .
fi
```

## 最佳实践

### 1. 迁移前检查清单
- [ ] 确认源项目状态栏配置正常工作
- [ ] 检查目标项目是否有重要配置需要备份
- [ ] 确认所有依赖工具已安装（jq、bc、git）
- [ ] 建议先使用预演模式测试
- [ ] 选择合适的迁移方式（主脚本 vs 独立脚本）

### 2. 迁移后验证
- [ ] 检查生成的配置文件格式正确
- [ ] 验证权限配置满足项目需求
- [ ] 测试状态栏脚本执行无错误
- [ ] 重启 Claude Code 确认状态栏正常显示
- [ ] 验证其他迁移组件功能正常（如果使用主迁移脚本）

### 3. 维护建议
- 定期更新状态栏脚本以适配新功能
- 为不同类型的项目维护配置模板
- 记录自定义配置的变更历史

## 版本历史

- **v1.0.0** (2025-10-22): 初始版本，支持基本的配置迁移功能

## 贡献

欢迎提交问题报告和功能请求到项目的 GitHub 仓库。

---

*本文档随迁移脚本一同更新，确保信息的准确性。*