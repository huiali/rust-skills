---
name: rust-concurrency
description: "Threading and async concurrency guidance for Send/Sync, channels, lock strategy, backpressure, and deadlock/race prevention in Rust systems."
---

# Rust Concurrency Skill

## Core Question

**How do we scale concurrent workloads while preserving safety and predictable latency?**

## Concurrency Model Choices

- Shared state + synchronization (`Mutex`, `RwLock`, atomics).
- Message passing (`mpsc`, actor-style channels).
- Hybrid model with strict ownership boundaries.

Prefer message passing when ownership transfer is natural. Use shared state only when contention and mutation semantics are well understood.

## Send/Sync Triage

When compiler reports trait-bound failures:
1. Identify the non-`Send`/`Sync` field.
2. Check for `Rc`, `RefCell`, raw pointers, or non-thread-safe FFI types.
3. Replace with `Arc`, `Mutex`, `RwLock`, or redesign ownership.

## Locking Strategy

- Keep lock scope minimal.
- Never hold lock across `.await`.
- Define lock ordering to avoid deadlock cycles.
- Measure contention before replacing with lock-free structures.

## Backpressure and Queue Control

- Use bounded channels by default.
- Define overload policy: drop, shed, retry with budget, or fail fast.
- Expose queue depth and processing lag metrics.

## Common Pitfalls

- Blocking calls in async runtime threads.
- Nested locks with inconsistent order.
- Unbounded producer rate with slow consumer.
- Overusing atomics for complex invariants.

## Review Checklist

- [ ] Shared mutable state has explicit ownership model.
- [ ] Locking scope and order are documented.
- [ ] Backpressure behavior is explicit.
- [ ] Cancellation/timeouts exist for waiting paths.
- [ ] Concurrency-critical paths have stress or race tests.

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
RUST_LOG=info cargo test -- --nocapture
```

## Related Skills

- `rust-async`
- `rust-performance`
- `rust-observability`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.
