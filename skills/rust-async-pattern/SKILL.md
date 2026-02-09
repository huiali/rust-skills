---
name: rust-async-pattern
description: 'Advanced async patterns expert covering Stream implementation, zero-copy
  buffers, tokio::spawn lifetimes,

  plugin system scheduling, tonic streaming, and async lifetime management.

  '
metadata:
  triggers:
  - async pattern
  - Stream
  - tokio::spawn
  - zero-copy
  - plugin system
  - tonic
  - streaming
  - BorrowedMessage
  - async scheduling
  - lifetime async
---

# Advanced Async Patterns Expert

## Core Question

**How do you manage complex async lifetime issues, especially with self-referential types and streaming?**

Async makes lifetime problems harder. Self-referential buffers, tokio::spawn requirements, and Stream trait constraints all interact in non-obvious ways.

---

## Solution Patterns

### Pattern 1: Stream with Internal Buffer (Worker + Channel)

```rust
use tokio::sync::mpsc::{channel, Sender, Receiver};
use bytes::Bytes;
use futures::Stream;
use std::pin::Pin;
use std::task::{Context, Poll};

// ❌ Problem: Stream returning borrowed data from internal buffer
// Can't work because Stream::Item may outlive self

// ✅ Solution: Worker holds buffer, Stream receives owned data

pub struct SessionWorker {
    rx_events: Receiver<Bytes>,
    tx_snapshots: Sender<SnapshotResponse>,
    buf: Vec<u8>,  // Internal buffer
}

impl SessionWorker {
    pub async fn run(&mut self) {
        while let Some(event) = self.rx_events.recv().await {
            let snapshot = self.process_event(event);
            let _ = self.tx_snapshots.send(snapshot).await;
        }
    }

    fn process_event(&mut self, event: Bytes) -> SnapshotResponse {
        // Borrow buf internally
        let start = self.buf.len();
        self.buf.extend_from_slice(&event);

        // Return owned snapshot
        SnapshotResponse {
            id: self.next_id(),
            payload: Bytes::copy_from_slice(&self.buf[start..]),
        }
    }
}

// Stream only reads channel, no self-references
pub struct SessionStream {
    rx_snapshots: Receiver<SnapshotResponse>,
}

impl Stream for SessionStream {
    type Item = Result<SnapshotResponse, Status>;

    fn poll_next(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Option<Self::Item>> {
        match self.rx_snapshots.poll_recv(cx) {
            Poll::Ready(Some(snapshot)) => Poll::Ready(Some(Ok(snapshot))),
            Poll::Ready(None) => Poll::Ready(None),
            Poll::Pending => Poll::Pending,
        }
    }
}

#[derive(Clone)]
pub struct SnapshotResponse {
    pub id: u64,
    pub payload: Bytes,  // Owned data
}
```

### Pattern 2: tokio::spawn with Non-'static Lifetimes (Arena Pattern)

```rust
use std::sync::Arc;
use parking_lot::RwLock;

// ❌ Problem: BorrowedMessage<'a> can't be spawned
// tokio::spawn requires 'static but borrowed data isn't

pub struct BorrowedMessage<'a> {
    pub raw: &'a [u8],
    pub meta: MessageMeta,
}

// ✅ Solution: Use index-based arena instead of direct borrows

pub struct MessageArena {
    buffers: Arc<RwLock<Vec<Arc<Vec<u8>>>>>,
}

impl MessageArena {
    pub fn new() -> Self {
        Self {
            buffers: Arc::new(RwLock::new(Vec::new())),
        }
    }

    pub fn alloc(&self, data: &[u8]) -> MessageRef {
        let mut buffers = self.buffers.write();
        let idx = buffers.len();
        buffers.push(Arc::new(data.to_vec()));
        MessageRef {
            index: idx,
            arena: self.buffers.clone(),
        }
    }

    pub fn get(&self, msg_ref: &MessageRef) -> Option<Arc<Vec<u8>>> {
        let buffers = self.buffers.read();
        buffers.get(msg_ref.index).cloned()
    }
}

// Reference by index, not pointer
#[derive(Clone)]
pub struct MessageRef {
    index: usize,
    arena: Arc<RwLock<Vec<Arc<Vec<u8>>>>>,
}

impl MessageRef {
    pub fn data(&self) -> Option<Arc<Vec<u8>>> {
        let buffers = self.arena.read();
        buffers.get(self.index).cloned()
    }
}

// Now plugin handlers can be 'static
pub trait Plugin: Send + Sync {
    async fn handle(&self, msg: MessageRef) -> Result<(), HandlerError>;
}

// Can spawn without lifetime issues
fn dispatch_to_plugins(plugins: &[Arc<dyn Plugin>], msg: MessageRef) {
    for plugin in plugins {
        let plugin = Arc::clone(plugin);
        let msg = msg.clone();

        tokio::spawn(async move {
            if let Err(e) = plugin.handle(msg).await {
                log::error!("Plugin error: {}", e);
            }
        });
    }
}
```

