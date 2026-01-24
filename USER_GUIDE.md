# Rust Skill User Guide

> How to use the Rust Skill system in AI programming tools

---
[中文](./USER_GUIDE_zh.md) | [English](./USER_GUIDE.md)

---

## Introduction

Rust Skill is an AI expert skill system designed for Rust programming. It divides Rust knowledge into **35 sub-skills** covering all areas from beginner to expert.

**Core Value**: Enabling AI to invoke domain-specific expertise when answering Rust-related questions for more accurate responses.

---

## Supported AI Tools

| Tool | Support | Configuration |
|-----|---------|---------------|
| **Cursor** | ✅ Native support | MCP configuration |
| **Claude Code** | ✅ Supported | MCP configuration |
| **GitHub Copilot** | ⚠️ Limited | Manual reference |
| **Other Agents** | ✅ Supported | Direct reference |

---

## Quick Start

### Method 1: Cursor + MCP (Recommended)

#### 1. Configure Cursor Rules

Create `.cursor/rules.md` in the project root:

```markdown
# Rust Skill Rules

When encountering Rust programming problems, AI should automatically match skills:
- Ownership/lifetime errors → `rust-ownership`
- Concurrency/async → `rust-concurrency`
- Error handling → `rust-error`
- unsafe/FFI → `rust-unsafe`
- Performance optimization → `rust-performance`
- Redis caching → `rust-cache`
- JWT authentication → `rust-auth`
- Middleware → `rust-middleware`
- Policy engine → `rust-xacml`

Skill definitions: `skills/*/SKILL.md`
```

#### 2. Configure MCP

Create `.cursor/mcp.json` in the project root:

```json
{
  "mcpServers": {
    "rust-skill": {
      "command": "builtin",
      "description": "Rust Skill System"
    }
  }
}
```

> **Configuration Notes**:
> - `.cursor/rules.md` - Cursor rules file
> - `.cursor/mcp.json` - MCP configuration file
> - `skills/` and `references/` - Project core content, no need to move

#### 3. Restart Cursor

After configuration, Cursor will automatically load the skill system.

#### 4. Use Skills

Describe problems directly in conversation, system will automatically route:

```
"How do I fix E0382 borrow checker error?"
→ Auto-triggers rust-ownership

"tokio::spawn requires 'static but I have borrowed data"
→ Auto-triggers rust-concurrency

"How do I implement Redis caching?"
→ Auto-triggers rust-cache
```

---

### Method 2: Direct Reference

If AI tools don't support MCP, directly tell it the skill file location:

```
Please reference the skill files in D:/space/rust-skill/skills/ directory,
especially rust-ownership/SKILL.md and rust-concurrency/SKILL.md.
```

---

## Skill Trigger Methods

### Auto-Trigger

Include trigger words in problem description, AI will automatically match:

| Problem Example | Triggered Skill |
|-----------------|-----------------|
| "Can I use the original variable after ownership transfer?" | rust-ownership |
| "What's the difference between Cell and RefCell?" | rust-mutability |
| "How to choose between Mutex and RwLock?" | rust-concurrency |
| "How to handle Result and Option?" | rust-error |
| "How to implement async Stream?" | rust-async |
| "What should I note in unsafe code?" | rust-unsafe |
| "How to call C++ libraries?" | rust-ffi |
| "How to develop in no_std environment?" | rust-embedded |
| "How to design Redis caching?" | rust-cache |
| "How to implement JWT authentication?" | rust-auth |

### Manual Specification

If auto-matching is inaccurate, explicitly specify skills:

```
Please use rust-ownership skill to answer:
"What's the difference between Rc and Arc?"
```

---

## Skill Categories Quick Reference

### Core Skills (Daily Use)

| Skill | Description | Use Case |
|-----|------|---------|
| rust-ownership | Ownership & lifetime | Borrow checker errors, memory safety |
| rust-mutability | Interior mutability | Cell, RefCell selection |
| rust-concurrency | Concurrency & async | Threads, channels, tokio |
| rust-error | Error handling | Result, Option handling |

### Advanced Skills (Deep Understanding)

| Skill | Description | Use Case |
|-----|------|---------|
| rust-unsafe | Unsafe code | FFI, raw pointers |
| rust-performance | Performance optimization | Benchmarks, SIMD |
| rust-web | Web development | axum, API design |
| rust-cache | Caching management | Redis, TTL strategies |
| rust-auth | Authentication/Authorization | JWT, API Key |
| rust-middleware | Middleware | CORS, rate limiting, logging |
| rust-xacml | Policy engine | RBAC, permission decisions |

### Expert Skills (Specialized)

| Skill | Description | Use Case |
|-----|------|---------|
| rust-ffi | Cross-language interop | C/C++ calls |
| rust-embedded | Embedded development | no_std, WASM |
| rust-ebpf | Kernel programming | eBPF, Linux kernel |
| rust-gpu | GPU computing | CUDA, parallel computing |

---

## Usage Examples

### Example 1: Fix Compilation Errors

**Question**:
```
error[E0382]: use of moved value: `value`
```

**AI Auto Response**:
→ Triggers rust-ownership skill
→ Explains ownership transfer rules
→ Provides solutions (borrowing, cloning, Arc)

### Example 2: Performance Optimization

**Question**:
```
This HashMap operation is too slow, how to optimize?
```

**AI Auto Response**:
→ Triggers rust-performance skill
→ Analyzes data structure selection
→ Suggests parallelization, SIMD optimization

### Example 3: Web Development

**Question**:
```
Write a REST API with axum, need authentication and rate limiting
```

**AI Auto Response**:
→ Triggers rust-web + rust-auth + rust-middleware
→ Provides complete code template
→ Includes JWT authentication, middleware configuration

---

## Project Structure

```
rust-skill/
├── .cursor/                  # Cursor configuration directory
│   ├── mcp.json             # MCP configuration file
│   └── rules.md             # Cursor rules file
├── skills/                  # Skills directory (35 sub-skills)
│   ├── rust-ownership/      # Ownership
│   ├── rust-concurrency/    # Concurrency
│   ├── rust-cache/          # Caching
│   ├── rust-auth/           # Authentication
│   ├── rust-middleware/     # Middleware
│   ├── rust-xacml/          # Policy engine
│   └── ...                  # More skills
├── references/              # Reference materials
│   ├── best-practices/      # Best practices
│   ├── core-concepts/       # Core concepts
│   └── ecosystem/           # Ecosystem crates
├── scripts/                 # Utility scripts
├── USER_GUIDE.md            # This guide (English)
├── USER_GUIDE_zh.md         # This guide (Chinese)
├── SKILL.md                 # Main entry (English)
├── SKILL_zh.md              # Main entry (Chinese)
└── README.md                # Project documentation (English)
```

---

## FAQ

### Q1: AI doesn't auto-trigger the corresponding skill?

**A**: Try including more keywords in the question, or directly specify the skill:

```
Please use rust-ownership to answer: What's the difference between Rc<T> and Arc<T>?
```

### Q2: Skill content is too detailed to read?

**A**: Each skill has a clear hierarchical structure, jump directly to needed section:

```markdown
## Core Patterns    ← Read this first
## Best Practices    ← Then read this
## FAQ    ← Check this when encountering problems
```

### Q3: Need to add new skills?

**A**: Create a new folder in `skills/` directory and add a `SKILL.md` file. Refer to existing skill formats.

---

## Related Links

- **GitHub**: https://github.com/huiali/rust-skills
- **Issue Reporting**: https://github.com/huiali/rust-skills/issues
- **Contribution Guide**: PRs welcome for new skills

---

## License

MIT License - Copyright (c) 2026 李偏偏

---

