# 激活特定的AI协作范式来优化你的Claude Code交互体验

使用方法：
/collaborate [范式名称] [主题描述]

**自动化知识保存**：协作会话支持自动保存功能，使用内置的协作会话管理系统自动记录完整的讨论内容、关键洞察和行动要点到 `docs/collaboration/` 目录。

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

## 自动化工作流

### 完整的协作会话管理

```bash
# 1. 初始化协作环境（首次使用）
./.specify/scripts/bash/collaboration-session-automation.sh init

# 2. 开始新的协作会话
./.specify/scripts/bash/collaboration-session-automation.sh start first-principles "数据库性能优化分析"

# 3. 在协作过程中添加内容
./.specify/scripts/bash/collaboration-session-automation.sh add-content "讨论了索引策略和查询优化"
./.specify/scripts/bash/collaboration-session-automation.sh add-insight "索引是空间换时间的权衡"
./.specify/scripts/bash/collaboration-session-automation.sh add-output "完成了索引优化方案设计"

# 4. 查看当前会话状态
./.specify/scripts/bash/collaboration-session-automation.sh status

# 5. 保存会话并自动更新索引
./.specify/scripts/bash/collaboration-session-automation.sh save

# 6. 列出所有协作会话
./.specify/scripts/bash/collaboration-session-automation.sh list
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

### 快速启动工具

对于更便捷的协作体验，可以使用快速启动工具：

```bash
# 交互式选择范式和输入主题
./.specify/scripts/bash/collaboration-quick-start.sh

# 指定范式，交互式输入主题
./.specify/scripts/bash/collaboration-quick-start.sh first-principles

# 直接指定范式和主题
./.specify/scripts/bash/collaboration-quick-start.sh creative "新产品功能头脑风暴"
```

## 自动化功能特性

- **智能会话管理**：自动生成唯一会话ID和时间戳
- **结构化内容**：使用标准模板确保文档一致性
- **实时状态跟踪**：记录会话过程中的所有关键信息
- **自动索引更新**：保存后自动更新索引文件
- **模板化输出**：生成符合标准的协作文档格式
- **一键式操作**：支持快速启动和简化工作流

## 知识保存机制

所有协作会话将自动保存为结构化文档，包含：

1. **会话元信息**：时间、范式、参与者、主题
2. **范式说明**：所用协作范式的核心要点
3. **讨论内容**：完整的对话记录
4. **关键洞察**：提炼出的核心知识点
5. **产出成果**：具体的解决方案和决策
6. **行动要点**：后续执行的任务列表
7. **知识总结**：便于后续查阅的结构化总结

保存位置：`docs/collaboration/YYYYMMDD-主题描述.md`

索引文件：`docs/collaboration/index.md`

---

当你想要AI采用特定的协作方式并保存共创知识时，使用此命令。