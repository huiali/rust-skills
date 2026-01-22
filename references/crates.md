# Recommended Crates

A curated list of essential Rust crates for various use cases.

## Web Development

### Web Frameworks

| Crate | Description | Downloads |
|-------|-------------|-----------|
| [actix-web](https://actix.rs/) | High-performance web framework | ~10M |
| [axum](https://github.com/tokio-rs/axum) | Ergonomic web framework | ~8M |
| [rocket](https://rocket.rs/) | Developer-friendly framework | ~5M |
| [poem](https://poem-web.github.io/poem/) | Elegant web framework | ~1M |

### HTTP Clients

```toml
[dependencies]
reqwest = { version = "0.11", features = ["json"] }
```

```rust
use reqwest;

let response = reqwest::Client::new()
    .post("https://api.example.com")
    .json(&payload)
    .send()
    .await?;
```

### Async Runtime

```toml
[dependencies]
tokio = { version = "1.0", features = ["full"] }
# or
async-std = { version = "1.0", features = ["attributes"] }
```

## Data Serialization

### JSON

```toml
[dependencies]
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
```

```rust
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
struct User {
    id: u64,
    name: String,
}
```

### Other Formats

| Crate | Format | Use Case |
|-------|--------|----------|
| `toml` | TOML | Config files |
| `csv` | CSV | Data processing |
| `postcard` | Various | Embedded/small systems |
| `bincode` | Binary | IPC, storage |

## Error Handling

```toml
[dependencies]
anyhow = "1.0"  # Application errors
thiserror = "1.0"  # Library errors
```

```rust
use anyhow::{Context, Result};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum ApiError {
    #[error("request failed: {source}")]
    Request { #[from] source: reqwest::Error },
    
    #[error("invalid response: {message}")]
    InvalidResponse { message: String },
}
```

## Database

### ORM and Query Builders

| Crate | Type | Database |
|-------|------|----------|
| [sqlx](https://github.com/launchbadge/sqlx) | Async SQL | PostgreSQL, MySQL, SQLite |
| [diesel](https://diesel.rs/) | ORM | PostgreSQL, MySQL, SQLite |
| [sea-orm](https://www.sea-ql.org/SeaORM/) | Async ORM | Multiple |
| [prisma-client-rust](https://prisma.rs/) | Prisma client | PostgreSQL, MySQL, SQLite |

```rust
// sqlx example
use sqlx::{Row, Postgres};

let row = sqlx::query("SELECT id, name FROM users WHERE id = $1")
    .bind(user_id)
    .fetch_one(&pool)
    .await?;

let id: i64 = row.try_get("id")?;
let name: String = row.try_get("name")?;
```

## Command Line

### Argument Parsing

```toml
[dependencies]
clap = { version = "4.0", features = ["derive"] }
```

```rust
use clap::{Parser, Args};

#[derive(Args)]
struct ConnectArgs {
    host: String,
    port: u16,
    #[arg(short, long)]
    timeout: Option<u64>,
}

#[derive(Parser)]
#[command(name = "myapp")]
struct Cli {
    #[command(flatten)]
    connect: ConnectArgs,
}
```

### Progress Bars

```toml
indicatif = "0.17"
```

## Async Concurrency

```toml
[dependencies]
tokio = { version = "1.0", features = ["full"] }
futures = "0.3"
```

| Crate | Description |
|-------|-------------|
| `tokio` | Async runtime |
| `async-trait` | Async trait methods |
| `tokio-stream` | Async streams |
| `tokio-util` | Utilities |
| `async-channel` | Channel for async |
| `futures` | Async abstractions |

## Logging and Tracing

```toml
[dependencies]
tracing = "0.1"
tracing-subscriber = "0.3"
log = "0.4"
```

```rust
use tracing::{info, instrument};

#[instrument]
async fn process_item(item: &Item) {
    info!("Processing item: {}", item.id);
    // ...
}
```

## Testing

```toml
[dev-dependencies]
proptest = "1.0"        # Property-based testing
mockall = "0.12"        # Mocking
rstest = "0.18"         # Parametrized tests
criterion = "0.5"       # Benchmarks
```

## Utilities

| Crate | Description | Use Case |
|-------|-------------|----------|
| `once_cell` | Lazy initialization | Config, singletons |
| `anyhow` | Error handling | Applications |
| `thiserror` | Error definitions | Libraries |
| `chrono` | Date/time | Timestamps |
| `regex` | Regular expressions | Text processing |
| `rand` | Random numbers | Games, testing |
| `fastrand` | Fast random | Performance critical |
| `dashmap` | Concurrent HashMap | High-performance caching |

## Validation

```toml
[dependencies]
validator = { version = "0.16", features = ["derive"] }
```

```rust
use validator::{Validate, email};

#[derive(Validate)]
struct UserRegistration {
    #[validate(email)]
    email: String,
    
    #[validate(length(min = 8))]
    password: String,
}
```

## Cryptography

| Crate | Description |
|-------|-------------|
| `ring` | General crypto |
| `rust-crypto` | Collection |
| `bcrypt` | Password hashing |
| `jsonwebtoken` | JWT |
| `sha2` | SHA-256/512 |
| `ed25519-dalek` | Ed25519 signatures |

## Serialization Speed

| Crate | Description | Speed |
|-------|-------------|-------|
| `serde_json` | JSON (default) | Medium |
| `simd-json` | JSON with SIMD | Fast |
| `rmp-serde` | MessagePack | Fast |
| `postcard` | Binary | Very fast |

## Selection Guide

### For New Projects

```
Web API:
├── actix-web or axum for framework
├── sqlx for database
├── tokio for async
└── tracing for observability

CLI Tool:
├── clap for args
├── anyhow for errors
└── indicatif for progress

Library:
├── thiserror for errors
├── proptest for testing
└── cargo-hack for MSRV testing
```

### MSRV Considerations

When supporting older Rust versions:

```toml
[package]
rust-version = "1.70"

[dependencies]
# Check MSRV before updating
serde = { version = "1.0", default-features = false }
```

## Updating Dependencies

```bash
# Check for updates
cargo outdated

# Update minor/patch versions
cargo update

# Update to new major version (manual review needed)
cargo update -p crate_name --aggressive
```

