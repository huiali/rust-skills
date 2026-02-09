# Rust Skills - Comprehensive Rust Expert System

> A comprehensive Rust programming expert skill system containing **40+ sub-skills** covering everything from beginner to expert level. Designed for Claude Code CLI and AI-assisted development.

---

[English](./README.md) | [中文](./README_zh.md)

---

## 🎯 Overview

**Rust Skills** is a meticulously crafted AI assistant skill system designed specifically for Rust programming. It provides comprehensive guidance from basic syntax to advanced patterns, with each skill deeply customized for specific domains to ensure precise solutions.

### ✨ Key Features

- **🎓 Layered Design**: Core → Advanced → Expert progression
- **🎯 Problem-Oriented**: Automatic routing based on problem type
- **💡 Practice-First**: Direct-to-use code patterns and best practices
- **📚 Comprehensive Coverage**: 40+ specialized skills covering all Rust domains
- **🔄 Continuously Updated**: Regular skill additions and improvements (22/40 optimized for Claude Code)
- **🌍 Bilingual**: English SKILL.md + Chinese SKILL_ZH.md for all optimized skills

---

## 📊 Skill Structure

```
┌─────────────────────────────────────────────────────┐
│                   rust-skill                         │
│              (Main Entry Point)                      │
└─────────────────────────────────────────────────────┘
                          │
     ┌────────────────────┼────────────────────┐
     ↓                    ↓                    ↓
┌─────────┐         ┌─────────┐         ┌─────────┐
│  Core   │         │Advanced │         │ Expert  │
│    7    │         │   13    │         │   20    │
└─────────┘         └─────────┘         └─────────┘
```

**Progress**: 22/40 skills optimized for Claude Code (55%)

---

## 📚 Skill List

### 🔵 Core Skills (Daily Use)

| Skill | Description | Status | Triggers |
|:-----|:-----|:------|:-------|
| **rust-skill** | Main Rust expert entry point | ✅ | Rust, cargo, compile error |
| **rust-ownership** | Ownership & lifetime | ✅ | ownership, borrow, lifetime |
| **rust-mutability** | Interior mutability | ✅ | mut, Cell, RefCell, borrow |
| **rust-concurrency** | Concurrency & async | ✅ | thread, async, tokio |
| **rust-error** | Error handling | ✅ | Result, Error, panic |
| **rust-coding** | Coding standards | ✅ | style, naming, clippy |
| **rust-web** | Web development | ✅ | web, axum, HTTP, API |

### 🟢 Advanced Skills (Deep Understanding)

| Skill | Description | Status | Triggers |
|:-----|:-----|:------|:-------|
| **rust-unsafe** | Unsafe code & FFI | ✅ | unsafe, FFI, raw pointer |
| **rust-anti-pattern** | Anti-patterns | ✅ | anti-pattern, clone, unwrap |
| **rust-performance** | Performance optimization | ✅ | performance, benchmark, false sharing |
| **rust-learner** | Learning & ecosystem | ✅ | version, new feature |
| **rust-ecosystem** | Crate selection | ✅ | crate, library, framework |
| **rust-cache** | Redis caching | ✅ | cache, redis, TTL |
| **rust-auth** | JWT & API Key auth | ✅ | auth, jwt, token, api-key |
| **rust-middleware** | Middleware patterns | ✅ | middleware, cors, rate-limit |
| **rust-actor** | Actor model | ✅ | actor, message passing, supervision |
| **rust-xacml** | Policy engine | 📝 | xacml, policy, rbac, permission |
| **rust-testing** | Testing strategy | 📝 | test, proptest, mock, loom, criterion |
| **rust-database** | Database & ORM | 📝 | sqlx, diesel, sea-orm, transaction, migration |
| **rust-observability** | Tracing & metrics | 📝 | tracing, opentelemetry, metrics, prometheus |

### 🟡 Expert Skills (Specialized)

