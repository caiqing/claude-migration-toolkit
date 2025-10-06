# 激活特定的AI协作范式来优化你的Claude Code交互体验

使用方法：
/collaborate [范式名称] [主题描述]

**🚀 全新增强版本**：现在支持一键式协作会话启动和自动对话记录！

**核心特性**：

- **一键启动**：自动创建协作会话并开始记录
- **智能捕获**：自动记录所有用户输入和AI回复
- **实时状态**：持续跟踪会话进度和消息数量
- **智能总结**：基于实际对话内容生成AI分析总结
- **关键词提取**：自动识别技术术语和核心概念
- **无缝切换**：支持会话中断后的自动恢复

**自动化工作流**：

- 会话开始时自动创建状态跟踪和文档模板
- **自动记录完整的用户-AI交互对话**
- 智能分析和总结协作内容
- 自动生成结构化Markdown文档
- 自动更新索引文件便于查阅

## 可用的协作范式

### 基础协作范式

- **creative** - 创意激发头脑风暴
- **critical** - 批判性思考分析
- **feynman** - 双向费曼学习法
- **first-principles** - 第一性原理思维分析
- **optimize** - 流程优化建议
- **progressive** - 渐进式沟通（从类比到深入）
- **smart** - SMART结构化表达
- **visual** - 可视化呈现（图表和流程图）

### 高级协作范式

- **ears** - EARS需求描述方法（事件、条件、行动、响应）
- **evolve** - 持续进化反馈
- **fusion** - 跨界知识融合
- **learning** - 个性化学习路径

## 🚀 简化的使用流程

### 基本用法（推荐）

```bash
# 1. 一键启动协作会话
/collaborate first-principles "数据库性能优化分析"

# 2. 进行正常的对话交互（系统自动记录）
# 用户：请用第一性原理分析数据库查询优化
# AI：让我们从基础原理开始分析...

# 3. 保存会话（一键完成所有文档工作）
/save
```

### 增强版工具（可选）

如需更多控制，可以使用增强版工具：

```bash
# 启动新的协作会话
./.specify/scripts/bash/collaboration-enhanced.sh start first-principles "数据库性能优化"

# 手动记录消息（可选，系统通常会自动处理）
./.specify/scripts/bash/collaboration-enhanced.sh message user "你的问题"
./.specify/scripts/bash/collaboration-enhanced.sh message assistant "AI的回复"

# 查看当前会话状态
./.specify/scripts/bash/collaboration-enhanced.sh status

# 保存会话
./.specify/scripts/bash/collaboration-enhanced.sh save

# 列出所有协作会话
./.specify/scripts/bash/collaboration-enhanced.sh list
```

### 使用示例

```bash
# 基础用法
/collaborate creative - 激发创意思维和头脑风暴
/collaborate critical - 进行批判性思考分析

# 带主题描述
/collaborate first-principles "分析数据库性能优化的本质"
/collaborate visual "设计微服务架构图"
/collaborate optimize "改进CI/CD流程效率"

# 高级范式
/collaborate ears "将用户登录需求转换为EARS格式"
/collaborate fusion "结合AI和区块链技术设计解决方案"
```

### 新增功能特性

#### 🤖 智能会话管理

- **自动会话检测**：系统自动识别是否已有活跃会话
- **会话恢复机制**：支持中断后的会话继续
- **智能状态跟踪**：实时显示会话进度和统计信息
- **冲突处理**：提供多种会话切换选项

#### 📊 增强的分析功能

- **对话统计分析**：消息数量、内容规模、会话时长
- **协作范式应用分析**：评估所选用协作范式的效果
- **核心内容概要**：基于实际内容提炼主要议题
- **关键洞察提炼**：自动识别重要观点和结论
- **协作价值评估**：从知识深度、实践指导、创新思维三个维度评估
- **后续建议**：基于协作内容提供个性化建议

#### 🔤 智能关键词提取

- **技术关键词**：自动识别技术术语和概念
- **通用概念关键词**：提取方法论和流程相关词汇
- **协作范式关键词**：标记使用的协作范式
- **词频统计**：生成词频统计和关键词云

## 知识保存机制

所有协作会话将自动保存为结构化文档，包含：

1. **会话元信息**：时间、范式、参与者、主题
2. **范式说明**：所用协作范式的核心要点
3. **完整对话记录**：所有用户消息和AI回复的完整记录
4. **关键洞察**：提炼出的核心知识点
5. **产出成果**：具体的解决方案和决策
6. **AI智能总结**：基于实际内容生成的智能分析总结
7. **关键词提取**：自动提取的关键技术词汇和概念
8. **行动要点**：后续执行的任务列表

保存位置：`docs/collaboration/YYYYMMDD-主题描述.md`

索引文件：`docs/collaboration/index.md`

---

当你想要AI采用特定的协作方式并保存共创知识时，使用此命令。