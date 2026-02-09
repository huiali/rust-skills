---
name: rust-actor
description: Actor model expert covering message passing, state isolation, supervision trees, deadlock prevention, fault tolerance, Actix framework, and Erlang-style concurrency patterns.
metadata:
  triggers:
    - actor
    - actor model
    - message passing
    - supervision
    - Actix
    - mailbox
    - actor system
    - fault tolerance
    - supervision tree
---


## Solution Patterns

### Pattern 1: Basic Actor Implementation

```rust
use tokio::sync::mpsc::{channel, Sender, Receiver};
use std::collections::HashMap;

// Actor trait
trait Actor: Send + 'static {
    type Message: Send + 'static;
    type Error: std::error::Error;

    fn receive(&mut self, ctx: &mut Context<Self>, msg: Self::Message);
}

// Actor context
struct Context<A: Actor> {
    mailbox: Receiver<A::Message>,
    sender: Sender<A::Message>,
    state: ActorState,
    supervisor: Option<SupervisorAddr>,
}

#[derive(Debug, Clone)]
enum ActorState {
    Starting,
    Running,
    Restarting,
    Stopping,
    Stopped,
}

// Address handle for sending messages
#[derive(Clone)]
struct Addr<A: Actor> {
    sender: Sender<A::Message>,
}

impl<A: Actor> Addr<A> {
    pub async fn send(&self, msg: A::Message) -> Result<(), SendError> {
        self.sender.send(msg).await
            .map_err(|_| SendError::Disconnected)
    }
}

// Example actor
struct CounterActor {
    count: usize,
}

#[derive(Debug)]
enum CounterMessage {
    Increment,
    Decrement,
    GetCount(Sender<usize>),
}

impl Actor for CounterActor {
    type Message = CounterMessage;
    type Error = std::io::Error;

    fn receive(&mut self, ctx: &mut Context<Self>, msg: Self::Message) {
        match msg {
            CounterMessage::Increment => {
                self.count += 1;
            }
            CounterMessage::Decrement => {
                self.count = self.count.saturating_sub(1);
            }
            CounterMessage::GetCount(reply) => {
                let _ = reply.try_send(self.count);
            }
        }
    }
}
```

### Pattern 2: Request-Response Pattern

```rust
use tokio::sync::oneshot;
use std::time::Duration;

// Request wrapper with response channel
struct Request<M, R> {
    payload: M,
    response: oneshot::Sender<R>,
}

// Synchronous request with timeout
async fn request<A: Actor, R>(
    actor: &Addr<A>,
    msg: A::Message,
    timeout: Duration,
) -> Result<R, RequestError> {
    let (tx, rx) = oneshot::channel();

    let request = Request {
        payload: msg,
        response: tx,
    };

    actor.send(request).await
        .map_err(|_| RequestError::SendFailed)?;

    tokio::time::timeout(timeout, rx).await
        .map_err(|_| RequestError::Timeout)?
        .map_err(|_| RequestError::Canceled)
}

// Usage example
async fn example_request_response() {
    let (tx, rx) = oneshot::channel();

    let addr = counter_actor.start();
    addr.send(CounterMessage::GetCount(tx)).await.unwrap();

    let count = rx.await.unwrap();
    println!("Count: {}", count);
}
```

### Pattern 3: Supervision Tree

