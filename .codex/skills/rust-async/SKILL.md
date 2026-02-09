---
name: rust-async
description: Advanced async patterns expert. Handles Stream processing, backpressure control, select/join operations, cancellation, Future trait implementation, and async runtime optimization.
metadata:
  triggers:
    - async
    - Stream
    - backpressure
    - select
    - Future
    - tokio
    - async-std
    - cancellation
    - poll
    - async trait
---


## Solution Patterns

### Pattern 1: Stream Processing

```rust
use tokio_stream::{self as stream, StreamExt};

async fn process_stream(stream: impl Stream<Item = Data>) {
    stream
        .chunks(100)           // Batch processing
        .for_each(|batch| async {
            process_batch(batch).await;
        })
        .await;
}
```

**When to use**: Processing continuous data flows (websockets, file streams, API pagination).

**Key insight**: Streams are async iterators - pull-based, lazy evaluation.

### Pattern 2: Backpressure Control

```rust
use tokio::sync::Semaphore;
use std::sync::Arc;

let semaphore = Arc::new(Semaphore::new(10));  // Max 10 concurrent

let stream = tokio_stream::iter(0..1000)
    .map(|i| {
        let permit = semaphore.clone().acquire_owned();
        async move {
            let _permit = permit.await?;
            process(i).await
        }
    })
    .buffer_unordered(100);  // Max 100 buffered futures
```

**When to use**: Prevent overwhelming downstream systems or resource exhaustion.

**Trade-offs**: Adds latency but prevents overload.

### Pattern 3: Select Multiplexing

```rust
use tokio::select;
use tokio::time::{sleep, Duration};

async fn multiplex() {
    loop {
        select! {
            msg = receiver.recv() => {
                if let Some(msg) = msg {
                    handle(msg).await;
                } else {
                    break;  // Channel closed
                }
            }
            _ = sleep(Duration::from_secs(5)) => {
                // Timeout handling
                check_health().await;
            }
            else => break,  // All branches complete
        }
    }
}
```

**When to use**: Waiting on multiple async operations, first-to-complete wins.

**Gotcha**: All branches must be cancellation-safe.

### Pattern 4: Task Cancellation

```rust
use tokio::time::timeout;
use std::time::Duration;

async fn with_timeout() -> Result<Value, TimeoutError> {
    timeout(Duration::from_secs(5), long_operation()).await
        .map_err(|_| TimeoutError)?
}

// Cooperative cancellation
let mut task = tokio::spawn(async move {
    loop {
        // Check cancellation
        tokio::task::yield_now().await;  // Yield point

        // Do work
        if let Err(_) = work().await {
            return;
        }
    }
});

// Cancel task
task.abort();
let _ = task.await;  // Will return JoinError::Cancelled
```

**When to use**: Operations with time limits or user-requested cancellation.

**Key insight**: Cancellation is cooperative - requires yield points.


## Workflow

### Step 1: Choose Stream vs Iterator

```
Sync data source?
  → Use Iterator (more efficient)

Async data source (network, DB)?
  → Use Stream

Need backpressure?
  → Definitely Stream
```

### Step 2: Design Concurrency Strategy

```
Sequential processing?
  → for_each / fold

Limited concurrency?
  → buffer_unordered(N) + Semaphore

Unlimited (dangerous)?
  → Use with extreme caution
```

### Step 3: Handle Cancellation

```
Long-running task?
  → Add timeout wrapper

User-initiated?
  → Implement abort signal

Resource cleanup?
  → Use Drop or explicit cleanup
```


## Join vs Try_Join

### Join - Wait for All

```rust
use tokio::join;

// All operations run concurrently, wait for all to complete
let (a, b, c) = join!(
    fetch_user(),
    fetch_posts(),
    fetch_comments()
);
// All values available, even if some operations failed
```

**Use when**: All results needed regardless of individual failures.

### Try_Join - Fail Fast

```rust
use tokio::try_join;

// Stop on first error
let (a, b) = try_join!(
    async_op_a(),
    async_op_b()
)?;
// Both succeeded, or error from first failure
```

**Use when**: All operations must succeed, fail fast on errors.

### Combined Pattern

```rust
async fn fetch_dashboard() -> Result<Dashboard, Error> {
    let (user, posts, comments) = try_join!(
        fetch_user(),
        fetch_posts(),
        fetch_comments()
    )?;

    Ok(Dashboard { user, posts, comments })
}
```


## Common Errors & Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `.await` forgotten | Future not polled | Check all async fn calls have `.await` |
| Cancellation unhandled | Task aborted mid-operation | Implement cooperative cancellation |
| Missing backpressure | Unbounded concurrency | Use Semaphore or buffer_unordered |
| Deadlock | Lock held across `.await` | Minimize lock scope, drop before await |
| Async drop unsupported | Drop in async context | Use spawn for cleanup or blocking drop |


## Backpressure Strategies

### Strategy 1: Semaphore-Based

```rust
let sem = Arc::new(Semaphore::new(10));

stream
    .map(|item| {
        let sem = sem.clone();
        async move {
            let _permit = sem.acquire().await?;
            process(item).await
        }
    })
    .buffer_unordered(10)
```

