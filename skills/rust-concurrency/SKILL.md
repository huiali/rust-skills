---
name: rust-concurrency
description: Concurrency and async programming expert. Handles Send, Sync, threads, async/await, tokio, channels, Mutex, RwLock, deadlock prevention, and race condition debugging.
metadata:
  triggers:
    - thread
    - spawn
    - channel
    - mpsc
    - Mutex
    - RwLock
    - Atomic
    - async
    - await
    - Future
    - tokio
    - deadlock
    - race condition
    - Send
    - Sync
---


## Concurrency vs Async

| Dimension | Concurrency (threads) | Async (async/await) |
|-----------|----------------------|---------------------|
| Memory | Each thread has separate stack | Single thread reused |
| Blocking | Blocks OS thread | Doesn't block, yields |
| Use case | CPU-intensive | I/O-intensive |
| Complexity | Simple and direct | Requires runtime |

**Key Insight**: Threads for parallelism, async for concurrency.


## Send/Sync Quick Reference

### Send - Can Transfer Ownership Between Threads

```
Basic types → automatically Send
Contains references → automatically Send
Raw pointers → NOT Send
Rc → NOT Send (non-atomic ref counting)
```

**Rule**: If all fields are Send, the type is Send.

### Sync - Can Share References Between Threads

```
&T where T: Sync → automatically Sync
RefCell → NOT Sync (runtime checking not thread-safe)
MutexGuard → NOT Sync (intentionally)
```

**Rule**: `&T` is Send if `T` is Sync.


## Solution Patterns

### Pattern 1: Shared Mutable State

```rust
use std::sync::{Arc, Mutex};

let counter = Arc::new(Mutex::new(0));
let mut handles = vec![];

for _ in 0..10 {
    let counter = Arc::clone(&counter);
    let handle = std::thread::spawn(move || {
        let mut num = counter.lock().unwrap();
        *num += 1;
    });
    handles.push(handle);
}

for handle in handles {
    handle.join().unwrap();
}
```

**When to use**: Multiple threads need to mutate shared data.

**Trade-offs**: Lock contention can limit scalability.

### Pattern 2: Message Passing

```rust
use std::sync::mpsc;

let (tx, rx) = mpsc::channel();

thread::spawn(move || {
    tx.send("hello").unwrap();
});

println!("{}", rx.recv().unwrap());
```

**When to use**: Threads communicate without shared state.

**Trade-offs**: Copy/move overhead for messages.

### Pattern 3: Async Runtime (Tokio)

```rust
use tokio;

#[tokio::main]
async fn main() {
    let handle = tokio::spawn(async {
        // Async task
        fetch_data().await
    });

    let result = handle.await.unwrap();
}
```

**When to use**: I/O-bound operations (network, filesystem).

**Trade-offs**: Requires async runtime, function coloring.


## Workflow

### Step 1: Choose Concurrency Model

```
CPU-intensive task?
  → Use threads (rayon for data parallelism)

I/O-intensive task?
  → Use async/await (tokio, async-std)

Both?
  → Use async with spawn_blocking for CPU work
```

### Step 2: Determine Data Sharing Strategy

```
No shared state?
  → Message passing (mpsc channels)

Read-heavy shared state?
  → Arc<RwLock<T>>

Write-heavy shared state?
  → Arc<Mutex<T>> or lock-free alternatives

Simple counters/flags?
  → Atomic types (AtomicUsize, AtomicBool)
```

### Step 3: Verify Thread Safety

```
Check Send bounds
  → Can transfer ownership?

Check Sync bounds
  → Can share references?

Test for data races
  → Use miri, loom, or thread sanitizers
```


## Common Errors & Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| E0277 Send not satisfied | Contains non-Send types | Check all fields, replace Rc with Arc |
| E0277 Sync not satisfied | Shared reference type not Sync | Wrap with Mutex/RwLock |
| Deadlock | Inconsistent lock ordering | Establish and follow lock hierarchy |
| MutexGuard across await | Lock held while suspended | Scope lock before await point |
| Data race (runtime) | Improper synchronization | Use proper sync primitives |


## Deadlock Prevention

### Rule 1: Consistent Lock Ordering

```rust
// Always lock A before B
let _lock_a = resource_a.lock();
let _lock_b = resource_b.lock();
// Never lock B before A elsewhere
```

### Rule 2: Minimize Lock Scope

```rust
// ❌ Bad: lock held too long
let guard = data.lock();
do_work(&guard);
more_work();  // still locked

// ✅ Good: release early
{
    let guard = data.lock();
    do_work(&guard);
}  // lock released
more_work();
```

