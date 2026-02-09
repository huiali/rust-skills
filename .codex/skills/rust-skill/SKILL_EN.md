---
name: rust-skill
description: "Main Rust routing skill for compile errors, ownership, lifetimes, async, concurrency, and performance issues. Use when a Rust task needs end-to-end diagnosis and solution planning."
---

# Rust Expert Skill

Use this skill for domain-specific, production-ready Rust guidance.

## Core Question

**How do we quickly route any Rust issue to the correct depth and produce a verifiable fix?**

## Solution Patterns

- Classify issue type: compile, design, runtime, performance
- Choose one primary skill and one secondary skill max
- Return fix + verification commands + tradeoff note

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

- Overloading context with too many sub-skills
- Optimizing before reproducing
- Fixing symptom without root-cause ownership model

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo fmt
```

## Related Skills

- `rust-skill-index`
- `rust-ownership`
- `rust-error`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.