**Pros**: Precise control, easy to reason about
**Cons**: Semaphore overhead

### Strategy 2: Buffered Stream

```rust
stream
    .chunks(100)
    .for_each_concurrent(5, |batch| async move {
        process_batch(batch).await
    })
    .await
```

**Pros**: Simple, built-in to StreamExt
**Cons**: Less fine-grained control

### Strategy 3: Channel-Based

```rust
let (tx, mut rx) = mpsc::channel(100);  // Buffer size = backpressure

// Producer respects backpressure
tx.send(item).await?;

// Consumer pulls at own pace
while let Some(item) = rx.recv().await {
    process(item).await;
}
```

**Pros**: Natural backpressure from bounded channel
**Cons**: Extra copy/move overhead


## Performance Tips

| Pattern | Performance Insight |
|---------|---------------------|
| `select!` | More lightweight than multiple `tokio::spawn` |
| `buffer_unordered` | More flexible than `for_each_concurrent` |
| `.chunks()` | Reduces per-item overhead for bulk operations |
| Lock-free at await | Never hold locks across `.await` points |
| `spawn_blocking` | Use for CPU-bound work in async context |


## Advanced: Future Trait

### Implementing Future

```rust
use std::future::Future;
use std::pin::Pin;
use std::task::{Context, Poll};

struct Delay {
    when: Instant,
}

impl Future for Delay {
    type Output = ();

    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<()> {
        if Instant::now() >= self.when {
            Poll::Ready(())
        } else {
            // Wake me later
            cx.waker().wake_by_ref();
            Poll::Pending
        }
    }
}
```

**When to implement**: Custom async primitives, advanced control flow.

**Gotcha**: Must properly handle wakeup notifications.


## Review Checklist

When reviewing async code:

- [ ] All async functions are properly `.await`ed
- [ ] Backpressure mechanisms in place for streams
- [ ] Cancellation handled cooperatively (yield points)
- [ ] No locks held across `.await` points
- [ ] Stream processing uses appropriate concurrency limits
- [ ] Error propagation uses `?` or proper handling
- [ ] `select!` branches are cancellation-safe
- [ ] Long-running tasks have timeout protection
- [ ] Resource cleanup happens even on cancellation
- [ ] CPU-bound work uses `spawn_blocking`


## Verification Commands

```bash
# Check async code compilation
cargo check

# Run async tests
cargo test

# Check for common async mistakes
cargo clippy -- -W clippy::await_holding_lock

# Test with tokio-console for debugging
RUSTFLAGS="--cfg tokio_unstable" cargo run

# Profile async runtime
cargo flamegraph --bin your-app
```


## Common Pitfalls

### 1. Forgotten Await

**Symptom**: Future never executes, unexpected behavior

```rust
// ❌ Bad: future not awaited
async fn bad() {
    fetch_data();  // Returns Future, never runs!
}

// ✅ Good
async fn good() {
    fetch_data().await;  // Actually runs
}
```

### 2. Unbounded Concurrency

**Symptom**: Resource exhaustion, system overload

```rust
// ❌ Bad: all operations run concurrently
let futures: Vec<_> = urls.iter()
    .map(|url| fetch(url))
    .collect();
let results = join_all(futures).await;

// ✅ Good: limited concurrency
use futures::stream::{self, StreamExt};

let results = stream::iter(urls)
    .map(|url| fetch(url))
    .buffer_unordered(10)  // Max 10 concurrent
    .collect::<Vec<_>>()
    .await;
```

### 3. Lock Across Await

**Symptom**: Deadlock, "future cannot be sent between threads safely"

```rust
// ❌ Bad: lock held during await
let guard = mutex.lock().await;
some_async_op().await;  // DANGER
drop(guard);

// ✅ Good: drop lock before await
let value = {
    let guard = mutex.lock().await;
    guard.clone()
};  // lock dropped
some_async_op().await;
```

### 4. Async Drop

**Symptom**: Cannot await in Drop impl

```rust
// ❌ Bad: async operation in Drop
impl Drop for Resource {
    fn drop(&mut self) {
        // Cannot await here!
        self.cleanup().await;  // Won't compile
    }
}

// ✅ Good: explicit async cleanup
impl Resource {
    async fn cleanup(self) {
        // Async cleanup logic
    }
}

// Or spawn cleanup task
impl Drop for Resource {
    fn drop(&mut self) {
        let handle = self.handle.take();
        tokio::spawn(async move {
            if let Some(h) = handle {
                h.cleanup().await;
            }
        });
    }
}
```


## Related Skills

- **rust-concurrency** - Thread safety, Send/Sync basics
- **rust-async-pattern** - Async architecture patterns
- **rust-ownership** - Lifetime issues in async contexts
- **rust-pin** - Pin and self-referential types
- **rust-performance** - Async performance optimization
- **rust-web** - Async web frameworks (axum, actix)


## Localized Reference

- **Chinese version**: [SKILL_ZH.md](./SKILL_ZH.md) - 完整中文版本，包含所有内容
