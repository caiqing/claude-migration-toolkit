#!/bin/bash

input=$(cat)

# 获取基本信息
MODEL=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // "Unknown"')
TRANSCRIPT_PATH=$(echo "$input" | jq -r '.transcript_path // ""')

# 获取Git分支信息
BRANCH=""
if git rev-parse --git-dir >/dev/null 2>&1; then
    BRANCH=" | 🌿 $(git branch --show-current 2>/dev/null)"
fi

# 从transcript文件中获取最新的token使用量
TOKENS_USED=0
if [[ -n "$TRANSCRIPT_PATH" ]] && [[ -f "$TRANSCRIPT_PATH" ]]; then
    # 获取最后一个包含usage字段的行
    LAST_USAGE_LINE=$(grep '"usage"' "$TRANSCRIPT_PATH" | tail -1)
    if [[ -n "$LAST_USAGE_LINE" ]]; then
        # 从JSON中提取token信息 - usage字段在message下
        INPUT_TOKENS=$(echo "$LAST_USAGE_LINE" | jq -r '.message.usage.input_tokens // 0' 2>/dev/null || echo "0")
        OUTPUT_TOKENS=$(echo "$LAST_USAGE_LINE" | jq -r '.message.usage.output_tokens // 0' 2>/dev/null || echo "0")
        CACHE_TOKENS=$(echo "$LAST_USAGE_LINE" | jq -r '.message.usage.cache_read_input_tokens // 0' 2>/dev/null || echo "0")

        # 计算总token数 (包含缓存)
        TOKENS_USED=$((INPUT_TOKENS + OUTPUT_TOKENS + CACHE_TOKENS))
    fi
fi

# 如果没有从transcript获取到token，检查exceeds_200k_tokens字段
if [[ $TOKENS_USED -eq 0 ]]; then
    EXCEEDS_TOKENS=$(echo "$input" | jq -r '.exceeds_200k_tokens // false')
    if [[ "$EXCEEDS_TOKENS" == "true" ]]; then
        TOKENS_USED=200000  # 如果超过了200k，显示为200k
    fi
fi

# 根据模型设置最大token数
MAX_TOKENS=200000
if [[ "$MODEL" == *"GPT-4"* ]] || [[ "$MODEL" == *"gpt-4"* ]]; then
    MAX_TOKENS=128000
elif [[ "$MODEL" == *"Claude"* ]] || [[ "$MODEL" == *"claude"* ]] || [[ "$MODEL" == *"glm"* ]]; then
    MAX_TOKENS=200000
fi

# 计算百分比
PERCENTAGE=$(echo "scale=1; $TOKENS_USED * 100 / $MAX_TOKENS" | bc 2>/dev/null || echo "0")

# 获取目录名
DIR_NAME=$(basename "$DIR")

# 输出状态栏内容
echo "[$MODEL] 📁 $DIR_NAME$BRANCH | 📊 上下文: ${PERCENTAGE}% ($TOKENS_USED/$MAX_TOKENS)"