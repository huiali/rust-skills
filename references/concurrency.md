# Concurrency Patterns in Rust

Rust's type system enforces memory safety and data race freedom at compile time.

## Send and Sync

### Send - Can Be Transferred Between Threads

```rust
// Types that implement Send:
// - All owned types (String, Vec, etc.)
// - Types with only Send fields
// - References (&T where T: Sync)

// ❌ Not Send: Rc<T> (reference counting not atomic)
```

### Sync - Can Be Shared Between Threads

```rust
// Types that implement Sync:
// - &T where T: Send
// - Mutex<T> where T: Send + Sync
// - Atomic types

// ❌ Not Sync: RefCell<T> (borrowing checked at runtime, not thread-safe)
```

## Basic Threading

### spawning Threads

```rust
use std::thread;
use std::time::Duration;

fn main() {
    let handle = thread::spawn(|| {
        for i in 1..=5 {
            println!("Thread: {}", i);
            thread::sleep(Duration::from_millis(100));
        }
    });
    
    for i in 1..=5 {
        println!("Main: {}", i);
        thread::sleep(Duration::from_millis(100));
    }
    
    handle.join().unwrap();  // Wait for thread
}
```

### Moving Values to Threads

```rust
fn main() {
    let v = vec![1, 2, 3];
    
    let handle = thread::spawn(move || {
        println!("Vector: {:?}", v);
    });
    
    handle.join().unwrap();
    // v is moved, cannot use here
}
```

## Shared State

### Mutex - Mutual Exclusion

```rust
use std::sync::{Arc, Mutex};
use std::thread;

fn main() {
    let counter = Arc::new(Mutex::new(0));
    let mut handles = vec![];
    
    for _ in 0..10 {
        let counter = Arc::clone(&counter);
        let handle = thread::spawn(move || {
            let mut num = counter.lock().unwrap();
            *num += 1;
        });
        handles.push(handle);
    }
    
    for handle in handles {
        handle.join().unwrap();
    }
    
    println!("Result: {}", *counter.lock().unwrap());
}
```

### RwLock - Multiple Readers, Single Writer

```rust
use std::sync::{Arc, RwLock};
use std::thread;

fn main() {
    let data = Arc::new(RwLock::new(0));
    let mut handles = vec![];
    
    // Multiple readers
    for _ in 0..5 {
        let data = Arc::clone(&data);
        let handle = thread::spawn(move || {
            let value = data.read().unwrap();
            println!("Read: {}", value);
        });
        handles.push(handle);
    }
    
    // Single writer
    {
        let mut value = data.write().unwrap();
        *value += 100;
        println!("Wrote: {}", value);
    }
    
    for handle in handles {
        handle.join().unwrap();
    }
}
```

## Message Passing

### Channels

```rust
use std::sync::mpsc;
use std::thread;

fn main() {
    let (tx, rx) = mpsc::channel();
    
    let tx1 = tx.clone();
    let handle1 = thread::spawn(move || {
        tx1.send("Hello from thread 1").unwrap();
    });
    
    let handle2 = thread::spawn(move || {
        tx.send("Hello from thread 2").unwrap();
    });
    
    for _ in 0..2 {
        println!("Received: {}", rx.recv().unwrap());
    }
    
    handle1.join().unwrap();
    handle2.join().unwrap();
}
```

### Multiple Values

```rust
use std::sync::mpsc;
use std::thread;

fn main() {
    let (tx, rx) = mpsc::channel();
    
    thread::spawn(move || {
        for i in 1..=5 {
            tx.send(i).unwrap();
            thread::sleep(std::time::Duration::from_millis(100));
        }
        drop(tx);  // Signal end of stream
    });
    
    for received in rx {
        println!("Got: {}", received);
    }
    
    println!("Channel closed");
}
```

## Atomics

### Basic Atomics

```rust
use std::sync::atomic::{AtomicUsize, Ordering};
use std::thread;

fn main() {
    let counter = AtomicUsize::new(0);
    let mut handles = vec![];
    
    for _ in 0..10 {
        let counter = &counter;
        let handle = thread::spawn(move || {
            counter.fetch_add(1, Ordering::SeqCst);
        });
        handles.push(handle);
    }
    
    for handle in handles {
        handle.join().unwrap();
    }
    
    println!("Counter: {}", counter.load(Ordering::SeqCst));
}
```

### Atomic Ordering

```rust
use std::sync::atomic::{AtomicBool, Ordering};

// Relaxed - No ordering guarantees, but atomic
// Acquire - Synchronizes with release
// Release - Synchronizes with acquire
// SeqCst - Sequential consistency (strongest, default)

fn example(ordering: Ordering) {
    let flag = AtomicBool::new(false);
    
    // Use SeqCst for correctness in most cases
    flag.store(true, Ordering::SeqCst);
    flag.load(Ordering::SeqCst);
}
```

