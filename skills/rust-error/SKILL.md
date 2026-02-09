---
name: rust-error
description: Error handling expert covering Result, Option, panic strategies, custom error types with thiserror/anyhow, error propagation patterns, and context-rich error chains.
metadata:
  triggers:
    - Result
    - Error
    - panic
    - '?'
    - unwrap
    - expect
    - anyhow
    - thiserror
    - error handling
    - Option
---


## Solution Patterns

### Pattern 1: Option for Normal Absence

```rust
// Lookup operations where "not found" is normal
fn find_user(id: u32) -> Option<User> {
    users.get(&id)
}

// Usage patterns
match find_user(123) {
    Some(user) => println!("Found: {}", user.name),
    None => println!("User not found"),
}

// Or convert to Result for propagation
let user = find_user(123).ok_or(UserNotFoundError)?;
```

**When to use**: Queries, lookups, optional configuration values.

**Key insight**: `None` carries no information, just absence.

### Pattern 2: Result for Expected Failures

```rust
// File might not exist (expected failure)
fn read_config(path: &Path) -> Result<String, io::Error> {
    std::fs::read_to_string(path)
}

// Network request might timeout
fn fetch(url: &str) -> Result<Response, reqwest::Error> {
    reqwest::blocking::get(url)
}
```

**When to use**: I/O operations, parsing, validation, network calls.

**Key insight**: Error type carries information about *why* it failed.

