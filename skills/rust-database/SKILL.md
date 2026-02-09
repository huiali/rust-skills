---
name: rust-database
description: Rust database development skill for sqlx, diesel, sea-orm, migrations, connection pooling, transactions, query performance, and schema evolution. Use when building or debugging persistence layers, transaction boundaries, deadlocks, or SQL correctness in Rust services.
---

# Rust Database Skill

Use this skill for persistence-layer design and troubleshooting in Rust.

## Workflow

1. Clarify data model and consistency requirements.
2. Choose abstraction level: SQL-first (`sqlx`) or ORM-first (`diesel`/`sea-orm`).
3. Define transaction boundaries and retry behavior.
4. Validate query plans and indexing strategy.
5. Ensure migration safety and rollback strategy.

## Stack Selection

- `sqlx`: compile-time checked SQL, strong for explicit SQL control.
- `diesel`: mature typed query builder and schema-driven workflow.
- `sea-orm`: async-first ORM with rapid CRUD iteration.

## Key Practices

### Connection management

- Configure pool size per workload and DB limits.
- Add health checks and startup readiness checks.
- Use timeouts for acquire/query/transaction operations.

### Transactions

- Keep transactions short.
- Avoid network calls inside transaction blocks.
- Handle serialization/deadlock retries explicitly.

### Query performance

- Avoid N+1 patterns.
- Index by access path, not by field popularity.
- Inspect slow queries with `EXPLAIN`/`ANALYZE`.

### Migrations

- Use forward-only, idempotent-friendly migration strategy where possible.
- Keep destructive changes staged and reversible.
- Verify compatibility windows for rolling deploys.

## Commands

```bash
cargo sqlx prepare
cargo sqlx migrate run
diesel migration run
cargo test -- --test-threads=1
```

## Guardrails

- Do not concatenate SQL with untrusted input.
- Do not share a transaction across unrelated request scopes.
- Do not ship unbounded queries without limits/pagination.
