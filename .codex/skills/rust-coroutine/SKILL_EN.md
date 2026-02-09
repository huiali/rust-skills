---
name: rust-coroutine
description: "Coroutine and generator-style control flow patterns for cooperative scheduling and resumable computations."
---

# Rust Coroutine Skill

Use this skill for domain-specific, production-ready Rust guidance.

## Core Question

**How do we model suspend/resume control flow without corrupting state transitions?**

## Solution Patterns

- Define explicit state machine phases for resume points
- Separate scheduler concerns from coroutine logic
- Handle cancellation and completion as first-class states

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

- Implicit shared mutable state across yields
- Unclear resume ordering assumptions
- No cleanup path on cancellation

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo fmt
```

## Related Skills

- `rust-async-pattern`
- `rust-concurrency`
- `rust-type-driven`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.

