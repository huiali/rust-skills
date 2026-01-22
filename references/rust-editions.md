# Rust Editions: 2021 and 2024

Rust editions are backward-compatible language versions. Each edition brings new features while maintaining compatibility with older code.

## Rust 2021

### Key Features

#### 1. IntoIterator for Arrays
```rust
let arr = [1, 2, 3];
for i in arr {
    // Now works! Previously required arr.into_iter()
}
```

#### 2. Result-Insistent Types
```rust
// Default: Result<T, !> coerces to T
fn get_value() -> Result<u32, !> {
    Ok(42)
}
let value: u32 = get_value();
```

#### 3. Panic Payload Compatibility
```rust
use std::panic;

fn main() {
    let result = panic::catch_unwind(|| {
        panic!("error message");
    });
    
    if let Err(panic_info) = result {
        // Can now extract &str from panic info
        if let Some(msg) = panic_info.downcast_ref::<&str>() {
            println!("Panic: {}", msg);
        }
    }
}
```

#### 4. const Generics
```rust
struct Array<T, const N: usize> {
    data: [T; N],
}

let arr = Array::<i32, 5> { data: [0; 5] };
```

#### 5. Better Error Messages
- Improved borrow checker diagnostics
- More helpful lifetime error messages

## Rust 2024

### Key Features

#### 1. Never Type Patterns
```rust
fn always_panics() -> ! {
    panic!("This function never returns");
}
```

#### 2. Inline const Expressions
```rust
const fn double(x: i32) -> i32 {
    x * 2
}

let arr = [const { double(5) }; 10]; // [10; 10]
```

#### 3. Gen Blocks (Preview)
```rust
use std::sync::mpsc;

fn read_all_messages() -> impl Iterator<Item = String> {
    gen {
        let (tx, rx) = mpsc::channel();
        let handle = std::thread::spawn(move || {
            for line in std::io::stdin().lines() {
                let _ = tx.send(line.unwrap());
            }
        });
        
        while let Ok(msg) = rx.recv() {
            yield msg;
        }
        
        handle.join().unwrap();
    }
}
```

#### 4. Async Drop (Preview)
```rust
struct AsyncResource {
    // Fields
}

impl Drop for AsyncResource {
    fn drop(&mut self) {
        // Can now be async
    }
}
```

#### 5. Ownership Enhancements
```rust
// More ergonomic API for resource management
fn process(data: impl Into<ProcessedData>) {
    let processed = data.into();
    // ...
}
```

### Edition Compatibility

| Feature | 2018 | 2021 | 2024 |
|---------|------|------|------|
| const generics | No | Yes | Yes |
| async/await | Yes | Yes | Yes |
| never type `!` | Limited | Yes | Yes |
| gen blocks | No | No | Preview |
| inline const | No | No | Yes |

### Migration Guide

```bash
# Check edition compatibility
cargo fix --edition

# Test migration
cargo check --edition 2024
```

### Best Practices

1. **Default to Latest Stable**: Use 2024 for new projects
2. **Gradual Migration**: Migrate existing code when dependencies support it
3. **MSRV Consideration**: If supporting older Rust, check crate MSRV policies
4. **Feature Flags**: Use feature flags to enable edition-specific features

