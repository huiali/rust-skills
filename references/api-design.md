# API Design Guidelines

Principles and patterns for designing idiomatic Rust APIs.

## General Principles

### 1. Make Invalid States Unrepresentable

```rust
// ❌ Bad: Invalid states possible
struct User {
    name: String,
    email: Option<String>,  // Can be None
    age: u32,               // Can be 0 or 200
}

// ✅ Good: Type-level constraints
struct Email(String);
struct Age(u8);  // 0-255 is reasonable for age

struct User {
    name: String,
    email: Email,
    age: Age,
}

impl Email {
    fn new(s: &str) -> Result<Self, InvalidEmailError> {
        if s.contains('@') {
            Ok(Self(s.to_string()))
        } else {
            Err(InvalidEmailError)
        }
    }
}
```

### 2. Use Strong Types

```rust
// ❌ Bad: Stringly-typed API
fn create_user(name: String, age: String) -> Result<(), String> {
    let age: u32 = age.parse()?;
    // ...
}

// ✅ Good: Strong types
struct UserName(String);
struct UserAge(u8);

fn create_user(name: UserName, age: UserAge) -> Result<(), CreateUserError> {
    // ...
}
```

### 3. Fail Fast with Validation

```rust
impl User {
    pub fn new(name: String, email: String) -> Result<Self, ValidationError> {
        // Validate early
        if name.is_empty() {
            return Err(ValidationError::EmptyName);
        }
        
        let email = Email::new(&email)
            .map_err(ValidationError::InvalidEmail)?;
        
        // Only create after validation passes
        Ok(Self { name, email })
    }
}
```

## Builder Pattern

### When to Use

For structs with multiple optional parameters.

```rust
pub struct Config {
    host: String,
    port: u16,
    timeout: Duration,
    retries: u32,
    cache_size: usize,
    debug: bool,
}

impl Config {
    pub fn builder() -> ConfigBuilder {
        ConfigBuilder::default()
    }
}

#[derive(Default)]
pub struct ConfigBuilder {
    host: Option<String>,
    port: Option<u16>,
    timeout: Option<Duration>,
    retries: Option<u32>,
    cache_size: Option<usize>,
    debug: bool,
}

impl ConfigBuilder {
    pub fn host(mut self, host: impl Into<String>) -> Self {
        self.host = Some(host.into());
        self
    }
    
    pub fn port(mut self, port: u16) -> Self {
        self.port = Some(port);
        self
    }
    
    pub fn timeout(mut self, timeout: Duration) -> Self {
        self.timeout = Some(timeout);
        self
    }
    
    // ... other setters
    
    pub fn build(self) -> Result<Config, BuildError> {
        Ok(Config {
            host: self.host.ok_or(BuildError::MissingHost)?,
            port: self.port.unwrap_or(8080),
            timeout: self.timeout.unwrap_or(Duration::from_secs(30)),
            retries: self.retries.unwrap_or(3),
            cache_size: self.cache_size.unwrap_or(1000),
            debug: self.debug,
        })
    }
}

// Usage
let config = Config::builder()
    .host("localhost")
    .port(3000)
    .debug(true)
    .build()?;
```

## Error Design

### Provide Rich Error Information

```rust
#[derive(Error, Debug)]
pub enum ApiError {
    #[error("HTTP error: {status}")]
    Http {
        status: reqwest::StatusCode,
        source: reqwest::Error,
    },
    
    #[error("validation failed: {field}={value} ({reason})")]
    Validation {
        field: &'static str,
        value: String,
        reason: &'static str,
    },
    
    #[error("rate limited (retry after {retry_after:?})")]
    RateLimited {
        retry_after: Duration,
    },
    
    #[error(transparent)]
    Other(#[from] Box<dyn std::error::Error + Send + Sync>),
}
```

### Error Conversion

```rust
// Automatic conversion between error types
impl From<std::io::Error> for ApiError {
    fn from(e: std::io::Error) -> Self {
        ApiError::Other(Box::new(e))
    }
}

// Allow ? operator to work seamlessly
fn make_request() -> Result<(), ApiError> {
    let data = std::fs::read("file.txt")?;  // Auto-converted
    Ok(())
}
```

## Builder vs Constructor

### Simple Constructor (3 or fewer params)