```rust
use std::collections::HashMap;

#[derive(Debug, Clone)]
enum SupervisionStrategy {
    OneForOne,    // Only restart failed child
    AllForOne,    // Restart all children if one fails
    RestForOne,   // Restart failed child and all after it
}

struct Supervisor {
    children: HashMap<ChildId, Child>,
    strategy: SupervisionStrategy,
    max_restarts: u32,
    window: Duration,
}

struct Child {
    id: ChildId,
    addr: Box<dyn std::any::Any + Send>,
    restart_count: u32,
    last_restart: Option<Instant>,
    spec: ChildSpec,
}

struct ChildSpec {
    factory: Box<dyn Fn() -> Box<dyn std::any::Any + Send>>,
    restart_strategy: RestartStrategy,
}

#[derive(Debug, Clone)]
enum RestartStrategy {
    Permanent,   // Always restart
    Temporary,   // Never restart
    Transient,   // Restart only on abnormal exit
}

impl Supervisor {
    fn new(strategy: SupervisionStrategy, max_restarts: u32, window: Duration) -> Self {
        Self {
            children: HashMap::new(),
            strategy,
            max_restarts,
            window,
        }
    }

    async fn handle_child_error(&mut self, child_id: ChildId, error: &dyn std::error::Error) {
        log::warn!("Child {} failed: {}", child_id, error);

        match self.strategy {
            SupervisionStrategy::OneForOne => {
                self.restart_child(child_id).await;
            }
            SupervisionStrategy::AllForOne => {
                for id in self.children.keys().cloned().collect::<Vec<_>>() {
                    self.stop_child(id).await;
                }
                for id in self.children.keys().cloned().collect::<Vec<_>>() {
                    self.restart_child(id).await;
                }
            }
            SupervisionStrategy::RestForOne => {
                let ids: Vec<_> = self.children.keys()
                    .filter(|&&id| id >= child_id)
                    .cloned()
                    .collect();

                for id in ids {
                    self.stop_child(id).await;
                    self.restart_child(id).await;
                }
            }
        }
    }

    async fn restart_child(&mut self, child_id: ChildId) -> bool {
        if let Some(child) = self.children.get_mut(&child_id) {
            child.restart_count += 1;

            // Check restart rate limit
            if self.should_give_up(child) {
                log::error!("Child {} exceeded max restarts, giving up", child_id);
                self.stop_child(child_id).await;
                return false;
            }

            child.last_restart = Some(Instant::now());
            log::info!("Restarting child {}", child_id);

            // Factory creates new instance
            let new_instance = (child.spec.factory)();
            child.addr = new_instance;

            true
        } else {
            false
        }
    }

    fn should_give_up(&self, child: &Child) -> bool {
        if child.restart_count > self.max_restarts {
            if let Some(last_restart) = child.last_restart {
                if last_restart.elapsed() < self.window {
                    return true;
                }
            }
        }
        false
    }

    async fn stop_child(&mut self, child_id: ChildId) {
        if let Some(child) = self.children.remove(&child_id) {
            log::info!("Stopping child {}", child_id);
            // Send stop signal
        }
    }
}
```

### Pattern 4: Deadlock Prevention with Bounded Mailboxes

```rust
use tokio::sync::mpsc;

struct BoundedMailbox<A: Actor> {
    receiver: mpsc::Receiver<A::Message>,
    sender: mpsc::Sender<A::Message>,
    capacity: usize,
}

impl<A: Actor> BoundedMailbox<A> {
    fn new(capacity: usize) -> Self {
        let (sender, receiver) = mpsc::channel(capacity);
        Self {
            receiver,
            sender,
            capacity,
        }
    }

    fn capacity(&self) -> usize {
        self.capacity
    }

    async fn send_with_backpressure(&self, msg: A::Message) -> Result<(), SendError> {
        // Will wait if mailbox is full (backpressure)
        self.sender.send(msg).await
            .map_err(|_| SendError::Disconnected)
    }

    fn try_send(&self, msg: A::Message) -> Result<(), TrySendError<A::Message>> {
        // Returns immediately if mailbox is full
        self.sender.try_send(msg)
            .map_err(|e| match e {
                mpsc::error::TrySendError::Full(msg) => TrySendError::Full(msg),
                mpsc::error::TrySendError::Closed(msg) => TrySendError::Disconnected(msg),
            })
    }
}

// Usage
async fn example_bounded_mailbox() {
    let mailbox: BoundedMailbox<CounterActor> = BoundedMailbox::new(100);

    // This will block if mailbox is full
    mailbox.send_with_backpressure(CounterMessage::Increment).await.unwrap();

    // This returns error immediately if full
    match mailbox.try_send(CounterMessage::Increment) {
        Ok(_) => println!("Sent"),
        Err(TrySendError::Full(_)) => println!("Mailbox full"),
        Err(TrySendError::Disconnected(_)) => println!("Actor stopped"),
    }
}
```

