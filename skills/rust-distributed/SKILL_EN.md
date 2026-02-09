---
name: rust-distributed
description: "Rust distributed systems skill for idempotency, retries, consistency tradeoffs, timeout budgets, and failure isolation across services."
---

# Rust Distributed Systems Skill

## Core Question

**How do we keep distributed workflows correct when networks, dependencies, and nodes fail independently?**

## Reliability Foundations

- Idempotency for externally visible write operations.
- Explicit timeout and retry budgets per dependency.
- Correlation IDs for end-to-end tracing.
- Clear consistency model per workflow.

## Consistency and Coordination

- Strong consistency: use when business invariants require it.
- Eventual consistency: acceptable for read models and non-critical propagation.
- Saga/outbox patterns for multi-step cross-service transactions.

## Retry and Failure Policy

- Retry only transient failures.
- Use exponential backoff + jitter.
- Cap retry attempts and total request deadline.
- Surface partial failure states explicitly.

## Data and Event Contracts

- Version all wire schemas.
- Keep backward compatibility during rolling deploys.
- Validate producer/consumer contracts in CI.

## Common Pitfalls

- Retrying non-idempotent writes.
- Missing deadlines leading to retry storms.
- Distributed locks without lease/ownership guarantees.
- Silent partial failures without compensating actions.

## Review Checklist

- [ ] Idempotency strategy is explicit for mutating operations.
- [ ] Timeout and retry budgets are bounded.
- [ ] Failure mode and compensation behavior are documented.
- [ ] Cross-service contracts are versioned and tested.
- [ ] Observability supports causal debugging.

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
RUST_LOG=info cargo test -- --nocapture
```

## Related Skills

- `rust-async-pattern`
- `rust-database`
- `rust-observability`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.
