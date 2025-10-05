# Claude迁移工具使用指南

本指南详细介绍如何使用Claude迁移工具包将AI协作功能和智能开发工作流迁移到其他项目。

## 目录

1. [快速开始](#快速开始)
2. [详细迁移步骤](#详细迁移步骤)
3. [功能使用指南](#功能使用指南)
4. [故障排除](#故障排除)
5. [高级配置](#高级配置)
6. [最佳实践](#最佳实践)

## 快速开始

### 一键迁移
```bash
# 1. 克隆或下载迁移工具包
git clone <repository-url> claude-migration-toolkit
cd claude-migration-toolkit

# 2. 运行迁移（迁移到当前目录）
./scripts/migrate.sh

# 3. 验证迁移结果
./scripts/validator.sh
```

### 迁移到指定项目
```bash
# 迁移到现有项目
./scripts/migrate.sh /path/to/your/project

# 验证指定项目
./scripts/validator.sh /path/to/your/project
```

## 详细迁移步骤

### 步骤1：准备迁移环境

**系统要求检查**
```bash
# 检查必要命令
which git bash sed grep mkdir chmod

# 检查权限
ls -la scripts/
```

**备份现有配置**
```bash
# 迁移工具会自动创建备份
# 备份位置: .claude-migration-backup-YYYYMMDD-HHMMSS/
```

### 步骤2：执行迁移

**基本迁移**
```bash
# 标准迁移
./scripts/migrate.sh

# 迁移到指定目录
./scripts/migrate.sh /path/to/target/project
```

**高级选项**
```bash
# 预览迁移操作（不实际执行）
./scripts/migrate.sh --dry-run

# 详细输出模式
./scripts/migrate.sh --verbose

# 跳过Git hooks安装
./scripts/migrate.sh --skip-git-hooks

# 组合选项
./scripts/migrate.sh --verbose --dry-run /path/to/project
```

### 步骤3：验证迁移结果

**快速验证**
```bash
./scripts/validator.sh
```

**详细验证**
```bash
./scripts/validator.sh --verbose
```

**快速验证**
```bash
./scripts/validator.sh --quick
```

## 功能使用指南

### AI协作功能

#### 激活协作范式
```bash
# 查看所有可用的协作范式
/collaborate help

# 激活可视化协作模式
/collaborate visual

# 激活第一性原理分析
/collaborate first-principles

# 激活渐进式沟通
/collaborate progressive

# 激活双向费曼学习法
/collaborate feynman

# 激活EARS需求描述方法
/collaborate ears
```

#### 使用场景示例

**场景1：架构设计讨论**
```bash
/collaborate visual
用户: 请解释微服务架构的组件交互
```

**场景2：学习新技术**
```bash
/collaborate progressive
用户: 用渐进式方式解释React Hooks
```

**场景3：需求分析**
```bash
/collaborate ears
用户: 用户登录时需要验证邮箱
```

### 智能分支命名

#### 创建新功能
```bash
# 基本用法
./.specify/scripts/bash/create-new-feature.sh "实现用户登录功能"

# 中文语义自动转换
./.specify/scripts/bash/create-new-feature.sh "MagicScript脚本的语义解释功能"
# 自动生成：001-magic-script-explain

# JSON模式输出
./.specify/scripts/bash/create-new-feature.sh --json "添加数据报表功能"
```

#### 智能命名特性
- **中文语义映射**：自动转换中文关键词为英文
- **领域特定优化**：特别针对编程智能体系统
- **模式匹配**：识别常见功能模式
- **标准化输出**：生成规范的分支名格式

### Git自动化

#### 安装Git hooks
```bash
# 安装自动化hooks
./.specify/scripts/bash/git-changelog-hook.sh install

# 查看hooks状态
./.specify/scripts/bash/git-changelog-hook.sh status

# 卸载hooks
./.specify/scripts/bash/git-changelog-hook.sh uninstall
```

#### 自动CHANGELOG更新
```bash
# 正常提交，自动更新CHANGELOG
git commit -m "feat: 添加用户认证功能"

# 手动添加CHANGELOG条目
./.specify/scripts/bash/update-changelog.sh add feat "新功能描述"

# 发布新版本
./.specify/scripts/bash/update-changelog.sh release 1.0.0
```

#### 支持的提交类型
- `feat` - 新功能
- `fix` - 修复
- `docs` - 文档
- `improvement` - 改进
- `performance` - 性能优化
- `refactor` - 重构
- `test` - 测试
- `example` - 示例
- `security` - 安全

## 故障排除

### 常见问题

#### 迁移相关问题

**Q: 迁移失败，提示权限不足**
```bash
# 解决方案：设置脚本执行权限
chmod +x claude-migration-toolkit/scripts/*.sh
```

**Q: 脚本路径引用错误**
```bash
# 解决方案：运行路径适配器
./scripts/path-adapter.sh /path/to/project
```

**Q: 文件复制失败**
```bash
# 解决方案：检查目标目录权限
ls -la /path/to/target/project
sudo chown -R $USER:$USER /path/to/target/project  # 如需要
```

#### 功能使用问题

**Q: /collaborate命令不工作**
```bash
# 检查命令文件是否存在
ls -la .claude/commands/collaborate.md

# 检查Claude Code配置
cat .claude/settings.local.json
```

**Q: 智能分支命名不生效**
```bash
# 检查脚本权限
ls -la .specify/scripts/bash/create-new-feature.sh
chmod +x .specify/scripts/bash/create-new-feature.sh

# 测试脚本
./.specify/scripts/bash/create-new-feature.sh --help
```

**Q: Git hooks未生效**
```bash
# 检查hooks安装
./.specify/scripts/bash/git-changelog-hook.sh status

# 重新安装hooks
./.specify/scripts/bash/git-changelog-hook.sh install

# 手动执行测试
./.specify/scripts/bash/git-changelog-hook.sh manual
```

### 诊断步骤

#### 1. 运行完整验证
```bash
./scripts/validator.sh --verbose /path/to/project
```

#### 2. 检查迁移报告
```bash
cat /path/to/project/.claude-validation-report.md
```

#### 3. 检查系统环境
```bash
# 检查Shell环境
echo $SHELL
bash --version

# 检查Git环境
git --version
git status

# 检查文件权限
find .specify -name "*.sh" -exec ls -la {} \;
```

#### 4. 测试单个功能
```bash
# 测试AI协作
/collaborate help

# 测试分支命名
./.specify/scripts/bash/create-new-feature.sh --help

# 测试Git自动化
./.specify/scripts/bash/git-changelog-hook.sh --help
```

## 高级配置

### 自定义配置

#### Git Changelog配置
```bash
# 创建配置文件
./.specify/scripts/bash/git-changelog-hook.sh config

# 编辑配置文件
vi .git/changelog-config
```

**配置示例**
```bash
# .git/changelog-config
AUTO_UPDATE=true
INTERACTIVE=false
SKIP_PATTERNS="^changelog ^docs ^style"
```

#### Claude配置
```json
{
  "model": "claude-3-sonnet",
  "maxTokens": 4000,
  "outputStyle": "explanatory"
}
```

### 集成现有工作流

#### 与CI/CD集成
```yaml
# .github/workflows/claude.yml
name: Claude AI Collaboration
on: [push, pull_request]
jobs:
  update-changelog:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Update CHANGELOG
        run: ./.specify/scripts/bash/git-changelog-hook.sh manual
```

#### 与项目管理系统集成
```bash
# 在提交信息中包含任务编号
git commit -m "feat: 用户认证功能 [TASK-123]"
# 自动解析并关联到项目管理系统
```

## 最佳实践

### 迁移最佳实践

#### 1. 迁移前准备
- 备份现有配置文件
- 确认团队成员对工具的了解
- 建立迁移计划和时间表

#### 2. 迁移过程
- 使用`--dry-run`模式预览操作
- 在测试环境中先进行试验
- 逐步验证各个功能模块

#### 3. 迁移后验证
- 运行完整的验证检查
- 组织团队培训和试用
- 收集反馈并优化配置

### 使用最佳实践

#### AI协作
- **选择合适的协作范式**：根据任务性质选择最适合的范式
- **提供清晰上下文**：给AI提供足够的背景信息
- **渐进式使用**：从简单的范式开始，逐步掌握高级用法

#### 分支命名
- **使用描述性文字**：清晰描述功能目的
- **保持一致性**：遵循团队的命名规范
- **利用智能特性**：充分利用中文语义转换功能

#### Git自动化
- **标准化提交信息**：使用约定的提交类型和格式
- **定期更新CHANGELOG**：保持项目文档的时效性
- **团队协作**：确保所有成员都了解自动化规则

### 团队协作

#### 培训建议
1. **基础培训**：介绍AI协作的基本概念和使用方法
2. **实践练习**：通过实际项目练习各种协作范式
3. **经验分享**：定期分享使用心得和最佳实践

#### 文档维护
- 更新项目README，说明Claude功能的使用方法
- 维护团队内部的协作规范和最佳实践文档
- 定期更新AI协作指南，添加新的使用案例

---

## 获取帮助

如需更多帮助，请：
1. 查看详细的故障排除文档
2. 运行诊断脚本获取详细信息
3. 查看迁移报告和验证报告
4. 联系技术支持团队

**相关文档**：
- [README.md](../README.md) - 迁移工具包概览
- [AI协作指南](../core-files/ai-collaboration-guide.md) - 详细的协作范式说明