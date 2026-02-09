---
name: rust-middleware
description: Web middleware expert covering request tracking, CORS configuration, rate limiting, authentication guards, compression, and middleware composition patterns.
metadata:
  triggers:
    - middleware
    - CORS
    - rate limiting
    - request tracking
    - authentication guard
    - compression
    - middleware pattern
---


## Solution Patterns

### Pattern 1: Request Tracking Middleware (Actix)

```rust
use actix_web::{
    dev::{forward_ready, Service, ServiceRequest, ServiceResponse, Transform},
    Error, HttpMessage,
};
use futures::future::{ready, LocalBoxFuture, Ready};
use std::rc::Rc;
use uuid::Uuid;

#[derive(Debug, Clone)]
pub struct RequestId(pub String);

pub struct RequestTracking;

impl<S, B> Transform<S, ServiceRequest> for RequestTracking
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error> + 'static,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type InitError = ();
    type Transform = RequestTrackingMiddleware<S>;
    type Future = Ready<Result<Self::Transform, Self::InitError>>;

    fn new_transform(&self, service: S) -> Self::Future {
        ready(Ok(RequestTrackingMiddleware {
            service: Rc::new(service),
        }))
    }
}

pub struct RequestTrackingMiddleware<S> {
    service: Rc<S>,
}

impl<S, B> Service<ServiceRequest> for RequestTrackingMiddleware<S>
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error> + 'static,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Future = LocalBoxFuture<'static, Result<Self::Response, Self::Error>>;

    forward_ready!(service);

    fn call(&self, req: ServiceRequest) -> Self::Future {
        let service = Rc::clone(&self.service);

        Box::pin(async move {
            // Extract or generate request ID
            let request_id = req
                .headers()
                .get("X-Request-ID")
                .or_else(|| req.headers().get("Request-ID"))
                .and_then(|v| v.to_str().ok())
                .map(|s| s.to_string())
                .unwrap_or_else(|| Uuid::new_v4().to_string());

            // Store in request extensions
            req.extensions_mut().insert(RequestId(request_id.clone()));

            let start_time = std::time::Instant::now();
            log::info!("Request: {} {} - ID: {}", req.method(), req.path(), request_id);

            // Call next middleware
            let mut res = service.call(req).await?;

            let duration = start_time.elapsed();
            log::info!(
                "Response: {} - Duration: {:?} - ID: {}",
                res.status().as_u16(),
                duration,
                request_id
            );

            // Add request ID to response headers
            res.headers_mut().insert(
                actix_web::http::header::HeaderName::from_static("x-request-id"),
                actix_web::http::header::HeaderValue::from_str(&request_id).unwrap(),
            );

            Ok(res)
        })
    }
}

// Usage
use actix_web::{web, App, HttpServer};

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .wrap(RequestTracking)  // Add middleware
            .route("/api", web::get().to(handler))
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await
}
```

### Pattern 2: CORS Configuration

```rust
use actix_cors::Cors;
use actix_web::http::header;

pub struct CorsBuilder;

impl CorsBuilder {
    /// Production CORS with strict origin validation
    pub fn production(allowed_origins: &[&str]) -> Cors {
        Cors::default()
            .allowed_origin_fn(move |origin, _req_head| {
                let origin_str = origin.to_str().unwrap_or("");
                let allowed = allowed_origins.iter().any(|&o| o == origin_str);
                log::debug!("CORS: origin={} allowed={}", origin_str, allowed);
                allowed
            })
            .allowed_methods(vec!["OPTIONS", "HEAD", "GET", "POST", "PUT", "PATCH", "DELETE"])
            .allowed_headers(vec![
                header::AUTHORIZATION,
                header::ACCEPT,
                header::CONTENT_TYPE,
            ])
            .expose_headers(vec!["x-request-id"])
            .supports_credentials()
            .max_age(3600)
    }

    /// Development CORS allowing any origin
    pub fn development() -> Cors {
        Cors::default()
            .allow_any_origin()
            .allow_any_method()
            .allow_any_header()
            .supports_credentials()
    }

    /// API CORS for strict origin control
    pub fn api(strict_origins: &[&str]) -> Cors {
        Cors::default()
            .allowed_origins(strict_origins)
            .allowed_methods(vec!["GET", "POST", "PUT", "DELETE", "PATCH"])
            .allowed_headers(vec![header::AUTHORIZATION, header::CONTENT_TYPE])
            .max_age(86400)
    }
}

// Usage
HttpServer::new(|| {
    App::new()
        .wrap(CorsBuilder::production(&["https://example.com"]))
        .service(api_routes())
})
```

### Pattern 3: Rate Limiting Middleware

