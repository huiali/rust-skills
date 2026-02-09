---
name: rust-mutability
description: Interior mutability expert covering Cell, RefCell, Mutex, RwLock patterns, borrow conflicts (E0596, E0499, E0502), and thread-safe mutation strategies.
metadata:
  triggers:
    - mutability
    - mut
    - Cell
    - RefCell
    - Mutex
    - RwLock
    - interior mutability
    - borrow conflict
    - E0596
    - E0499
    - E0502
---


## Mutability Types

| Type | Controller | Thread-Safe | Use Case |
|------|------------|-------------|----------|
| `&mut T` | External caller | Yes | Standard mutable borrow |
| `Cell<T>` | Interior | No | Copy types with interior mutability |
| `RefCell<T>` | Interior | No | Non-Copy types with interior mutability |
| `Mutex<T>` | Interior | Yes | Multi-threaded interior mutability |
| `RwLock<T>` | Interior | Yes | Multi-threaded read-write lock |


## Solution Patterns

### Pattern 1: External Mutability

```rust
// Standard mutable borrow
fn increment(counter: &mut u32) {
    *counter += 1;
}

// Mutable method
impl Counter {
    fn increment(&mut self) {
        self.value += 1;
    }
}
```

**When to use**: Default choice, mutability controlled by caller.

### Pattern 2: Cell for Copy Types

```rust
use std::cell::Cell;

struct State {
    count: Cell<u32>,
}

impl State {
    // Get immutable &self, mutate interior
    fn increment(&self) {
        self.count.set(self.count.get() + 1);
    }
}
```

**When to use**: Simple values (Copy types) need interior mutability.

**Trade-offs**: Only works with Copy types, no references.

### Pattern 3: RefCell for Non-Copy Types

```rust
use std::cell::RefCell;

struct Cache {
    data: RefCell<HashMap<String, Value>>,
}

impl Cache {
    fn insert(&self, key: String, value: Value) {
        self.data.borrow_mut().insert(key, value);
    }

    fn get(&self, key: &str) -> Option<Value> {
        self.data.borrow().get(key).cloned()
    }
}
```

**When to use**: Need `&mut T` from `&self`, single-threaded.

**Trade-offs**: Runtime borrow checking, can panic.

### Pattern 4: Mutex for Thread Safety

```rust
use std::sync::Mutex;

struct SharedState {
    data: Mutex<HashMap<String, Value>>,
}

impl SharedState {
    fn insert(&self, key: String, value: Value) {
        self.data.lock().unwrap().insert(key, value);
    }
}
```

**When to use**: Multi-threaded interior mutability.

**Trade-offs**: Lock contention, can deadlock.

### Pattern 5: RwLock for Read-Heavy Workloads

```rust
use std::sync::RwLock;

struct Config {
    settings: RwLock<HashMap<String, String>>,
}

impl Config {
    fn get(&self, key: &str) -> Option<String> {
        self.settings.read().unwrap().get(key).cloned()
    }

    fn update(&self, key: String, value: String) {
        self.settings.write().unwrap().insert(key, value);
    }
}
```

**When to use**: Many readers, few writers.

**Trade-offs**: Write locks more expensive than Mutex.


## Borrow Rules

```
At any time, you can have either:
├─ Multiple &T (immutable borrows)
└─ OR one &mut T (mutable borrow)

Never both simultaneously
```


## Error Code Quick Reference

| Code | Meaning | Don't Say | Ask Instead |
|------|---------|-----------|-------------|
| E0596 | Cannot get mutable reference | "add mut" | Does this really need mutability? |
| E0499 | Multiple mutable borrows conflict | "split borrows" | Is data structure design correct? |
| E0502 | Borrow conflict | "separate scopes" | Why both borrows needed simultaneously? |
| RefCell panic | Runtime borrow error | "use try_borrow" | Is runtime checking appropriate? |


## Workflow

### Step 1: Choose Mutability Strategy

```
Single-threaded?
  Need &mut from &self?
    → RefCell<T>
  Copy type?
    → Cell<T>
  Otherwise?
    → &mut T

Multi-threaded?
  Simple atomic?
    → AtomicU64/AtomicBool
  Complex data?
    Read-heavy → RwLock<T>
    Write-heavy → Mutex<T>
```

### Step 2: Handle Borrow Conflicts

```
E0499 (multiple mut borrows)?
  → Split struct into smaller pieces
  → Use Cell/RefCell for interior mutability
  → Redesign to avoid simultaneous access

E0502 (borrow conflict)?
  → Minimize borrow scopes
  → Clone data if needed
  → Restructure code flow
```

