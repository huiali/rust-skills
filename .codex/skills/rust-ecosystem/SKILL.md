---
name: rust-ecosystem
description: |
  Rust ecosystem expert covering crate selection, library recommendations, framework
  comparisons, async runtime choices (tokio, async-std), and common tools.
triggers:
  - crate
  - library
  - framework
  - ecosystem
  - async runtime
  - tokio
  - async-std
  - serde
  - reqwest
  - axum
---

# Rust Ecosystem Expert

## Core Question

**Which crate should I use to solve this problem?**

Choosing the right library is key to efficient Rust development.

---

## Async Runtimes

| Runtime | Characteristics | Use Case |
|---------|----------------|----------|
| **tokio** | Most popular, feature-rich | General async applications |
| **async-std** | std-like API | Prefer std-style APIs |
| **smol** | Minimal, embeddable | Lightweight applications |
| **async-executors** | Unified interface | Need runtime portability |

```toml
# Web services
tokio = { version = "1", features = ["full"] }
axum = "0.7"

# Lightweight
async-std = "1"

# Minimal
smol = "2"
```

---

## Solution Patterns

### Pattern 1: Web Service Stack

```toml
[dependencies]
# Async runtime
tokio = { version = "1", features = ["full"] }

# Web framework
axum = "0.7"

# Database
sqlx = { version = "0.7", features = ["runtime-tokio", "postgres"] }

# Serialization
serde = { version = "1", features = ["derive"] }
serde_json = "1"

# Error handling
anyhow = "1"
thiserror = "1"

# Tracing
tracing = "0.1"
tracing-subscriber = "0.3"
```

### Pattern 2: CLI Tool Stack

```toml
[dependencies]
# Argument parsing
clap = { version = "4", features = ["derive"] }

# Error handling
anyhow = "1"

# Config
config = "0.13"
dotenvy = "0.15"

# Progress
indicatif = "0.17"

# Terminal colors
colored = "2"
```

### Pattern 3: Data Processing

```toml
[dependencies]
# Parallelism
rayon = "1"

# CSV
csv = "1"

# Serialization
serde = { version = "1", features = ["derive"] }
serde_json = "1"

# HTTP client
reqwest = { version = "0.11", features = ["json", "blocking"] }
```

---

## Web Frameworks

| Framework | Characteristics | Performance |
|-----------|----------------|-------------|
| **axum** | Tower middleware, type-safe | High |
| **actix-web** | Highest performance | Highest |
| **rocket** | Developer-friendly | Medium |
| **warp** | Compositional, filters | High |

```rust
// axum example
use axum::{Router, routing::get, Json};
use serde::Serialize;

#[derive(Serialize)]
struct User {
    id: u64,
    name: String,
}

async fn get_user() -> Json<User> {
    Json(User {
        id: 1,
        name: "Alice".to_string(),
    })
}

let app = Router::new()
    .route("/user", get(get_user));
```

---

## Serialization

| Library | Characteristics | Performance |
|---------|----------------|-------------|
| **serde** | Standard choice | High |
| **bincode** | Binary, compact | Highest |
| **postcard** | no_std, embedded | High |
| **ron** | Readable format | Medium |

```rust
use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize)]
struct User {
    id: u64,
    name: String,
}

// JSON
let json = serde_json::to_string(&user)?;
let user: User = serde_json::from_str(&json)?;

// Binary (more efficient)
let bytes = bincode::serialize(&user)?;
let user: User = bincode::deserialize(&bytes)?;
```

---

## HTTP Clients

| Library | Characteristics |
|---------|----------------|
| **reqwest** | Most popular, easy to use |
| **ureq** | Sync, simple |
| **surf** | Async, modern |
| **hyper** | Low-level, flexible |

```rust
// reqwest - async
let response = reqwest::Client::new()
    .post("https://api.example.com")
    .json(&payload)
    .send()
    .await?
    .json::<Response>()
    .await?;

// ureq - sync (no async runtime needed)
let response: Response = ureq::post("https://api.example.com")
    .send_json(&payload)?
    .into_json()?;
```

---

## Databases

| Type | Library |
|------|---------|
| ORM | **sqlx**, diesel, sea-orm |
| Raw SQL | **sqlx**, tokio-postgres |
| NoSQL | mongodb, redis |
| Connection pool | **sqlx**, deadpool, r2d2 |

```rust
// sqlx with compile-time checked queries
use sqlx::PgPool;

let pool = PgPool::connect(&database_url).await?;

let user = sqlx::query_as!(
    User,
    "SELECT id, name FROM users WHERE id = $1",
    user_id
)
.fetch_one(&pool)
.await?;
```

---

## Concurrency & Parallelism

| Scenario | Recommendation |
|----------|---------------|
| Data parallelism | **rayon** |
| Work stealing | **crossbeam**, tokio |
| Channels | **tokio::sync**, crossbeam, flume |
| Atomics | **std::sync::atomic** |