## Scoped Threads

### std::thread::scope

```rust
use std::thread;

fn main() {
    let mut numbers = vec![1, 2, 3];
    
    thread::scope(|s| {
        s.spawn(|| {
            println!("Length: {}", numbers.len());
        });
        
        s.spawn(|| {
            numbers.push(4);  // Mutable access allowed!
        });
    });
    
    // Numbers is valid here - threads are scoped
    println!("Numbers: {:?}", numbers);
}
```

## Async Concurrency

### Tokio

```rust
use tokio::task;
use tokio::time::{sleep, Duration};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let handle = task::spawn(async {
        for i in 1..=5 {
            println!("Async task: {}", i);
            sleep(Duration::from_millis(100)).await;
        }
        "Done!"
    });
    
    println!("Waiting for task...");
    let result = handle.await?;
    println!("Result: {}", result);
    
    Ok(())
}
```

### Async Channels

```rust
use tokio::sync::mpsc;

#[tokio::main]
async fn main() {
    let (tx, mut rx) = mpsc::channel(32);
    
    tokio::spawn(async move {
        for i in 1..=5 {
            if tx.send(i).await.is_err() {
                break;
            }
        }
    });
    
    while let Some(value) = rx.recv().await {
        println!("Received: {}", value);
    }
}
```

### Mutex in Async

```rust
use tokio::sync::Mutex;
use std::sync::Arc;

#[tokio::main]
async fn main() {
    let counter = Arc::new(Mutex::new(0));
    let mut tasks = vec![];
    
    for _ in 0..5 {
        let counter = Arc::clone(&counter);
        let task = tokio::spawn(async move {
            let mut guard = counter.lock().await;
            *guard += 1;
            println!("Counter: {}", *guard);
        });
        tasks.push(task);
    }
    
    for task in tasks {
        task.await.unwrap();
    }
    
    println!("Final: {}", *counter.lock().await);
}
```

## Parallel Iterators

```rust
use rayon::prelude::*;

fn main() {
    let numbers: Vec<i32> = (1..=1000).collect();
    
    let sum: i32 = numbers
        .par_iter()
        .map(|&x| x * x)
        .sum();
    
    println!("Sum of squares: {}", sum);
}
```

## Sync Traits

### OnceLock and OnceCell

```rust
use std::sync::OnceLock;

fn get_global_config() -> &'static Config {
    static CONFIG: OnceLock<Config> = OnceLock::new();
    
    CONFIG.get_or_init(|| {
        Config::load()
    })
}
```

### Barrier

```rust
use std::sync::{Arc, Barrier};
use std::thread;

fn main() {
    let barrier = Arc::new(Barrier::new(10));
    let mut handles = vec![];
    
    for _ in 0..10 {
        let barrier = barrier.clone();
        let handle = thread::spawn(move || {
            println!("Before barrier");
            barrier.wait();
            println!("After barrier");
        });
        handles.push(handle);
    }
    
    for handle in handles {
        handle.join().unwrap();
    }
}
```

## Best Practices

### Do

```rust
// ✅ Use Arc for shared ownership
let shared = Arc::new(Data::new());

// ✅ Lock only as long as needed
{
    let data = mutex.lock().unwrap();
    process(&data);  // Don't hold lock during processing
}

// ✅ Use channels for loose coupling
let (tx, rx) = mpsc::channel();

// ✅ Prefer scoped threads for short-lived work
thread::scope(|s| {
    s.spawn(|| { /* ... */ });
});
```

### Don't

```rust
// ❌ Don't hold locks across await points in async
let mut guard = mutex.lock().unwrap();
some_async_operation().await;  // Could deadlock!
drop(guard);  // Release first

// ❌ Don't use Rc in multi-threaded code
let rc = std::rc::Rc::new(42);
// thread::spawn(move || println!("{}", rc));  // Error!

// ❌ Don't forget to join threads
let handle = thread::spawn(|| { /* ... */ });
handle.join();  // Always join!
```

## Summary

| Primitive | Use Case |
|-----------|----------|
| `thread::spawn` | Basic threading |
| `Arc<Mutex<T>>` | Shared mutable state |
| `Arc<RwLock<T>>` | Reader-writer lock |
| `mpsc::channel` | Message passing |
| `Atomic*` | Lock-free counters/flags |
| `Barrier` | Synchronize thread groups |
| `Condvar` | Wait for conditions |
| `tokio::spawn` | Async tasks |
| `rayon` | Parallel iterators |