### Step 3: Consider Trade-offs

```
RefCell?
  ✅ Flexible
  ❌ Runtime panics possible
  → Use in prototypes, single-threaded

Mutex?
  ✅ Thread-safe
  ❌ Lock contention
  → Profile before optimizing

RwLock?
  ✅ Many readers efficient
  ❌ Writer starvation possible
  → Use when reads >> writes
```


## Thread-Safe Selection

### Atomic Types

```rust
use std::sync::atomic::{AtomicU64, Ordering};

let counter = AtomicU64::new(0);
counter.fetch_add(1, Ordering::Relaxed);
```

**Use when**: Simple counters, flags.

### Mutex

```rust
use std::sync::Mutex;

let data = Mutex::new(HashMap::new());
data.lock().unwrap().insert(key, value);
```

**Use when**: Thread-safe mutation, balanced read/write.

### RwLock

```rust
use std::sync::RwLock;

let data = RwLock::new(HashMap::new());
data.read().unwrap().get(&key);  // Many readers
data.write().unwrap().insert(key, value);  // Few writers
```

**Use when**: Read-heavy workloads (10+ reads per write).


## Common Pitfalls

### 1. Borrow Conflict

**Symptom**: E0499, E0502 errors

```rust
// ❌ Bad: multiple mutable borrows
let r1 = &mut data.field1;
let r2 = &mut data.field2;  // Error!

// ✅ Good: split borrows
let (field1, field2) = (&mut data.field1, &mut data.field2);

// ✅ Better: restructure
struct Data {
    part1: Part1,
    part2: Part2,
}
```

### 2. RefCell Panic

**Symptom**: "already borrowed" panic at runtime

```rust
// ❌ Bad: nested borrows
let cell = RefCell::new(vec![1, 2, 3]);
let borrow1 = cell.borrow();
let borrow2 = cell.borrow_mut();  // Panics!

// ✅ Good: drop first borrow
{
    let borrow1 = cell.borrow();
    // use borrow1...
}  // dropped
let borrow2 = cell.borrow_mut();  // OK

// ✅ Better: use try_borrow
if let Ok(mut b) = cell.try_borrow_mut() {
    // safe mutation
}
```

### 3. Lock Held Across Await

**Symptom**: Deadlock in async code

```rust
// ❌ Bad: MutexGuard across await
let guard = mutex.lock().unwrap();
async_op().await;  // DANGER

// ✅ Good: drop lock before await
let value = {
    let guard = mutex.lock().unwrap();
    guard.clone()
};  // lock dropped
async_op().await;
```


## Review Checklist

When reviewing mutability code:

- [ ] Mutability truly necessary (not premature)
- [ ] Appropriate mutability type chosen (Cell/RefCell/Mutex)
- [ ] RefCell used only in single-threaded contexts
- [ ] Mutex/RwLock used for multi-threaded access
- [ ] Lock scopes minimized to avoid contention
- [ ] No locks held across `.await` points
- [ ] Borrow conflicts resolved at design level
- [ ] Runtime panics handled (try_borrow)
- [ ] Atomic types used for simple counters/flags
- [ ] Read-write patterns match RwLock choice


## Verification Commands

```bash
# Check compilation
cargo check

# Look for borrow conflict errors
cargo check 2>&1 | grep -E "E0499|E0502|E0596"

# Run tests
cargo test

# Check for deadlocks (with loom)
cargo test --features loom

# Clippy warnings
cargo clippy -- -W clippy::mutex_atomic
```


## Advanced Patterns

### Splitting Borrows

```rust
// ✅ Split struct to enable simultaneous borrows
struct Data {
    readers: Vec<Reader>,
    writers: Vec<Writer>,
}

fn process(data: &mut Data) {
    let readers = &data.readers;
    let writers = &mut data.writers;  // OK, different fields
    // use both...
}
```

### Interior Mutability with Shared Ownership

```rust
use std::sync::{Arc, Mutex};

#[derive(Clone)]
struct Shared {
    inner: Arc<Mutex<Inner>>,
}

impl Shared {
    fn update(&self) {
        self.inner.lock().unwrap().modify();
    }
}
```


## Related Skills

- **rust-ownership** - Ownership and borrowing fundamentals
- **rust-concurrency** - Thread-safe patterns
- **rust-unsafe** - UnsafeCell and low-level mutability
- **rust-anti-pattern** - Mutability anti-patterns
- **rust-performance** - Lock contention optimization


## Localized Reference

- **Chinese version**: [SKILL_ZH.md](./SKILL_ZH.md) - 完整中文版本，包含所有内容
