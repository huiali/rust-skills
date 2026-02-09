---
name: rust-database
description: "Rust database skill for SQLx/Diesel/SeaORM design, transaction boundaries, migration safety, query performance, and operational reliability."---

# Rust Database Skill

## Core Question

**How do we guarantee data correctness while keeping queries and migrations operationally safe?**

## Persistence Architecture

- Keep repository/data-access layer separate from business logic.
- Define explicit transaction boundaries around business invariants.
- Choose stack by need:
  - `sqlx`: explicit SQL and compile-time query checks.
  - `diesel`: typed query builder with strong schema coupling.
  - `sea-orm`: async ORM convenience with rapid CRUD iteration.

## Transaction and Consistency Rules

- Keep transactions short.
- Do not perform network calls inside transactions.
- Handle deadlock/serialization retries with bounded policy.

## Query Performance

- Use indexes based on real access patterns.
- Detect and remove N+1 query behavior.
- Inspect query plans for slow paths.

## Migration Safety

- Prefer additive migrations for rolling deployments.
- Separate destructive changes into phased rollouts.
- Verify backward/forward compatibility windows.

## Common Pitfalls

- Long-lived transactions causing lock contention.
- Schema changes incompatible with old app versions.
- Inconsistent timezone/nullability handling across layers.
- Pool exhaustion under burst traffic.

## Review Checklist

- [ ] Transaction boundaries align with domain invariants.
- [ ] Retry/timeout policy is explicit for DB operations.
- [ ] Migrations are safe for rolling deploy.
- [ ] Query plans and indexes are validated.
- [ ] Metrics cover pool usage, latency, and error rates.

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo sqlx prepare
cargo sqlx migrate run
```

## Related Skills

- `rust-web`
- `rust-cache`
- `rust-observability`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.
