#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
协作会话索引更新工具
安全地处理多行内容和特殊字符
"""

import os
import re
import glob
from datetime import datetime

def update_collaboration_index():
    """更新协作会话索引文件"""

    collaboration_dir = "docs/collaboration"
    index_file = os.path.join(collaboration_dir, "index.md")

    # 扫描所有的协作文档
    session_list = []

    for file_path in glob.glob(os.path.join(collaboration_dir, "*.md")):
        filename = os.path.basename(file_path)

        # 跳过索引文件和README
        if filename in ["index.md", "README.md"]:
            continue

        # 解析文件名
        basename = filename.replace(".md", "")
        parts = basename.split("-", 2)

        if len(parts) >= 2:
            file_date = parts[0]
            topic = parts[2] if len(parts) > 2 else "未命名主题"
            topic = topic.rstrip("-")  # 移除末尾的短横线
        else:
            continue

        # 读取文件内容提取元信息
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            # 提取协作范式
            paradigm_match = re.search(r'\*\*协作范式\*\*: (.+?) \(', content)
            paradigm = paradigm_match.group(1) if paradigm_match else "未知范式"

            # 提取关键洞察
            insights = []
            insight_section = re.search(r'## 关键洞察\n\n(.+?)\n\n##', content, re.DOTALL)
            if insight_section:
                insight_lines = insight_section.group(1).strip().split('\n')
                insights = [line.strip() for line in insight_lines if line.strip().startswith('-')]

            # 格式化会话条目
            session_entry = f"""#### [{basename}]({basename}.md)

**协作范式**: {paradigm}
**主题**: {topic}
**核心洞察**:
{chr(10).join(insights[:3]) if insights else '- 暂无记录'}

---

"""
            session_list.append((file_date, session_entry))

        except Exception as e:
            print(f"处理文件 {filename} 时出错: {e}")
            continue

    # 按日期排序
    session_list.sort(key=lambda x: x[0], reverse=True)

    # 生成会话列表内容
    session_content = ""
    current_date_group = ""

    for date, entry in session_list:
        # 格式化日期显示
        if len(date) == 8:
            try:
                formatted_date = datetime.strptime(date, "%Y%m%d").strftime("%Y-%m-%d")
            except:
                formatted_date = date
        else:
            formatted_date = date

        # 按日期分组
        if formatted_date != current_date_group:
            if current_date_group:
                session_content += "\n"
            session_content += f"### {formatted_date}\n\n"
            current_date_group = formatted_date

        session_content += entry

    # 读取索引模板
    try:
        with open(index_file, 'r', encoding='utf-8') as f:
            index_template = f.read()
    except FileNotFoundError:
        print(f"索引文件 {index_file} 不存在")
        return False

    # 更新索引内容
    updated_index = re.sub(
        r'## 会话列表\n\n.*?---\n\n',
        f'## 会话列表\n\n{session_content}---\n\n',
        index_template,
        flags=re.DOTALL
    )

    # 更新最后更新时间
    update_time = datetime.now().strftime("%Y-%m-%d %H:%M")
    updated_index = re.sub(
        r'\*最后更新: .*?\*',
        f'*最后更新: {update_time}*',
        updated_index
    )

    # 写入更新后的索引
    try:
        with open(index_file, 'w', encoding='utf-8') as f:
            f.write(updated_index)
        print(f"✅ 索引文件已更新 - {update_time}")
        return True
    except Exception as e:
        print(f"写入索引文件时出错: {e}")
        return False

if __name__ == "__main__":
    update_collaboration_index()