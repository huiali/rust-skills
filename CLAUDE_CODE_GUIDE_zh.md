# Rust Skills for Claude Code (中文版)

> 为 Claude Code CLI 设计的全面 Rust 编程专家技能系统

[中文版](./CLAUDE_CODE_GUIDE_zh.md) | [English](./CLAUDE_CODE_GUIDE.md)

---

## 概述

本仓库包含 **40+ 个专业 Rust 技能**，可扩展 Claude Code 在 Rust 开发方面的能力。每个技能提供深度领域专业知识，涵盖从所有权和生命周期到异步模式、Web 开发和系统编程的各个方面。

**为什么使用？** 配备这些技能的 Claude Code 可以为 Rust 编程挑战提供更准确、更有上下文意识的帮助。

---

## Claude Code 快速开始

### 1. 安装技能

将此仓库克隆到本地：

```bash
git clone https://github.com/huiali/rust-skills.git
cd rust-skills
```   

### 2. 配置 Claude Code

在此目录创建或编辑 `.claude/settings.local.json`：

```json
{
  "enabledMcpjsonServers": ["rust-skill"],
  "enableAllProjectMcpServers": true
}
```

### 3. 在 Claude Code 中使用技能

只需用自然语言描述你的 Rust 问题，Claude Code 会自动调用相应的技能：

```bash
# 示例：所有权问题
claude "我遇到了 E0382 use of moved value 错误"
# → 自动触发 rust-ownership 技能

# 示例：异步模式
claude "如何用 async stream 实现背压控制？"
# → 自动触发 rust-async 技能

# 示例：Web 开发
claude "构建一个带 JWT 认证和限流的 REST API"
# → 自动触发 rust-web, rust-auth, rust-middleware
```

---

## 可用技能

### 核心技能（日常使用）

| 技能 | 描述 | 主要触发词 |
|------|------|-----------|
| `rust-skill` | Rust 专家主入口 | Rust, cargo, 编译错误 |
| `rust-ownership` | 所有权与生命周期 | ownership, borrow, lifetime, E0382, E0597 |
| `rust-mutability` | 内部可变性 | mut, Cell, RefCell, 内部可变性 |
| `rust-concurrency` | 并发与异步基础 | thread, async, tokio, Send, Sync |
| `rust-error` | 错误处理 | Result, Error, panic, unwrap |
| `rust-error-advanced` | 高级错误处理 | thiserror, anyhow, context, 错误链 |
| `rust-coding` | 编码规范 | clippy, fmt, 命名, 最佳实践 |

### 高级技能

| 技能 | 描述 | 主要触发词 |
|------|------|-----------|
| `rust-unsafe` | 不安全代码与裸指针 | unsafe, raw pointer, UB |
| `rust-anti-pattern` | 常见反模式 | anti-pattern, clone 滥用, unwrap |
| `rust-performance` | 性能优化 | benchmark, SIMD, false sharing |
| `rust-web` | Web 开发 | web, axum, HTTP, REST API |
| `rust-learner` | Rust 学习 | learning, resources, roadmap |
| `rust-ecosystem` | Crate 选择 | crate, library, dependency |
| `rust-testing` | 测试策略 | test, proptest, mock, criterion |
| `rust-database` | 数据库与 ORM | sqlx, diesel, sea-orm, migration |
| `rust-observability` | 跟踪与指标 | tracing, metrics, opentelemetry |
| `rust-cache` | 缓存策略 | cache, redis, TTL |
| `rust-auth` | 身份认证 | JWT, API key, auth |
| `rust-middleware` | Web 中间件 | middleware, CORS, rate limit |
| `rust-xacml` | 策略引擎 | XACML, RBAC, policy |

### 专家技能

