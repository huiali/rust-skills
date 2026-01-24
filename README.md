# Rust Skill - Rust 专家技能系统

> 基于 Cursor Agent 的 Rust 编程专家技能系统，包含 **31 个子技能**，覆盖 Rust 从入门到专家的全部领域。

---

## 概述

Rust Skill 是一个专为 Rust 编程设计的 AI 助手技能系统，提供从基础到专家的全方位编程指导。每个技能都针对特定领域进行深度定制，确保能够精准解决各类 Rust 问题。

### 核心特性

- **分层设计**：Core（核心）→ Advanced（进阶）→ Expert（专家）
- **问题导向**：根据问题类型自动路由到合适技能
- **实战导向**：提供可直接使用的代码模式和最佳实践
- **持续更新**：定期补充新技能和完善现有内容

---

## 技能结构

```
┌─────────────────────────────────────────────────────┐
│                   rust-skill                         │
│                    (主入口技能)                       │
└─────────────────────────────────────────────────────┘
                          │
     ┌────────────────────┼────────────────────┐
     ↓                    ↓                    ↓
┌─────────┐         ┌─────────┐         ┌─────────┐
│  Core   │         │Advanced │         │ Expert  │
│  核心   │         │ 进阶    │         │ 专家    │
│  7 个   │         │  6 个   │         │ 18 个   │
└─────────┘         └─────────┘         └─────────┘
```

---

## 技能列表

### Core Skills（核心技能 - 日常必用）

| 技能 | 描述 | 触发词 |
|:-----|:-----|:-------|
| **rust-skill** | Rust 专家主入口 | Rust, cargo, 编译错误 |
| **rust-ownership** | 所有权与生命周期 | ownership, borrow, lifetime |
| **rust-mutability** | 可变性深入 | mut, Cell, RefCell, borrow |
| **rust-concurrency** | 并发与异步 | thread, async, tokio |
| **rust-error** | 错误处理 | Result, Error, panic |
| **rust-error-advanced** | 深入错误处理 | thiserror, anyhow, context |
| **rust-coding** | 编码规范 | style, naming, clippy |

### Advanced Skills（进阶技能 - 深入理解）

| 技能 | 描述 | 触发词 |
|:-----|:-----|:-------|
| **rust-unsafe** | 不安全代码与 FFI | unsafe, FFI, raw pointer |
| **rust-anti-pattern** | 反模式与常见错误 | anti-pattern, clone, unwrap |
| **rust-performance** | 性能优化（含高级优化） | performance, benchmark, false sharing |
| **rust-web** | Web 开发 | web, axum, HTTP, API |
| **rust-learner** | 学习与生态追踪 | version, new feature |
| **rust-ecosystem** | crate 选择 | crate, library, framework |

### Expert Skills（专家技能 - 疑难杂症）

| 技能 | 描述 | 触发词 |
|:-----|:-----|:-------|
| **rust-ffi** | 跨语言互操作 | FFI, C, C++, bindgen, C++ exception |
| **rust-pin** | Pin 与自引用 | Pin, Unpin, self-referential |
| **rust-macro** | 宏与过程元编程 | macro, derive, proc-macro |
| **rust-async** | 异步模式 | Stream, backpressure, select |
| **rust-async-pattern** | 高级异步模式 | tokio::spawn, 插件 |
| **rust-const** | Const generics | const, generics, compile-time |
| **rust-embedded** | 嵌入式与 no_std | no_std, embedded, ISR, WASM, RISC-V |
| **rust-lifetime-complex** | 复杂生命周期 | HRTB, GAT, 'static, dyn |
| **rust-skill-index** | 技能索引 | skill, index, 技能列表 |
| **rust-linear-type** | 线性类型与资源管理 | Destructible, RAII, linear semantics |
| **rust-coroutine** | 协程与绿色线程 | generator, suspend/resume, coroutine |
| **rust-ebpf** | eBPF 与内核编程 | eBPF, kernel module, map, tail call |
| **rust-gpu** | GPU 内存与计算 | CUDA, GPU memory, compute shader |

---

## 问题类型速查

### 编译错误

| 问题类型 | 推荐技能 |
|:---------|:---------|
| 所有权/生命周期错误 | `rust-ownership` |
| 借用冲突/可变性 | `rust-mutability` |
| Send/Sync 错误 | `rust-concurrency` |
| HRTB/GAT 复杂生命周期 | `rust-lifetime-complex` |
| 泛型/常量泛型错误 | `rust-const` |

### 性能问题

| 问题类型 | 推荐技能 |
|:---------|:---------|
| 基础优化、基准测试 | `rust-performance` |
| 伪共享/NUMA/锁竞争 | `rust-performance` |
| 并发性能优化 | `rust-concurrency` |

### 异步代码

| 问题类型 | 推荐技能 |
|:---------|:---------|
| 基础 async/await | `rust-concurrency` |
| Stream/select/backpressure | `rust-async` |
| 高级模式/生命周期 | `rust-async-pattern` |
| Future 与 Pin | `rust-pin` |

### 错误处理

| 问题类型 | 推荐技能 |
|:---------|:---------|
| 基础 Result/Option | `rust-error` |
| thiserror/anyhow | `rust-error-advanced` |

### 高级类型系统

| 问题类型 | 推荐技能 |
|:---------|:---------|
| HRTB/GAT/'static | `rust-lifetime-complex` |
| 过程宏 | `rust-macro` |
| Const generics | `rust-const` |

### 系统编程