### Pattern 5: Actor Lifecycle Management

```rust
trait LifecycleHandler: Actor {
    fn pre_start(&mut self, ctx: &mut Context<Self>) {
        // Initialize resources
        log::info!("Actor starting");
    }

    fn post_start(&mut self, ctx: &mut Context<Self>) {
        // Start timers, establish connections
        log::info!("Actor started");
    }

    fn pre_restart(&mut self, ctx: &mut Context<Self>, error: &dyn std::error::Error) {
        // Clean up resources before restart
        log::warn!("Actor restarting due to: {}", error);
    }

    fn post_restart(&mut self, ctx: &mut Context<Self>) {
        // Reinitialize after restart
        log::info!("Actor restarted");
    }

    fn post_stop(&mut self) {
        // Save state, close connections
        log::info!("Actor stopped");
    }
}

// Example with lifecycle hooks
struct DatabaseActor {
    connection: Option<DatabaseConnection>,
}

impl LifecycleHandler for DatabaseActor {
    fn pre_start(&mut self, ctx: &mut Context<Self>) {
        // Establish database connection
        self.connection = Some(DatabaseConnection::new());
    }

    fn pre_restart(&mut self, ctx: &mut Context<Self>, error: &dyn std::error::Error) {
        // Close existing connection
        if let Some(conn) = self.connection.take() {
            conn.close();
        }
    }

    fn post_stop(&mut self) {
        // Ensure connection is closed
        if let Some(conn) = self.connection.take() {
            conn.close();
        }
    }
}
```


## Actor vs Thread Model

| Feature | Thread Model | Actor Model |
|---------|-------------|-------------|
| State sharing | Shared memory + locks | Isolated, message passing |
| Deadlock risk | High (lock ordering) | Low (message queues) |
| Scalability | Limited by thread count | Millions of actors possible |
| Fault handling | Manual | Supervision trees |
| Debugging | Hard (race conditions) | Easier (message sequence) |
| Memory | Shared | Isolated per actor |


## Workflow

### Step 1: Design Actor Hierarchy

```
Design questions:
  → What state needs isolation? Each isolated state = 1 actor
  → What operations need sequential processing? Group in same actor
  → What can fail independently? Separate actors with supervision
  → What needs to scale? Use actor pool pattern
```

### Step 2: Choose Messaging Pattern

```
Message patterns:
  → Fire-and-forget: Async send, no response
  → Request-response: Oneshot channel for reply
  → Streaming: Channel for multiple responses
  → Broadcast: Multiple recipients
```

### Step 3: Set Up Supervision

```
Supervision strategy:
  → OneForOne: Independent actors (default choice)
  → AllForOne: Tightly coupled actors needing consistent state
  → RestForOne: Sequential dependencies

Restart policy:
  → Permanent: Critical actors (always restart)
  → Temporary: One-time tasks (never restart)
  → Transient: Restart on errors only
```


## Review Checklist

When implementing actor systems:

- [ ] Each actor has clear single responsibility
- [ ] Mailboxes have bounded capacity (prevent memory leaks)
- [ ] Message types are Send + 'static
- [ ] No shared mutable state between actors
- [ ] Supervision strategy appropriate for error handling
- [ ] Actor lifecycle properly managed (cleanup in post_stop)
- [ ] No circular message dependencies (deadlock risk)
- [ ] Timeouts on request-response patterns
- [ ] Monitoring tracks mailbox size and message latency
- [ ] Backpressure handled when mailbox is full


## Verification Commands