### Pattern 3: Plugin System with Actor Pattern (Event Loop)

```rust
use tokio::sync::mpsc;

// Alternative: Don't spawn, use actor event loop per plugin

struct PluginActor<P: Plugin> {
    plugin: P,
    queue: mpsc::Receiver<PluginMsg>,
    arena: Arc<MessageArena>,
}

enum PluginMsg {
    Process(MessageRef),
    Shutdown,
}

impl<P: Plugin> PluginActor<P> {
    pub async fn run(&mut self) {
        while let Some(msg) = self.queue.recv().await {
            match msg {
                PluginMsg::Process(msg_ref) => {
                    // Process within actor's event loop
                    if let Err(e) = self.plugin.handle(msg_ref).await {
                        log::error!("Plugin error: {}", e);
                    }
                }
                PluginMsg::Shutdown => break,
            }
        }
    }
}

pub struct PluginDispatcher {
    actors: Vec<mpsc::Sender<PluginMsg>>,
}

impl PluginDispatcher {
    pub async fn dispatch(&self, msg: MessageRef) {
        for actor in &self.actors {
            // Send to actor's mailbox, no spawn needed
            let _ = actor.send(PluginMsg::Process(msg.clone())).await;
        }
    }
}
```

### Pattern 4: Zero-Copy with Owned Snapshots

```rust
use bytes::Bytes;

// Zero-copy approach: use Bytes (reference-counted buffer slices)

pub struct ZeroCopyBuffer {
    data: Bytes,  // Reference-counted
}

impl ZeroCopyBuffer {
    pub fn new(data: Vec<u8>) -> Self {
        Self {
            data: Bytes::from(data),
        }
    }

    pub fn slice(&self, range: std::ops::Range<usize>) -> Bytes {
        // Zero-copy slice (just increments reference count)
        self.data.slice(range)
    }
}

// Usage in stream
pub struct ZeroCopyStream {
    buffer: ZeroCopyBuffer,
    position: usize,
    chunk_size: usize,
}

impl Stream for ZeroCopyStream {
    type Item = Result<Bytes, std::io::Error>;

    fn poll_next(mut self: Pin<&mut Self>, _cx: &mut Context<'_>) -> Poll<Option<Self::Item>> {
        if self.position >= self.buffer.data.len() {
            return Poll::Ready(None);
        }

        let end = (self.position + self.chunk_size).min(self.buffer.data.len());
        let chunk = self.buffer.slice(self.position..end);  // Zero-copy
        self.position = end;

        Poll::Ready(Some(Ok(chunk)))
    }
}
```

### Pattern 5: Tonic Streaming with Snapshot Pattern

```rust
use tonic::{Request, Response, Status};
use futures::Stream;

pub struct MyService {
    arena: Arc<MessageArena>,
}

#[tonic::async_trait]
impl MyServiceTrait for MyService {
    type StreamResponse = Pin<Box<dyn Stream<Item = Result<SnapshotResponse, Status>> + Send>>;

    async fn stream_data(
        &self,
        request: Request<StreamRequest>,
    ) -> Result<Response<Self::StreamResponse>, Status> {
        let (tx, rx) = mpsc::channel(100);

        let arena = self.arena.clone();

        // Spawn worker that processes and sends snapshots
        tokio::spawn(async move {
            // Worker holds buffer
            let mut buffer = Vec::new();

            for i in 0..100 {
                // Simulate processing
                let data = format!("chunk {}", i);
                buffer.extend_from_slice(data.as_bytes());

                // Send owned snapshot
                let snapshot = SnapshotResponse {
                    id: i,
                    payload: Bytes::copy_from_slice(&buffer),
                };

                if tx.send(Ok(snapshot)).await.is_err() {
                    break;
                }
            }
        });

        // Return stream that reads from channel
        let stream = tokio_stream::wrappers::ReceiverStream::new(rx);
        Ok(Response::new(Box::pin(stream)))
    }
}
```

---

## Architecture Patterns

### When to Use Each Pattern

| Pattern | Use Case | Pros | Cons |
|---------|----------|------|------|
| **Worker + Channel** | Stream with internal state | Clean separation, no lifetime issues | Extra allocation for snapshots |
| **Arena + Index** | Plugin systems, tokio::spawn | Can spawn tasks, zero-copy possible | Complex lifecycle management |
| **Actor Event Loop** | Coordinated scheduling | No spawn needed, backpressure control | Single-threaded per actor |
| **Bytes (Arc)** | Network buffers | True zero-copy via reference counting | Reference counting overhead |
| **Owned Snapshots** | API boundaries | Simple, always works | Copies data |

---

## Workflow

### Step 1: Identify Lifetime Constraint

