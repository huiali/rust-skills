---
name: rust-xacml
description: "Policy-based authorization in Rust using XACML/RBAC concepts for fine-grained access control."
---

# Rust XACML Skill

Use this skill for domain-specific, production-ready Rust guidance.

## Core Question

**How do we keep authorization decisions explainable, consistent, and enforceable across services?**

## Solution Patterns

- Separate policy authoring from enforcement points
- Model subject/resource/action/context explicitly
- Log decision traces for audit/debug

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

- Business logic bypassing policy engine
- Policy sprawl without versioning
- Missing deny-by-default fallback

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo fmt
```

## Related Skills

- `rust-auth`
- `rust-middleware`
- `rust-observability`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.

