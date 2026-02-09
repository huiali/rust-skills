# Rust Skill - Rust Expert Skill System

> A Rust programming expert skill system for Cursor Agent, containing **38 sub-skills** covering Rust from beginner to expert level.

---

[中文](./README_zh.md) | [English](./README.md)

---

## Overview

Rust Skill is an AI assistant skill system designed specifically for Rust programming, providing comprehensive programming guidance from basics to expert level. Each skill is deeply customized for specific domains to ensure precise solutions for various Rust problems.

### Core Features

- **Layered Design**: Core → Advanced → Expert
- **Problem-Oriented**: Automatic routing based on problem type
- **Practice-Oriented**: Direct-to-use code patterns and best practices
- **Continuously Updated**: Regular skill additions and improvements

---

## Skill Structure

```
┌─────────────────────────────────────────────────────┐
│                   rust-skill                         │
│                    (Main Entry)                      │
└─────────────────────────────────────────────────────┘
                          │
     ┌────────────────────┼────────────────────┐
     ↓                    ↓                    ↓
┌─────────┐         ┌─────────┐         ┌─────────┐
│  Core   │         │Advanced │         │ Expert  │
│   7     │         │   10    │         │   18    │
└─────────┘         └─────────┘         └─────────┘
```

---

## Skill List

### Core Skills (Daily Use)

| Skill | Description | Triggers |
|:-----|:-----|:-------|
| **rust-skill** | Main Rust expert entry point | Rust, cargo, compile error |
| **rust-ownership** | Ownership & lifetime | ownership, borrow, lifetime |
| **rust-mutability** | Interior mutability | mut, Cell, RefCell, borrow |
| **rust-concurrency** | Concurrency & async | thread, async, tokio |
| **rust-error** | Error handling | Result, Error, panic |
| **rust-error-advanced** | Advanced error handling | thiserror, anyhow, context |
| **rust-coding** | Coding standards | style, naming, clippy |

### Advanced Skills (Deep Understanding)

| Skill | Description | Triggers |
|:-----|:-----|:-------|
| **rust-unsafe** | Unsafe code & FFI | unsafe, FFI, raw pointer |
| **rust-anti-pattern** | Anti-patterns | anti-pattern, clone, unwrap |
| **rust-performance** | Performance optimization | performance, benchmark, false sharing |
| **rust-web** | Web development | web, axum, HTTP, API |
| **rust-learner** | Learning & ecosystem | version, new feature |
| **rust-ecosystem** | Crate selection | crate, library, framework |
| **rust-cache** | Redis caching | cache, redis, TTL |
| **rust-auth** | JWT & API Key auth | auth, jwt, token, api-key |
| **rust-middleware** | Middleware patterns | middleware, cors, rate-limit |
| **rust-xacml** | Policy engine | xacml, policy, rbac, permission |
| **rust-testing** | Testing strategy | test, proptest, mock, loom, criterion |
| **rust-database** | Database & ORM | sqlx, diesel, sea-orm, transaction, migration |
| **rust-observability** | Tracing & metrics | tracing, opentelemetry, metrics, prometheus |

### Expert Skills (Specialized)

| Skill | Description | Triggers |
|:-----|:-----|:-------|
| **rust-ffi** | Cross-language interop | FFI, C, C++, bindgen, C++ exception |
| **rust-pin** | Pin & self-referential | Pin, Unpin, self-referential |
| **rust-macro** | Macros & proc-macro | macro, derive, proc-macro |
| **rust-async** | Async patterns | Stream, backpressure, select |
| **rust-async-pattern** | Advanced async | tokio::spawn, plugin |
| **rust-const** | Const generics | const, generics, compile-time |
| **rust-embedded** | Embedded & no_std | no_std, embedded, ISR, WASM, RISC-V |
| **rust-lifetime-complex** | Complex lifetimes | HRTB, GAT, 'static, dyn |
| **rust-skill-index** | Skill index | skill, index |
| **rust-linear-type** | Linear types & resource mgmt | Destructible, RAII, linear semantics |
| **rust-coroutine** | Coroutines & green threads | generator, suspend/resume, coroutine |
| **rust-ebpf** | eBPF & kernel programming | eBPF, kernel module, map, tail call |
| **rust-gpu** | GPU memory & computing | CUDA, GPU memory, compute shader |

---

## Problem-Based Lookup

### Compilation Errors

| Problem Type | Recommended Skill |
|:---------|:---------|
| Ownership/lifetime errors | `rust-ownership` |
| Borrow conflicts/mutability | `rust-mutability` |
| Send/Sync errors | `rust-concurrency` |
| HRTB/GAT complex lifetimes | `rust-lifetime-complex` |
| Generic/const generic errors | `rust-const` |

### Performance Issues

| Problem Type | Recommended Skill |
|:---------|:---------|
| Basic optimization, benchmarks | `rust-performance` |
| False sharing/NUMA/lock contention | `rust-performance` |
| Concurrency optimization | `rust-concurrency` |

### Async Code

| Problem Type | Recommended Skill |
|:---------|:---------|
| Basic async/await | `rust-concurrency` |
| Stream/select/backpressure | `rust-async` |
| Advanced patterns/lifetimes | `rust-async-pattern` |
| Future & Pin | `rust-pin` |

### Error Handling

| Problem Type | Recommended Skill |
|:---------|:---------|
| Basic Result/Option | `rust-error` |
| thiserror/anyhow | `rust-error-advanced` |

### Advanced Type System

| Problem Type | Recommended Skill |
|:---------|:---------|
| HRTB/GAT/'static | `rust-lifetime-complex` |
| Procedural macros | `rust-macro` |
| Const generics | `rust-const` |

### Infrastructure

