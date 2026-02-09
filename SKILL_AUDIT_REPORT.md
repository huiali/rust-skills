# Rust Skills 规范化分析报告

> 检查所有技能文件是否符合 Claude Code skill 规范

---

## 执行总结

**检查范围：** 40+ 个 SKILL.md 文件
**符合规范：** 3 个 (rust-testing, rust-database, rust-observability)
**需要优化：** 37+ 个
**主要问题：** Frontmatter 格式不统一、内容语言混杂、结构不一致

---

## 一、规范标准

### Claude Code Skill 标准格式

```markdown
---
name: skill-name
description: "Clear, concise English description (1-2 sentences max)"
---

# Skill Title

## Core Question
The fundamental problem this skill addresses

## Solution Patterns
Key approaches and patterns

## Workflow
Step-by-step process

## Review Checklist
- [ ] Critical checks

## Common Pitfalls
What to avoid

## Verification Commands
```bash
# Commands to verify solutions
```

## Related Skills
Links to complementary skills
```

---

## 二、当前状态分析

### ✅ 符合规范的技能（3个）

#### 1. rust-testing
```yaml
---
name: rust-testing
description: "Rust testing expert for unit, integration, async, property-based, concurrency, and benchmark testing workflows."
---
```

**优点：**
- ✅ Frontmatter 简洁清晰
- ✅ 英文描述
- ✅ 标准章节结构
- ✅ 有 Core Question, Review Checklist
- ✅ 有 Verification Commands

#### 2. rust-database
```yaml
---
name: rust-database
description: "Rust database skill for SQLx/Diesel/SeaORM design, transaction boundaries, migration safety, query performance, and operational reliability."
---
```

**优点：**
- ✅ 描述清晰具体
- ✅ 英文格式
- ✅ 完整的标准章节

#### 3. rust-observability
```yaml
---
name: rust-observability
description: "Rust observability skill for tracing, metrics, structured logging, OpenTelemetry pipelines, and production incident diagnostics."
---
```

**优点：**
- ✅ 专业描述
- ✅ 标准格式

---

### ⚠️ 需要优化的技能（37+个）

#### 类型 A：Frontmatter 过于冗长

**示例：rust-web**

```yaml
---
name: rust-web
description: Rust Web 开发专家。处理 axum, actix, HTTP, REST, API, 数据库, 状态管理等问题。触发词：web,HTTP, REST, API, axum, actix, handler, database, web开发, 服务器, 路由
---
```

**问题：**
- ❌ 描述太长，包含太多细节
- ❌ 中文描述
- ❌ 混入触发词（应该单独字段）
- ❌ 没有使用引号包裹

**建议优化为：**

```yaml
---
name: rust-web
description: "Rust web development expert covering HTTP frameworks (axum, actix), REST API design, state management, and database integration."
triggers:
  - web
  - HTTP
  - REST
  - API
  - axum
  - actix
  - handler
---
```

#### 类型 B：内容全中文

**示例：rust-async**

```yaml
---
name: rust-async
description: 高级异步模式专家。处理 Stream, backpressure, select, join, cancellation, Future
  trait 等问题。触发词：async, Stream, backpressure, select, Future, tokio, async-std, 异步,
  流, 取消
---

# 高级异步模式

## 核心问题

**如何在异步代码中正确处理流、控制和资源？**
```

**问题：**
- ❌ 描述和内容都是中文
- ❌ 缺少标准化章节
- ❌ 没有 Review Checklist

**建议：** 改为英文或双语布局

#### 类型 C：缺少标准化章节

**示例：rust-ownership**

```yaml
---
name: rust-ownership
description: 所有权、借用、生命周期专家。处理 E0382, E0597, E0506, E0507, E0515, E0716, E0106 等错误。触发词：ownership,
  borrow, lifetime, move, clone, Copy, 所有权, 借用, 生命周期
---

# 所有权与生命周期专家

## 核心信条

**每个值都有一个明确的主人**

## 常见问题模式
...
```

**问题：**
- ❌ 缺少 Core Question
- ❌ 缺少 Review Checklist
- ❌ 缺少 Verification Commands
- ❌ 缺少 Related Skills

---

## 三、统一规范建议

### 1. Frontmatter 标准格式

```yaml
---
name: skill-name
description: |
  Single-line English description that clearly states what the skill does.
  Max 2 sentences. Focus on capabilities, not implementation.
triggers:
  - keyword1
  - keyword2
  - keyword3
---
```

**要求：**
- `name`: 技能名称，小写，用连字符分隔
- `description`: 简洁的英文描述，1-2 句话
  - 用双引号包裹（单行）或管道符（多行）
  - 说明核心能力，不要列举太多细节
- `triggers`: 可选，单独的触发关键词列表

### 2. 内容结构标准

#### 必需章节（按顺序）