### Rule 3: Avoid Locks Across Await

```rust
// ❌ Bad: lock across await
let guard = mutex.lock().unwrap();
async_call().await;  // DEADLOCK RISK

// ✅ Good: drop lock before await
let value = {
    let guard = mutex.lock().unwrap();
    guard.clone()
};  // lock dropped
async_call().await;
```


## Performance Considerations

| Strategy | When to Use | Trade-offs |
|----------|-------------|------------|
| Fine-grained locking | Lock small portions | More complex, avoid contention |
| RwLock | Read-heavy workloads | Slower writes than Mutex |
| Atomics | Simple counters/flags | Limited operations, no compound ops |
| Message passing | Avoid shared state | Copy/move overhead |
| Lock-free structures | High contention | Complex, use crates (crossbeam) |


## Async-Specific Patterns

### Spawning Tasks

```rust
// Spawn independent task
tokio::spawn(async move {
    process_data(data).await
});

// Spawn with 'static requirement
tokio::spawn(async move {
    let data = Arc::clone(&data);  // Share ownership
    work_with(data).await
});
```

### Concurrent Operations

```rust
use tokio::join;

// Wait for all to complete
let (result1, result2, result3) = tokio::join!(
    fetch_user(),
    fetch_posts(),
    fetch_comments()
);

// First to complete
let result = tokio::select! {
    r = fetch_from_primary() => r,
    r = fetch_from_backup() => r,
};
```

### Timeout and Cancellation

```rust
use tokio::time::{timeout, Duration};

match timeout(Duration::from_secs(5), long_operation()).await {
    Ok(result) => result,
    Err(_) => {
        // Operation timed out
    }
}
```


## Review Checklist

When reviewing concurrent code:

- [ ] All shared data properly synchronized (Arc/Mutex/RwLock)
- [ ] Send/Sync bounds satisfied for types crossing threads
- [ ] No locks held across await points
- [ ] Consistent lock ordering to prevent deadlocks
- [ ] Appropriate choice between threads and async
- [ ] Message passing channels used correctly (no deadlocks)
- [ ] Atomic operations used for simple shared state
- [ ] Thread pool sized appropriately for workload
- [ ] Error handling for lock poisoning
- [ ] Graceful shutdown and resource cleanup


## Verification Commands

```bash
# Check compilation with thread safety
cargo check

# Run tests with thread sanitizer (requires nightly)
RUSTFLAGS="-Z sanitizer=thread" cargo +nightly test

# Test with miri (detect undefined behavior)
cargo +nightly miri test

# Use loom for exhaustive concurrency testing
cargo test --features loom

# Check for race conditions
cargo clippy -- -W clippy::mutex_atomic
```


## Common Pitfalls

### 1. Rc in Multi-threaded Context

**Symptom**: E0277 error, Rc<T> cannot be sent between threads

**Fix**: Replace `Rc` with `Arc`

```rust
// ❌ Bad
let data = Rc::new(value);
thread::spawn(move || { /* use data */ });

// ✅ Good
let data = Arc::new(value);
thread::spawn(move || { /* use data */ });
```

### 2. Lock Across Await Points

**Symptom**: Deadlock or "future cannot be sent between threads safely"

**Fix**: Drop lock before await

```rust
// ❌ Bad
let guard = mutex.lock().unwrap();
async_fn().await;

// ✅ Good
let value = mutex.lock().unwrap().clone();
drop(guard);  // Explicit drop
async_fn().await;
```

### 3. Missing Arc Clone

**Symptom**: Borrow checker errors when spawning threads

**Fix**: Clone Arc before moving into closure

```rust
// ❌ Bad
let data = Arc::new(vec![1, 2, 3]);
thread::spawn(move || { /* data moved */ });
// data is gone

// ✅ Good
let data = Arc::new(vec![1, 2, 3]);
let data_clone = Arc::clone(&data);
thread::spawn(move || { /* data_clone moved */ });
// data still available
```


## Related Skills

- **rust-async** - Advanced async patterns (Stream, select, backpressure)
- **rust-async-pattern** - Async architecture and design patterns
- **rust-ownership** - Understanding ownership for thread safety
- **rust-mutability** - Interior mutability patterns (Cell, RefCell)
- **rust-performance** - Concurrency performance optimization
- **rust-unsafe** - Writing safe concurrent abstractions


## Localized Reference

- **Chinese version**: [SKILL_ZH.md](./SKILL_ZH.md) - 完整中文版本，包含所有内容
