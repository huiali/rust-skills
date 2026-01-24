# Rust Skill 使用指南

> 如何在 AI 编程工具中使用 Rust Skill 系统

---

## 简介

Rust Skill 是一个 AI 专家技能系统，专为 Rust 编程设计。它将 Rust 知识拆分为 **35 个子技能**，覆盖从入门到专家的全部领域。

**核心价值**：让 AI 在回答 Rust 相关问题时，能够调用对应领域的专业知识，提供更精准的解答。

---

## 支持的 AI 工具

| 工具 | 支持情况 | 配置方式 |
|-----|---------|---------|
| **Cursor** | ✅ 原生支持 | MCP 配置 |
| **Claude Code** | ✅ 支持 | MCP 配置 |
| **GitHub Copilot** | ⚠️ 有限支持 | 手动参考 |
| **其他 Agent** | ✅ 支持 | 直接引用 |

---

## 快速开始

### 方式一：Cursor + MCP（推荐）

#### 1. 配置 Cursor Rules

在项目根目录创建 `.cursor/rules.md` 文件：

```markdown
# Rust Skill Rules

当遇到 Rust 编程问题时，AI 应自动匹配对应技能：
- 所有权/生命周期错误 → `rust-ownership`
- 并发/异步 → `rust-concurrency`
- 错误处理 → `rust-error`
- unsafe/FFI → `rust-unsafe`
- 性能优化 → `rust-performance`
- Redis 缓存 → `rust-cache`
- JWT 认证 → `rust-auth`
- 中间件 → `rust-middleware`
- 策略引擎 → `rust-xacml`

技能定义：`skills/*/SKILL.md`
```

#### 2. 配置 MCP

在项目根目录创建 `.cursor/mcp.json` 文件：

```json
{
  "mcpServers": {
    "rust-skill": {
      "command": "builtin",
      "description": "Rust Skill 系统"
    }
  }
}
```

> **配置说明**：
> - `.cursor/rules.md` - Cursor 规则文件
> - `.cursor/mcp.json` - MCP 配置文件
> - `skills/` 和 `references/` - 项目核心内容，无需移动

#### 3. 重启 Cursor

配置完成后，Cursor 会自动加载技能系统。

#### 3. 使用技能

直接在对话中描述问题，系统会自动路由到对应技能：

```
"如何修复 E0382 借用检查器错误？"
→ 自动触发 rust-ownership

"tokio::spawn 需要 'static 但我有借用数据"
→ 自动触发 rust-concurrency

"如何实现 Redis 缓存管理？"
→ 自动触发 rust-cache
```

---

### 方式二：直接引用

如果 AI 工具不支持 MCP，可以直接告诉它技能文件的位置：

```
请参考 D:/space/rust-skill/skills/ 目录下的技能文件，
特别是 rust-ownership/SKILL.md 和 rust-concurrency/SKILL.md。
```

---

## 技能触发方式

### 自动触发

描述问题时包含触发词，AI 会自动匹配对应技能：

| 问题示例 | 触发技能 |
|---------|---------|
| "所有权转移后原变量还能用吗？" | rust-ownership |
| "Cell 和 RefCell 有什么区别？" | rust-mutability |
| "Mutex 和 RwLock 怎么选？" | rust-concurrency |
| "Result 和 Option 怎么处理？" | rust-error |
| "async Stream 怎么实现？" | rust-async |
| "unsafe 代码要注意什么？" | rust-unsafe |
| "如何调用 C++ 库？" | rust-ffi |
| "no_std 环境怎么开发？" | rust-embedded |
| "Redis 缓存怎么设计？" | rust-cache |
| "JWT 认证怎么做？" | rust-auth |

### 手动指定

如果自动匹配不准确，可以明确指定技能：

```
请使用 rust-ownership 技能回答：
" Rc 和 Arc 有什么区别？ "
```

---

## 技能分类速查

### Core Skills（核心技能 - 日常必用）

| 技能 | 描述 | 适用场景 |
|-----|------|---------|
| rust-ownership | 所有权与生命周期 | 借用检查错误、内存安全 |
| rust-mutability | 可变性深入 | Cell、RefCell 选择 |
| rust-concurrency | 并发与异步 | 线程、通道、tokio |
| rust-error | 错误处理 | Result、Option 处理 |

### Advanced Skills（进阶技能 - 深入理解）

| 技能 | 描述 | 适用场景 |
|-----|------|---------|
| rust-unsafe | 不安全代码 | FFI、原始指针 |
| rust-performance | 性能优化 | 基准测试、SIMD |
| rust-web | Web 开发 | axum、API 设计 |
| rust-cache | 缓存管理 | Redis、TTL 策略 |
| rust-auth | 认证授权 | JWT、API Key |
| rust-middleware | 中间件 | CORS、限流、日志 |
| rust-xacml | 策略引擎 | RBAC、权限决策 |

### Expert Skills（专家技能 - 疑难杂症）

| 技能 | 描述 | 适用场景 |
|-----|------|---------|
| rust-ffi | 跨语言互操作 | C/C++ 调用 |
| rust-embedded | 嵌入式开发 | no_std、WASM |
| rust-ebpf | 内核编程 | eBPF、Linux 内核 |
| rust-gpu | GPU 计算 | CUDA、并行计算 |

---

## 使用示例

### 示例 1：修复编译错误

**提问**：
```
error[E0382]: use of moved value: `value`
```

**AI 自动响应**：
→ 触发 rust-ownership 技能
→ 解释所有权转移规则
→ 提供解决方案（借用、克隆、Arc）

### 示例 2：性能优化

**提问**：
```
这个 HashMap 操作太慢了，怎么优化？
```

**AI 自动响应**：
→ 触发 rust-performance 技能
→ 分析数据结构选择
→ 建议并行化、SIMD 优化

### 示例 3：Web 开发

**提问**：
```
用 axum 写一个 REST API，需要认证和限流
```

**AI 自动响应**：
→ 触发 rust-web + rust-auth + rust-middleware
→ 提供完整代码模板
→ 包含 JWT 认证、中间件配置

---

## 项目结构

```
rust-skill/
├── .cursor/                  # Cursor 配置目录
│   ├── mcp.json             # MCP 配置文件
│   └── rules.md             # Cursor 规则文件
├── skills/                  # 技能目录（35 个子技能）
│   ├── rust-ownership/      # 所有权
│   ├── rust-concurrency/    # 并发
│   ├── rust-cache/          # 缓存
│   ├── rust-auth/           # 认证
│   ├── rust-middleware/     # 中间件
│   ├── rust-xacml/          # 策略引擎
│   └── ...                  # 更多技能
├── references/              # 参考资料
│   ├── best-practices/      # 最佳实践
│   ├── core-concepts/       # 核心概念
│   └── ecosystem/           # 生态 crate
├── scripts/                 # 工具脚本
├── USER_GUIDE.md            # 本使用指南
├── SKILL.md                 # 主入口
└── README.md                # 项目说明
```

---

## 常见问题

### Q1: AI 没有自动触发对应技能？

**A**: 尝试在问题中包含更多关键词，或直接指定技能：

```
请使用 rust-ownership 回答：Rc<T> 和 Arc<T> 的区别？
```

### Q2: 技能内容太详细，看不完？

**A**: 每个技能都有清晰的层级结构，可以直接跳转到需要的部分：

```markdown
## 核心模式    ← 先看这个
## 最佳实践    ← 然后看这个
## 常见问题    ← 遇到问题时查这个
```

### Q3: 需要添加新的技能？

**A**: 在 `skills/` 目录下创建新文件夹，添加 `SKILL.md` 文件即可。参考现有技能的格式。

---

## 相关链接

- **GitHub**: https://github.com/huiali/rust-skills
- **问题反馈**: https://github.com/huiali/rust-skills/issues
- **贡献指南**: 欢迎提交 PR 添加新技能

---

## 许可证

MIT License - Copyright (c) 2026 李偏偏

