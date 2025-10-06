# 协作会话保存功能调用指南

## 🎯 核心调用方法

### 方法一：使用Claude Code斜杠命令（最简单）

```bash
# 1. 开始协作会话
/collaborate [范式] "[主题]"

# 2. 进行AI协作讨论
# 与AI进行自然语言交流，系统会自动记录内容

# 3. 保存会话（一键保存）
/save
```

### 方法二：直接脚本调用（高级用户）

```bash
# 1. 开始协作会话
./.specify/scripts/bash/collaboration-session-automation.sh start [范式] "[主题]"

# 2. 添加内容、洞察、成果
./.specify/scripts/bash/collaboration-session-automation.sh add-content "内容描述"
./.specify/scripts/bash/collaboration-session-automation.sh add-insight "关键洞察"
./.specify/scripts/bash/collaboration-session-automation.sh add-output "产出成果"
./.specify/scripts/bash/collaboration-session-automation.sh add-action "行动要点"

# 3. 显式保存会话（生成MD文档并更新索引）
./.specify/scripts/bash/collaboration-session-automation.sh save
```

### 方法三：使用快速启动工具

```bash
# 交互式启动（会自动处理保存）
./.specify/scripts/bash/collaboration-quick-start.sh

# 指定范式启动（需要手动保存）
./.specify/scripts/bash/collaboration-quick-start.sh [范式] "[主题]"
```

## 📋 完整操作示例

### 示例1：技术原理分析协作（推荐方式）
```bash
# 开始第一性原理分析
/collaborate first-principles "分析数据库性能优化原理"

# 与AI进行自然语言讨论
# AI会自动记录关键内容和洞察

# 一键保存会话
/save
```

### 示例2：架构设计协作（脚本方式）
```bash
# 开始可视化架构设计
./.specify/scripts/bash/collaboration-session-automation.sh start visual "微服务架构设计"

# 添加设计内容
./.specify/scripts/bash/collaboration-session-automation.sh add-content "设计API网关和服务发现机制"
./.specify/scripts/bash/collaboration-session-automation.sh add-insight "微服务拆分要遵循单一职责原则"
./.specify/scripts/bash/collaboration-session-automation.sh add-output "创建了完整的架构图和组件说明"

# 保存会话
./.specify/scripts/bash/collaboration-session-automation.sh save
```

### 示例3：快速协作工作流（最简单）
```bash
# 开始协作
/collaborate creative "新产品功能头脑风暴"

# 与AI自由讨论创意和想法
# 无需手动记录，AI自动跟踪

# 完成后保存
/save
```

## 🔧 常用命令一览

### Claude Code斜杠命令（推荐）

| 命令 | 功能 | 用法 |
|------|------|------|
| `/collaborate` | 开始新协作会话 | `/collaborate [范式] "[主题]"` |
| `/save` | 保存当前协作会话 | `/save` |

### 脚本命令（高级用户）

| 命令 | 功能 | 用法 |
|------|------|------|
| `start` | 开始新会话 | `start [范式] "[主题]"` |
| `add-content` | 添加讨论内容 | `add-content "内容描述"` |
| `add-insight` | 添加关键洞察 | `add-insight "洞察描述"` |
| `add-output` | 添加产出成果 | `add-output "成果描述"` |
| `add-action` | 添加行动要点 | `add-action "行动描述"` |
| `save` | 保存会话 | `save` |
| `status` | 查看当前状态 | `status` |
| `list` | 列出所有会话 | `list` |
| `update-index` | 更新索引 | `update-index` |

## 🎨 可用协作范式

- `first-principles` - 第一性原理思维
- `progressive` - 渐进式沟通
- `visual` - 可视化呈现
- `creative` - 创意激发
- `critical` - 批判性思考
- `feynman` - 双向费曼学习法
- `smart` - SMART结构化表达
- `optimize` - 流程优化
- `ears` - EARS需求描述
- `evolve` - 持续进化反馈
- `fusion` - 跨界知识融合
- `learning` - 个性化学习

## ⚠️ 重要提醒

### 斜杠命令使用
1. **必须先/collaborate才能/save** - 会话必须在活跃状态下
2. **/save是显式操作** - 需要手动调用才会生成文档
3. **自动更新索引** - /save时会自动更新索引文件
4. **自然语言交互** - AI会自动记录讨论内容，无需手动添加

### 脚本命令使用
1. **必须先start才能save** - 会话必须在活跃状态下
2. **需要手动添加内容** - 使用add-content等命令记录内容
3. **显式保存操作** - 需要手动调用save命令
4. **文件命名规则** - 格式：`YYYYMMDD-主题描述.md`

## 📁 文件位置

- 协作文档：`docs/collaboration/`
- 索引文件：`docs/collaboration/index.md`
- 管理脚本：`.specify/scripts/bash/collaboration-session-automation.sh`
- 斜杠命令：`.claude/commands/collaborate.md` 和 `.claude/commands/save.md`

## 🚀 最佳实践

### 新手用户（推荐）
1. **使用斜杠命令** - `/collaborate` 开始，`/save` 结束
2. **专注讨论内容** - 让AI自动记录和整理
3. **简洁主题命名** - 便于后续查找和管理
4. **及时保存** - 讨论完成后立即使用 `/save`

### 高级用户
1. **脚本精细控制** - 使用脚本命令精确控制内容记录
2. **内容分类管理** - 使用add-content/add-insight等分类记录
3. **批量操作** - 适合处理大量协作会话
4. **定期检查索引** - 确保所有会话都正确索引

## 🔄 新功能亮点

### /save 命令的优势
- ✅ **一键保存** - 无需记忆复杂的脚本命令
- ✅ **智能检测** - 自动检查活跃会话状态
- ✅ **完整文档** - 生成标准格式的协作文档
- ✅ **自动索引** - 更新协作会话索引
- ✅ **友好反馈** - 提供清晰的成功/错误信息

---

*最后更新: 2025-10-06 18:50*
*新增功能: /save 斜杠命令*
*协作系统版本: v1.0*