```rust
use actix_web::{
    dev::{forward_ready, Service, ServiceRequest, ServiceResponse, Transform},
    Error, HttpResponse,
};
use futures::future::{ready, LocalBoxFuture, Ready};
use std::collections::HashMap;
use std::sync::Arc;
use std::time::{Duration, Instant};
use tokio::sync::RwLock;

#[derive(Debug, Clone)]
pub struct RateLimitConfig {
    pub requests_per_second: u64,
    pub window_seconds: u64,
    pub whitelist: Vec<String>,
}

struct SlidingWindow {
    count: u64,
    window_start: Instant,
}

pub struct RateLimiting {
    config: RateLimitConfig,
    counters: Arc<RwLock<HashMap<String, SlidingWindow>>>,
}

impl RateLimiting {
    pub fn new(config: RateLimitConfig) -> Self {
        Self {
            config,
            counters: Arc::new(RwLock::new(HashMap::new())),
        }
    }

    async fn is_rate_limited(&self, key: &str) -> bool {
        let mut counters = self.counters.write().await;
        let now = Instant::now();

        // Clean up expired windows
        counters.retain(|_, w| {
            now.duration_since(w.window_start) < Duration::from_secs(self.config.window_seconds)
        });

        // Check or create window for this key
        match counters.get_mut(key) {
            Some(window) => {
                if now.duration_since(window.window_start)
                    < Duration::from_secs(self.config.window_seconds)
                {
                    window.count += 1;
                    window.count > self.config.requests_per_second
                } else {
                    // Reset window
                    window.count = 1;
                    window.window_start = now;
                    false
                }
            }
            None => {
                // New window
                counters.insert(
                    key.to_string(),
                    SlidingWindow {
                        count: 1,
                        window_start: now,
                    },
                );
                false
            }
        }
    }
}

impl<S, B> Transform<S, ServiceRequest> for RateLimiting
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error> + 'static,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type InitError = ();
    type Transform = RateLimitingMiddleware<S>;
    type Future = Ready<Result<Self::Transform, Self::InitError>>;

    fn new_transform(&self, service: S) -> Self::Future {
        ready(Ok(RateLimitingMiddleware {
            service,
            config: self.config.clone(),
            counters: self.counters.clone(),
        }))
    }
}

pub struct RateLimitingMiddleware<S> {
    service: S,
    config: RateLimitConfig,
    counters: Arc<RwLock<HashMap<String, SlidingWindow>>>,
}

impl<S, B> Service<ServiceRequest> for RateLimitingMiddleware<S>
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error> + 'static,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Future = LocalBoxFuture<'static, Result<Self::Response, Self::Error>>;

    forward_ready!(service);

    fn call(&self, req: ServiceRequest) -> Self::Future {
        let client_ip = req
            .connection_info()
            .peer_addr()
            .map(|s| s.to_string())
            .unwrap_or_else(|| "unknown".to_string());

        // Skip rate limiting for whitelisted IPs
        if self.config.whitelist.contains(&client_ip) {
            return Box::pin(self.service.call(req));
        }

        let counters = self.counters.clone();
        let config = self.config.clone();
        let service = self.service.clone();

        Box::pin(async move {
            let limiter = RateLimiting {
                config,
                counters,
            };

            if limiter.is_rate_limited(&client_ip).await {
                let response = HttpResponse::TooManyRequests().json(serde_json::json!({
                    "error": "RATE_LIMIT_EXCEEDED",
                    "message": "Too many requests"
                }));
                return Ok(ServiceResponse::new(req.into_parts().0, response));
            }

            service.call(req).await
        })
    }
}

// Usage
let rate_limit = RateLimiting::new(RateLimitConfig {
    requests_per_second: 100,
    window_seconds: 60,
    whitelist: vec!["127.0.0.1".to_string()],
});

HttpServer::new(move || {
    App::new()
        .wrap(rate_limit.clone())
        .service(api_routes())
})
```

### Pattern 4: Authentication Guard (Axum)

```rust
use axum::{
    extract::Request,
    http::StatusCode,
    middleware::Next,
    response::{IntoResponse, Response},
};

#[derive(Clone)]
pub struct Claims {
    pub sub: String,
    pub exp: usize,
}

pub async fn auth_middleware(
    mut req: Request,
    next: Next,
) -> Result<Response, StatusCode> {
    let auth_header = req
        .headers()
        .get("Authorization")
        .and_then(|h| h.to_str().ok())
        .ok_or(StatusCode::UNAUTHORIZED)?;

    let token = auth_header
        .strip_prefix("Bearer ")
        .ok_or(StatusCode::UNAUTHORIZED)?;

    // Verify JWT token
    let claims = verify_jwt(token)
        .map_err(|_| StatusCode::UNAUTHORIZED)?;

    // Store claims in request extensions
    req.extensions_mut().insert(claims);

    Ok(next.run(req).await)
}

fn verify_jwt(token: &str) -> Result<Claims, jsonwebtoken::errors::Error> {
    // JWT verification logic
    todo!()
}

// Usage with Axum
use axum::{middleware, routing::get, Router};

async fn protected_handler(
    Extension(claims): Extension<Claims>,
) -> impl IntoResponse {
    format!("Hello, user {}", claims.sub)
}

let app = Router::new()
    .route("/protected", get(protected_handler))
    .layer(middleware::from_fn(auth_middleware));
```