| Skill | Description | Status | Triggers |
|:-----|:-----|:------|:-------|
| **rust-ffi** | Cross-language interop | ✅ | FFI, C, C++, bindgen, C++ exception |
| **rust-pin** | Pin & self-referential | ✅ | Pin, Unpin, self-referential |
| **rust-macro** | Macros & proc-macro | ✅ | macro, derive, proc-macro |
| **rust-async** | Async patterns | ✅ | Stream, backpressure, select |
| **rust-async-pattern** | Advanced async | ✅ | tokio::spawn, plugin |
| **rust-const** | Const generics | ✅ | const, generics, compile-time |
| **rust-type-driven** | Type-driven design | ✅ | type state, newtype, PhantomData |
| **rust-lifetime-complex** | Complex lifetimes | ✅ | HRTB, GAT, 'static, dyn |
| **rust-embedded** | Embedded & no_std | 📝 | no_std, embedded, ISR, WASM, RISC-V |
| **rust-skill-index** | Skill index | 📝 | skill, index |
| **rust-linear-type** | Linear types & resource mgmt | 📝 | Destructible, RAII, linear semantics |
| **rust-coroutine** | Coroutines & green threads | 📝 | generator, suspend/resume, coroutine |
| **rust-ebpf** | eBPF & kernel programming | 📝 | eBPF, kernel module, map, tail call |
| **rust-gpu** | GPU memory & computing | 📝 | CUDA, GPU memory, compute shader |
| **rust-dpdk** | DPDK high-performance | 📝 | DPDK, packet processing |
| **rust-distributed** | Distributed systems | 📝 | distributed, consensus, raft |
| **rust-resource** | Resource management | 📝 | RAII, drop, resource |
| **rust-zero-cost** | Zero-cost abstractions | 📝 | zero-cost, monomorphization |
| **rust-error-advanced** | Advanced error handling | 📝 | thiserror, anyhow, context |

**Legend**: ✅ Optimized | 📝 To be optimized

---

## 🔍 Problem-Based Lookup

### Compilation Errors

| Problem Type | Recommended Skill |
|:---------|:---------|
| Ownership/lifetime errors (E0382, E0506) | `rust-ownership` |
| Borrow conflicts/mutability (E0502, E0507) | `rust-mutability` |
| Send/Sync errors | `rust-concurrency` |
| HRTB/GAT complex lifetimes | `rust-lifetime-complex` |
| Generic/const generic errors | `rust-const` |
| "one type is more general" errors | `rust-lifetime-complex` |

### Performance Issues

| Problem Type | Recommended Skill |
|:---------|:---------|
| Basic optimization, benchmarks | `rust-performance` |
| False sharing/NUMA/lock contention | `rust-performance` |
| Concurrency optimization | `rust-concurrency` |
| Cache optimization | `rust-cache` |

### Async Code

| Problem Type | Recommended Skill |
|:---------|:---------|
| Basic async/await | `rust-concurrency` |
| Stream/select/backpressure | `rust-async` |
| Advanced patterns/lifetimes | `rust-async-pattern` |
| tokio::spawn 'static issues | `rust-async-pattern` |
| Future & Pin | `rust-pin` |
| Actor model & message passing | `rust-actor` |

### Error Handling

| Problem Type | Recommended Skill |
|:---------|:---------|
| Basic Result/Option | `rust-error` |
| thiserror/anyhow | `rust-error-advanced` |
| Error design patterns | `rust-anti-pattern` |

### Advanced Type System

| Problem Type | Recommended Skill |
|:---------|:---------|
| HRTB/GAT/'static conflicts | `rust-lifetime-complex` |
| Procedural macros | `rust-macro` |
| Const generics & compile-time | `rust-const` |
| Type-state pattern | `rust-type-driven` |
| PhantomData & zero-sized types | `rust-type-driven` |

### Web Development & Infrastructure

| Problem Type | Recommended Skill |
|:---------|:---------|
| Web frameworks (Axum, Actix) | `rust-web` |
| Caching strategies (Redis) | `rust-cache` |
| Authentication/Authorization | `rust-auth`, `rust-xacml` |
| Web middleware (CORS, rate limiting) | `rust-middleware` |
| Actor systems | `rust-actor` |

### Systems Programming

