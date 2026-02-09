---
name: rust-macro
description: "Declarative and procedural macro design, expansion debugging, and API ergonomics."
---

# Rust Macro Skill

Use this skill for domain-specific, production-ready Rust guidance.

## Core Question

**How do we generate ergonomic code while keeping diagnostics and maintenance quality high?**

## Solution Patterns

- Start with declarative macro when possible
- For proc-macro, keep parser and generator modular
- Provide precise compile-time diagnostics for misuse

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

- Opaque generated code with poor errors
- Macro hygiene issues from unqualified paths
- Overusing macros where functions/traits suffice

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo expand
```

## Related Skills

- `rust-type-driven`
- `rust-coding`
- `rust-const`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.