### Pattern 5: Compression Middleware

```rust
use actix_web::middleware::Compress;

// Actix compression middleware
HttpServer::new(|| {
    App::new()
        .wrap(Compress::default())  // Enables gzip, brotli, deflate
        .service(api_routes())
})

// Axum compression
use tower_http::compression::CompressionLayer;

let app = Router::new()
    .route("/", get(handler))
    .layer(CompressionLayer::new());  // Enables gzip, br, deflate, zstd
```


## Middleware Composition Patterns

### Layer-Based Ordering

```
Request Flow:
  ↓
┌─────────────────────┐
│   Request Tracking  │  1. Generate request ID
├─────────────────────┤
│   CORS              │  2. Handle preflight
├─────────────────────┤
│   Compression       │  3. Compress response
├─────────────────────┤
│   Rate Limiting     │  4. Check rate limits
├─────────────────────┤
│   Authentication    │  5. Verify credentials
├─────────────────────┤
│   Handler           │  6. Business logic
└─────────────────────┘
  ↓
Response
```


## Workflow

### Step 1: Identify Cross-Cutting Concerns

```
Common middleware needs:
  → Request tracking? Add request ID middleware
  → API from web clients? Add CORS
  → Public API? Add rate limiting
  → Protected routes? Add authentication guard
  → Large responses? Add compression
  → Logging? Add logger middleware
```

### Step 2: Choose Middleware Order

```
Recommended order (outer to inner):
  1. Request tracking (first, for logging)
  2. CORS (handle preflight early)
  3. Compression (wrap entire response)
  4. Rate limiting (before expensive operations)
  5. Authentication (verify before business logic)
  6. Handler (business logic)
```

### Step 3: Configure Per Environment

```
Development:
  → Permissive CORS
  → Verbose logging
  → No rate limiting

Production:
  → Strict CORS with whitelist
  → Info logging only
  → Rate limiting enabled
  → Compression enabled
```


## Review Checklist

When implementing middleware:

- [ ] Middleware order optimized (outer to inner matters)
- [ ] Request extensions used for passing data
- [ ] Error handling doesn't expose internals
- [ ] CORS configured correctly for environment
- [ ] Rate limiting uses distributed store (Redis) in production
- [ ] Authentication middleware only on protected routes
- [ ] Compression enabled for large responses
- [ ] Request tracking includes correlation IDs
- [ ] Middleware is composable and reusable
- [ ] No blocking operations in middleware


## Verification Commands

```bash
# Test CORS configuration
curl -X OPTIONS http://localhost:8080/api \
  -H "Origin: https://example.com" \
  -H "Access-Control-Request-Method: POST" \
  -v

# Test rate limiting
for i in {1..150}; do
  curl http://localhost:8080/api &
done

# Check compression
curl http://localhost:8080/api \
  -H "Accept-Encoding: gzip" \
  -v | grep "Content-Encoding"

# Test authentication
curl http://localhost:8080/protected \
  -H "Authorization: Bearer <token>" \
  -v

# Load test middleware stack
wrk -t4 -c100 -d30s http://localhost:8080/api
```


## Common Pitfalls

### 1. Incorrect CORS Configuration

**Symptom**: Preflight requests fail, browser blocks requests

```rust
// ❌ Bad: Allowing credentials without specific origin
Cors::default()
    .allow_any_origin()
    .supports_credentials()  // Error: can't use with allow_any_origin

// ✅ Good: Specific origins with credentials
Cors::default()
    .allowed_origins(&["https://example.com"])
    .supports_credentials()
```

### 2. Rate Limiting Memory Leak

**Symptom**: Memory grows unbounded

```rust
// ❌ Bad: No cleanup of old entries
let counters: HashMap<String, Counter> = HashMap::new();
// Old entries never removed

// ✅ Good: Periodic cleanup
counters.retain(|_, window| {
    now.duration_since(window.start) < window_duration
});
```

### 3. Blocking Operations in Middleware

**Symptom**: Request latency spikes, thread starvation

```rust
// ❌ Bad: Blocking I/O in middleware
async fn bad_middleware(req: Request, next: Next) -> Response {
    std::fs::read("config.json").unwrap();  // Blocks!
    next.run(req).await
}

// ✅ Good: Async I/O
async fn good_middleware(req: Request, next: Next) -> Response {
    tokio::fs::read("config.json").await.unwrap();
    next.run(req).await
}
```


## Related Skills

- **rust-web** - Web framework basics
- **rust-auth** - Authentication implementations
- **rust-async** - Async middleware patterns
- **rust-error** - Error handling in middleware
- **rust-performance** - Middleware optimization


## Localized Reference

- **Chinese version**: [SKILL_ZH.md](./SKILL_ZH.md) - 完整中文版本，包含所有内容
