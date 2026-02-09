---
name: rust-learner
description: "Learning-oriented Rust guidance for roadmap planning, concept progression, and feature adoption."
---

# Rust Learner Skill

Use this skill for domain-specific, production-ready Rust guidance.

## Core Question

**What is the shortest learning path from current level to target production capability?**

## Solution Patterns

- Sequence topics by dependency: ownership -> errors -> async/concurrency
- Use small hands-on tasks for each concept
- Review mistakes and convert them into checklists

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

- Jumping to advanced topics without ownership mastery
- Reading without coding practice
- No feedback loop from code review/tests

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo fmt
```

## Related Skills

- `rust-coding`
- `rust-ecosystem`
- `rust-anti-pattern`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.