```
Check for:
  → Stream returning borrowed data? Worker + Channel
  → tokio::spawn with <'a> lifetimes? Arena or owned data
  → Self-referential struct? Redesign with indices
  → API boundary (GraphQL, gRPC)? Use owned DTOs
```

### Step 2: Choose Architecture

```
Decision tree:
  → Need true zero-copy? Use Bytes (Arc-based)
  → Need to spawn tasks? Arena or owned data
  → Plugin system? Actor pattern or Arena
  → Simple API? Owned snapshots (accept copy cost)
```

### Step 3: Validate Constraints

```
Verify:
  → All spawned tasks are 'static
  → Stream::Item doesn't borrow self
  → No self-referential pointers
  → API types are Send + Sync + 'static
```

---

## Review Checklist

When implementing advanced async patterns:

- [ ] Stream::Item doesn't borrow from self
- [ ] All tokio::spawn tasks are 'static
- [ ] No self-referential pointers (use indices instead)
- [ ] Worker/actor pattern separates buffer ownership
- [ ] API boundaries use owned data (DTO pattern)
- [ ] Zero-copy only where performance critical
- [ ] Backpressure handled with bounded channels
- [ ] Channel capacity configured (not unbounded)
- [ ] Arena cleanup prevents memory leaks
- [ ] Error handling doesn't panic in streams

---

## Verification Commands

```bash
# Check for lifetime errors
cargo check

# Expand async code to see generated Future
cargo expand --lib my_async_fn

# Test stream implementations
cargo test --test stream_tests

# Benchmark zero-copy vs copy
cargo bench --bench buffer_bench

# Check for Send/Sync issues
cargo clippy -- -W clippy::future_not_send
```

---

## Common Pitfalls

### 1. Stream Returning Borrowed Data

**Symptom**: "hidden type captures lifetime that does not appear in bounds"

```rust
// ❌ Bad: Stream borrows from self
pub struct BadStream<'buf> {
    buf: Vec<u8>,
}

impl<'buf> Stream for BadStream<'buf> {
    type Item = &'buf [u8];  // Lifetime escape!

    fn poll_next(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Option<Self::Item>> {
        // Can't return &self.buf because Item can outlive self
        Poll::Ready(None)
    }
}

// ✅ Good: Use Worker + Channel pattern
pub struct GoodStream {
    rx: Receiver<Bytes>,  // Owned data
}

impl Stream for GoodStream {
    type Item = Bytes;  // No lifetime

    fn poll_next(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Option<Self::Item>> {
        self.rx.poll_recv(cx)
    }
}
```

### 2. Spawning Non-'static Future

**Symptom**: "borrowed data escapes outside of method"

```rust
// ❌ Bad: spawning borrowed data
async fn bad_spawn(data: &[u8]) {
    tokio::spawn(async move {
        process(data).await;  // Error: data not 'static
    });
}

// ✅ Good: clone to owned or use Arc
async fn good_spawn(data: &[u8]) {
    let owned = data.to_vec();
    tokio::spawn(async move {
        process(&owned).await;  // OK: owned is 'static
    });
}

// ✅ Better: use Arc for zero-copy
async fn better_spawn(data: Arc<Vec<u8>>) {
    tokio::spawn(async move {
        process(&data).await;  // OK: Arc is 'static
    });
}
```

### 3. Blocking Operations in Async

**Symptom**: Task blocks event loop, other tasks can't progress

```rust
// ❌ Bad: blocking I/O in async
async fn bad_async() {
    let data = std::fs::read("file.txt").unwrap();  // Blocks entire executor!
}

// ✅ Good: use async I/O
async fn good_async() {
    let data = tokio::fs::read("file.txt").await.unwrap();  // Non-blocking
}

// ✅ Good: spawn_blocking for unavoidable blocking
async fn blocking_async() {
    let data = tokio::task::spawn_blocking(|| {
        std::fs::read("file.txt").unwrap()  // Runs on blocking thread pool
    }).await.unwrap();
}
```

---

## Decision Matrix

### When to Spawn vs Event Loop

| Scenario | Approach |
|----------|----------|
| Independent parallel tasks | tokio::spawn |
| Coordinated scheduling | Event loop |
| Plugin system | Actor pattern |
| Long-running stateful | Actor |
| Short-lived tasks | spawn |
| Need backpressure | Channel + actor |
| Complex lifecycle | Actor with supervision |

---

## Related Skills

- **rust-async** - Async/await fundamentals
- **rust-lifetime-complex** - Advanced lifetime patterns
- **rust-pin** - Pin and self-referential types
- **rust-actor** - Actor model patterns
- **rust-concurrency** - Concurrency primitives
- **rust-performance** - Zero-copy optimization

---

## Localized Reference

- **Chinese version**: [SKILL_ZH.md](./SKILL_ZH.md) - 完整中文版本，包含所有内容