```markdown
## Core Question
一句话说明这个技能要解决的核心问题

## Solution Patterns / 解决方案模式
核心方法和模式

## Workflow / 工作流程
解决问题的步骤

## Review Checklist / 审查清单
- [ ] 关键检查点1
- [ ] 关键检查点2

## Common Pitfalls / 常见陷阱
要避免的错误

## Verification Commands / 验证命令
```bash
# 验证解决方案的命令
cargo test
cargo clippy
```

## Related Skills / 相关技能
- `skill-name-1`
- `skill-name-2`
```

#### 可选章节

```markdown
## Examples / 示例
实际代码示例

## Best Practices / 最佳实践
推荐做法

## Troubleshooting / 故障排除
常见问题解决
```

### 3. 双语布局建议

对于已有中文内容的技能，建议采用**英文主体 + 中文补充**的方式：

#### 方案 A：英文 SKILL.md + 中文 SKILL_ZH.md

```
skills/rust-ownership/
├── SKILL.md        # 英文版（主文件）
└── SKILL_ZH.md     # 中文版（可选）
```

**SKILL.md (English)**
```markdown
---
name: rust-ownership
description: "Ownership, borrowing, and lifetime expert. Handles E0382, E0597, E0506 and related compiler errors."
---

# Ownership & Lifetime Expert

## Core Question

**Who owns this data and for how long?**

## Solution Patterns
...

## Localized Reference
- Chinese version: [SKILL_ZH.md](./SKILL_ZH.md)
```

#### 方案 B：单文件双语

```markdown
---
name: rust-ownership
description: "Ownership, borrowing, and lifetime expert. Handles E0382, E0597, E0506 and related compiler errors."
---

# Ownership & Lifetime Expert
# 所有权与生命周期专家

[English](#english) | [中文](#中文)

## <a name="english"></a>English

### Core Question
...

---

## <a name="中文"></a>中文

### 核心问题
...
```

**推荐：方案 A（更清晰）**

---

## 四、优化优先级

### P0 - 立即优化（影响 Claude Code 识别）

修复 Frontmatter 格式问题：

| 技能 | 当前问题 | 优化方案 |
|-----|---------|---------|
| rust-web | 描述过长、中文 | 简化为英文 |
| rust-async | 描述过长、中文 | 简化为英文 |
| rust-performance | 描述过长、中文 | 简化为英文 |
| rust-ownership | 描述过长、中文 | 简化为英文 |
| rust-concurrency | 描述过长、中文 | 简化为英文 |
| ... | ... | ... |

**批量修复脚本：**

```bash
# 见下一节
```

### P1 - 重要优化（提升一致性）

添加缺失的标准章节：

- [ ] 所有技能添加 Core Question
- [ ] 所有技能添加 Review Checklist
- [ ] 所有技能添加 Verification Commands
- [ ] 所有技能添加 Related Skills

### P2 - 建议优化（提升质量）

内容改进：

- [ ] 添加更多代码示例
- [ ] 增加常见错误处理
- [ ] 补充最佳实践
- [ ] 添加性能提示

---

## 五、批量优化工具

### 1. Frontmatter 检查脚本

创建 `scripts/check-frontmatter.sh`：

```bash
#!/bin/bash

echo "检查所有 SKILL.md 的 frontmatter..."

find skills -name "SKILL.md" | while read file; do
    skill_name=$(basename $(dirname "$file"))

    # 提取 description
    desc=$(sed -n '/^description:/,/^---$/p' "$file" | grep -v '^---$' | grep -v '^description:')

    # 检查是否包含中文
    if echo "$desc" | grep -P '[\p{Han}]' > /dev/null; then
        echo "⚠️  $skill_name - 描述包含中文"
    fi

    # 检查描述长度
    desc_len=$(echo "$desc" | wc -c)
    if [ $desc_len -gt 200 ]; then
        echo "⚠️  $skill_name - 描述过长 ($desc_len 字符)"
    fi
done
```

### 2. 章节检查脚本

创建 `scripts/check-structure.sh`：

```bash
#!/bin/bash

REQUIRED_SECTIONS=(
    "Core Question"
    "Review Checklist"
    "Verification Commands"
    "Related Skills"
)

find skills -name "SKILL.md" | while read file; do
    skill_name=$(basename $(dirname "$file"))

    missing=()
    for section in "${REQUIRED_SECTIONS[@]}"; do
        if ! grep -q "## $section" "$file"; then
            missing+=("$section")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo "⚠️  $skill_name 缺少章节: ${missing[*]}"
    fi
done
```

### 3. 自动优化脚本模板

创建 `scripts/optimize-skill-template.sh`：

