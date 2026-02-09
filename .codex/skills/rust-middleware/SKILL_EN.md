---
name: rust-middleware
description: "Middleware composition for Rust web frameworks including request tracing, rate limiting, CORS, and security headers."
---

# Rust Middleware Skill

Use this skill for domain-specific, production-ready Rust guidance.

## Core Question

**How should cross-cutting concerns be layered so behavior stays deterministic and observable?**

## Solution Patterns

- Define middleware order explicitly
- Separate auth, policy, rate-limit, tracing concerns
- Keep middleware stateless or bounded-state

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

- Order-dependent bugs between auth and rate limits
- Hidden blocking in middleware
- Leaking internal errors through shared handlers

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo fmt
```

## Related Skills

- `rust-web`
- `rust-auth`
- `rust-observability`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.

