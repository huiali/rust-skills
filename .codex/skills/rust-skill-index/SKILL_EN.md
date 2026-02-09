---
name: rust-skill-index
description: "Directory skill for selecting the best Rust skill by problem type, domain, and complexity. Use when deciding which sub-skill should handle the current Rust task."
---

# Rust Skill Index

Use this skill for domain-specific, production-ready Rust guidance.

## Core Question

**Which skill has the highest precision for this request with minimum context overhead?**

## Solution Patterns

- Route by failure mode first, domain second
- Escalate to expert skills only when needed
- Prefer deterministic, narrow skill selection

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

- Keyword-only routing without intent check
- Multiple overlapping skills loaded unnecessarily
- Ignoring operational constraints of target domain

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo fmt
```

## Related Skills

- `rust-skill`
- `rust-web`
- `rust-unsafe`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.

