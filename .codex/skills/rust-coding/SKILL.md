---
name: rust-coding
description: 'Rust coding conventions expert covering naming, formatting, comments,
  clippy, rustfmt,

  lints, code style, best practices, and idiomatic patterns.

  '
metadata:
  triggers:
  - coding convention
  - naming
  - formatting
  - clippy
  - rustfmt
  - lint
  - code style
  - best practice
  - idiomatic
  - code review
---

# Rust Coding Conventions Expert

## Core Question

**What makes Rust code "idiomatic"?**

Follow community conventions to make code readable and maintainable.

---

## Naming Conventions (Rust-Specific)

| Rule | Correct | Incorrect |
|------|---------|-----------|
| No `get_` prefix for methods | `fn name(&self)` | `fn get_name(&self)` |
| Iterator methods | `iter()` / `iter_mut()` / `into_iter()` | `get_iter()` |
| Conversion naming | `as_` (cheap), `to_` (expensive), `into_` (ownership) | Mixed usage |
| `static` variables uppercase | `static CONFIG: Config` | `static config: Config` |
| `const` variables | `const BUFFER_SIZE: usize = 1024` | No restriction |

### General Naming

```rust
// Variables and functions: snake_case
let max_connections = 100;
fn process_data() { ... }

// Types and traits: CamelCase
struct UserSession;
trait Cacheable {}

// Constants: SCREAMING_SNAKE_CASE
const MAX_CONNECTIONS: usize = 100;
static CONFIG: once_cell::sync::Lazy<Config> = ...
```

---

## Solution Patterns

### Pattern 1: Conversion Methods

```rust
impl Buffer {
    // as_ - cheap, view conversion
    pub fn as_slice(&self) -> &[u8] {
        &self.data
    }

    // to_ - expensive, allocating conversion
    pub fn to_vec(&self) -> Vec<u8> {
        self.data.clone()
    }

    // into_ - consuming, ownership transfer
    pub fn into_vec(self) -> Vec<u8> {
        self.data
    }
}
```

### Pattern 2: Newtype Pattern

```rust
// ✅ Domain semantics with newtypes
struct Email(String);
struct UserId(u64);
struct Meters(f64);

impl Email {
    pub fn new(s: impl Into<String>) -> Result<Self, EmailError> {
        let email = s.into();
        if email.contains('@') {
            Ok(Self(email))
        } else {
            Err(EmailError::Invalid)
        }
    }
}
```

### Pattern 3: Error Handling

```rust
// ✅ Good: propagate errors
fn read_config() -> Result<Config, ConfigError> {
    let content = std::fs::read_to_string("config.toml")
        .map_err(ConfigError::from)?;
    toml::from_str(&content)
        .map_err(ConfigError::Parse)
}

// ❌ Avoid: panic in library code
fn read_config() -> Config {
    std::fs::read_to_string("config.toml").unwrap()  // panic!
}

// ✅ Use expect when invariant guaranteed
fn get_user(&self) -> &User {
    self.user.as_ref()
        .expect("user always initialized in constructor")
}
```

### Pattern 4: String Handling

```rust
// ✅ Accept &str in APIs
fn greet(name: &str) {
    println!("Hello, {}", name);
}

// ✅ Use Cow when might need owned
use std::borrow::Cow;

fn process(input: &str) -> Cow<str> {
    if input.contains("special") {
        Cow::Owned(input.replace("special", "normal"))
    } else {
        Cow::Borrowed(input)
    }
}

// ✅ Pre-allocate when size known
let mut s = String::with_capacity(100);
```

---

## Data Type Guidelines

| Rule | Description | Example |
|------|-------------|---------|
| Use newtype | Domain semantics | `struct Email(String)` |
| Use slice patterns | Pattern matching | `if let [first, .., last] = slice` |
| Pre-allocate | Avoid reallocations | `Vec::with_capacity()` |
| Avoid Vec abuse | Fixed size → array | `let arr: [u8; 256]` |

### String Guidelines

| Rule | Description |
|------|-------------|
| ASCII data use `bytes()` | `s.bytes()` faster than `s.chars()` |
| Might modify → `Cow<str>` | Borrow or owned |
| Use `format!` for concat | Better than `+` operator |
| Avoid nested `contains()` | O(n*m) complexity |

---

## Error Handling Guidelines

| Rule | Description |
|------|-------------|
| Use `?` to propagate | Don't use `try!()` macro |
| `expect()` over `unwrap()` | When value guaranteed |
| Use `assert!` for invariants | At function entry |

---

## Memory and Lifetimes

| Rule | Description |
|------|-------------|
| Meaningful lifetime names | `'src`, `'ctx` not just `'a` |
| `RefCell` use `try_borrow` | Avoid panics |
| Use shadowing for conversions | `let x = x.parse()?` |

---

## Concurrency Guidelines

| Rule | Description |
|------|-------------|
| Define lock ordering | Prevent deadlocks |
| Atomics for primitives | Not `Mutex<bool>` |
| Choose memory ordering carefully | Relaxed/Acquire/Release/SeqCst |

---

## Async Guidelines

| Rule | Description |
|------|-------------|
| CPU-bound → sync | Async for I/O |
| Don't hold locks across await | Use scoped guards |

---

## Macro Guidelines

