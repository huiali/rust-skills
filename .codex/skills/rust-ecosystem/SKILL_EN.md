---
name: rust-ecosystem
description: "Crate and framework selection guidance based on maturity, maintenance, ergonomics, and fit-for-purpose tradeoffs."
---

# Rust Ecosystem Skill

Use this skill for domain-specific, production-ready Rust guidance.

## Core Question

**Which crates should we choose for long-term maintainability, performance, and team fit?**

## Solution Patterns

- Evaluate maintenance cadence and issue responsiveness
- Prefer widely adopted crates for critical paths
- Document default choice plus fallback options

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

- Picking trendy crates without maintenance history
- Locking into heavy frameworks prematurely
- Ignoring MSRV/license constraints

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo tree
```

## Related Skills

- `rust-learner`
- `rust-coding`
- `rust-performance`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.

