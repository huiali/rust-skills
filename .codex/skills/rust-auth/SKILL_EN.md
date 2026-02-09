---
name: rust-auth
description: "Rust authentication skill for JWT, API keys, session security, token lifecycle, and authorization boundaries in service architectures."
---

# Rust Auth Skill

## Core Question

**How do we enforce authentication and authorization without creating fragile security boundaries?**

## Auth Model Selection

- JWT: stateless verification, good for distributed APIs.
- Session cookies: strong browser UX and revocation control.
- API keys: service-to-service or automation contexts.

Use layered checks:
1. Identity verification (who are you?).
2. Authorization policy (what can you do?).
3. Context constraints (tenant/scope/resource).

## JWT Best Practices

- Validate `iss`, `aud`, `exp`, `nbf`, and `sub` claims.
- Enforce short access-token TTL and refresh-token rotation.
- Keep signing key rotation strategy documented and tested.

```rust
#[derive(serde::Deserialize)]
struct Claims {
    sub: String,
    exp: usize,
    aud: String,
    iss: String,
}
```

## API Key Best Practices

- Store only hashed API keys (never plaintext).
- Support key prefix for lookup + secret for verification.
- Scope keys to least privilege and expiration window.

## Password and Secret Handling

- Use memory-hard hashing (`argon2`) for user passwords.
- Compare secrets in constant time.
- Never log credentials or raw tokens.

## Middleware Boundary Design

- Parse and verify auth once at entry middleware.
- Propagate typed auth context downstream.
- Keep business handlers free of token parsing logic.

## Review Checklist

- [ ] Token/key verification checks all required claims/fields.
- [ ] Revocation/rotation model is explicit.
- [ ] Authorization is separated from authentication.
- [ ] Secret handling avoids logs and insecure storage.
- [ ] Tests cover expired/forged/wrong-audience scenarios.

## Common Pitfalls

- Treating signature-valid JWT as fully authorized.
- Long-lived tokens without rotation.
- Shared admin API keys across environments.
- Missing clock-skew handling around `exp/nbf`.

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
RUST_LOG=debug cargo test -- --nocapture
```

## Related Skills

- `rust-web`
- `rust-xacml`
- `rust-observability`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.
