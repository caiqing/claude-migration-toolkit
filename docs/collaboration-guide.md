# AI协作系统使用指南

## 概述

AI协作系统是一套完整的知识管理和协作框架，支持多种协作范式，提供自动化的会话管理和知识保存功能。

## 核心特性

### 🤖 多种协作范式
- **第一性原理思维** - 深度分析技术本质
- **渐进式沟通** - 从类比到深入的理解过程
- **可视化呈现** - 通过图表直观展示复杂概念
- **创意激发** - 头脑风暴和创新思维
- **批判性思考** - 深度分析和质疑
- **双向费曼学习** - 互相提问检验理解
- **SMART结构化表达** - 清晰的沟通和表达
- **流程优化** - 工作流程分析和改进
- **EARS需求描述** - 标准化的需求表达
- **持续进化反馈** - 迭代改进机制
- **跨界知识融合** - 多领域知识整合
- **个性化学习** - 定制化学习路径

### 📁 自动化知识管理
- 智能会话创建和跟踪
- 结构化文档生成
- 自动索引更新
- 模板化内容组织

## 快速开始

### 1. 环境初始化

首次使用需要初始化协作环境：

```bash
# 运行初始化脚本
./.specify/scripts/bash/collaboration-session-automation.sh init
```

这将创建：
- `docs/collaboration/` 目录
- 协作会话模板
- 基础索引文件

### 2. 快速启动协作会话

使用快速启动工具：

```bash
# 交互式启动
./.specify/scripts/bash/collaboration-quick-start.sh

# 指定范式启动
./.specify/scripts/bash/collaboration-quick-start.sh first-principles

# 指定范式和主题
./.specify/scripts/bash/collaboration-quick-start.sh creative "新产品功能头脑风暴"
```

### 3. 使用Claude Code命令

直接在Claude Code中使用：

```bash
# 激活协作范式
/collaborate first-principles "分析Claude Code自定义commands的技术原理"
```

## 详细使用指南

### 协作会话生命周期

#### 1. 会话开始
```bash
./.specify/scripts/bash/collaboration-session-automation.sh start <范式> <主题>
```

**示例**：
```bash
./.specify/scripts/bash/collaboration-session-automation.sh start first-principles "数据库性能优化分析"
```

#### 2. 内容记录
在协作过程中，可以实时记录不同类型的信息：

```bash
# 添加讨论内容
./.specify/scripts/bash/collaboration-session-automation.sh add-content "讨论了B+树索引的内部结构"

# 添加关键洞察
./.specify/scripts/bash/collaboration-session-automation.sh add-insight "索引优化的本质是空间换时间的权衡"

# 添加产出成果
./.specify/scripts/bash/collaboration-session-automation.sh add-output "完成了索引优化方案设计"

# 添加行动要点
./.specify/scripts/bash/collaboration-session-automation.sh add-action "实施索引监控和性能测试"
```

#### 3. 状态查看
```bash
./.specify/scripts/bash/collaboration-session-automation.sh status
```

#### 4. 会话保存
```bash
./.specify/scripts/bash/collaboration-session-automation.sh save
```

保存后：
- 自动生成结构化文档
- 更新索引文件
- 清理临时状态文件

### 高级功能

#### 批量内容添加
```bash
# 添加多行内容
./.specify/scripts/bash/collaboration-session-automation.sh add-content "第一点内容
第二点内容
第三点内容"
```

#### 会话管理
```bash
# 列出所有会话
./.specify/scripts/bash/collaboration-session-automation.sh list

# 手动更新索引
./.specify/scripts/bash/collaboration-session-automation.sh update-index
```

## 协作范式详解

### 基础协作范式

#### creative - 创意激发头脑风暴
- **适用场景**：需要创新思维和多元化观点
- **使用技巧**：
  - 提出开放性问题
  - 鼓励非常规想法
  - 使用联想和类比思维

#### critical - 批判性思考分析
- **适用场景**：需要深入分析和风险评估
- **使用技巧**：
  - 主动质疑假设
  - 寻找潜在问题
  - 考虑替代方案

#### feynman - 双向费曼学习法
- **适用场景**：需要深入理解复杂概念
- **使用技巧**：
  - 用简单语言解释概念
  - 互相提问检验理解
  - 识别知识盲点

#### first-principles - 第一性原理思维
- **适用场景**：需要从本质出发解决问题
- **使用技巧**：
  - 追问最基础的原理
  - 质疑传统做法
  - 重新构建解决方案

