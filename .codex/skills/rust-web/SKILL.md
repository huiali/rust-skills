---
name: rust-web
description: |
  Rust web development expert covering HTTP frameworks (axum, actix), REST API design, handler
  patterns, state management, middleware, database integration, and domain-driven architecture.
triggers:
  - web
  - HTTP
  - REST
  - API
  - axum
  - actix
  - handler
  - router
  - middleware
  - endpoint
---

# Rust Web Development Expert

## Core Question

**How do we build reliable, performant web services in Rust?**

Choose the right framework, design clean handlers, manage state safely, and structure code for maintainability.

---

## Framework Selection

| Framework | Characteristics | Recommended For |
|-----------|-----------------|-----------------|
| **axum** | Modern, Tokio ecosystem, type-safe | New projects (default choice) |
| **actix-web** | High performance, Actor model | Performance-critical services |
| **rocket** | Developer-friendly, zero-config | Rapid prototyping |
| **warp** | Filter-based, functional style | Niche use cases |

**Recommendation**: Start with **axum** for most projects. It has excellent ergonomics, strong ecosystem integration, and active development.

---

## Solution Patterns

### Pattern 1: Axum Basic Structure

```rust
use axum::{routing::get, Router};

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/", get(root))
        .route("/users", get(list_users).post(create_user))
        .route("/users/:id", get(get_user).delete(delete_user))
        .with_state(app_state());

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000")
        .await
        .unwrap();

    axum::serve(listener, app)
        .await
        .unwrap();
}
```

**Key insight**: Routes are type-safe, handlers are async functions.

### Pattern 2: Handler Patterns

```rust
use axum::{extract::{Path, Query, Json}, http::StatusCode};

// Path parameters
async fn get_user(Path(id): Path<u32>) -> Result<Json<User>, StatusCode> {
    User::find(id).await
        .map(Json)
        .ok_or(StatusCode::NOT_FOUND)
}

// JSON body
async fn create_user(
    Json(payload): Json<CreateUserRequest>
) -> Result<Json<User>, StatusCode> {
    User::create(payload).await
        .map(Json)
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)
}

// Query parameters
async fn list_users(
    Query(params): Query<ListUsersParams>
) -> Json<Vec<User>> {
    Json(User::list(params).await)
}

// Multiple extractors
async fn update_user(
    Path(id): Path<u32>,
    State(db): State<DbPool>,
    Json(update): Json<UserUpdate>,
) -> Result<Json<User>, ApiError> {
    User::update(&db, id, update).await
        .map(Json)
}
```

**When to use**: Each extractor pattern for different input types.

### Pattern 3: State Management

```rust
use std::sync::Arc;
use sqlx::PgPool;

// Define shared state
#[derive(Clone)]
struct AppState {
    db: PgPool,
    config: Arc<Config>,
}

// Extract state in handlers
async fn handler(State(state): State<AppState>) -> Json<Response> {
    let user = User::fetch(&state.db, 123).await?;
    Json(Response { user })
}

// Setup
let state = AppState {
    db: PgPoolOptions::new()
        .max_connections(5)
        .connect(&db_url)
        .await?,
    config: Arc::new(load_config()),
};

let app = Router::new()
    .route("/", get(handler))
    .with_state(state);
```

**When to use**: Share database pools, configuration, clients across handlers.

**Trade-offs**: State must be `Clone + Send + Sync + 'static`.

### Pattern 4: Error Handling

```rust
use axum::{
    response::{IntoResponse, Response},
    http::StatusCode,
    Json,
};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum ApiError {
    #[error("resource not found")]
    NotFound,

    #[error("invalid input: {0}")]
    Validation(String),

    #[error("database error")]
    Database(#[from] sqlx::Error),

    #[error("authentication required")]
    Unauthorized,
}

impl IntoResponse for ApiError {
    fn into_response(self) -> Response {
        let (status, message) = match self {
            ApiError::NotFound => (StatusCode::NOT_FOUND, self.to_string()),
            ApiError::Validation(msg) => (StatusCode::BAD_REQUEST, msg),
            ApiError::Database(e) => {
                tracing::error!("database error: {}", e);
                (StatusCode::INTERNAL_SERVER_ERROR, "internal error".to_string())
            }
            ApiError::Unauthorized => (StatusCode::UNAUTHORIZED, self.to_string()),
        };

        (status, Json(serde_json::json!({
            "error": message
        }))).into_response()
    }
}
```

**When to use**: Custom error types for domain-specific failures.

---

## Workflow

### Step 1: Choose Framework

```
Need high performance?
  → actix-web

Want modern ergonomics + Tokio ecosystem?
  → axum (recommended)

Rapid prototyping?
  → rocket
```

