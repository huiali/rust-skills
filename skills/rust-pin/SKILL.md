---
name: rust-pin
description: Pin and self-referential types expert covering Pin, Unpin, Future, async state machines, pinning projection, and memory stability guarantees.
metadata:
  triggers:
    - Pin
    - Unpin
    - self-referential
    - Future
    - async
    - Generator
    - pinning
    - memory stability
---


## When Pin is Needed

### 1. async/await Futures

```rust
use std::pin::Pin;
use std::task::{Context, Poll};
use std::future::Future;

struct MyFuture {
    state: State,
}

impl Future for MyFuture {
    type Output = ();

    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
        // self is pinned, guaranteed not to move
        let this = self.get_mut();
        Poll::Ready(())
    }
}
```

### 2. Self-Referential Structures

```rust
use std::pin::Pin;

struct Node {
    value: i32,
    // Self-reference: pointer to field within same struct
    next: Option<Pin<Box<Node>>>,
}
```


## Solution Patterns

### Pattern 1: Pinning on Heap

```rust
use std::pin::Pin;

let future = async {
    // async block creates a Future
};

// Pin future on heap
let pinned: Pin<Box<dyn Future<Output = ()>>> = Box::pin(future);

// Now safe to poll
```

### Pattern 2: Pinning with Pin::new_unchecked

```rust
use std::pin::Pin;

struct SelfReferential {
    data: String,
    ptr: *const String,  // Points to data field
}

impl SelfReferential {
    fn new(data: String) -> Pin<Box<Self>> {
        let mut boxed = Box::new(SelfReferential {
            data,
            ptr: std::ptr::null(),
        });

        let ptr = &boxed.data as *const String;
        boxed.ptr = ptr;

        // SAFETY: boxed is on heap and won't move
        unsafe { Pin::new_unchecked(boxed) }
    }

    fn data(&self) -> &str {
        // SAFETY: ptr still valid because we're pinned
        unsafe { &*self.ptr }
    }
}
```

### Pattern 3: Pin Projection

```rust
use std::pin::Pin;

struct Wrapper<T> {
    inner: T,
    extra: String,
}

impl<T: Unpin> Wrapper<T> {
    // Safe projection: T is Unpin
    fn project(self: Pin<&mut Self>) -> Pin<&mut T> {
        Pin::new(&mut self.get_mut().inner)
    }
}

impl<T> Wrapper<T> {
    // Unsafe projection: must maintain invariants
    fn project_unchecked(self: Pin<&mut Self>) -> Pin<&mut T> {
        // SAFETY: if Self is pinned, inner field is also pinned
        unsafe {
            Pin::new_unchecked(&mut self.get_unchecked_mut().inner)
        }
    }
}
```

### Pattern 4: Pinning in Async Context

```rust
use std::pin::Pin;
use futures::Future;

async fn process_data() {
    let mut state = String::new();

    // This reference is held across await
    let state_ref = &mut state;

    some_async_operation().await;

    // state_ref must remain valid
    state_ref.push_str("data");
}

// Compiler ensures state doesn't move by pinning the Future
```


## Pin Types

| Type | Use Case | Example |
|------|----------|---------|
| `Pin<&T>` | Borrowed, immutable | `Pin<&Foo>` |
| `Pin<&mut T>` | Borrowed, mutable | `Pin<&mut Foo>` |
| `Pin<Box<T>>` | Owned on heap | `Pin<Box<Foo>>` |
| `Pin<Arc<T>>` | Shared ownership | `Pin<Arc<Foo>>` |


## Unpin Marker Trait

```rust
// Most types implement Unpin (safe to move)
struct MyType {
    data: Vec<u8>,
}
// Unpin auto-implemented

// Which types DON'T implement Unpin?
// - Futures (from async/await)
// - Generators
// - Manually marked with PhantomPinned

use std::marker::PhantomPinned;

struct NotUnpin {
    data: String,
    _pin: PhantomPinned,  // Opts out of Unpin
}
```


## Workflow

### Step 1: Determine if Pin Needed

```
Need Pin when:
  → async/await (Future trait)
  → Self-referential struct
  → Implementing custom Future
  → Working with generators

Don't need Pin when:
  → Synchronous code
  → No self-references
  → Stack-allocated temporaries
  → Type is Unpin
```

### Step 2: Choose Pinning Strategy

```
Heap pinning:
  → Box::pin(value)
  → Safe, most common

Stack pinning:
  → pin!(value)  // macro in std
  → More complex, zero allocation

Unsafe pinning:
  → Pin::new_unchecked()
  → Require SAFETY comments
```

### Step 3: Handle Projections

```
Projecting to field:
  → If T: Unpin → Safe with Pin::new
  → If !Unpin → Unsafe, need Pin::new_unchecked
  → Use pin-project crate for safety
```


## Common Use Cases

| Scenario | Need Pin? |
|----------|-----------|
| `async {}` block | ✅ Yes (Future) |
| `Box<dyn Future>` | ✅ Yes |
| Self-referential struct | ✅ Yes |
| Regular Vec/HashMap | ❌ No |
| Stack variables | ❌ No |
| No self-references | ❌ No |


## Review Checklist

When working with Pin:

- [ ] Pin actually necessary (async or self-ref)
- [ ] Correct pinning strategy chosen (heap vs stack)
- [ ] Unsafe projections have SAFETY comments
- [ ] Type correctly implements/opts-out of Unpin
- [ ] No accidental moves after pinning
- [ ] Projection maintains structural pinning
- [ ] Drop implementation respects pinning
- [ ] Documentation explains why pinned


## Verification Commands

```bash
# Check if type is Unpin
cargo expand

# Verify async state machine
cargo expand --lib my_async_fn

# Test with miri
cargo +nightly miri test
```


## Common Pitfalls

### 1. Forgetting to Pin Future

**Symptom**: Compilation error about poll signature

```rust
// ❌ Bad: Future not pinned
fn poll_future(mut future: impl Future) {
    future.poll();  // Error: no poll method
}

// ✅ Good: Pin the Future
fn poll_future(mut future: Pin<&mut impl Future>) {
    future.as_mut().poll(cx);  // OK
}
```

### 2. Moving Pinned Value

**Symptom**: Undefined behavior

```rust
// ❌ Bad: moving after pinning
let pinned = Box::pin(value);
let moved = *pinned;  // Error: cannot move out of pinned

// ✅ Good: work with pinned reference
let pinned = Box::pin(value);
let pinned_ref: Pin<&mut Value> = pinned.as_mut();
```

### 3. Incorrect Projection

**Symptom**: Unsoundness in self-referential types

```rust
// ❌ Bad: unsafe projection without guarantee
impl<T> Wrapper<T> {
    fn bad_project(self: Pin<&mut Self>) -> &mut T {
        &mut self.get_mut().inner  // Unsound if T: !Unpin
    }
}

// ✅ Good: safe projection with Unpin bound
impl<T: Unpin> Wrapper<T> {
    fn safe_project(self: Pin<&mut Self>) -> Pin<&mut T> {
        Pin::new(&mut self.get_mut().inner)
    }
}
```


## Related Skills

- **rust-async** - Async/await and Future trait
- **rust-unsafe** - Unsafe code for Pin::new_unchecked
- **rust-ownership** - Lifetime and borrowing
- **rust-type-driven** - PhantomPinned and marker types
- **rust-performance** - Zero-cost abstractions with Pin


## Localized Reference

- **Chinese version**: [SKILL_ZH.md](./SKILL_ZH.md) - 完整中文版本，包含所有内容
