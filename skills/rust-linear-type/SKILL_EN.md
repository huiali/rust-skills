---
name: rust-linear-type
description: "Linear resource management patterns in Rust for ownership-driven lifecycle guarantees and RAII-centric design."
---

# Rust Linear Type Skill

Use this skill for domain-specific, production-ready Rust guidance.

## Core Question

**How do we encode one-time resource transitions so invalid states are unrepresentable?**

## Solution Patterns

- Use typestate-style wrappers for lifecycle transitions
- Consume self on irreversible operations
- Expose recovery paths for failed transitions

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

- Allowing duplicate handles for linear resources
- State transitions hidden in side effects
- No explicit drop/finalization contract

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo fmt
```

## Related Skills

- `rust-type-driven`
- `rust-resource`
- `rust-ownership`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.

