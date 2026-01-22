# Error Handling Patterns in Rust

Rust's error handling is built on `Result<T, E>` and `Option<T>`, enabling compile-time checking of error paths.

## The Result Type

### Basic Usage

```rust
fn read_file(path: &str) -> Result<String, std::io::Error> {
    std::fs::read_to_string(path)
}
```

### Error Propagation

```rust
fn process_config() -> Result<Config, ConfigError> {
    let content = std::fs::read_to_string("config.json")?;  // Propagate error
    let config: Config = serde_json::from_str(&content)?;    // Propagate error
    Ok(config)
}
```

## Custom Error Types

### Using thiserror

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
    #[error("configuration error: {source}")]
    Config {
        #[from]
        source: ConfigError,
    },
    
    #[error("database error at {operation}: {message}")]
    Database {
        operation: String,
        message: String,
    },
    
    #[error("validation failed: {field}={value}")]
    Validation {
        field: String,
        value: String,
    },
    
    #[error(transparent)]
    Io(#[from] std::io::Error),
}
```

### Manual Error Implementation

```rust
use std::fmt;
use std::error::Error;

#[derive(Debug)]
pub struct CustomError {
    message: String,
    source: Option<Box<dyn Error>>,
}

impl CustomError {
    pub fn new(message: String) -> Self {
        Self { message, source: None }
    }
    
    pub fn with_source(message: String, source: impl Error + 'static) -> Self {
        Self {
            message,
            source: Some(Box::new(source)),
        }
    }
}

impl fmt::Display for CustomError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.message)
    }
}

impl Error for CustomError {
    fn source(&self) -> Option<&(dyn Error + 'static)> {
        self.source.as_deref()
    }
}
```

## Error Handling Strategies

### Strategy 1: Early Return Pattern

```rust
fn process_user(input: &str) -> Result<User, AppError> {
    let trimmed = input.trim();
    if trimmed.is_empty() {
        return Err(AppError::Validation {
            field: "name".to_string(),
            value: "empty".to_string(),
        });
    }
    
    let parsed = trimmed.parse::<String>()?;
    
    if parsed.len() < 2 {
        return Err(AppError::Validation {
            field: "name".to_string(),
            value: "too short".to_string(),
        });
    }
    
    Ok(User::new(parsed))
}
```

### Strategy 2: Combinators

```rust
fn parse_age(input: &str) -> Option<u32> {
    input
        .trim()
        .parse::<u32>()
        .ok()
        .filter(|&age| age >= 0 && age <= 150)
}

fn get_user_age() -> Result<u32, AppError> {
    let input = get_input();
    parse_age(&input)
        .ok_or_else(|| AppError::Validation {
            field: "age".to_string(),
            value: input,
        })
}
```

### Strategy 3: Contextual Errors

```rust
fn read_users() -> Result<Vec<User>, AppError> {
    let file = std::fs::File::open("users.json")
        .map_err(|e| AppError::Io.with_source(e))?;
    
    let reader = std::io::BufReader::new(file);
    let users: Vec<User> = serde_json::from_reader(reader)
        .map_err(|e| AppError::Config {
            source: e.into(),
        })?;
    
    Ok(users)
}
```

### Strategy 4: Error Conversion

```rust
// Automatic conversion via From
impl From<std::io::Error> for AppError {
    fn from(e: std::io::Error) -> Self {
        AppError::Io(e)
    }
}

// Usage
fn read_file(path: &str) -> Result<String, AppError> {
    std::fs::read_to_string(path)  // auto-converted
}
```

## Best Practices

### Do

```rust
// ✅ Use concrete error types for library code
pub fn parse(input: &str) -> Result<Token, ParseError> {
    // ...
}

// ✅ Use thiserror for clean error definitions
#[derive(Error, Debug)]
pub enum ParseError {
    #[error("unexpected token: {token}")]
    UnexpectedToken { token: String },
    
    #[error("unclosed delimiter: {delimiter}")]
    UnclosedDelimiter { delimiter: char },
}

// ✅ Provide context with map_err
let config = File::open("config.json")
    .map_err(|e| ConfigError::with_source("failed to open config", e))?;
```

### Don't

```rust
// ❌ Don't panic in library code
fn parse(input: &str) -> Result<Token, ParseError> {
    if input.is_empty() {
        panic!("empty input");  // Never do this!
    }
    // ...
}

// ❌ Don't use generic error types in libraries
fn parse(input: &str) -> Result<Token, Box<dyn Error>> {  // Avoid
    // ...
}

// ❌ Don't swallow errors
let _ = some_fn_that_returns_result();  // Bad!
```

## Error Handling in Application Code

### Using anyhow for Application Code

```rust
use anyhow::{Context, Result, bail};

fn main() -> Result<()> {
    let config = load_config()
        .context("Failed to load configuration")?;
    
    let data = process_config(&config)
        .context("Failed to process configuration")?;
    
    save_data(&data)
        .context("Failed to save data")?;
    
    Ok(())
}
```

### Structured Logging with Errors

```rust
use tracing::{error, warn, info};

fn handle_request(req: Request) -> Result<Response, AppError> {
    info!("Processing request: {}", req.id);
    
    let result = validate_request(&req)
        .map_err(|e| {
            warn!("Validation failed: {}", e);
            e
        })?;
    
    // ...
}
```

### Error Metrics

```rust
use metrics::{counter, histogram};

fn record_error(error: &AppError) {
    counter!("errors_total", "type" => error.to_string()).increment(1);
    histogram!("error_handling_duration").record(duration);
}
```

## Summary

| Scenario | Recommended Approach |
|----------|---------------------|
| Library code | Custom error type implementing `Error` trait |
| Application code | `anyhow` for simplicity |
| Performance critical | `thiserror` + context-free errors |
| Multi-error composition | Enum with variants for each error type |

