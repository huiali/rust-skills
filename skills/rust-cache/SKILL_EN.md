---
name: rust-cache
description: "Rust caching skill for Redis-backed and in-process cache design, TTL policy, invalidation strategy, stampede control, and consistency tradeoffs."
---

# Rust Cache Skill

## Core Question

**Which caching strategy improves latency without violating correctness guarantees?**

## Strategy Selection

- Cache-aside: default for read-heavy workloads.
- Read-through: useful when data access should be transparent.
- Write-through/write-behind: use only with explicit consistency contracts.

Choose by requirement:
- Strong consistency needed: shorter TTL + explicit invalidation.
- Eventual consistency acceptable: longer TTL + async refresh.
- High churn keys: avoid cache, or use tiny TTL.

## Key Design Rules

- Use stable, versioned key schema: `service:entity:v1:{id}`.
- Separate tenant/user dimensions explicitly in key.
- Keep payload compact; avoid oversized serialized blobs.

## Stampede and Thundering Herd Controls

- Single-flight per hot key.
- Jitter TTL to avoid synchronized expirations.
- Serve stale-on-error when upstream is degraded.

```rust
fn ttl_with_jitter(base_secs: u64, jitter_pct: u64) -> u64 {
    let jitter = base_secs * jitter_pct / 100;
    base_secs + fastrand::u64(..=jitter)
}
```

## Invalidation Patterns

- Write path should invalidate/update affected keys atomically.
- Prefer tag/key-prefix invalidation only when key cardinality is bounded.
- Use event-driven invalidation for cross-service cache coherence.

## Redis Operational Guidance

- Set command timeout and retry budget.
- Monitor hit rate, evictions, memory, and p99 latency.
- Use connection pooling with bounded limits.

## Review Checklist

- [ ] Cache key schema is documented and versioned.
- [ ] TTL and invalidation rules are explicit.
- [ ] Overload behavior is defined (fallback/stale/fail-fast).
- [ ] Cache miss path is rate-limited/protected.
- [ ] Metrics exist for hit/miss/error/eviction.

## Common Pitfalls

- Caching errors as successful values without marker semantics.
- Unbounded key cardinality (user IDs, query strings) causing memory blowups.
- Missing invalidation on write path.
- Relying on cache for correctness instead of performance.

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
RUST_LOG=info cargo test -- --nocapture
```

## Related Skills

- `rust-database`
- `rust-observability`
- `rust-performance`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.