```bash
#!/bin/bash

# 用法: ./optimize-skill-template.sh rust-web

SKILL_NAME=$1
SKILL_DIR="skills/$SKILL_NAME"
SKILL_FILE="$SKILL_DIR/SKILL.md"

if [ ! -f "$SKILL_FILE" ]; then
    echo "错误: 找不到 $SKILL_FILE"
    exit 1
fi

# 备份原文件
cp "$SKILL_FILE" "$SKILL_FILE.bak"

# 读取原 description
OLD_DESC=$(sed -n '/^description:/,/^---$/p' "$SKILL_FILE" | grep -v '^---$' | grep -v '^description:')

echo "原描述:"
echo "$OLD_DESC"
echo ""
echo "请提供新的英文描述（按 Ctrl+D 结束）:"
NEW_DESC=$(cat)

# 生成新的 frontmatter
cat > /tmp/new-frontmatter << EOF
---
name: $SKILL_NAME
description: "$NEW_DESC"
---
EOF

# 替换 frontmatter（需要手动验证）
echo "新的 frontmatter 已生成在 /tmp/new-frontmatter"
echo "请手动验证并更新文件"
```

---

## 六、推荐行动方案

### 阶段 1: 修复 Frontmatter（1-2天）

1. 运行检查脚本识别问题
2. 为每个技能编写简洁的英文描述
3. 统一格式为标准格式

### 阶段 2: 补充标准章节（3-5天）

1. 为每个技能添加 Core Question
2. 为每个技能添加 Review Checklist
3. 为每个技能添加 Verification Commands
4. 为每个技能添加 Related Skills

### 阶段 3: 双语化（可选，1-2周）

1. 将现有中文技能改为英文主体
2. 保留中文为 SKILL_ZH.md
3. 在英文版添加链接

---

## 七、示例对比

### Before（rust-web）

```yaml
---
name: rust-web
description: Rust Web 开发专家。处理 axum, actix, HTTP, REST, API, 数据库, 状态管理等问题。触发词：web,HTTP, REST, API, axum, actix, handler, database, web开发, 服务器, 路由
---

# Rust Web 开发

## 主流框架选择
...
```

### After（优化版）

```yaml
---
name: rust-web
description: |
  Rust web development expert covering HTTP frameworks (axum, actix), REST API design,
  state management, middleware patterns, and database integration.
triggers:
  - web
  - HTTP
  - REST
  - API
  - axum
  - actix
  - handler
---

# Rust Web Development Skill

## Core Question

**How do we build reliable, performant web services in Rust?**

## Solution Patterns

- Use axum/actix-web for modern async HTTP handling
- Design clean handler signatures with extractors
- Implement proper error handling with IntoResponse
- Manage shared state with Arc<AppState>
- Structure projects by domain for maintainability

## Workflow

1. Choose framework based on requirements (axum for type safety, actix for performance)
2. Design handler signatures and routing
3. Implement state management and dependency injection
4. Add middleware (CORS, logging, auth)
5. Integrate database and caching layers
6. Write integration tests

## Review Checklist

- [ ] Error handling uses custom types and IntoResponse
- [ ] Shared state uses Arc for thread safety
- [ ] Middleware is composable and reusable
- [ ] Database connections use connection pooling
- [ ] Handlers are async and non-blocking
- [ ] API responses follow consistent format

## Common Pitfalls

- Using Rc instead of Arc for shared state (not thread-safe)
- Holding locks across await points (potential deadlock)
- Not setting request body size limits
- Missing proper CORS configuration
- Not using tracing for request logging

## Verification Commands

```bash
cargo check
cargo test --test integration
cargo clippy -- -D warnings
cargo run
```

## Related Skills

- `rust-async` - Advanced async patterns
- `rust-database` - Database integration
- `rust-auth` - Authentication and authorization
- `rust-middleware` - Middleware patterns
- `rust-observability` - Logging and metrics
- `rust-error-advanced` - Advanced error handling

## Localized Reference

- Chinese version: [SKILL_ZH.md](./SKILL_ZH.md)
```

---

## 八、总结

### 关键改进点

1. **Frontmatter 简化** - 从冗长混杂到简洁清晰
2. **标准章节** - 添加 Core Question、Review Checklist 等
3. **语言统一** - 英文为主，中文为辅
4. **结构一致** - 所有技能遵循相同格式

### 预期收益

- ✅ Claude Code 更准确地识别和路由技能
- ✅ 提升技能系统的专业性
- ✅ 便于维护和扩展
- ✅ 更好的国际化支持

### 下一步建议

1. **立即执行**：运行检查脚本，了解当前状态
2. **优先修复**：修复 3-5 个最常用的技能作为模板
3. **批量优化**：按照模板优化其余技能
4. **持续改进**：新技能严格遵循规范

---

## 附录：完整检查清单

```bash
# 运行所有检查
./scripts/check-frontmatter.sh > report-frontmatter.txt
./scripts/check-structure.sh > report-structure.txt

# 查看报告
cat report-frontmatter.txt
cat report-structure.txt
```

**需要帮助优化特定技能？告诉我技能名称，我可以帮你生成优化后的版本。**