```rust
// rayon - easy parallelism
use rayon::prelude::*;

let sum: i32 = data
    .par_iter()
    .map(|x| expensive_computation(x))
    .sum();
```

---

## Error Handling

| Library | Use Case |
|---------|----------|
| **thiserror** | Library error types |
| **anyhow** | Application error propagation |
| **snafu** | Structured errors |

```rust
// thiserror - for libraries
use thiserror::Error;

#[derive(Error, Debug)]
pub enum MyError {
    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),

    #[error("Invalid data: {msg}")]
    Invalid { msg: String },
}

// anyhow - for applications
use anyhow::{Context, Result};

fn load_config() -> Result<Config> {
    let content = std::fs::read_to_string("config.toml")
        .context("failed to read config file")?;

    toml::from_str(&content)
        .context("failed to parse config")
}
```

---

## Common Tools

| Scenario | Library |
|----------|---------|
| CLI parsing | **clap** (v4), structopt |
| Logging | **tracing**, log |
| Config | **config**, dotenvy |
| Testing | **tempfile**, rstest, proptest |
| Time | **chrono**, time |
| Random | **rand** |
| Regex | **regex** |

---

## Crate Selection Principles

1. **Active maintenance**: Check GitHub activity, recent updates
2. **Download count**: Reference crates.io downloads
3. **MSRV**: Minimum Supported Rust Version compatibility
4. **Dependencies**: Number and security of dependencies
5. **Documentation**: Complete docs and examples
6. **License**: MIT/Apache2 compatibility

```bash
# Check crate info
cargo info <crate-name>

# Check dependencies
cargo tree

# Security audit
cargo audit

# License check
cargo deny check licenses
```

---

## Workflow

### Step 1: Identify Need

```
What problem to solve?
  → Web service? Choose framework (axum/actix)
  → CLI tool? Use clap + anyhow
  → Data processing? Use rayon
  → Database access? Use sqlx
```

### Step 2: Evaluate Options

```
Check:
  → crates.io download count
  → GitHub stars and activity
  → Documentation quality
  → Recent releases
  → Community support
```

### Step 3: Verify Safety

```bash
# Security audit
cargo audit

# License compatibility
cargo deny check

# Dependency tree
cargo tree -i <crate>
```

---

## Deprecated Patterns → Modern

| Deprecated | Modern | Reason |
|-----------|--------|--------|
| `lazy_static` | `std::sync::OnceLock` | std built-in |
| `rand::thread_rng` | `rand::rng()` | New API |
| `failure` | `thiserror` + `anyhow` | More popular |
| `serde_derive` | `serde` (unified) | Simpler imports |

---

## Quick Reference

| Scenario | Recommended Stack |
|----------|------------------|
| Web service | axum + tokio + sqlx + serde |
| CLI tool | clap + anyhow + config |
| Serialization | serde + (json/bincode/postcard) |
| Parallel compute | rayon |
| Config management | config + dotenvy |
| Logging | tracing + tracing-subscriber |
| Testing | tempfile + rstest + proptest |
| Date/time | chrono or time |

---

## Review Checklist

When selecting crates:

- [ ] Crate is actively maintained (updated within 6 months)
- [ ] Good documentation and examples
- [ ] Reasonable dependency count
- [ ] No known security issues (cargo audit)
- [ ] Compatible license (MIT/Apache2)
- [ ] MSRV compatible with project
- [ ] High download count and community usage
- [ ] Stable API (1.0+ or widely used)

---

## Verification Commands

```bash
# Search crates
cargo search <keyword>

# Get crate info
cargo info <crate-name>

# Check dependencies
cargo tree

# Security audit
cargo audit

# License check
cargo deny check

# Check for updates
cargo outdated
```

---

## Common Pitfalls

### 1. Too Many Dependencies

**Symptom**: Long compile times, dependency conflicts

```toml
# ❌ Avoid: unnecessary dependencies
[dependencies]
# Don't need full tokio if only using channels
tokio = { version = "1", features = ["full"] }

# ✅ Better: minimal features
tokio = { version = "1", features = ["sync"] }
```

### 2. Unmaintained Crates

**Symptom**: Security vulnerabilities, incompatibilities

```bash
# Check last update
cargo info <crate-name>

# Check for alternatives
cargo search <similar-crate>
```

### 3. Version Conflicts

**Symptom**: Build failures, duplicate dependencies

```bash
# Diagnose conflicts
cargo tree -d

# Use same version across workspace
[workspace.dependencies]
serde = "1"
```

---

## Related Skills

- **rust-async** - Async runtime patterns
- **rust-web** - Web framework usage
- **rust-error** - Error handling libraries
- **rust-testing** - Testing libraries
- **rust-performance** - Performance-critical crates

---

## Localized Reference

- **Chinese version**: [SKILL_ZH.md](./SKILL_ZH.md) - 完整中文版本，包含所有内容