```rust
pub struct Point {
    x: f64,
    y: f64,
}

impl Point {
    pub fn new(x: f64, y: f64) -> Self {
        Self { x, y }
    }
    
    pub fn origin() -> Self {
        Self { x: 0.0, y: 0.0 }
    }
}
```

### Builder (4+ params or many optional)

```rust
// Use builder as shown above
```

## Trait Design

### Design for Ergonomics

```rust
// ❌ Bad: Split read/write operations
trait File {
    fn read(&mut self, buf: &mut [u8]) -> Result<usize, Error>;
    fn write(&mut self, buf: &[u8]) -> Result<usize, Error>;
}

// ✅ Good: Unified interface
trait File {
    async fn read(&mut self, buf: &mut [u8]) -> Result<usize, Error>;
    async fn write(&mut self, buf: &[u8]) -> Result<usize, Error>;
    
    // Or provide convenience methods
    async fn read_exact(&mut self, mut buf: &mut [u8]) -> Result<(), Error> {
        while !buf.is_empty() {
            let n = self.read(buf).await?;
            if n == 0 {
                return Err(Error::UnexpectedEof);
            }
            buf = &mut buf[n..];
        }
        Ok(())
    }
}
```

### Provide Default Implementations

```rust
pub trait Processor {
    fn process(&self, data: &[u8]) -> Result<Vec<u8>, Error> {
        // Default implementation
        Ok(data.to_vec())
    }
    
    fn process_batch(&self, data: &[&[u8]]) -> Result<Vec<Vec<u8>>, Error> {
        // Uses process() by default
        data.iter().map(|&d| self.process(d)).collect()
    }
}
```

## Generic APIs

### Trait Bounds

```rust
// ✅ Good: Clear bounds
fn serialize<T>(value: &T) -> Result<String, Error>
where
    T: serde::Serialize,
{
    Ok(serde_json::to_string(value)?)
}

// ✅ Good: Rust 2024 style (inferred bounds)
fn serialize<T: serde::Serialize>(value: &T) -> Result<String, Error> {
    Ok(serde_json::to_string(value)?)
}
```

### Avoid Unnecessary Constraints

```rust
// ❌ Bad: Unnecessary Send + Sync
fn process<T>(value: &T)
where
    T: Send + Sync + Debug,
{
    // Only uses Debug
    println!("{:?}", value);
}

// ✅ Good: Only what's needed
fn process<T: Debug>(value: &T) {
    println!("{:?}", value);
}
```

## Iterator Design

```rust
pub struct Lines<'a> {
    input: &'a str,
}

impl<'a> Iterator for Lines<'a> {
    type Item = &'a str;
    
    fn next(&mut self) -> Option<Self::Item> {
        // Return None when exhausted
        self.input.find('\n').map(|i| {
            let line = &self.input[..i];
            self.input = &self.input[i + 1..];
            line
        })
    }
}

// Provide consuming and borrowing variants
impl<'a> IntoIterator for &'a str {
    type Item = &'a str;
    type IntoIter = Lines<'a>;
    
    fn into_iter(self) -> Self::IntoIter {
        Lines { input: self }
    }
}
```

## Async API Design

### Return Concrete Types When Possible

```rust
// ✅ Good: Concrete future type (simpler, easier to debug)
async fn get_user(id: u64) -> Result<User, Error> {
    // ...
}

// ❌ Avoid: Impl Trait in return position (harder to debug in error messages)
async fn get_user(id: u64) -> impl Future<Output = Result<User, Error>> {
    async move { /* ... */ }
}
```

### Cancellation Safety

```rust
use tokio::select;

async fn read_with_timeout(
    rx: &mut Receiver<Item>,
    timeout: Duration,
) -> Result<Item, Error> {
    tokio::time::timeout(timeout, rx.recv()).await?
}
```

## Summary

| Scenario | Pattern |
|----------|---------|
| Few optional params | Default values |
| Many optional params | Builder |
| Validation needed | Constructor with Result |
| Multiple types | Traits + generics |
| 4+ constructor params | Builder |
| Async operations | Async trait methods |
| Collections | Iterator trait |

## Checklist

- [ ] Invalid states unrepresentable
- [ ] Strong types over primitives
- [ ] Fail fast with validation
- [ ] Consistent error handling
- [ ] Ergonomic API design
- [ ] Proper documentation
- [ ] Tests for edge cases

