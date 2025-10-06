# Claude标准迁移工具包

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-v0.1.0-blue.svg)](https://github.com/caiqing/claude-migration-toolkit/releases)
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

### 一键迁移

```bash
# 克隆仓库
git clone https://github.com/caiqing/claude-migration-toolkit.git
cd claude-migration-toolkit

# 运行主迁移脚本
./scripts/migrate.sh /path/to/target/project

# 验证迁移结果
./scripts/validator.sh /path/to/target/project
```

## 📖 使用指南

### AI协作功能

```bash
# 启动协作会话
/collaborate visual    # 可视化呈现
/collaborate creative  # 创意激发
/collaborate critical  # 批判性思考
/collaborate first-principles  # 第一性原理分析

# 使用增强版命令（推荐）
/enhance start progressive "系统架构分析"
/enhance save
/enhance health
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

## 📁 项目结构

```text
claude-migration-toolkit/
├── .specify/              # Specify框架配置和优化组件
├── .claude/               # Claude Code配置
├── core-files/            # 15个核心迁移文件
├── scripts/               # 迁移和验证脚本
├── docs/                  # 使用文档和指南
└── tests/                 # 测试用例
```

## 🛠️ 系统要求

- **操作系统**: macOS, Linux, Windows (WSL)
- **Shell环境**: bash, zsh
- **Git**: 版本 2.0+
- **权限**: 脚本执行权限

## 📚 详细文档

- [SDD规范驱动开发](docs/SDD规范驱动开发.md) - 规范驱动开发方法论和实践指南
- [系统优化指南](docs/system_optimization_guide.md)
- [v0.1.0发布报告](docs/v0.1.0-release-report.md)
- [变更日志](docs/CHANGELOG.md)

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

**版本**: v0.1.0 (2025-10-06) | **维护者**: [开目软件 AI研究院](https://github.com/caiqing)