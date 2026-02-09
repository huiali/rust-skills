---
name: rust-lifetime-complex
description: "Complex lifetime reasoning for HRTB, GAT, trait objects, and advanced generic constraints."
---

# Rust Lifetime Complex Skill

Use this skill for domain-specific, production-ready Rust guidance.

## Core Question

**How do we express advanced lifetime relations (HRTB/GAT/trait objects) without sacrificing usability?**

## Solution Patterns

- Minimize failing case before rewriting bounds
- Use owned return types to simplify external API
- Hide complex bounds behind internal helper traits

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

- Leaking deep generic constraints to public callers
- Overly broad static bounds
- Complex trait objects without clear lifetime ownership

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo fmt
```

## Related Skills

- `rust-ownership`
- `rust-type-driven`
- `rust-pin`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.