| Problem Type | Recommended Skill |
|:---------|:---------|
| Caching strategies | `rust-cache` |
| Authentication/Authorization | `rust-auth`, `rust-xacml` |
| Web middleware | `rust-middleware`, `rust-web` |

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

### Library Selection

| Problem Type | Recommended Skill |
|:---------|:---------|
| Crate recommendations | `rust-ecosystem` |

### Testing

| Problem Type | Recommended Skill |
|:---------|:---------|
| Unit/integration test design | `rust-testing` |
| Property/concurrency/flaky tests | `rust-testing` |

### Database & Persistence

| Problem Type | Recommended Skill |
|:---------|:---------|
| SQLx/Diesel/SeaORM usage | `rust-database` |
| Transaction/deadlock/migration issues | `rust-database` |

### Observability

| Problem Type | Recommended Skill |
|:---------|:---------|
| Tracing/logging/metrics instrumentation | `rust-observability` |
| OpenTelemetry and production diagnostics | `rust-observability` |

---

## Skill Collaboration

```
rust-skill (main entry)
    │
    ├─► rust-ownership ──► rust-mutability ──► rust-concurrency ──► rust-async
    │         │                     │                     │
    │         └─► rust-unsafe ──────┘                     │
    │                   │                                  │
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
    └─► rust-learner ──► rust-ecosystem / rust-embedded
              │
              └─► rust-pin / rust-macro / rust-const
                        │
                        └─► rust-lifetime-complex / rust-async-pattern
                                  │
                                  └─► rust-coroutine
```

---

## Installation & Usage

### Quick Start

Choose your installation method:

| Scenario | Method | Documentation |
|----------|--------|---------------|
| Personal development | **Global Install** | [USAGE_GLOBAL.md](./USAGE_GLOBAL.md) |
| Team collaboration | **Git Submodule** | [USAGE_SUBMODULE.md](./USAGE_SUBMODULE.md) |
| Claude Code specific | **Claude Code Setup** | [CLAUDE_CODE_GUIDE.md](./CLAUDE_CODE_GUIDE.md) |

📖 **See [USAGE_GUIDE.md](./USAGE_GUIDE.md) for detailed comparison and guidance**

### Usage Examples

Describe your Rust problem directly, and the system will automatically route to the appropriate sub-skill:

```rust
// Example questions
"How do I fix E0382 borrow checker error?"
"How do I optimize this HashMap performance?"
"tokio::spawn requires 'static but I have borrowed data"
"I encountered lifetime issues when implementing Stream trait"
"How do I choose the right Web framework?"
"What's the difference between Cell and RefCell?"
"How do I call C++ code from Rust and handle exceptions?"
"How do I write no_std code for RISC-V embedded development?"
```

---

## Development Guidelines

### Code Analysis

1. Identify ownership and borrowing patterns
2. Check for lifetime issues
3. Evaluate error handling strategies
4. Assess concurrency safety (Send/Sync)
5. Review API ergonomics

### Problem Solving

1. Start with safe, idiomatic solutions
2. Only use `unsafe` when absolutely necessary
3. Prefer type system over runtime checks
4. Use ecosystem crates appropriately
5. Consider performance implications

### Best Practices

1. Always use `Result` and `Option`
2. Implement `std::error::Error` for custom errors
3. Write comprehensive tests (unit + integration)
4. Document public APIs with rustdoc
5. Use `cargo clippy` and `cargo fmt`

---

## Performance Tools

```bash
# Type checking
cargo check

# Release build
cargo build --release

# Run tests
cargo test --lib --doc

# Code checking
cargo clippy

# Code formatting
cargo fmt
```

---

## Project Structure

```
rust-skill/
├── SKILL.md                    # Main entry (skill index)
├── README.md                   # This file
├── LICENSE                     # MIT License
├── USER_GUIDE.md               # User guide for AI tools
├── scripts/
│   ├── compile.sh              # Compile check
│   ├── test.sh                 # Run tests
│   ├── clippy.sh               # Code checking
│   └── fmt.sh                  # Format check
├── .cursor/                    # Cursor configuration
│   ├── mcp.json                # MCP configuration
│   └── rules.md                # Cursor rules
└── skills/                     # Sub-skills directory
    ├── rust-skill/             # Main skill
    ├── rust-ownership/         # Ownership
    ├── rust-mutability/        # Mutability
    ├── rust-concurrency/       # Concurrency
    ├── rust-async/             # Async
    ├── rust-async-pattern/     # Advanced async
    ├── rust-error/             # Error handling
    ├── rust-error-advanced/    # Advanced error
    ├── rust-coding/            # Coding standards
    ├── rust-unsafe/            # Unsafe code
    ├── rust-anti-pattern/      # Anti-patterns
    ├── rust-performance/       # Performance
    ├── rust-web/               # Web development
    ├── rust-learner/           # Learning
    ├── rust-ecosystem/         # Ecosystem
    ├── rust-ffi/               # FFI
    ├── rust-pin/               # Pin
    ├── rust-macro/             # Macros
    ├── rust-const/             # Const generics
    ├── rust-embedded/          # Embedded
    ├── rust-lifetime-complex/  # Complex lifetimes
    ├── rust-skill-index/       # Skill index
    ├── rust-linear-type/       # Linear types
    ├── rust-coroutine/         # Coroutines
    ├── rust-ebpf/              # eBPF
    ├── rust-gpu/               # GPU computing
    ├── rust-cache/             # Caching
    ├── rust-auth/              # Authentication
    ├── rust-middleware/        # Middleware
    └── rust-xacml/             # Policy engine
```

---

## Contributing

Contributions for new skills or improvements are welcome.

---

## License

MIT License - Copyright (c) 2026 李偏偏 <huiali@hotmail.com>

---

