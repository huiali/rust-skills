---
name: rust-error-advanced
description: "Advanced error composition with anyhow, thiserror, context layering, and boundary mapping across modules/services."
---

# Rust Error Advanced Skill

Use this skill for detailed, production-ready guidance in this Rust domain.

## Core Question

**Where should typed errors end and opaque app errors begin?**

## Solution Patterns

- thiserror for libraries, anyhow near app edge
- Preserve source errors with #[from]
- Keep stable boundary error contracts

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

- Opaque errors everywhere
- Inconsistent mapping between layers
- Poor diagnosability

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo fmt
```

## Related Skills

- `rust-error`
- `rust-web`
- `rust-observability`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.
