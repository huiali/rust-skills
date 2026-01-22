# Rust Best Practices

A comprehensive guide to writing idiomatic, safe, and performant Rust code.

## Code Organization

### Module System

```rust
// lib.rs
pub mod frontend;
pub mod backend;
mod internal;

// Re-export for convenience
pub use backend::config::Config;
```

### Clear Module Hierarchy

```
src/
├── lib.rs          # Public API
├── error.rs        # Error types
├── lib.rs
├── main.rs         # Binary entry point
├── config.rs       # Configuration
├── api/
│   ├── mod.rs
│   ├── client.rs
│   └── server.rs
├── models/
│   ├── mod.rs
│   └── user.rs
└── utils/
    ├── mod.rs
    └── helpers.rs
```

## Naming Conventions

### General Rules

| Item | Convention | Example |
|------|------------|---------|
| Variables | snake_case | `let max_value` |
| Functions | snake_case | `fn calculate_total()` |
| Constants | SCREAMING_SCREAMING_SNAKE_CASE | `const MAX_CONNECTIONS` |
| Types | PascalCase | `struct UserProfile` |
| Traits | PascalCase | `trait Serialize` |
| Enums | PascalCase | `enum EventType` |
| Crates | kebab-case | `my-project` |

### Boolean Names

```rust
// ✅ Good
let is_valid = true;
let has_error = false;
let can_connect = true;

// ❌ Bad
let valid = true;
let error = false;
let connect = true;
```

### Getter Methods

```rust
pub struct User {
    name: String,
    age: u32,
}

impl User {
    // ✅ Good: Don't prefix with get_
    pub fn name(&self) -> &str {
        &self.name
    }
    
    pub fn age(&self) -> u32 {
        self.age
    }
}
```

## Error Handling

### Use Result for Recoverable Errors

```rust
// ✅ Good
fn parse_config(path: &Path) -> Result<Config, ConfigError> {
    let content = std::fs::read_to_string(path)?;
    serde_json::from_str(&content)?
}

// ❌ Bad: Panics for expected errors
fn parse_config(path: &Path) -> Config {
    std::fs::read_to_string(path)
        .expect("Failed to read config")
}
```

### Provide Context in Errors

```rust
use anyhow::{Context, Result};

fn load_user(id: u32) -> Result<User> {
    let db = Database::connect()
        .context("Failed to connect to database")?;
    
    let user = db.query_user(id)
        .with_context(|| format!("Failed to query user {}", id))?;
    
    Ok(user)
}
```

## Ownership and Borrowing

### Prefer Borrowing Over Copying

```rust
// ✅ Good
fn process_name(name: &str) {
    println!("{}", name);
}

// ❌ Bad: Unnecessary clone
fn process_name(name: &String) {
    let name = name.clone();  // Wasteful
    println!("{}", name);
}
```

### Use Appropriate Smart Pointers

```rust
// For single ownership: Box<T>
let heap_data = Box::new(ExpensiveData::default());

// For shared ownership (single-threaded): Rc<T>
let shared = Rc::new(data);

// For shared ownership (multi-threaded): Arc<T>
let atomic_shared = Arc::new(data);

// For interior mutability: RefCell<T>, Cell<T>
let cell = RefCell::new(value);
```

## Performance

### Stack vs Heap

```rust
// ✅ Prefer stack for small, fixed-size data
fn process_point(p: Point) { ... }  // Copy type

// Use heap for large data
fn process_large_data(data: Box<LargeStruct>) { ... }

// Use heap for dynamic sizing
fn process_dynamic_data(data: Vec<u8>) { ... }
```

### Avoid Unnecessary Allocations

```rust
// ❌ Bad: Multiple allocations
let result = format!("{}-{}-{}", a, b, c);

// ✅ Good: Pre-allocate
let mut result = String::with_capacity(50);
result.push_str(&a);
result.push('-');
result.push_str(&b);
```

## Documentation

### Doc Comments

```rust
/// Represents a user in the system.
///
/// # Fields
///
/// * `id` - Unique identifier
/// * `name` - User's display name
/// * `email` - Contact email address
///
/// # Examples
///
/// ```
/// let user = User::new(1, "Alice", "alice@example.com");
/// ```
///
/// # Panics
///
/// This function panics if the email format is invalid.
#[derive(Debug)]
pub struct User {
    pub id: u32,
    pub name: String,
    pub email: String,
}
```

### Module Documentation

```rust
//! Database operations module.
//!
//! This module provides abstractions for common database operations
//! including CRUD operations, transactions, and connection pooling.
//!
//! # Usage
//!
//! ```
//! use db::{Database, User};
//! let db = Database::connect("postgres://...").await?;
//! ```

pub mod connection;
pub mod transaction;
```

## Testing

### Test Organization

```rust
#[cfg(test)]
mod tests {
    use super::*;
    
    // Unit tests
    #[test]
    fn test_user_creation() { ... }
    
    // Property-based tests
    proptest! {
        #[test]
        fn test_serialization_roundtrip(user in any::<User>()) {
            let serialized = serde_json::to_string(&user).unwrap();
            let deserialized: User = serde_json::from_str(&serialized).unwrap();
            assert_eq!(user, deserialized);
        }
    }
}
```

## Dependencies

### Cargo.toml Best Practices

```toml
[package]
name = "my-project"
version = "0.1.0"
edition = "2024"

[dependencies]
# Version pinning
anyhow = "1.0"

# Optional features
serde = { version = "1.0", features = ["derive"] }

# Dev dependencies (only for tests/benchmarks)
[dev-dependencies]
proptest = "1.0"

[profile.release]
lto = true
opt-level = 3
```

## Code Quality

### Run Tools Regularly

```bash
# Format code
cargo fmt

# Check for lints
cargo clippy

# Find bugs
cargo test

# Check for security issues
cargo audit

# Update dependencies
cargo outdated
```

### CI Configuration

```yaml
# .github/workflows/ci.yml
jobs:
  check:
    run: |
      cargo fmt --check
      cargo clippy -- -D warnings
      cargo test --lib --bins --doc
```

## Summary Checklist

- [ ] Use `cargo fmt` for consistent formatting
- [ ] Use `cargo clippy` for linting
- [ ] Write comprehensive tests
- [ ] Document public APIs
- [ ] Use `Result` for error handling
- [ ] Prefer borrowing over cloning
- [ ] Use appropriate data structures
- [ ] Keep functions small and focused
- [ ] Use meaningful names
- [ ] Follow naming conventions