### Step 2: Design Handler Signatures

```
What data comes from?
  Path → Path<T>
  Query string → Query<T>
  JSON body → Json<T>
  Headers → TypedHeader<T>
  State → State<AppState>
```

### Step 3: Implement Error Handling

```
Library code?
  → Custom error enum + IntoResponse

Application code?
  → anyhow::Error with context
```

### Step 4: Add Middleware

```
Logging → tower_http::trace
CORS → tower_http::cors
Rate limiting → tower::limit
Authentication → custom middleware
```

---

## Middleware Patterns

### Logging Middleware

```rust
use axum::{
    middleware::{self, Next},
    http::Request,
    response::Response,
};
use std::time::Instant;

async fn log_requests<B>(
    req: Request<B>,
    next: Next<B>,
) -> Response {
    let start = Instant::now();
    let method = req.method().clone();
    let uri = req.uri().clone();

    let response = next.run(req).await;

    tracing::info!(
        "{} {} {} - {:?}",
        method,
        uri,
        response.status(),
        start.elapsed()
    );

    response
}

// Apply middleware
let app = Router::new()
    .route("/", get(handler))
    .layer(middleware::from_fn(log_requests));
```

### Authentication Middleware

```rust
use axum::{
    middleware,
    extract::Request,
    http::{StatusCode, header},
};

async fn auth_middleware(
    mut req: Request,
    next: Next,
) -> Result<Response, StatusCode> {
    let auth_header = req.headers()
        .get(header::AUTHORIZATION)
        .and_then(|h| h.to_str().ok())
        .ok_or(StatusCode::UNAUTHORIZED)?;

    let user = validate_token(auth_header)
        .ok_or(StatusCode::UNAUTHORIZED)?;

    req.extensions_mut().insert(user);
    Ok(next.run(req).await)
}
```

---

## Database Integration

### SQLx Pattern

```rust
use sqlx::{PgPool, FromRow};
use chrono::{DateTime, Utc};

// Define model
#[derive(Debug, FromRow)]
struct User {
    id: i32,
    name: String,
    email: String,
    created_at: DateTime<Utc>,
}

// Query
async fn get_user(pool: &PgPool, id: i32) -> Result<User, sqlx::Error> {
    sqlx::query_as!(
        User,
        "SELECT id, name, email, created_at FROM users WHERE id = $1",
        id
    )
    .fetch_one(pool)
    .await
}

// Transaction
async fn create_user_with_profile(
    pool: &PgPool,
    user: NewUser,
) -> Result<User, sqlx::Error> {
    let mut tx = pool.begin().await?;

    let user_id = sqlx::query!(
        "INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id",
        user.name,
        user.email
    )
    .fetch_one(&mut *tx)
    .await?
    .id;

    sqlx::query!(
        "INSERT INTO profiles (user_id, bio) VALUES ($1, $2)",
        user_id,
        user.bio
    )
    .execute(&mut *tx)
    .await?;

    tx.commit().await?;

    get_user(pool, user_id).await
}
```

---

## Best Practices

| Concern | Recommendation |
|---------|----------------|
| JSON serialization | `#[derive(Serialize, Deserialize)]` + serde |
| Configuration | `config` crate + environment variables |
| Logging | `tracing` + `tracing-subscriber` |
| Health check | `GET /health` endpoint returning 200 |
| CORS | `tower_http::cors::CorsLayer` |
| Rate limiting | `tower::limit::RateLimitLayer` |
| OpenAPI | `utoipa` for API documentation |
| Request validation | `validator` crate with #[validate] |
| Graceful shutdown | `tokio::signal` for SIGTERM handling |

---

## Common Pitfalls

| Pitfall | Problem | Solution |
|---------|---------|----------|
| Using `Rc` for state | Not thread-safe | Use `Arc` |
| Holding locks across `.await` | Potential deadlock | Minimize lock scope |
| Not handling errors | Handler panics | Implement `IntoResponse` for errors |
| Large request bodies | Memory pressure | Set body size limits with `DefaultBodyLimit` |
| Missing CORS headers | Browser blocks requests | Add `CorsLayer` |
| Synchronous blocking | Blocks executor | Use `spawn_blocking` for CPU work |

---

## Domain-Driven Project Structure

**Recommended structure for medium-to-large projects:**

