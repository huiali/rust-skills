# Modern Rust Crates

Emerging and recommended crates for modern Rust development.

## 2024-2025 Recommended Crates

### CLI Development

| Crate | Description | Why Use |
|-------|-------------|---------|
| **clap v4** | CLI argument parsing | Derive API, type-safe |
| **tokio** | Async runtime | Production-ready |
| **tracing** | Structured logging | Debugging, observability |
| **indicatif** | Progress bars | User feedback |
| **dialoguer** | Interactive prompts | User input |

```rust
use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "myapp")]
#[command(author, version, about, long_about = None)]
struct Args {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Process files
    Process {
        /// Input file
        #[arg(short, long)]
        input: String,
    },
    /// Show status
    Status,
}
```

### Async & Concurrency

| Crate | Description | Use Case |
|-------|-------------|----------|
| **tokio** | Async runtime | Mainstream choice |
| **async-trait** | Async trait methods | Trait-based APIs |
| **tokio-stream** | Stream utilities | Async iteration |
| **futures-util** | Future extensions | Low-level async |
| **async-broadcast** | Event broadcasting | Pub/sub |
| **flume** | Channel (faster) | High-throughput |

```rust
use async_stream::stream;
use tokio::time::{interval, sleep};

use std::time::Duration;

async fn event_stream() -> impl tokio_stream::Stream<Item = Event> {
    stream! {
        let mut interval = interval(Duration::from_secs(1));
        loop {
            interval.tick().await;
            yield Event::Tick;
        }
    }
}
```

### Error Handling

| Crate | Description | When |
|-------|-------------|------|
| **anyhow** | Application errors | Main binary |
| **thiserror** | Library errors | Libraries |
| **snafu** | Structured errors | Complex contexts |
| **eyre** | Colorful errors | Debugging |
| **error-chain** | Error chains | Backtraces |

### Web Development

| Crate | Description | Performance |
|-------|-------------|-------------|
| **axum** | Web framework | High |
| **actix-web** | Web framework | Highest |
| **warp** | Filter-based | High |
| **poem** | Elegant | High |
| **salvo** | Modern | High |

### Database

| Crate | Description | Type |
|-------|-------------|------|
| **sqlx** | Async SQL | Async |
| **sea-orm** | ORM | Async |
| **diesel** | ORM | Sync |
| **rusqlite** | SQLite | Sync |
| **mongodb** | MongoDB | Async |
| **redis** | Redis | Async |

### Serialization

| Crate | Description | Speed |
|-------|-------------|-------|
| **serde** | Framework | - |
| **serde_json** | JSON | Medium |
| **simd-json** | JSON (SIMD) | Fast |
| **postcard** | Binary (no_std) | Fastest |
| **cbor** | CBOR | Fast |
| **rmp-serde** | MessagePack | Fast |
| **flexbuffers** | Serialization | Fast |

### Data Structures

| Crate | Description | Use Case |
|-------|-------------|----------|
| **ahash** | Hash function | Default HashMap |
| **hashbrown** | HashMap | Faster std |
| **indexmap** | Ordered map | Insertion order |
| **petgraph** | Graphs | Graph algorithms |
| **btreemap** | BTreeMap | Sorted data |
| **smartstring** | Inline string | Small strings |
| **compact_str** | String | Memory efficient |
| **smallvec** | Stack vec | Small collections |

### Time

| Crate | Description | Features |
|-------|-------------|----------|
| **chrono** | Date/time | Full featured |
| **time** | Date/time | Simpler |
| **humantime** | Human parsing | CLI args |
| **duration_str** | Duration parsing | Config files |

### Parsing

| Crate | Description | Use Case |
|-------|-------------|----------|
| **nom** | Parser combinator | Binary/text |
| **pest** | PEG grammar | Structured |
| **chumsky** | Parser combinator | Friendly |
| **winnow** | Parser combinator | Fast nom fork |
| **regex** | Regular expressions | Text |

### Internationalization

| Crate | Description |
|-------|-------------|
| **fluent** | FFI-compatible |
| **unic-langid** | Language tags |
| **date_time** | Time zones |

### GUI

| Crate | Description | Backend |
|-------|-------------|---------|
| **iced** | Pure Rust | Custom |
| **tauri** | Web-based | System |
| **dioxus** | React-like | Web/Native |
| **yew** | Component-based | Web |
| **egui** | Immediate mode | Simple |

### Cryptography

| Crate | Description |
|-------|-------------|
| **ring** | General crypto |
| **rust-crypto** | Collection |
| **ed25519-dalek** | Ed25519 |
| **x25519-dalek** | X25519 key exchange |
| **sha2** | SHA-256/512 |
| **bcrypt** | Password hashing |
| **argon2** | Password hashing |
| **jsonwebtoken** | JWT |
| **rustls** | TLS |
| **aws-lc-rs** | AWS TLS |

### Unsafe & FFI

| Crate | Description |
|-------|-------------|
| **libc** | C types |
| **bindgen** | C header binding |
| **cxx** | C++ interop |
| **mlua** | Lua scripting |
| **rquickjs** | QuickJS |

### Embedded & WASM

| Crate | Description |
|-------|-------------|
| **embassy** | Async executor |
| **defmt** | Formatting |
| **nb** | Non-blocking |
| **embedded-hal** | HAL traits |
| **wasm-bindgen** | WASM binding |
| **wasm-bindgen-futures** | WASM async |

### Observability

| Crate | Description |
|-------|-------------|
| **tracing** | Structured logging |
| **tracing-subscriber** | Subscriber impl |
| **metrics** | Metrics |
| **opentelemetry** | Telemetry |
| **console-subscriber** | Async tracing |

### FFI and System

| Crate | Description |
|-------|-------------|
| **nix** | Unix APIs |
| **windows** | Windows APIs |
| **libc** | C standard library |

## Deprecated → Replacement

| Deprecated | Replacement | Reason |
|------------|-------------|--------|
| `lazy_static` | `std::sync::OnceLock` | std built-in |
| `rand::thread_rng` | `rand::rng()` | New API |
| `failure` | `thiserror` + `anyhow` | Deprecated |
| `serde_derive` | `serde` | Unified |
| `getrandom` feature | `getrandom` crate | Split out |

## Performance-Critical Crates

| Crate | Description | Speed |
|-------|-------------|-------|
| **rayon** | Data parallelism | ~linear |
| **crossbeam** | Concurrency | High |
| **parking_lot** | Synchronization | Faster std |
| **ahash** | Hash function | ~5x std |
| **regex** | Regex | Optimized |
| **bytes** | Bytes type | Zero-copy |
| **smallvec** | Stack allocation | No heap |
| **stringcache** | String interning | Zero-allocation |

## Choosing the Right Crate

### Decision Tree

```
Need async runtime?
├─ Yes → tokio (most popular) or async-std (std-like)
└─ No → std threads

Need database?
├─ SQL → sqlx (async) or diesel (sync)
├─ NoSQL → mongodb, redis
└─ SQLite → rusqlite

Need web framework?
├─ High performance → actix-web
├─ Ergonomic → axum
└─ Simple → rocket

Need CLI?
├─ Complex → clap
└─ Simple → pico-args
```

### Star History

Check GitHub stars for popularity trends:

```bash
# Check crate popularity
cargo search --limit 100 | sort -t' ' -k2 -nr
```

