#!/bin/bash

echo "=== Rust Skills Frontmatter 检查 ==="
echo ""

total=0
issues=0

find skills -name "SKILL.md" | sort | while read file; do
    total=$((total + 1))
    skill_name=$(basename $(dirname "$file"))

    has_issue=false

    # 提取 frontmatter
    frontmatter=$(sed -n '/^---$/,/^---$/p' "$file" | head -n -1 | tail -n +2)

    # 检查 description
    desc=$(echo "$frontmatter" | grep -A 100 "^description:" | sed '/^name:/q' | grep -v "^name:" | grep -v "^description:")

    # 检查是否包含中文
    if echo "$desc" | grep -P '[\p{Han}]' > /dev/null 2>&1; then
        echo "⚠️  $skill_name - Description contains Chinese"
        has_issue=true
    fi

    # 检查描述长度（中文字符算2个）
    desc_clean=$(echo "$desc" | tr -d '\n' | sed 's/^[ \t]*//;s/[ \t]*$//')
    desc_len=${#desc_clean}
    if [ $desc_len -gt 200 ]; then
        echo "⚠️  $skill_name - Description too long ($desc_len chars)"
        has_issue=true
    fi

    # 检查是否有 triggers 字段
    if ! echo "$frontmatter" | grep -q "^triggers:"; then
        if echo "$desc" | grep -q "触发词"; then
            echo "⚠️  $skill_name - Triggers mixed in description"
            has_issue=true
        fi
    fi

    # 检查是否有引号包裹（单行描述）
    if echo "$frontmatter" | grep "^description:" | grep -q '"'; then
        : # OK
    elif echo "$frontmatter" | grep "^description:" | grep -q "|"; then
        : # OK
    else
        if [ $(echo "$desc" | wc -l) -eq 1 ]; then
            echo "⚠️  $skill_name - Single-line description should use quotes"
            has_issue=true
        fi
    fi

    if [ "$has_issue" = true ]; then
        issues=$((issues + 1))
    fi
done

echo ""
echo "=== 总结 ==="
echo "检查文件数: $total"
echo "发现问题数: $issues"
