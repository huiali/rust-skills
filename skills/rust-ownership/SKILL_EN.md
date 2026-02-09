---
name: rust-ownership
description: "Ownership, borrowing, and lifetime troubleshooting for Rust compiler errors such as move-after-use and invalid references."
---

# Rust Ownership Skill

Use this skill for detailed, production-ready guidance in this Rust domain.

## Core Question

**How do we satisfy borrow checker rules without clone-heavy workarounds?**

## Solution Patterns

- Prefer borrowing over moving when possible
- Return owned values at boundary layers to simplify lifetimes
- Use Arc/Rc/Box only when ownership model requires it

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

- Clone as default fix for move errors
- References tied to temporaries
- Overlapping mutable/immutable borrows

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo fmt
```

## Related Skills

- `rust-mutability`
- `rust-lifetime-complex`
- `rust-type-driven`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.