| Problem Type | Recommended Skill |
|:---------|:---------|
| unsafe/memory operations | `rust-unsafe` |
| C/C++/Python interop | `rust-ffi` |
| C++ exception handling | `rust-ffi` |
| no_std/WASM development | `rust-embedded` |
| RISC-V embedded | `rust-embedded` |
| eBPF kernel programming | `rust-ebpf` |
| GPU computing | `rust-gpu` |

### Code Quality & Testing

| Problem Type | Recommended Skill |
|:---------|:---------|
| Code style & conventions | `rust-coding` |
| Anti-patterns & code smells | `rust-anti-pattern` |
| Unit/integration test design | `rust-testing` |
| Property/concurrency testing | `rust-testing` |

### Learning & Ecosystem

| Problem Type | Recommended Skill |
|:---------|:---------|
| Version tracking, RFCs, learning paths | `rust-learner` |
| Crate recommendations | `rust-ecosystem` |

### Database & Observability

| Problem Type | Recommended Skill |
|:---------|:---------|
| SQLx/Diesel/SeaORM usage | `rust-database` |
| Transaction/deadlock/migration issues | `rust-database` |
| Tracing/logging/metrics | `rust-observability` |
| OpenTelemetry integration | `rust-observability` |

---

## 🚀 Installation & Usage

### Quick Start

Choose your installation method based on your scenario:

| Scenario | Method | Documentation |
|----------|--------|---------------|
| **Personal development** | Global Install | [USAGE_GLOBAL.md](./USAGE_GLOBAL.md) |
| **Team collaboration** | Git Submodule | [USAGE_SUBMODULE.md](./USAGE_SUBMODULE.md) |
| **Claude Code specific** | Claude Code Setup | [CLAUDE_CODE_GUIDE.md](./CLAUDE_CODE_GUIDE.md) ([中文](./CLAUDE_CODE_GUIDE_zh.md)) |

📖 **See [USAGE_GUIDE.md](./USAGE_GUIDE.md) for detailed comparison and setup guidance**

### Usage Examples

Describe your Rust problem directly, and the system will automatically route to the appropriate sub-skill:

```rust
// Ownership & Lifetimes
"How do I fix E0382 borrow checker error?"
"Why does my struct need 'static lifetime?"

// Performance
"How do I optimize this HashMap performance?"
"What's causing false sharing in my concurrent code?"

// Async Programming
"tokio::spawn requires 'static but I have borrowed data"
"I encountered lifetime issues when implementing Stream trait"
"How do I handle backpressure in my async Stream?"

// Web Development
"How do I choose between Axum and Actix for my REST API?"
"How do I implement JWT authentication with Redis session storage?"
"How do I set up CORS and rate limiting middleware?"

// Type System
"What's the difference between Cell and RefCell?"
"How do I use PhantomData for type-level state machines?"
"How do I fix 'one type is more general than the other' error?"

// Systems Programming
"How do I call C++ code from Rust and handle exceptions?"
"How do I write no_std code for RISC-V embedded development?"
```

---

## 🔗 Skill Relationships

```
rust-skill (main entry)
    │
    ├─► rust-ownership ──► rust-mutability ──► rust-concurrency ──► rust-async
    │         │                     │                     │              │
    │         │                     │                     └──► rust-actor
    │         └─► rust-unsafe ──────┘
    │                   │
    │                   └─► rust-ffi ─────────────────────► rust-ebpf
    │                             │                         │
    │                             └────────────────────────► rust-gpu
    │
    ├─► rust-error ──► rust-error-advanced ──► rust-anti-pattern
    │
    ├─► rust-coding ──► rust-performance
    │
    ├─► rust-web ──► rust-middleware ──► rust-auth ──► rust-xacml
    │                              │
    │                              └─► rust-cache
    │
    ├─► rust-type-driven ──► rust-lifetime-complex
    │
    └─► rust-learner ──► rust-ecosystem / rust-embedded
              │
              └─► rust-pin / rust-macro / rust-const
                        │
                        └─► rust-async-pattern / rust-coroutine
```

---

## 🛠️ Development Workflow

### Code Analysis Checklist

1. ✅ Identify ownership and borrowing patterns
2. ✅ Check for lifetime issues
3. ✅ Evaluate error handling strategies
4. ✅ Assess concurrency safety (Send/Sync)
5. ✅ Review API ergonomics