| Rule | Description |
|------|-------------|
| Avoid macros (unless necessary) | Prefer functions/generics |
| Macro input like Rust | Readability first |

---

## Deprecated Patterns → Modern

| Deprecated | Modern | Version |
|-----------|---------|---------|
| `lazy_static!` | `std::sync::OnceLock` | 1.70 |
| `once_cell::Lazy` | `std::sync::LazyLock` | 1.80 |
| `std::sync::mpsc` | `crossbeam::channel` | - |
| `std::sync::Mutex` | `parking_lot::Mutex` | - |
| `failure`/`error-chain` | `thiserror`/`anyhow` | - |
| `try!()` | `?` operator | 2018 |

---

## Clippy Configuration

```toml
[package]
edition = "2024"
rust-version = "1.85"

[lints.rust]
unsafe_code = "warn"

[lints.clippy]
all = "warn"
pedantic = "warn"
```

### Common Clippy Lints

| Lint | Description |
|------|-------------|
| `clippy::all` | Enable all warnings |
| `clippy::pedantic` | Stricter checks |
| `clippy::unwrap_used` | Avoid unwrap |
| `clippy::expect_used` | Prefer expect |
| `clippy::clone_on_ref_ptr` | Avoid cloning Arc |

---

## Formatting (rustfmt)

```bash
# Use default config
rustfmt src/lib.rs

# Check formatting
rustfmt --check src/lib.rs

# Config file: .rustfmt.toml
max_width = 100
tab_spaces = 4
edition = "2024"
```

---

## Documentation Guidelines

```rust
/// Module documentation
//! This module handles user authentication...

/// Struct documentation
///
/// # Examples
/// ```
/// let user = User::new("name");
/// ```
pub struct User { ... }

/// Method documentation
///
/// # Arguments
///
/// * `name` - User name
///
/// # Returns
///
/// Initialized user instance
///
/// # Panics
///
/// Panics when name is empty
pub fn new(name: &str) -> Self { ... }
```

---

## Workflow

### Step 1: Name Things Properly

```
Choosing a name?
  → Function/variable? snake_case
  → Type/trait? CamelCase
  → Constant? SCREAMING_SNAKE_CASE
  → Conversion method?
    - Cheap view? as_foo()
    - Expensive? to_foo()
    - Consuming? into_foo()
```

### Step 2: Format Code

```bash
# Run rustfmt
cargo fmt

# Check formatting in CI
cargo fmt --check

# Fix clippy warnings
cargo clippy --fix
```

### Step 3: Review Idioms

```
Check:
  → No unnecessary clone()
  → Use ? not unwrap()
  → &str in function parameters
  → Iterator methods not index loops
  → Meaningful error types
```

---

## Quick Reference

```
Naming: snake_case (fn/var), CamelCase (type), SCREAMING_SNAKE_CASE (const)
Format: rustfmt (just use it)
Docs: /// for public items, //! for module docs
Lint: #![warn(clippy::all)]
```

---

## Review Checklist

When reviewing code:

- [ ] Naming follows Rust conventions
- [ ] Using `?` instead of `unwrap()`
- [ ] Avoiding unnecessary `clone()`
- [ ] `unsafe` blocks have SAFETY comments
- [ ] Public APIs have doc comments
- [ ] Ran `cargo clippy`
- [ ] Ran `cargo fmt`
- [ ] No `get_` prefix on accessor methods
- [ ] Conversion methods named correctly (as/to/into)
- [ ] String parameters use `&str` when possible

---

## Verification Commands

```bash
# Format check
cargo fmt --check

# Lint check
cargo clippy -- -D warnings

# Documentation check
cargo doc --no-deps --open

# Run tests
cargo test

# Check naming conventions
cargo clippy -- -W clippy::wrong_self_convention
```

---

## Common Pitfalls

### 1. Wrong Method Naming

**Symptom**: Clippy warning `wrong_self_convention`

```rust
// ❌ Bad: unnecessary get_ prefix
impl User {
    fn get_name(&self) -> &str { &self.name }
}

// ✅ Good: direct accessor
impl User {
    fn name(&self) -> &str { &self.name }
}
```

### 2. String Type Misuse

**Symptom**: Unnecessary allocations

```rust
// ❌ Bad: forces allocation
fn greet(name: String) {
    println!("Hello, {}", name);
}

// ✅ Good: accepts borrowed or owned
fn greet(name: &str) {
    println!("Hello, {}", name);
}

// Both work now:
greet("Alice");  // &str
greet(&owned_string);  // &String → &str
```

### 3. Index Loops

**Symptom**: Less idiomatic, error-prone

```rust
// ❌ Bad: manual indexing
for i in 0..items.len() {
    println!("{}: {}", i, items[i]);
}

// ✅ Good: iterator
for item in &items {
    println!("{}", item);
}

// ✅ Good: with index
for (i, item) in items.iter().enumerate() {
    println!("{}: {}", i, item);
}
```

---

## Related Skills

- **rust-anti-pattern** - What not to do
- **rust-error** - Error handling patterns
- **rust-performance** - Performance idioms
- **rust-async** - Async conventions
- **rust-unsafe** - SAFETY comment style

---

## Localized Reference

- **Chinese version**: [SKILL_ZH.md](./SKILL_ZH.md) - 完整中文版本，包含所有内容
