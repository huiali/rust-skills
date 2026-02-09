---
name: rust-resource
description: "Resource management patterns in Rust for ownership, pooling, cleanup guarantees, and failure-safe lifecycle handling."
---

# Rust Resource Skill

Use this skill for domain-specific, production-ready Rust guidance.

## Core Question

**How do we guarantee acquisition, usage, and cleanup under both success and failure paths?**

## Solution Patterns

- Model ownership and cleanup contract first
- Use RAII and guard types for automatic release
- Bound pool size and expose saturation metrics

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

- Resource leaks on error short-circuit
- Global mutable singletons without lifecycle control
- Unbounded pools under burst traffic

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo fmt
```

## Related Skills

- `rust-linear-type`
- `rust-unsafe`
- `rust-performance`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.