### Problem Solving Approach

1. Start with safe, idiomatic solutions
2. Only use `unsafe` when absolutely necessary
3. Prefer type system over runtime checks
4. Use ecosystem crates appropriately
5. Consider performance implications

### Best Practices

- ✅ Always use `Result` and `Option` for error handling
- ✅ Implement `std::error::Error` for custom errors
- ✅ Write comprehensive tests (unit + integration + doc)
- ✅ Document public APIs with rustdoc comments
- ✅ Use `cargo clippy` and `cargo fmt` regularly
- ✅ Follow Rust API guidelines

---

## ⚡ Quick Commands

```bash
# Type checking
cargo check

# Release build with optimizations
cargo build --release

# Run tests
cargo test --lib --doc

# Code linting
cargo clippy -- -W clippy::all

# Code formatting
cargo fmt --check

# Generate documentation
cargo doc --open

# Benchmarking (with criterion)
cargo bench

# Security audit
cargo audit
```

---

## 📁 Project Structure

```
rust-skills/
├── README.md                   # This file
├── README_zh.md                # Chinese README
├── LICENSE                     # MIT License
├── USAGE_GUIDE.md              # Installation guide
├── USAGE_GLOBAL.md             # Global install guide
├── USAGE_SUBMODULE.md          # Git submodule guide
├── CLAUDE_CODE_GUIDE.md        # Claude Code setup (EN)
├── CLAUDE_CODE_GUIDE_zh.md     # Claude Code setup (ZH)
├── SKILL_AUDIT_REPORT.md       # Skill optimization progress
├── .claude/                    # Claude Code config
│   └── settings.local.json
├── .codex/                     # Codex configuration
│   └── skills/                 # Codex skill symlinks
├── scripts/                    # Development scripts
│   ├── check-frontmatter.sh    # Validate skill frontmatter
│   └── check-structure.sh      # Validate skill structure
└── skills/                     # All skills (40+)
    ├── rust-skill/             # Main entry point
    ├── rust-ownership/         # ✅ Optimized
    ├── rust-mutability/        # ✅ Optimized
    ├── rust-concurrency/       # ✅ Optimized
    ├── rust-async/             # ✅ Optimized
    ├── rust-async-pattern/     # ✅ Optimized
    ├── rust-actor/             # ✅ Optimized
    ├── rust-error/             # ✅ Optimized
    ├── rust-coding/            # ✅ Optimized
    ├── rust-unsafe/            # ✅ Optimized
    ├── rust-anti-pattern/      # ✅ Optimized
    ├── rust-performance/       # ✅ Optimized
    ├── rust-web/               # ✅ Optimized
    ├── rust-learner/           # ✅ Optimized
    ├── rust-ecosystem/         # ✅ Optimized
    ├── rust-ffi/               # ✅ Optimized
    ├── rust-pin/               # ✅ Optimized
    ├── rust-macro/             # ✅ Optimized
    ├── rust-const/             # ✅ Optimized
    ├── rust-type-driven/       # ✅ Optimized
    ├── rust-lifetime-complex/  # ✅ Optimized
    ├── rust-cache/             # ✅ Optimized
    ├── rust-auth/              # ✅ Optimized
    ├── rust-middleware/        # ✅ Optimized
    └── ... (17 more to optimize)
```

---

## 🤝 Contributing

Contributions for new skills or improvements are welcome! Please ensure:

1. Follow the established skill structure (see optimized skills as examples)
2. Include both English SKILL.md and Chinese SKILL_ZH.md
3. Add proper frontmatter with triggers under metadata
4. Include: Core Question, Solution Patterns, Workflow, Review Checklist, Verification Commands, Common Pitfalls

---

## 📄 License

MIT License - Copyright (c) 2026 李偏偏 (huiali@hotmail.com)

---

## 🌟 Acknowledgments

This skill system is designed for use with:
- [Claude Code CLI](https://github.com/anthropics/claude-code) - Official Claude AI development tool
- AI-assisted development environments (Cursor, VS Code + Claude, etc.)

---

**Made with ❤️ for the Rust community**