| 技能 | 描述 | 主要触发词 |
|------|------|-----------|
| `rust-ffi` | 外部函数接口 | FFI, C, C++, bindgen |
| `rust-pin` | Pin 与自引用 | Pin, Unpin, self-referential |
| `rust-macro` | 宏与过程宏 | macro, derive, proc-macro |
| `rust-async` | 高级异步模式 | Stream, backpressure, select |
| `rust-async-pattern` | 异步架构 | tokio::spawn, async plugin |
| `rust-const` | 常量泛型 | const, generics, compile-time |
| `rust-embedded` | 嵌入式与 no_std | no_std, embedded, WASM, RISC-V |
| `rust-lifetime-complex` | 复杂生命周期 | HRTB, GAT, 'static, dyn |
| `rust-linear-type` | 线性类型 | RAII, linear semantics |
| `rust-coroutine` | 协程 | generator, suspend/resume |
| `rust-ebpf` | eBPF 编程 | eBPF, kernel module |
| `rust-gpu` | GPU 计算 | CUDA, GPU memory, shader |
| `rust-actor` | Actor 模型 | actor, message passing |
| `rust-distributed` | 分布式系统 | distributed, consensus |
| `rust-dpdk` | DPDK 网络 | DPDK, packet processing |

---

## 使用模式

### 基于问题的自动路由

Claude Code 会自动将问题路由到正确的技能：

| 你的问题 | 使用的技能 |
|---------|-----------|
| "E0382 use of moved value" | `rust-ownership` |
| "无法跨线程共享 Rc" | `rust-concurrency` |
| "如何在 Result 中处理 Option？" | `rust-error` |
| "Stream trait 生命周期错误" | `rust-async` → `rust-lifetime-complex` |
| "异步 Postgres 最佳 ORM？" | `rust-ecosystem` → `rust-database` |
| "编写 eBPF XDP 过滤器" | `rust-ebpf` |

### 显式技能调用

你也可以明确请求特定技能：

```bash
# 使用 rust-ownership 技能
claude --context "使用 rust-ownership 技能" "Rc 和 Arc 有什么区别？"

# 链接多个技能
claude "使用 rust-web 和 rust-auth 构建 JWT 保护的 API"
```

---

## 技能结构

每个技能遵循以下结构：

```markdown
---
name: skill-name
description: 简短的一行描述
---

# 技能标题

## 核心问题
此技能解决的基本问题

## 解决方案模式
关键模式和方法

## 工作流程
逐步解决问题的过程

## 审查检查清单
- [ ] 完成前的关键检查

## 常见陷阱
要避免的事项

## 验证命令
```bash
# 验证解决方案的命令
```

## 相关技能
相关技能的链接
```

---

## 与开发工作流集成

### 配合 Cargo 命令

```bash
# 检查代码并请求修复
cargo check 2>&1 | claude "修复这些 Rust 错误"

# 审查 clippy 警告
cargo clippy 2>&1 | claude "解释并修复这些警告"

# 优化性能
cargo bench | claude "分析这些基准测试结果"
```

### 配合 Git 工作流

```bash
# 提交前审查代码
git diff | claude "审查这段 Rust 代码的问题"

# 生成提交信息
git diff --staged | claude "生成提交信息"
```

---

## 配置详情

### 目录结构

```
rust-skills/
├── .claude/
│   └── settings.local.json   # Claude Code 配置
├── .codex/
│   ├── AGENTS.md              # Codex agents 配置
│   └── skills -> ../skills    # 指向 skills 的符号链接
├── skills/                    # 所有技能定义
│   ├── rust-skill/
│   │   └── SKILL.md
│   ├── rust-ownership/
│   │   └── SKILL.md
│   └── ...
├── references/                # 支持材料
│   ├── best-practices/
│   ├── core-concepts/
│   └── ecosystem/
└── scripts/                   # 辅助脚本
```

### MCP Server 配置

`.mcp.json` 文件定义了 Claude Code 可用的资源和工具：

```json
{
  "mcpServers": {
    "rust-skill": {
      "command": "builtin",
      "description": "Rust Skill 系统"
    }
  },
  "resources": {
    "skills": {
      "path": "skills/"
    }
  }
}
```

---

## 示例

### 示例 1：修复所有权错误

```bash
$ claude "我遇到这个错误：
error[E0382]: use of moved value: `config`
  --> src/main.rs:10:5
   |
5  |     let config = Config::new();
   |         ------ move occurs because `config` has type `Config`
6  |     process(config);
   |             ------ value moved here
10 |     println!(\"{:?}\", config);
   |     ^^^^^^^^^^^^^^^ value used here after move"

Claude (使用 rust-ownership 技能):
这是一个经典的所有权转移问题。以下是三种解决方案：

1. **使用借用而不是移动**：
   ```rust
   process(&config);  // 传递引用
   println!("{:?}", config);  // config 仍然有效
   ```

2. **需要时克隆**：
   ```rust
   process(config.clone());
   println!("{:?}", config);
   ```

3. **重构以返回所有权**：
   ```rust
   let config = process(config);  // process 返回 Config
   println!("{:?}", config);
   ```

推荐：使用方案 1（借用），除非 process() 需要所有权。
```

