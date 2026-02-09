---
name: rust-zero-cost
description: "Zero-cost abstraction techniques in Rust for high-level APIs with minimal runtime overhead."
---

# Rust Zero Cost Skill

Use this skill for domain-specific, production-ready Rust guidance.

## Core Question

**How do we keep abstraction quality high while ensuring no hidden runtime penalties?**

## Solution Patterns

- Benchmark before and after abstraction changes
- Prefer monomorphization-friendly generic design
- Avoid unnecessary allocations and virtual dispatch on hot paths

## Workflow

1. Reproduce and isolate the issue with a minimal failing case.
2. Choose a domain-appropriate safe design and constraints.
3. Implement with explicit ownership, error, and boundary contracts.
4. Validate behavior with tests and operational checks.

## Review Checklist

- [ ] Correct behavior for success and failure paths.
- [ ] Domain invariants and boundaries are explicit.
- [ ] Errors and diagnostics are actionable.
- [ ] Performance/operational impact is measured.
- [ ] Regression tests cover the changed behavior.

## Common Pitfalls

- Premature micro-optimizations
- Complex abstractions with unclear performance model
- Ignoring cache/layout effects

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo bench
```

## Related Skills

- `rust-performance`
- `rust-const`
- `rust-type-driven`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.