```text
src/
├── main.rs                              # Entry point (load config, start HTTP)
├── bootstrap/
│   ├── mod.rs
│   └── app_builder.rs                   # Global assembly (DB/Cache/Telemetry)
├── domains/
│   ├── user/                            # Domain directory with all layers
│   │   ├── mod.rs
│   │   ├── http.rs                      # Routes + handlers + DTO mapping
│   │   ├── app.rs                       # Use cases / commands / queries
│   │   ├── entity.rs                    # Domain entities
│   │   ├── value.rs                     # Value objects
│   │   ├── policy.rs                    # Domain rules/policies
│   │   ├── port.rs                      # Port definitions (traits)
│   │   ├── repo.rs                      # Infrastructure implementation
│   │   ├── cache.rs                     # Caching adapter
│   │   ├── errors.rs                    # Domain errors
│   │   └── tests.rs                     # Domain tests
│   ├── auth/
│   │   ├── mod.rs
│   │   ├── http.rs
│   │   ├── app.rs
│   │   ├── entity.rs
│   │   ├── policy.rs
│   │   ├── port.rs
│   │   ├── repo.rs
│   │   ├── jwt.rs
│   │   ├── errors.rs
│   │   └── tests.rs
│   └── order/
│       ├── mod.rs
│       ├── http.rs
│       ├── app.rs
│       ├── entity.rs
│       ├── port.rs
│       ├── repo.rs
│       ├── events.rs
│       ├── errors.rs
│       └── tests.rs
├── shared/
│   ├── mod.rs
│   ├── error.rs                         # Common error model
│   ├── result.rs                        # Unified Result alias
│   ├── types.rs                         # Common types (ID/Time)
│   └── middleware.rs                    # Cross-domain middleware
└── tests/
    ├── integration/
    └── fixtures/
```

**Structural Principles:**
- **Domain-centric**: Each domain contains interface/application/domain/infrastructure concerns
- **File naming**: Single-word filenames clarify responsibility (`app.rs`, `port.rs`, `repo.rs`, `http.rs`)
- **Loose coupling**: Domains collaborate through application-layer interfaces, avoid direct access
- **Shared utilities**: Common capabilities in `shared/`, domain-specific logic stays local

**File Responsibilities:**
- `http.rs` - HTTP routes, handlers, request/response DTOs
- `app.rs` - Application services, use case orchestration
- `entity.rs` - Domain entities with business logic
- `port.rs` - Port trait definitions (hexagonal architecture)
- `repo.rs` - Repository implementations (database, cache)
- `errors.rs` - Domain-specific error types

---

## Review Checklist

When reviewing web service code:

- [ ] Handlers have appropriate extractors (Path, Query, Json)
- [ ] Shared state uses `Arc` for thread safety
- [ ] Error types implement `IntoResponse`
- [ ] Database operations use connection pooling
- [ ] Middleware is composable and reusable
- [ ] API responses follow consistent JSON format
- [ ] Authentication/authorization properly enforced
- [ ] Request body size limits configured
- [ ] CORS configured for browser clients
- [ ] Health check endpoint exists
- [ ] Logging/tracing properly instrumented
- [ ] Graceful shutdown implemented

---

## Verification Commands

```bash
# Check compilation
cargo check

# Run tests
cargo test

# Integration tests
cargo test --test integration

# Check for common mistakes
cargo clippy -- -D warnings

# Run development server
cargo run

# Build optimized release
cargo build --release

# Run with environment variables
DATABASE_URL=postgres://localhost cargo run
```

---

## Performance Optimization

### Connection Pooling

```rust
use sqlx::postgres::PgPoolOptions;

let pool = PgPoolOptions::new()
    .max_connections(100)
    .min_connections(10)
    .acquire_timeout(Duration::from_secs(5))
    .idle_timeout(Duration::from_secs(600))
    .connect(&database_url)
    .await?;
```

### Response Compression

```rust
use tower_http::compression::CompressionLayer;

let app = Router::new()
    .route("/", get(handler))
    .layer(CompressionLayer::new());
```

### Caching Headers

```rust
use axum::http::{header, HeaderMap};

async fn cached_handler() -> (HeaderMap, Json<Data>) {
    let mut headers = HeaderMap::new();
    headers.insert(
        header::CACHE_CONTROL,
        "public, max-age=3600".parse().unwrap(),
    );

    (headers, Json(get_data()))
}
```

---

## Related Skills

- **rust-async** - Async patterns for handlers
- **rust-concurrency** - Thread safety in web services
- **rust-database** - Database integration patterns
- **rust-error** - Error handling strategies
- **rust-auth** - Authentication and authorization
- **rust-middleware** - Middleware patterns
- **rust-observability** - Logging and metrics

---

## Localized Reference

- **Chinese version**: [SKILL_ZH.md](./SKILL_ZH.md) - 完整中文版本，包含所有内容
