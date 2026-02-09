---
name: rust-learner
description: |
  Rust learning and ecosystem tracking expert covering version updates, new features, RFC tracking,
  crate updates, best practice evolution, and learning resources.
triggers:
  - learning
  - latest version
  - what's new
  - version update
  - new features
  - RFC
  - weekly news
  - tutorial
  - learning path
---

# Rust Learning and Ecosystem Tracking Expert

## Core Question

**How do you keep up with Rust's evolution?**

Rust releases a new version every 6 weeks. Stay updated but don't blindly chase every new feature.

---

## Version Update Strategy

### Stable Updates

```bash
# Check current version
rustc --version

# Update Rust
rustup update stable

# View changelog
rustup doc --changelog
```

### When to Upgrade

| Scenario | Recommendation |
|----------|---------------|
| New project | Use latest stable |
| Production project | Follow 6-week cycle |
| Library project | Consider MSRV policy |

### MSRV (Minimum Supported Rust Version)

```toml
[package]
rust-version = "1.70"  # Declare minimum version

[dependencies]
# MSRV-sensitive dependencies require care
serde = { version = "1.0", default-features = false }
```

---

## Solution Patterns

### Pattern 1: Following Stable Releases

```bash
# Quarterly update routine
rustup update stable
cargo outdated
cargo audit
cargo test --all-features

# Read release notes
rustup doc --changelog
```

### Pattern 2: Tracking Ecosystem Changes

```bash
# Check for breaking changes
cargo update --dry-run

# Security audit
cargo audit

# License check
cargo deny check licenses

# Check dependency tree
cargo tree
```

### Pattern 3: Learning New Features

```rust
// Edition 2024 features

// Inline const (1.79+)
const fn compute() -> [u8; 32] {
    let mut arr = [0u8; 32];
    // compute at compile time
    arr
}

// Never type improvements (1.82+)
fn diverge() -> ! {
    panic!("never returns")
}

// Async fn in trait (1.75+)
trait Repository {
    async fn fetch(&self, id: u64) -> Result<Data, Error>;
}
```

---

## Learning Path

### Beginner → Advanced

```
Basics → Ownership, lifetimes, borrow checker
   ↓
Intermediate → Trait objects, generics, closures
   ↓
Concurrency → async/await, threads, channels
   ↓
Advanced → unsafe, FFI, performance optimization
   ↓
Expert → Macros, type system, design patterns
```

---

## Information Sources

### Official Channels

| Source | Content | Frequency |
|--------|---------|-----------|
| [This Week in Rust](https://this-week-in-rust.org/) | Weekly digest, RFCs, blogs | Weekly |
| [Rust Blog](https://blog.rust-lang.org/) | Major releases, deep dives | As released |
| [Rust RFCs](https://github.com/rust-lang/rfcs) | Design discussions | Ongoing |
| [Release Notes](https://github.com/rust-lang/rust/blob/master/RELEASES.md) | Version changes | Every 6 weeks |

### Community Resources

| Resource | Content |
|----------|---------|
| [docs.rs](https://docs.rs/) | Documentation search |
| [crates.io](https://crates.io/) | Package search |
| [lib.rs](https://lib.rs/) | Find alternative crates |
| [Rust Analyzer](https://rust-analyzer.github.io/) | IDE plugin |

---

## Dependency Management

### Regular Updates

```bash
# Check outdated dependencies
cargo outdated

# Update compatible versions
cargo update

# Update to latest (may break)
cargo upgrade
```

### Security Audit

```bash
# Check for known vulnerabilities
cargo audit

# Check dependency licenses
cargo deny check licenses

# Analyze dependency tree
cargo tree -d  # Show duplicates
```

---

## Workflow

### Quarterly Checklist

```
Every 3 months:
- [ ] Upgrade to latest stable Rust
- [ ] Run cargo outdated
- [ ] Run cargo audit
- [ ] Check dependencies for breaking changes
- [ ] Evaluate new features worth adopting
- [ ] Update tooling (clippy, rustfmt)
```

### Annual Checklist

```
Every year:
- [ ] Consider edition upgrade
- [ ] Refactor deprecated patterns
- [ ] Evaluate MSRV policy
- [ ] Update development toolchain
- [ ] Review architecture patterns
```

---

## Learning Resources

### Beginner

- [The Rust Programming Language](https://doc.rust-lang.org/book/) - Official book
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/) - Example-driven
- [Rustlings](https://github.com/rust-lang/rustlings) - Interactive exercises

### Intermediate

- [The Rust Reference](https://doc.rust-lang.org/reference/) - Language reference
- [Rust Nomicon](https://doc.rust-lang.org/nomicon/) - Unsafe guide
- [Effective Rust](https://www.lurklurk.org/effective-rust/) - Best practices

### Advanced

- [Rust for Rustaceans](https://rust-for-rustaceans.com/) - Advanced patterns
- [Async Book](https://rust-lang.github.io/async-book/) - Async/await deep dive
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/) - API design

### Practice

- [Exercism Rust Track](https://exercism.org/tracks/rust) - Practice problems
- [Rust by Practice](https://practice.rs/) - Hands-on exercises
- [Advent of Code](https://adventofcode.com/) - Annual coding challenge

---

## Edition Update Strategy

| Edition | Released | Key Features |
|---------|----------|--------------|
| 2015 | Original | - |
| 2018 | Dec 2018 | Module system, NLL |
| 2021 | Oct 2021 | Disjoint captures, IntoIterator |
| 2024 | TBD | Gen blocks, async drop |

### Upgrading Editions

```bash
# Check if upgrade possible
cargo fix --edition

# Update Cargo.toml
# edition = "2024"

# Test thoroughly
cargo test --all-features
```

---

## Review Checklist

When learning new Rust features:

- [ ] Feature is stable (not experimental)
- [ ] Understand the problem it solves
- [ ] Know when NOT to use it
- [ ] Aware of trade-offs
- [ ] Tested in small project first
- [ ] Read release notes thoroughly
- [ ] Checked ecosystem adoption
- [ ] Updated team documentation

---

## Verification Commands

```bash
# Check Rust version
rustc --version
rustup show

# Update toolchain
rustup update

# Check outdated dependencies
cargo outdated

# Security audit
cargo audit

# License compliance
cargo deny check

# Check for deprecated features
cargo clippy -- -W deprecated
```

---

## Common Pitfalls

### 1. Chasing Shiny Features

**Symptom**: Using unstable features in production

```toml
# ❌ Avoid: nightly features in production
#![feature(generic_associated_types)]

# ✅ Good: wait for stabilization
# Use stable alternatives
```

### 2. Ignoring MSRV

**Symptom**: Breaking downstream users

```toml
# ✅ Good: declare MSRV
[package]
rust-version = "1.70"

# Test against MSRV in CI
# cargo +1.70 test
```

### 3. Not Reading Release Notes

**Symptom**: Surprised by breaking changes

```bash
# ✅ Good: read before updating
rustup doc --changelog

# Check crate changelogs
cargo info <crate> --version <version>
```

---

## Related Skills

- **rust-ecosystem** - Crate selection and tools
- **rust-coding** - Best practices and conventions
- **rust-performance** - Performance improvements
- **rust-async** - Async/await patterns
- **rust-error** - Error handling evolution

---

## Localized Reference

- **Chinese version**: [SKILL_ZH.md](./SKILL_ZH.md) - 完整中文版本，包含所有内容
