---
name: rust-type-driven
description: "Type-driven design in Rust for encoding invariants at compile time and reducing runtime error classes."
---

# Rust Type Driven Skill

Use this skill for domain-specific, production-ready Rust guidance.

## Core Question

**Which domain rules should be enforced by types so invalid states never compile?**

## Solution Patterns

- Introduce newtypes for domain boundaries
- Use typestate/builders for staged construction
- Encode invariants in trait bounds where readable

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

- Excessive type complexity harming usability
- Leaking internal type machinery to API consumers
- Runtime checks duplicated with type checks

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo fmt
```

## Related Skills

- `rust-const`
- `rust-linear-type`
- `rust-coding`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.

