# Rust Skills for Claude Code

> A comprehensive Rust programming expert skill system designed for Claude Code CLI

[中文版](./CLAUDE_CODE_GUIDE_zh.md) | [English](./CLAUDE_CODE_GUIDE.md)

---

## Overview

This repository contains **40+ specialized Rust skills** that extend Claude Code's capabilities for Rust development. Each skill provides deep domain expertise, from ownership and lifetimes to async patterns, web development, and systems programming.

**Why use this?** Claude Code with these skills can provide more accurate, context-aware assistance for Rust programming challenges.

---

## Quick Start with Claude Code

### 1. Install Skills

Clone this repository to your local machine:

```bash
git clone https://github.com/huiali/rust-skills.git
cd rust-skills
```

### 2. Configure Claude Code

Create or edit `.claude/settings.local.json` in this directory:

```json
{
  "enabledMcpjsonServers": ["rust-skill"],
  "enableAllProjectMcpServers": true
}
```

### 3. Use Skills in Claude Code

Simply describe your Rust problem in natural language. Claude Code will automatically invoke the appropriate skill:

```bash
# Example: Ownership issues
claude "I'm getting E0382 use of moved value error"
# → Auto-triggers rust-ownership skill

# Example: Async patterns
claude "How do I implement backpressure with async streams?"
# → Auto-triggers rust-async skill

# Example: Web development
claude "Build a REST API with JWT auth and rate limiting"
# → Auto-triggers rust-web, rust-auth, rust-middleware
```

---

## Available Skills

### Core Skills (Daily Use)

| Skill | Description | Key Triggers |
|-------|-------------|--------------|
| `rust-skill` | Main Rust expert entry | Rust, cargo, compile error |
| `rust-ownership` | Ownership & lifetimes | ownership, borrow, lifetime, E0382, E0597 |
| `rust-mutability` | Interior mutability | mut, Cell, RefCell, interior mutability |
| `rust-concurrency` | Concurrency & async basics | thread, async, tokio, Send, Sync |
| `rust-error` | Error handling | Result, Error, panic, unwrap |
| `rust-error-advanced` | Advanced errors | thiserror, anyhow, context, error chain |
| `rust-coding` | Coding standards | clippy, fmt, naming, best practices |

### Advanced Skills

| Skill | Description | Key Triggers |
|-------|-------------|--------------|
| `rust-unsafe` | Unsafe code & raw pointers | unsafe, raw pointer, UB |
| `rust-anti-pattern` | Common anti-patterns | anti-pattern, clone abuse, unwrap |
| `rust-performance` | Performance optimization | benchmark, SIMD, false sharing |
| `rust-web` | Web development | web, axum, HTTP, REST API |
| `rust-learner` | Learning Rust | learning, resources, roadmap |
| `rust-ecosystem` | Crate selection | crate, library, dependency |
| `rust-testing` | Testing strategies | test, proptest, mock, criterion |
| `rust-database` | Database & ORM | sqlx, diesel, sea-orm, migration |
| `rust-observability` | Tracing & metrics | tracing, metrics, opentelemetry |
| `rust-cache` | Caching strategies | cache, redis, TTL |
| `rust-auth` | Authentication | JWT, API key, auth |
| `rust-middleware` | Web middleware | middleware, CORS, rate limit |
| `rust-xacml` | Policy engine | XACML, RBAC, policy |

### Expert Skills

| Skill | Description | Key Triggers |
|-------|-------------|--------------|
| `rust-ffi` | Foreign function interface | FFI, C, C++, bindgen |
| `rust-pin` | Pin & self-referential | Pin, Unpin, self-referential |
| `rust-macro` | Macros & proc-macros | macro, derive, proc-macro |
| `rust-async` | Advanced async patterns | Stream, backpressure, select |
| `rust-async-pattern` | Async architecture | tokio::spawn, async plugin |
| `rust-const` | Const generics | const, generics, compile-time |
| `rust-embedded` | Embedded & no_std | no_std, embedded, WASM, RISC-V |
| `rust-lifetime-complex` | Complex lifetimes | HRTB, GAT, 'static, dyn |
| `rust-linear-type` | Linear types | RAII, linear semantics |
| `rust-coroutine` | Coroutines | generator, suspend/resume |
| `rust-ebpf` | eBPF programming | eBPF, kernel module |
| `rust-gpu` | GPU computing | CUDA, GPU memory, shader |
| `rust-actor` | Actor model | actor, message passing |
| `rust-distributed` | Distributed systems | distributed, consensus |
| `rust-dpdk` | DPDK networking | DPDK, packet processing |

---

## Usage Patterns

### Problem-Based Routing

Claude Code automatically routes questions to the right skill:

| Your Problem | Skills Used |
|--------------|-------------|
| "E0382 use of moved value" | `rust-ownership` |
| "Can't share Rc across threads" | `rust-concurrency` |
| "How to handle Option in Result?" | `rust-error` |
| "Stream trait lifetime errors" | `rust-async` → `rust-lifetime-complex` |
| "Best ORM for async Postgres?" | `rust-ecosystem` → `rust-database` |
| "Write eBPF XDP filter" | `rust-ebpf` |

### Explicit Skill Invocation

You can also explicitly request a specific skill:

```bash
# Use rust-ownership skill
claude --context "use rust-ownership skill" "What's the difference between Rc and Arc?"

# Chain multiple skills
claude "Use rust-web and rust-auth to build JWT-protected API"
```

---

## Skill Structure

Each skill follows this structure:

