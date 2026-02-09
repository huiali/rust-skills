---
name: rust-actor
description: "Actor-model skill for Rust systems: mailbox design, message flow, backpressure, deadlock avoidance, supervision strategies, lifecycle management, and Actix-style implementations."
---

# Rust Actor Model

## Core Question

**How do you avoid deadlocks while keeping message-driven concurrency reliable at scale?**

The actor model simplifies concurrency through state isolation and message passing.

## Actor Model vs Thread-Sharing Model

| Dimension | Shared-State Threads | Actor Model |
|---|---|---|
| State sharing | Shared memory + locks | Isolated state + messages |
| Deadlock risk | High (lock ordering) | Lower (mailbox ordering) |
| Scalability | Limited by lock contention | High with distributed actor systems |
| Fault handling | Manual, ad-hoc | Supervision strategies |
| Debuggability | Race-heavy and difficult | Message timeline is clearer |

## Actor Core Structure

```rust
trait Actor: Send + 'static {
    type Message: Send + 'static;
    type Error: std::error::Error + Send + Sync + 'static;

    fn receive(&mut self, ctx: &mut Context<Self::Message>, msg: Self::Message);
}

struct Context<M> {
    // mailbox/runtime-specific fields
    _marker: std::marker::PhantomData<M>,
}

enum ActorState {
    Starting,
    Running,
    Restarting,
    Stopping,
    Stopped,
}
```

## Message Passing Patterns

```rust
// fire-and-forget
fn send_async<A: Actor>(addr: &Addr<A>, msg: A::Message) {
    let _ = addr.try_send(msg);
}

// request-response with timeout
async fn request_with_timeout<A, R>(
    addr: &Addr<A>,
    msg: A::Message,
    timeout: std::time::Duration,
) -> Result<R, RequestError>
where
    A: Actor,
    A: Handler<A::Message, Result = R>,
{
    tokio::time::timeout(timeout, addr.send(msg))
        .await
        .map_err(|_| RequestError::Timeout)?
        .map_err(|_| RequestError::MailboxClosed)
}
```

Use envelopes/signals to separate:
- Business messages
- System/lifecycle signals
- Internal control messages

## Deadlock Prevention

1. Avoid cyclic synchronous waits between actors.
2. Use timeouts for request-response.
3. Keep mailbox bounded and apply backpressure.
4. Avoid blocking operations inside handlers.
5. Use explicit retry policies rather than infinite waits.

```rust
enum SendError {
    Timeout,
    MailboxFull,
    MailboxClosed,
}
```

## Mailbox and Backpressure

Design recommendations:
- Use bounded mailboxes for critical actors.
- Prefer dropping/coalescing low-priority messages over unbounded growth.
- Track queue length and processing latency metrics.
- Separate control and data-plane mailboxes for high-throughput systems.

## Supervision Strategy

```rust
enum SupervisionStrategy {
    OneForOne,
    AllForOne,
    RestForOne,
}
```

Guidelines:
- `OneForOne`: default for isolated workloads.
- `AllForOne`: use when child actors share tightly coupled state.
- `RestForOne`: use for dependency chains.

Restart policy should include:
- Max restarts in a rolling window.
- Circuit-breaker behavior on repeated failures.
- Escalation to parent supervisor.

## State Management

```rust
struct UserActor {
    id: u64,
    online: bool,
    followers: std::collections::HashSet<u64>,
}

impl UserActor {
    fn snapshot(&self) -> UserSnapshot {
        UserSnapshot {
            id: self.id,
            online: self.online,
            followers_count: self.followers.len(),
        }
    }
}
```

Rules:
- Keep actor state private.
- Mutate state only in actor context.
- Expose snapshots/queries through messages.

## Lifecycle Management

Lifecycle hooks (conceptual):
- `pre_start`: allocate resources.
- `post_start`: start timers/subscriptions.
- `pre_restart`: clean up partial state.
- `post_restart`: rehydrate and re-subscribe.
- `post_stop`: final flush and release.

Checklist:
- No leaked resources on restart/stop.
- Idempotent startup logic.
- Clear behavior for in-flight messages during restart.

## Actix Example

```rust
use actix::{Actor, Context, Handler, Message};

struct CounterActor {
    counter: usize,
}

impl Actor for CounterActor {
    type Context = Context<Self>;
}

#[derive(Message)]
#[rtype(result = "usize")]
struct Increment;

impl Handler<Increment> for CounterActor {
    type Result = usize;

    fn handle(&mut self, _msg: Increment, _ctx: &mut Self::Context) -> Self::Result {
        self.counter += 1;
        self.counter
    }
}
```

## Common Failure Patterns

| Problem | Typical Cause | Mitigation |
|---|---|---|
| Deadlock-like stalls | Circular request wait | Timeout + async message choreography |
| Message backlog | Slow consumer | Bounded mailbox + backpressure |
| Memory growth | Unbounded queues | Limit queue size + prioritize/drop policy |
| State inconsistency | Cross-actor shared mutable state | Strict state ownership per actor |
| Restart storms | Aggressive retry loops | Restart windows + exponential backoff |

## Skill Links

- `rust-concurrency`: low-level synchronization and Send/Sync analysis.
- `rust-async`: async task orchestration and cancellation handling.
- `rust-error`: error propagation contracts across actor boundaries.

## Localized Reference

- Original Chinese content is preserved in `SKILL_ZH.md`.