#### optimize - 流程优化
- **适用场景**：改进现有工作流程
- **使用技巧**：
  - 识别瓶颈环节
  - 分析效率问题
  - 提出改进建议

#### progressive - 渐进式沟通
- **适用场景**：需要层次化理解复杂主题
- **使用技巧**：
  - 从简单类比开始
  - 逐步深入细节
  - 确保理解同步

#### smart - SMART结构化表达
- **适用场景**：需要明确目标和行动计划
- **使用技巧**：
  - 设定具体目标
  - 确保可衡量性
  - 明确时间期限

#### visual - 可视化呈现
- **适用场景**：需要将复杂概念可视化
- **使用技巧**：
  - 请求创建各种图表
  - 使用Mermaid语法
  - 将抽象概念具体化

### 高级协作范式

#### ears - EARS需求描述
- **适用场景**：精确描述软件需求
- **格式**：事件(Event)、条件(Action)、行动(Action)、响应(Response)

#### evolve - 持续进化
- **适用场景**：需要迭代改进的长期项目
- **使用技巧**：
  - 定期反馈和调整
  - 跟踪进展和变化
  - 持续学习和优化

#### fusion - 跨界融合
- **适用场景**：结合多个领域知识创新
- **使用技巧**：
  - 识别跨领域联系
  - 整合不同方法论
  - 创造新解决方案

#### learning - 个性化学习
- **适用场景**：定制化学习路径规划
- **使用技巧**：
  - 评估当前能力
  - 设定学习目标
  - 规划学习步骤

## 文档结构

### 协作会话文档结构

每个协作文档包含以下标准化结构：

1. **会话元信息**
   - 会话ID
   - 时间戳
   - 协作范式
   - 参与者
   - 主题

2. **范式说明**
   - 所用范式的核心要点
   - 适用场景说明

3. **讨论内容**
   - 完整的对话记录
   - 分析过程

4. **关键洞察**
   - 提炼的核心知识点
   - 重要发现

5. **产出成果**
   - 具体解决方案
   - 架构图、代码等

6. **行动要点**
   - 后续执行任务
   - 实施建议

7. **知识总结**
   - 结构化总结
   - 价值意义

### 文件命名规范

- **格式**: `YYYYMMDD-主题描述.md`
- **示例**: `20251006-Claude-Code自定义Commands技术原理分析.md`
- **位置**: `docs/collaboration/`

## 最佳实践

### 1. 协作前准备
- 明确协作目标和主题
- 选择合适的协作范式
- 准备相关背景资料

### 2. 协作过程中
- 及时记录关键讨论内容
- 提炼和总结重要洞察
- 明确具体产出和行动要点

### 3. 协作后管理
- 及时保存会话记录
- 定期回顾和整理知识库
- 分享有价值的协作成果

### 4. 持续改进
- 根据使用效果调整协作范式
- 优化会话管理流程
- 完善知识组织结构

## 故障排除

### 常见问题

#### 1. 权限问题
```bash
chmod +x .specify/scripts/bash/collaboration-*.sh
```

#### 2. 目录不存在
```bash
./.specify/scripts/bash/collaboration-session-automation.sh init
```

#### 3. 会话状态丢失
检查 `.collaboration-session.state` 文件是否存在，如丢失需要重新开始会话。

#### 4. 文件命名冲突
系统会自动处理文件名冲突，确保每次会话都有唯一的文件名。

### 调试模式

如果遇到问题，可以查看详细错误信息：
```bash
bash -x .specify/scripts/bash/collaboration-session-automation.sh <command>
```

## 扩展和定制

### 添加新的协作范式

1. 在 `collaboration-session-automation.sh` 中的 `get_paradigm_info` 函数添加新范式
2. 更新 `.claude/commands/collaborate.md` 中的范式列表
3. 创建相应的使用示例和模板

### 自定义文档模板

修改 `.specify/templates/collaboration-session-template.md` 文件来自定义文档结构。

### 集成其他工具

可以在会话保存脚本中集成其他工具，如：
- 自动发送通知
- 集成项目管理工具
- 生成报告等

## 总结

AI协作系统提供了完整的协作会话管理解决方案，通过标准化的流程和自动化的工具，帮助用户更好地进行知识协作和管理。通过合理使用不同的协作范式，可以显著提升协作效率和知识产出质量。

---

*更多帮助请参考：*
- *协作会话索引：`docs/collaboration/index.md`*
- *快速启动工具：`./.specify/scripts/bash/collaboration-quick-start.sh`*
- *完整管理工具：`./.specify/scripts/bash/collaboration-session-automation.sh`*

*更新时间：2025-10-06*