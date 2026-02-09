---
name: rust-mutability
description: "Interior mutability and borrowing-conflict handling with Cell, RefCell, Mutex, and RwLock patterns."
---

# Rust Mutability Skill

Use this skill for detailed, production-ready guidance in this Rust domain.

## Core Question

**Which mutability model is correct with minimal runtime overhead?**

## Solution Patterns

- Use &mut first, interior mutability second
- Cell for Copy types, RefCell for single-thread runtime checks
- Use Mutex/RwLock for cross-thread mutation

## Workflow

1. Reproduce and isolate the issue with a minimal failing case.
2. Choose the smallest safe design that satisfies constraints.
3. Implement with explicit ownership, errors, and boundaries.
4. Verify with tests, linting, and scenario-specific checks.

## Review Checklist

- [ ] Correct behavior for both success and failure paths.
- [ ] Ownership and API boundaries are explicit.
- [ ] Error handling and diagnostics are actionable.
- [ ] Performance-sensitive paths are measured.
- [ ] Regression tests cover the changed behavior.

## Common Pitfalls

- RefCell across await points
- Wide lock scopes
- Unnecessary shared mutable state

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo fmt
```

## Related Skills

- `rust-ownership`
- `rust-concurrency`
- `rust-async`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.