| 问题类型 | 推荐技能 |
|:---------|:---------|
| unsafe/内存操作 | `rust-unsafe` |
| C/C++/Python 互操作 | `rust-ffi` |
| C++ 异常处理 | `rust-ffi` |
| no_std/WASM 开发 | `rust-embedded` |
| RISC-V 嵌入式 | `rust-embedded` |
| eBPF 内核编程 | `rust-ebpf` |
| GPU 计算 | `rust-gpu` |

### 库选择

| 问题类型 | 推荐技能 |
|:---------|:---------|
| crate 推荐 | `rust-ecosystem` |

---

## 技能协作关系

```
rust-skill (主入口)
    │
    ├─► rust-ownership ──► rust-mutability ──► rust-concurrency ──► rust-async
    │         │                     │                     │
    │         └─► rust-unsafe ──────┘                     │
    │                   │                                  │
    │                   └─► rust-ffi ─────────────────────► rust-ebpf
    │                             │
    │                             └─► rust-gpu
    │
    ├─► rust-error ──► rust-error-advanced ──► rust-anti-pattern
    │
    ├─► rust-coding ──► rust-performance
    │
    ├─► rust-learner ──► rust-web / rust-ecosystem / rust-embedded
    │         │
    │         └─► rust-pin / rust-macro / rust-const
    │                   │
    │                   └─► rust-lifetime-complex / rust-async-pattern
    │                             │
    │                             └─► rust-coroutine
```

---

## 使用方法

在 Cursor 中直接描述你的 Rust 问题，系统会自动路由到合适的子技能：

```rust
// 示例问题
"How do I fix E0382 borrow checker error?"
"如何优化这个 HashMap 的性能？"
"tokio::spawn requires 'static but I have borrowed data"
"实现 Stream trait 时遇到生命周期问题"
"如何选择合适的 Web 框架？"
"Cell 和 RefCell 有什么区别？"
"如何在 Rust 中调用 C++ 代码并处理异常？"
"如何为 RISC-V 嵌入式开发编写 no_std 代码？"
```

---

## 开发规范

### 代码分析

1. 识别所有权和借用模式
2. 检查生命周期问题
3. 评估错误处理策略
4. 评估并发安全性 (Send/Sync)
5. 审查 API ergonomics

### 问题解决

1. 从安全、惯用的解决方案开始
2. 仅在绝对必要时使用 `unsafe`
3. 优先使用类型系统而非运行时检查
4. 适当使用生态 crates
5. 考虑抽象的性能影响

### 最佳实践

1. 始终使用 `Result` 和 `Option`
2. 为自定义错误类型实现 `std::error::Error`
3. 编写全面的测试（单元+集成）
4. 使用 rustdoc 记录公共 API
5. 使用 `cargo clippy` 和 `cargo fmt`

---

## 性能工具

```bash
# 类型检查
cargo check

# 发布构建
cargo build --release

# 运行测试
cargo test --lib --doc

# 代码检查
cargo clippy

# 代码格式化
cargo fmt
```

---

## 项目结构

```
rust-skill/
├── SKILL.md                    # 主入口（包含所有子技能索引）
├── README.md                   # 本文件
├── LICENSE                     # MIT 许可证
├── scripts/
│   ├── compile.sh              # 编译检查
│   ├── test.sh                 # 运行测试
│   ├── clippy.sh               # 代码检查
│   └── fmt.sh                  # 格式化检查
├── skills/                     # 子技能目录
│   ├── rust-skill/             # Rust 主技能
│   ├── rust-ownership/         # 所有权
│   ├── rust-mutability/        # 可变性
│   ├── rust-concurrency/       # 并发
│   ├── rust-async/             # 异步
│   ├── rust-async-pattern/     # 高级异步
│   ├── rust-error/             # 错误处理
│   ├── rust-error-advanced/    # 深入错误处理
│   ├── rust-coding/            # 编码规范
│   ├── rust-unsafe/            # 不安全代码
│   ├── rust-anti-pattern/      # 反模式
│   ├── rust-performance/       # 性能优化（含高级）
│   ├── rust-web/               # Web 开发
│   ├── rust-learner/           # 学习追踪
│   ├── rust-ecosystem/         # 生态选择
│   ├── rust-ffi/               # FFI（含 C++ 异常）
│   ├── rust-pin/               # Pin
│   ├── rust-macro/             # 宏
│   ├── rust-const/             # Const generics
│   ├── rust-embedded/          # 嵌入式（含 WASM/RISC-V）
│   ├── rust-lifetime-complex/  # 复杂生命周期
│   ├── rust-skill-index/       # 技能索引
│   ├── rust-linear-type/       # 线性类型
│   ├── rust-coroutine/         # 协程
│   ├── rust-ebpf/              # eBPF
│   └── rust-gpu/               # GPU 计算
└── references/                 # 参考资料
    ├── api-design.md           # API 设计指南
    ├── best-practices.md       # 最佳实践
    ├── concurrency.md          # 并发编程
    ├── crates.md               # 推荐 crate
    ├── error-handling.md       # 错误处理
    ├── lifetimes.md            # 生命周期
    ├── modern-crates.md        # 现代 crate 推荐
    ├── ownership.md            # 所有权
    ├── rust-editions.md        # Rust 版本
    └── testing.md              # 测试策略
```

---

## 贡献

欢迎贡献新的技能或改进现有技能。

---

## 许可证

MIT License - Copyright (c) 2026 李偏偏 <huiali@hotmail.com>

---
