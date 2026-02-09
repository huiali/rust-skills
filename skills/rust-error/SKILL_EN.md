---
name: rust-error
description: "Practical Rust error handling with Result/Option, propagation, and stable API error contracts."
---

# Rust Error Skill

Use this skill for detailed, production-ready guidance in this Rust domain.

## Core Question

**How do we model failures so callers can recover predictably?**

## Solution Patterns

- Use Result for recoverable failures
- Map low-level errors at module boundaries
- Attach context to external failures

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

- Panic in production paths
- Leaking low-level error types across API boundaries
- Dropping root-cause context

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo fmt
```

## Related Skills

- `rust-error-advanced`
- `rust-testing`
- `rust-coding`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.
