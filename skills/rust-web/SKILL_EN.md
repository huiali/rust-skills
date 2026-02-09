---
name: rust-web
description: "Rust web backend skill for axum/actix APIs, middleware layering, error mapping, and production-ready service architecture."
---

# Rust Web Skill

## Core Question

**How do we deliver robust HTTP APIs with clear boundaries and operational safety?**

## Architecture Boundaries

Recommended structure:
- Router layer: route definitions and middleware composition.
- Handler layer: request/response mapping only.
- Service layer: business rules and orchestration.
- Repository/integration layer: DB/cache/external APIs.

## Handler and Extractor Rules

- Prefer typed extractors for path/query/body/auth context.
- Validate inputs near request boundary.
- Return typed domain errors mapped to stable HTTP responses.

## Middleware Ordering

Typical order:
1. Request ID / tracing
2. Authentication
3. Authorization / policy
4. Rate limiting / quotas
5. Business routes

## Performance and Resilience

- Set request and downstream timeouts.
- Add payload size limits.
- Use connection pools with bounded size.
- Avoid blocking operations in async handlers.

## Common Pitfalls

- Business logic in handlers.
- Leaking internal errors in API responses.
- Missing idempotency handling for retryable endpoints.
- No structured telemetry for request lifecycle.

## Review Checklist

- [ ] Route/handler/service responsibilities are separated.
- [ ] Error mapping is deterministic and client-safe.
- [ ] AuthN/AuthZ boundaries are explicit.
- [ ] Timeout, retry, and payload limits are configured.
- [ ] API behavior is covered by integration tests.

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
RUST_LOG=info cargo test -- --nocapture
```

## Related Skills

- `rust-middleware`
- `rust-auth`
- `rust-database`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.
