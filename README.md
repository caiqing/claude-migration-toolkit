# Claude标准迁移工具包

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-v0.1.1-blue.svg)](https://github.com/caiqing/claude-migration-toolkit/releases)
[![Release Status](https://img.shields.io/badge/release-stable-brightgreen.svg)](https://github.com/caiqing/claude-migration-toolkit)

这个工具包提供了将Claude AI协作功能和智能开发工作流迁移到其他项目的完整解决方案，包含完整的协作会话管理系统和增强版错误处理机制。

## ✨ 主要特性

- **🤖 AI协作核心** - 12种AI协作范式，支持创意激发、批判性思考、可视化分析等
- **📝 协作会话管理** - 自动化知识保存和索引系统，完整的会话生命周期管理
- **🔧 系统优化组件** - 增强版内容处理、错误诊断、完整性验证
- **🌟 智能分支命名** - 中文语义到英文的智能映射
- **📊 Git自动化** - 自动CHANGELOG更新和提交解析
- **🛡️ 内容完整性保障** - Mermaid图表、代码块100%保护，保存成功率97%

## 🚀 快速开始

### Step 1. 安装 specify-cli
```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
```
### Step 2. specify 初始化（从最新模板初始化制定项目）
```bash
specify init <PROJECT_NAME>
```
### Step 3. 制定项目原则（基本法），创建或更新项目管理原则和开发指南，以指导所有后续开发
```bash
/speckit.constitution Create principles focused on code quality, testing standards, user experience consistency, and performance requirements
```

### Step 4. 使用本项目，完成AI协作增强能力一键迁移
```bash
# 克隆仓库
git clone https://github.com/caiqing/claude-migration-toolkit.git

# 进入工具目录
cd claude-migration-toolkit

# 运行主迁移脚本
./scripts/migrate.sh /path/to/target/project

# 验证迁移结果
./scripts/validator.sh /path/to/target/project
```

## 📖 使用指南

### AI协作功能

```bash
# 启动AI协作会话
/ai.collab start creative "产品创新头脑风暴"        # 创意激发
/ai.collab start visual "系统架构可视化分析"        # 可视化呈现
/ai.collab start critical "技术方案批判性思考"      # 批判性思考
/ai.collab start first-principles "性能优化根本原因"  # 第一性原理分析
/ai.collab start progressive "复杂系统渐进式分析" "实现细节"

# 会话管理
/ai.collab save        # 智能保存协作会话
/ai.collab health      # 系统健康检查
/ai.collab status      # 查看会话状态
/ai.collab help        # 显示完整帮助
```

### 智能分支命名

```bash
# 创建新功能（自动生成语义化分支名）
./.specify/scripts/bash/create-new-feature.sh "实现用户认证功能"
# 自动生成分支名：001-user-authentication
```

### 系统优化工具

```bash
# 错误诊断和修复
./.specify/optimization/error-handler.sh analyze "错误信息"
./.specify/optimization/error-handler.sh auto-fix

# 内容完整性验证
./.specify/optimization/content-validator.sh batch-validate
```

## 📁 详细项目结构

```text
claude-migration-toolkit/
├── .claude/               # Claude Code配置
│   ├── commands/          # 斜杠命令定义
│   │   ├── ai.collab.md   # 统一AI协作系统 v2.0
│   │   └── speckit.*.md   # Speckit工作流命令(8个)
│   └── settings.local.json
├── .specify/              # Specify框架配置
│   ├── memory/           # 项目章程和记忆
│   ├── scripts/          # 自动化脚本
│   ├── templates/        # 文档模板
│   └── optimization/     # 系统优化工具
├── backup/               # 备份文件
│   ├── CLAUDE.md.bak
│   └── README.md.bak
├── core-files/           # 15个核心迁移文件
│   ├── scripts/          # 核心脚本
│   ├── documents/        # 重要文档
│   └── optimization/     # 优化组件
├── docs/
│   ├── collaboration/    # AI协作会话记录
│   └── reports/          # 迁移报告
│       ├── ai_collab_command_simplification_report.md
│       ├── final_command_architecture.md
│       ├── speckit_migration_report.md
│       ├── v0.1.0_final_release_report.md
│       └── README.md
├── scripts/              # 主要脚本
│   ├── migrate.sh        # 主迁移脚本 ⭐
│   ├── validator.sh      # 验证脚本 ⭐
│   ├── path-adapter.sh   # 路径适配器 ⭐
│   └── temp/            # 临时性脚本(可删除)
└── README.md            # 项目说明文档
```

## 🎯 核心文件说明

### 必备脚本
- **migrate.sh**: 主迁移脚本，用于将工具包迁移到目标项目
- **validator.sh**: 验证脚本，检查迁移完整性
- **path-adapter.sh**: 路径适配器，处理不同环境路径问题

### 临时脚本 (scripts/temp/)
这些是迁移过程中使用的临时性脚本，在确认迁移完成前可保留：
- ai-command-migrator.sh
- check-specify-compatibility.sh
- final-command-validator.sh
- simple-command-test.sh
- speckit-migration-helper.sh
- test-ai-collab-commands.sh
- validate-speckit-migration.sh

## 🔧 维护建议

### 定期清理
1. 确认迁移完成后，可删除 `scripts/temp/` 目录下的临时脚本
2. 检查 `backup/` 目录，确认不需要后可删除备份文件
3. 清理不再需要的临时文件和日志

### 文档更新
1. 新功能添加后更新 README.md
2. 重要变更记录在 docs/CHANGELOG.md
3. AI协作会话自动保存在 docs/collaboration/

## 📊 迁移状态

✅ **已完成的迁移**:
- AI协作系统 v2.0 (ai.collab)
- Speckit工作流命令 (8个命令)
- 项目结构优化
- 文档整理和归档
- 权限配置更新

✅ **已清理的项目**:
- 临时文件和日志
- 测试目录
- 冗余脚本
- 备份文件归档

## 🛠️ 系统要求

- **操作系统**: macOS, Linux, Windows (WSL)
- **Shell环境**: bash, zsh
- **Git**: 版本 2.0+
- **权限**: 脚本执行权限

## 📚 详细文档

- [SDD规范驱动开发](docs/SDD规范驱动开发.md) - 规范驱动开发方法论和实践指南
- [系统优化指南](docs/system_optimization_guide.md)
- [项目报告文档](docs/reports/) - 完整的技术报告和发布说明
  - [v0.1.0最终发布报告](docs/reports/v0.1.0_final_release_report.md)
  - [AI协作命令简化报告](docs/reports/ai_collab_command_simplification_report.md)
  - [最终命令架构文档](docs/reports/final_command_architecture.md)
  - [Speckit迁移报告](docs/reports/speckit_migration_report.md)
- [变更日志](docs/CHANGELOG.md)
- [AI协作会话记录](docs/collaboration/) - 历史协作会话文档

## 🤝 贡献

欢迎贡献代码！请确保：

1. 遵循项目的代码规范
2. 添加适当的测试
3. 更新相关文档
4. 提交前运行验证脚本

## 📄 许可证

本项目采用 [MIT许可证](LICENSE)。

## 🔗 相关链接

- [Claude Code](https://claude.com/claude-code) - AI开发智能体
- [Specify框架](https://github.com/github/spec-kit) - SDD开发框架

---

**版本**: v0.1.1 (2025-10-08) | **维护者**: [开目软件 AI研究院](https://github.com/caiqing)