```bash
# Run tests with actor system
cargo test --test actor_tests

# Check for deadlocks with timeout
cargo test --test deadlock_tests -- --test-threads=1 --nocapture

# Profile actor message throughput
cargo bench --bench actor_bench

# Check memory usage under load
cargo run --release --bin load_test

# Monitor actor lifecycle events
RUST_LOG=debug cargo run
```


## Common Pitfalls

### 1. Circular Message Dependencies (Deadlock)

**Symptom**: Actors waiting for each other's responses

```rust
// ❌ Bad: Actor A waits for Actor B, Actor B waits for Actor A
async fn actor_a_handler(&mut self, msg: Message) {
    let response = self.actor_b.request(msg).await;  // Blocks
    // Actor A is blocked, can't process Actor B's request
}

async fn actor_b_handler(&mut self, msg: Message) {
    let response = self.actor_a.request(msg).await;  // Blocks
    // Deadlock!
}

// ✅ Good: Use timeouts and avoid circular dependencies
async fn actor_a_handler(&mut self, msg: Message) {
    match tokio::time::timeout(
        Duration::from_secs(5),
        self.actor_b.request(msg)
    ).await {
        Ok(response) => { /* handle response */ }
        Err(_) => { /* timeout, handle error */ }
    }
}

// Better: redesign to avoid circular dependency
```

### 2. Unbounded Mailbox Growth

**Symptom**: Memory grows unbounded, OOM crashes

```rust
// ❌ Bad: unbounded channel
let (tx, rx) = mpsc::unbounded_channel();

// Slow consumer can't keep up, mailbox grows forever

// ✅ Good: bounded channel with backpressure
let (tx, rx) = mpsc::channel(100);  // Max 100 messages

// Sender will wait when mailbox is full (backpressure)
tx.send(msg).await?;
```

### 3. Blocking Operations in Actor

**Symptom**: Actor becomes unresponsive, messages pile up

```rust
// ❌ Bad: blocking I/O in actor
impl Actor for MyActor {
    fn receive(&mut self, ctx: &mut Context<Self>, msg: Self::Message) {
        // Blocks entire actor!
        let data = std::fs::read("file.txt").unwrap();
        // Other messages can't be processed
    }
}

// ✅ Good: use async I/O or spawn blocking task
impl Actor for MyActor {
    fn receive(&mut self, ctx: &mut Context<Self>, msg: Self::Message) {
        let addr = ctx.address();
        tokio::spawn(async move {
            // Runs in separate task
            let data = tokio::fs::read("file.txt").await.unwrap();
            addr.send(ProcessData(data)).await;
        });
        // Actor continues processing messages
    }
}
```


## Actix Framework Example

```rust
use actix::{Actor, Handler, Message, Context};

struct MyActor {
    counter: usize,
}

impl Actor for MyActor {
    type Context = Context<Self>;

    fn started(&mut self, _ctx: &mut Self::Context) {
        println!("Actor started");
    }

    fn stopped(&mut self, _ctx: &mut Self::Context) {
        println!("Actor stopped");
    }
}

#[derive(Message)]
#[rtype(result = "usize")]
struct Increment;

impl Handler<Increment> for MyActor {
    type Result = usize;

    fn handle(&mut self, _msg: Increment, _ctx: &mut Self::Context) -> Self::Result {
        self.counter += 1;
        self.counter
    }
}

// Usage
#[actix_rt::main]
async fn main() {
    let actor = MyActor { counter: 0 }.start();
    let result = actor.send(Increment).await.unwrap();
    println!("Counter: {}", result);
}
```


## Related Skills

- **rust-concurrency** - Concurrency primitives and patterns
- **rust-async** - Async message handling
- **rust-error** - Error propagation in actor systems
- **rust-channel** - Channel-based communication
- **rust-performance** - Actor system optimization


## Localized Reference

- **Chinese version**: [SKILL_ZH.md](./SKILL_ZH.md) - 完整中文版本，包含所有内容
