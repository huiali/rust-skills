---
name: rust-async
description: "Async Rust engineering skill for task orchestration, streams, backpressure, cancellation safety, timeout strategy, and runtime coordination in production services."
---

# Rust Async Skill

## Core Question

**How do we keep async code correct under cancellation, load, and partial failure?**

Async code is easiest to debug when ownership, cancellation behavior, and backpressure are explicit.

## Key Design Principles

- Prefer bounded concurrency over unconstrained spawning.
- Treat cancellation as a first-class behavior, not an edge case.
- Keep I/O boundaries and retry/timeout strategy explicit.
- Avoid blocking operations on runtime worker threads.

## Practical Patterns

### 1. Bounded fan-out with cancellation

```rust
use futures::{stream, StreamExt, TryStreamExt};

async fn fetch_all(urls: Vec<String>) -> Result<Vec<String>, reqwest::Error> {
    stream::iter(urls)
        .map(|u| async move { reqwest::get(u).await?.text().await })
        .buffer_unordered(32)
        .try_collect()
        .await
}
```

Why this works:
- Limits in-flight requests (`32`) to prevent memory blowups.
- Preserves throughput without unconstrained task creation.

### 2. Structured timeout + retry boundary

```rust
use tokio::time::{timeout, Duration};

async fn call_with_timeout<F, T, E>(f: F) -> Result<T, String>
where
    F: std::future::Future<Output = Result<T, E>>,
    E: std::fmt::Display,
{
    match timeout(Duration::from_secs(2), f).await {
        Ok(Ok(v)) => Ok(v),
        Ok(Err(e)) => Err(format!("request failed: {e}")),
        Err(_) => Err("request timed out".to_string()),
    }
}
```

### 3. Graceful shutdown signal wiring

```rust
use tokio::select;
use tokio::sync::watch;

async fn run_loop(mut shutdown: watch::Receiver<bool>) {
    loop {
        select! {
            _ = shutdown.changed() => {
                if *shutdown.borrow() { break; }
            }
            _ = do_one_tick() => {}
        }
    }
}

async fn do_one_tick() {
    // periodic work
}
```

## Async Streams and Backpressure

Guidelines:
- Use `Stream` pipelines with explicit buffering (`buffered`/`buffer_unordered`).
- Keep channel capacities bounded and observable.
- Define drop/coalesce policy for overload conditions.

Backpressure checklist:
- [ ] Max in-flight tasks is bounded.
- [ ] Queue sizes are bounded.
- [ ] Timeout budget is defined per downstream dependency.
- [ ] Overload behavior (drop, retry, fail-fast) is explicit.

## Cancellation Safety

Cancellation-safe code must avoid partial side effects that leave inconsistent state.

Use this sequence for side-effecting flows:
1. Build idempotency key.
2. Persist intent.
3. Execute external side effect.
4. Commit final state.

If cancellation occurs mid-flight, recovery path should be deterministic and replayable.

## Common Pitfalls

- Spawning unbounded tasks (`tokio::spawn` in loops without limits).
- Using `std::sync::Mutex` in hot async paths.
- Holding locks across `.await` points.
- Mixing CPU-heavy work into async workers without `spawn_blocking`.
- Retrying aggressively without jitter or deadline budget.

## Review Checklist

- [ ] Concurrency is bounded.
- [ ] Timeout/cancellation behavior is documented.
- [ ] No blocking operations on runtime workers.
- [ ] Lock scope does not cross `.await`.
- [ ] Error and retry policy is explicit per call boundary.

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo fmt
RUST_LOG=debug cargo test -- --nocapture
```

## Related Skills

- `rust-concurrency`
- `rust-async-pattern`
- `rust-observability`
- `rust-performance`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.