### Pattern 3: Custom Error Types (thiserror)

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum ParseError {
    #[error("invalid format: {0}")]
    InvalidFormat(String),

    #[error("missing required field: {0}")]
    MissingField(&'static str),

    #[error("IO error")]
    Io(#[from] io::Error),

    #[error("parse error: {0}")]
    Parse(#[from] serde_json::Error),
}

// Use in library code
pub fn parse_config(input: &str) -> Result<Config, ParseError> {
    let raw: RawConfig = serde_json::from_str(input)?;  // Auto-converts
    validate_config(raw)
}
```

**When to use**: Library code, public APIs, need type-safe error handling.

**Trade-offs**: More boilerplate, but precise error types.

### Pattern 4: Flexible Errors (anyhow)

```rust
use anyhow::{Context, Result, bail};

fn process_request() -> Result<Response> {
    let config = std::fs::read_to_string("config.json")
        .context("failed to read config file")?;

    let parsed: Config = serde_json::from_str(&config)
        .context("failed to parse config as JSON")?;

    if !parsed.is_valid() {
        bail!("invalid configuration: missing API key");
    }

    Ok(build_response(parsed))
}
```

**When to use**: Application code, rapid development, error context matters more than types.

**Trade-offs**: Loses type information, but gains flexibility and context.


## Workflow

### Step 1: Classify the Failure

```
Is absence normal?
  → Option<T>

Is failure expected and recoverable?
  → Result<T, E>

Is this a bug or invariant violation?
  → panic!() or assert!()
```

### Step 2: Choose Error Representation

```
Library code (public API)?
  → thiserror (typed errors)

Application code (internal)?
  → anyhow (flexible errors)

Need error conversions?
  → Implement From traits
```

### Step 3: Propagate or Handle

```
Can caller handle this?
  → Return Result, use ?

Need to add context?
  → .context("why it failed")?

Must handle here?
  → match / if let / unwrap_or
```


## Error Propagation Best Practices

### ✅ Good Patterns

```rust
// Clear error types
fn validate() -> Result<(), ValidationError> {
    if name.is_empty() {
        return Err(ValidationError::EmptyName);
    }
    Ok(())
}

// Add context during propagation
let config = File::open("config.json")
    .context("failed to open config.json")?;

// Use ? operator
let data = read_file(&path)?;

// Provide defaults
let timeout = config.timeout.unwrap_or(Duration::from_secs(30));

// Pattern match for complex handling
match parse_input(input) {
    Ok(value) => process(value),
    Err(ParseError::InvalidFormat(msg)) => log_and_retry(msg),
    Err(e) => return Err(e),
}
```

### ❌ Anti-Patterns

```rust
// ❌ unwrap() on operations that can fail
let content = std::fs::read_to_string("config.json").unwrap();

// ❌ Silently ignore errors
let _ = some_fallible_operation();

// ❌ Generic error messages
Err(anyhow!("error"))  // Too vague

// ❌ Converting all errors to strings
.map_err(|e| e.to_string())?  // Loses type info

// ❌ Panic for expected failures
let num: i32 = input.parse().expect("parse failed");  // User input!
```


## When to Panic

### ✅ Acceptable Panic Scenarios

| Scenario | Example | Reasoning |
|----------|---------|-----------|
| Invariant violation | Array index out of bounds | Programming bug |
| Initialization checks | `env::var("HOME").expect(...)` | Required for program to run |
| Test assertions | `assert_eq!(result, expected)` | Verify assumptions |
| Unrecoverable state | OOM, corrupted data structures | Can't continue safely |

```rust
// ✅ Acceptable: initialization check
let api_key = std::env::var("API_KEY")
    .expect("API_KEY environment variable must be set");

// ✅ Acceptable: test assertion
#[test]
fn test_user_creation() {
    let user = create_user("Alice");
    assert_eq!(user.name, "Alice");
}

// ✅ Acceptable: invariant violation
let first = queue.pop().expect("queue should never be empty at this point");
```

### ❌ Unacceptable Panic Scenarios

```rust
// ❌ User input validation
let num: i32 = input.parse().unwrap();  // Use Result instead

// ❌ Network operations
let response = reqwest::blocking::get(url).unwrap();  // Use Result

// ❌ File operations
let config = std::fs::read_to_string("config.json").unwrap();  // Use Result
```


## Error Type Design

### Enum for Multiple Error Cases

```rust
#[derive(Error, Debug)]
pub enum ConfigError {
    #[error("file not found at {path}")]
    FileNotFound { path: String },

    #[error("invalid syntax at line {line}: {message}")]
    InvalidSyntax { line: usize, message: String },

    #[error("missing required field: {0}")]
    MissingField(String),

    #[error(transparent)]
    Io(#[from] io::Error),

    #[error(transparent)]
    Parse(#[from] serde_json::Error),
}
```

### Nested Errors with Context

```rust
#[derive(Error, Debug)]
pub enum AppError {
    #[error("configuration error")]
    Config(#[from] ConfigError),

    #[error("database error")]
    Database(#[from] DatabaseError),

    #[error("authentication failed: {0}")]
    Auth(String),
}
```


## Common Pitfalls

| Anti-Pattern | Problem | Correct Approach |
|--------------|---------|------------------|
| `.unwrap()` everywhere | Production panics | Use `?` or `.with_context()` |
| `Box<dyn Error>` | Loses type information | Use thiserror enums |
| Silent error ignoring | Bugs go unnoticed | Handle or propagate |
| Deep error hierarchies | Over-engineering | Design as needed |
| Panic for control flow | Abusing panic | Use normal control flow |
| String errors | No pattern matching | Use typed errors |


## Quick Reference

| Scenario | Choice | Tool |
|----------|--------|------|
| Library returns custom errors | `Result<T, CustomEnum>` | thiserror |
| Application rapid development | `Result<T, anyhow::Error>` | anyhow |
| Absence is normal | `Option<T>` | `None` / `Some(x)` |
| Intentional panic | `panic!()` / `assert!()` | Special cases only |
| Error conversion | `.map_err()` / `.context()` | Add context |
| Fallback values | `.unwrap_or()` / `.unwrap_or_else()` | Safe defaults |
| Early return | `?` operator | Propagate errors |


## Review Checklist

When reviewing error handling code:

- [ ] All fallible operations return `Result` or `Option`
- [ ] Error types are meaningful (not just `String`)
- [ ] Error context is preserved through propagation
- [ ] `unwrap()` used only with justification (comments)
- [ ] `panic!()` used only for bugs or unrecoverable states
- [ ] Library code uses typed errors (thiserror)
- [ ] Application code adds context (anyhow `.context()`)
- [ ] Error messages are actionable for users/operators
- [ ] No silent error swallowing (`let _ = ...`)
- [ ] Tests cover error paths, not just happy paths


## Verification Commands

```bash
# Check for unwrap/expect usage
cargo clippy -- -W clippy::unwrap_used -W clippy::expect_used

# Check for panic in production code
cargo clippy -- -W clippy::panic

# Run tests including error paths
cargo test

# Check for unused Results
cargo clippy -- -D unused_must_use

# Verify error types implement Error trait
cargo check
```


## Conversion Patterns

### Option ↔ Result

```rust
// Option → Result
let result: Result<T, E> = option.ok_or(error_value)?;
let result: Result<T, E> = option.ok_or_else(|| compute_error())?;

// Result → Option
let option: Option<T> = result.ok();

// Result<Option<T>, E> → Result<T, E>
result.and_then(|opt| opt.ok_or(error))?;
```

### Error Type Conversions

```rust
// Manual conversion
.map_err(|e| MyError::from(e))?;

// Automatic with #[from]
// Requires: #[derive(Error, Debug)] with #[from] attribute
result?;  // Auto-converts if From impl exists

// Add context
.map_err(|e| MyError::Wrapped(e.to_string()))?;

// Use anyhow for flexibility
.context("operation failed")?;
```


## Advanced: Error Source Chains

```rust
use std::error::Error;

fn print_error_chain(e: &dyn Error) {
    eprintln!("Error: {}", e);

    let mut source = e.source();
    while let Some(e) = source {
        eprintln!("  Caused by: {}", e);
        source = e.source();
    }
}

// Usage
if let Err(e) = dangerous_operation() {
    print_error_chain(&e);
}
```


## Related Skills

- **rust-error-advanced** - Advanced error patterns (thiserror, anyhow, error chains)
- **rust-anti-pattern** - Error handling anti-patterns to avoid
- **rust-coding** - Error handling coding standards
- **rust-web** - Error handling in web contexts
- **rust-async** - Error handling in async code


## Localized Reference

- **Chinese version**: [SKILL_ZH.md](./SKILL_ZH.md) - 完整中文版本，包含所有内容
