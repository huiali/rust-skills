#!/bin/bash

echo "=== Rust Skills 结构检查 ==="
echo ""

REQUIRED_SECTIONS=(
    "Core Question"
    "Review Checklist"
    "Verification Commands"
    "Related Skills"
)

total=0
missing_count=0

find skills -name "SKILL.md" | sort | while read file; do
    total=$((total + 1))
    skill_name=$(basename $(dirname "$file"))

    missing=()
    for section in "${REQUIRED_SECTIONS[@]}"; do
        if ! grep -qi "## $section" "$file"; then
            missing+=("$section")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo "⚠️  $skill_name"
        echo "    缺少: ${missing[*]}"
        echo ""
        missing_count=$((missing_count + 1))
    fi
done

echo "=== 总结 ==="
echo "检查文件数: $total"
echo "缺少标准章节: $missing_count"
