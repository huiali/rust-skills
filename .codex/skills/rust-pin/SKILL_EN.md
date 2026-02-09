---
name: rust-pin
description: "Pin/Unpin and self-referential safety patterns for async and low-level Rust abstractions."
---

# Rust Pin Skill

Use this skill for domain-specific, production-ready Rust guidance.

## Core Question

**How do we preserve pinning invariants for self-referential and async state machines?**

## Solution Patterns

- Pin at stable ownership boundary
- Project pinned fields safely
- Separate Unpin and !Unpin behaviors explicitly

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

- Moving pinned values after projection
- Unsafe projection without invariant proof
- Confusing borrow lifetime with pin guarantees

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo fmt
```

## Related Skills

- `rust-async`
- `rust-lifetime-complex`
- `rust-unsafe`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.