```markdown
---
name: skill-name
description: Brief one-line description
---

# Skill Title

## Core Question
The fundamental question this skill addresses

## Solution Patterns
Key patterns and approaches

## Workflow
Step-by-step problem-solving process

## Review Checklist
- [ ] Critical checks before completion

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

## Integration with Development Workflow

### With Cargo Commands

```bash
# Check code and ask for fixes
cargo check 2>&1 | claude "Fix these Rust errors"

# Review clippy warnings
cargo clippy 2>&1 | claude "Explain and fix these warnings"

# Optimize performance
cargo bench | claude "Analyze these benchmark results"
```

### With Git Workflow

```bash
# Review code before commit
git diff | claude "Review this Rust code for issues"

# Generate commit messages
git diff --staged | claude "Generate a commit message"
```

---

## Configuration Details

### Directory Structure

```
rust-skills/
├── .claude/
│   └── settings.local.json   # Claude Code configuration
├── .codex/
│   ├── AGENTS.md              # Codex agents config
│   └── skills -> ../skills    # Symlink to skills
├── skills/                    # All skill definitions
│   ├── rust-skill/
│   │   └── SKILL.md
│   ├── rust-ownership/
│   │   └── SKILL.md
│   └── ...
├── references/                # Supporting materials
│   ├── best-practices/
│   ├── core-concepts/
│   └── ecosystem/
└── scripts/                   # Helper scripts
```

### MCP Server Configuration

The `.mcp.json` file defines resources and tools available to Claude Code:

```json
{
  "mcpServers": {
    "rust-skill": {
      "command": "builtin",
      "description": "Rust Skill system"
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

## Examples

### Example 1: Fix Ownership Error

```bash
$ claude "I have this error:
error[E0382]: use of moved value: `config`
  --> src/main.rs:10:5
   |
5  |     let config = Config::new();
   |         ------ move occurs because `config` has type `Config`
6  |     process(config);
   |             ------ value moved here
10 |     println!(\"{:?}\", config);
   |     ^^^^^^^^^^^^^^^ value used here after move"

Claude (using rust-ownership skill):
This is a classic ownership transfer issue. Here are three solutions:

1. **Borrow instead of move**:
   ```rust
   process(&config);  // Pass by reference
   println!("{:?}", config);  // config is still valid
   ```

2. **Clone if needed**:
   ```rust
   process(config.clone());
   println!("{:?}", config);
   ```

3. **Restructure to return ownership**:
   ```rust
   let config = process(config);  // process returns Config
   println!("{:?}", config);
   ```

Recommendation: Use option 1 (borrow) unless process() needs ownership.
```

### Example 2: Implement Async Stream

```bash
$ claude "Implement an async stream that fetches paginated API results with backpressure"

Claude (using rust-async skill):
Here's an implementation using async Stream with proper backpressure:

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
        // Implementation with proper backpressure handling
        // ...
    }
}
```

Key points:
- Implements Stream trait for pull-based backpressure
- Uses internal buffer to batch API calls
- Poll-based design prevents overwhelming the API
```

---

## Best Practices

### When to Use Which Skill

1. **Start with specific skills** for focused problems:
   - Compile error? → `rust-ownership`, `rust-mutability`
   - Performance issue? → `rust-performance`
   - Async confusion? → `rust-async`

2. **Use rust-skill** for general questions or when unsure:
   - "What's the best way to structure this Rust project?"
   - "Should I use async here?"

3. **Chain skills** for complex problems:
   - Web API with auth → `rust-web` + `rust-auth` + `rust-middleware`
   - Async with lifetime issues → `rust-async` + `rust-lifetime-complex`

### Getting the Most from Skills

- **Be specific**: "E0382 error in trait method returning borrowed data" beats "ownership error"
- **Provide context**: Mention if it's library code, embedded, web service, etc.
- **Include error codes**: E0382, E0597, etc. trigger targeted responses
- **Ask follow-ups**: Skills are designed for iterative problem-solving

---

## Troubleshooting

### Skills Not Loading

1. Check `.claude/settings.local.json` exists and is valid JSON
2. Verify you're in the rust-skills directory
3. Restart Claude Code: `claude --restart`

### Wrong Skill Triggered

- Explicitly specify: `claude "use rust-ownership skill: explain Rc vs Arc"`
- Add more context: Include error codes, crate names, or domain keywords

### Need to Add Custom Skill

1. Create `skills/your-skill/SKILL.md`
2. Follow the structure in existing skills
3. Add to main SKILL.md index
4. Restart Claude Code

---

## Contributing

We welcome contributions of:

- New skills for emerging Rust domains
- Improvements to existing skills
- Additional examples and patterns
- Bug fixes and corrections

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

---

## Resources

### Documentation
- [Main Skill Index](./SKILL.md) - All available skills
- [User Guide](./USER_GUIDE.md) - General usage guide
- [README](./README.md) - Project overview

### References
- [Best Practices](./references/best-practices/)
- [Core Concepts](./references/core-concepts/)
- [Ecosystem Guide](./references/ecosystem/)

### Community
- **GitHub**: https://github.com/huiali/rust-skills
- **Issues**: https://github.com/huiali/rust-skills/issues
- **Discussions**: https://github.com/huiali/rust-skills/discussions

---

## License

MIT License - Copyright (c) 2026 李偏偏 <huiali@hotmail.com>

---

## Changelog

### 2026-02
- Added `rust-testing`, `rust-database`, `rust-observability` skills
- Added `rust-actor`, `rust-distributed`, `rust-dpdk` skills
- Optimized for Claude Code compatibility
- Added this Claude Code usage guide

### 2025-01
- Initial release with 35 skills
- MCP server configuration
- Cursor IDE integration

---

**Ready to supercharge your Rust development with Claude Code? Start by running:**

```bash
claude "Show me available Rust skills"
```
