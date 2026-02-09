---
name: rust-async-pattern
description: "Advanced async architecture patterns for task supervision, orchestration pipelines, plugin lifecycles, and graceful shutdown in large Rust services."
---

# Rust Async Pattern Skill

## Core Question

**How do we scale async architecture without losing lifecycle control and failure isolation?**

When async systems grow, correctness depends on supervision, ownership boundaries, and deterministic shutdown.

## Architecture Patterns

### 1. Supervisor + worker set

Use a supervisor task to own worker lifecycles, restart strategy, and health reporting.

```rust
use tokio::{select, task::JoinSet};

async fn run_workers() {
    let mut set = JoinSet::new();
    for id in 0..8 {
        set.spawn(async move { worker(id).await });
    }

    while let Some(res) = set.join_next().await {
        if res.is_err() {
            // restart or escalate based on policy
            set.spawn(async move { worker(999).await });
        }
    }
}

async fn worker(_id: usize) {}
```

Guidance:
- Define restart budget (max restarts/time window).
- Escalate permanently failing workers instead of infinite restarts.

### 2. Stage pipeline with bounded channels

```rust
use tokio::sync::mpsc;

async fn pipeline() {
    let (tx1, mut rx1) = mpsc::channel::<String>(256);
    let (tx2, mut rx2) = mpsc::channel::<String>(256);

    tokio::spawn(async move {
        while let Some(v) = rx1.recv().await {
            let _ = tx2.send(v.to_uppercase()).await;
        }
    });

    tokio::spawn(async move {
        while let Some(v) = rx2.recv().await {
            println!("sink={v}");
        }
    });

    let _ = tx1.send("hello".into()).await;
}
```

Guidance:
- Capacity is a contract, not a guess.
- Apply per-stage timeout and dead-letter policy.

### 3. Select loop with explicit priority

```rust
use tokio::select;

async fn event_loop() {
    loop {
        select! {
            biased;
            _ = handle_shutdown() => break,
            _ = handle_control_plane() => {},
            _ = handle_data_plane() => {},
        }
    }
}

async fn handle_shutdown() {}
async fn handle_control_plane() {}
async fn handle_data_plane() {}
```

Use `biased` only when priority is intentional and documented.

## Lifecycle and Shutdown Semantics

Define these phases explicitly:
1. Stop intake (reject new work).
2. Drain in-flight work with deadline.
3. Flush side effects and offsets.
4. Close resources in dependency order.

Shutdown checklist:
- [ ] Intake closed before draining.
- [ ] Max drain timeout configured.
- [ ] Idempotent close/finalize operations.
- [ ] Metrics emitted for dropped/drained work.

## Plugin / Extension Pattern

For plugin-driven async systems:
- Use trait-based plugin boundary with explicit async contract.
- Isolate plugin failures from core runtime.
- Version plugin protocol and feature flags.

## Common Pitfalls

- `tokio::spawn` everywhere without ownership model.
- Hidden circular dependencies between async services.
- Channel fan-out without backpressure.
- Shutdown race conditions from unordered stop sequence.
- Restart storms due to no supervision budget.

## Review Checklist

- [ ] Supervisor strategy and restart budget are defined.
- [ ] All channels/queues are bounded.
- [ ] Control-plane and data-plane are separated.
- [ ] Shutdown sequence is deterministic and tested.
- [ ] Failure domains are isolated (one plugin/task failure does not cascade silently).

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo fmt
RUST_LOG=info cargo test -- --nocapture
```

## Related Skills

- `rust-async`
- `rust-concurrency`
- `rust-distributed`
- `rust-observability`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.