### 示例 2：实现异步流

```bash
$ claude "实现一个异步流，获取分页 API 结果并支持背压控制"

Claude (使用 rust-async 技能):
以下是使用 async Stream 实现的正确背压控制：

```rust
use futures::stream::{Stream, StreamExt};
use std::pin::Pin;
use std::task::{Context, Poll};

struct PaginatedFetcher {
    client: reqwest::Client,
    base_url: String,
    page: usize,
    buffer: Vec<Item>,
}

impl Stream for PaginatedFetcher {
    type Item = Result<Item, Error>;

    fn poll_next(mut self: Pin<&mut Self>, cx: &mut Context<'_>)
        -> Poll<Option<Self::Item>>
    {
        // 实现适当的背压处理
        // ...
    }
}
```

关键点：
- 实现 Stream trait 以实现基于拉取的背压
- 使用内部缓冲区批处理 API 调用
- 基于轮询的设计防止 API 过载
```

---

## 最佳实践

### 何时使用哪个技能

1. **从特定技能开始**处理针对性问题：
   - 编译错误？ → `rust-ownership`, `rust-mutability`
   - 性能问题？ → `rust-performance`
   - 异步困惑？ → `rust-async`

2. **使用 rust-skill** 处理一般问题或不确定时：
   - "构建 Rust 项目的最佳方式是什么？"
   - "这里应该使用 async 吗？"

3. **链接技能**处理复杂问题：
   - 带认证的 Web API → `rust-web` + `rust-auth` + `rust-middleware`
   - 带生命周期问题的异步 → `rust-async` + `rust-lifetime-complex`

### 充分利用技能

- **具体明确**："返回借用数据的 trait 方法中的 E0382 错误"优于"所有权错误"
- **提供上下文**：说明是库代码、嵌入式还是 Web 服务等
- **包含错误代码**：E0382、E0597 等会触发针对性响应
- **提出后续问题**：技能设计用于迭代式问题解决

---

## 故障排除

### 技能未加载

1. 检查 `.claude/settings.local.json` 存在且为有效 JSON
2. 验证你在 rust-skills 目录中
3. 重启 Claude Code：`claude --restart`

### 触发了错误的技能

- 显式指定：`claude "使用 rust-ownership 技能：解释 Rc vs Arc"`
- 添加更多上下文：包含错误代码、crate 名称或领域关键词

### 需要添加自定义技能

1. 创建 `skills/your-skill/SKILL.md`
2. 遵循现有技能的结构
3. 添加到主 SKILL.md 索引
4. 重启 Claude Code

---

## 贡献

我们欢迎以下贡献：

- 新兴 Rust 领域的新技能
- 改进现有技能
- 额外的示例和模式
- Bug 修复和更正

参见 [CONTRIBUTING.md](./CONTRIBUTING.md) 获取指南。

---

## 资源

### 文档
- [主技能索引](./SKILL.md) - 所有可用技能
- [用户指南](./USER_GUIDE.md) - 通用使用指南
- [README](./README.md) - 项目概述

### 参考资料
- [最佳实践](./references/best-practices/)
- [核心概念](./references/core-concepts/)
- [生态系统指南](./references/ecosystem/)

### 社区
- **GitHub**: https://github.com/huiali/rust-skills
- **Issues**: https://github.com/huiali/rust-skills/issues
- **Discussions**: https://github.com/huiali/rust-skills/discussions

---

## 许可证

MIT License - Copyright (c) 2026 李偏偏 <huiali@hotmail.com>

---

## 更新日志

### 2026-02
- 添加 `rust-testing`、`rust-database`、`rust-observability` 技能
- 添加 `rust-actor`、`rust-distributed`、`rust-dpdk` 技能
- 优化 Claude Code 兼容性
- 添加 Claude Code 使用指南

### 2025-01
- 初始版本，包含 35 个技能
- MCP server 配置
- Cursor IDE 集成

---

**准备好用 Claude Code 增强你的 Rust 开发了吗？从运行以下命令开始：**

```bash
claude "显示可用的 Rust 技能"
```
