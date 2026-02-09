---
name: rust-auth
description: Authentication and authorization expert covering JWT, API keys, OAuth, RBAC, password hashing, distributed token storage, and session management patterns.
metadata:
  triggers:
    - authentication
    - authorization
    - JWT
    - API key
    - OAuth
    - RBAC
    - password
    - session
    - token
    - auth
---


## Authentication Strategies

| Method | Use Case | Security | Complexity |
|--------|----------|----------|------------|
| **JWT Token** | API access, SPA | High | Medium |
| **API Key** | Service-to-service, automation | Medium | Low |
| **OAuth 2.0** | Third-party login | High | High |
| **Session Cookie** | Traditional web apps | Medium | Medium |
| **mTLS** | Service mesh, microservices | Very High | High |


## Solution Patterns

### Pattern 1: JWT Authentication

```rust
use jsonwebtoken::{decode, encode, Algorithm, DecodingKey, EncodingKey, Header, Validation};
use serde::{Deserialize, Serialize};
use std::time::{SystemTime, UNIX_EPOCH};

#[derive(Debug, Serialize, Deserialize)]
struct Claims {
    sub: String,           // Subject (user ID)
    exp: u64,              // Expiration
    iat: u64,              // Issued at
    roles: Vec<String>,    // User roles
}

struct JwtService {
    encoding_key: EncodingKey,
    decoding_key: DecodingKey,
    algorithm: Algorithm,
    expiry_seconds: u64,
}

impl JwtService {
    // Recommended: EdDSA (Ed25519)
    pub fn new_ed25519(private_pem: &[u8], public_pem: &[u8]) -> Result<Self, Error> {
        Ok(Self {
            encoding_key: EncodingKey::from_ed_pem(private_pem)?,
            decoding_key: DecodingKey::from_ed_pem(public_pem)?,
            algorithm: Algorithm::EdDSA,
            expiry_seconds: 3600, // 1 hour
        })
    }

    // Alternative: RS256 (RSA)
    pub fn new_rs256(private_pem: &[u8], public_pem: &[u8]) -> Result<Self, Error> {
        Ok(Self {
            encoding_key: EncodingKey::from_rsa_pem(private_pem)?,
            decoding_key: DecodingKey::from_rsa_pem(public_pem)?,
            algorithm: Algorithm::RS256,
            expiry_seconds: 3600,
        })
    }

    pub fn generate_token(&self, user_id: &str, roles: Vec<String>) -> Result<String, Error> {
        let now = SystemTime::now().duration_since(UNIX_EPOCH)?.as_secs();

        let claims = Claims {
            sub: user_id.to_string(),
            exp: now + self.expiry_seconds,
            iat: now,
            roles,
        };

        encode(&Header::new(self.algorithm), &claims, &self.encoding_key)
            .map_err(Into::into)
    }

    pub fn verify_token(&self, token: &str) -> Result<Claims, Error> {
        let mut validation = Validation::new(self.algorithm);
        validation.validate_exp = true;

        decode::<Claims>(token, &self.decoding_key, &validation)
            .map(|data| data.claims)
            .map_err(Into::into)
    }
}
```

**Algorithm Selection:**
- **EdDSA (Ed25519)**: Recommended default (fast, secure, small keys)
- **RS256**: Use when ecosystem already standardized on RSA
- **HS256**: Only for single-service, tightly controlled scenarios

### Pattern 2: API Key Authentication

```rust
use sha2::{Digest, Sha256};
use rand::{thread_rng, Rng};

struct ApiKey {
    key_id: String,
    secret_hash: String,
    owner_id: String,
    scopes: Vec<String>,
    expires_at: i64,
    disabled: bool,
}

struct ApiKeyService {
    secret: String,
    prefix: String,
}

impl ApiKeyService {
    pub fn generate(&self, owner_id: &str, scopes: Vec<String>) -> (String, String) {
        let key_id = self.generate_id();
        let secret = self.generate_secret();
        let signature = self.compute_signature(&key_id, &secret);

        let api_key = format!("{}_{}_{}", self.prefix, key_id, signature);
        let secret_hash = self.hash_secret(&secret);

        (api_key, secret_hash)
    }

    pub fn verify(&self, api_key: &str, stored: &ApiKey) -> Result<(), AuthError> {
        if stored.disabled {
            return Err(AuthError::KeyRevoked);
        }

        let now = chrono::Utc::now().timestamp();
        if stored.expires_at < now {
            return Err(AuthError::KeyExpired);
        }

        let parts: Vec<&str> = api_key.split('_').collect();
        if parts.len() != 3 {
            return Err(AuthError::InvalidFormat);
        }

        let expected_sig = self.compute_signature(parts[1], "");
        if parts[2] != expected_sig {
            return Err(AuthError::InvalidSignature);
        }

        Ok(())
    }

    fn generate_id(&self) -> String {
        const CHARSET: &[u8] = b"abcdefghijklmnopqrstuvwxyz0123456789";
        let mut rng = thread_rng();
        (0..16).map(|_| CHARSET[rng.gen_range(0..CHARSET.len())] as char).collect()
    }

    fn generate_secret(&self) -> String {
        const CHARSET: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        let mut rng = thread_rng();
        (0..32).map(|_| CHARSET[rng.gen_range(0..CHARSET.len())] as char).collect()
    }

    fn compute_signature(&self, key_id: &str, secret: &str) -> String {
        let mut hasher = Sha256::new();
        hasher.update(format!("{}{}{}", key_id, secret, self.secret));
        format!("{:x}", hasher.finalize())[..16].to_string()
    }

    fn hash_secret(&self, secret: &str) -> String {
        let mut hasher = Sha256::new();
        hasher.update(format!("{}{}", secret, self.secret));
        format!("{:x}", hasher.finalize())
    }
}
```

### Pattern 3: Password Hashing (Argon2)

```rust
use argon2::{Argon2, PasswordHash, PasswordHasher, PasswordVerifier};
use argon2::password_hash::{rand_core::OsRng, SaltString};

struct PasswordService;

impl PasswordService {
    pub fn hash_password(password: &str) -> Result<String, argon2::password_hash::Error> {
        let salt = SaltString::generate(&mut OsRng);
        let argon2 = Argon2::default();

        let hash = argon2.hash_password(password.as_bytes(), &salt)?;
        Ok(hash.to_string())
    }

    pub fn verify_password(password: &str, hash: &str) -> Result<bool, argon2::password_hash::Error> {
        let parsed_hash = PasswordHash::new(hash)?;
        let argon2 = Argon2::default();

        Ok(argon2.verify_password(password.as_bytes(), &parsed_hash).is_ok())
    }
}
```

### Pattern 4: Distributed Token Storage (Redis)

```rust
use redis::AsyncCommands;
use serde_json;

struct TokenStore {
    redis: redis::aio::ConnectionManager,
    prefix: String,
}

impl TokenStore {
    pub async fn store_token(
        &mut self,
        user_id: &str,
        token_id: &str,
        claims: &Claims,
        max_concurrent: usize,
    ) -> Result<(), Error> {
        let user_tokens_key = format!("{}:user:{}:tokens", self.prefix, user_id);

        // Check concurrent session limit
        let count: usize = self.redis.scard(&user_tokens_key).await?;
        if count >= max_concurrent {
            // Remove oldest token
            if let Some(old_token) = self.redis.spop::<_, Option<String>>(&user_tokens_key).await? {
                self.redis.del(format!("{}:token:{}", self.prefix, old_token)).await?;
            }
        }

        // Store new token
        let token_key = format!("{}:token:{}", self.prefix, token_id);
        let data = serde_json::to_string(claims)?;
        let ttl = claims.exp - chrono::Utc::now().timestamp() as u64;

        self.redis.set_ex(&token_key, data, ttl as usize).await?;
        self.redis.sadd(&user_tokens_key, token_id).await?;

        Ok(())
    }

    pub async fn revoke_token(&mut self, user_id: &str, token_id: &str) -> Result<(), Error> {
        self.redis.del(format!("{}:token:{}", self.prefix, token_id)).await?;
        self.redis.srem(format!("{}:user:{}:tokens", self.prefix, user_id), token_id).await?;
        Ok(())
    }

    pub async fn revoke_all_tokens(&mut self, user_id: &str) -> Result<(), Error> {
        let user_tokens_key = format!("{}:user:{}:tokens", self.prefix, user_id);
        let tokens: Vec<String> = self.redis.smembers(&user_tokens_key).await?;

        for token_id in tokens {
            self.redis.del(format!("{}:token:{}", self.prefix, token_id)).await?;
        }
        self.redis.del(&user_tokens_key).await?;

        Ok(())
    }
}
```

### Pattern 5: Auth Middleware (Axum)

```rust
use axum::{
    extract::Request,
    middleware::Next,
    response::Response,
    http::StatusCode,
};

pub async fn jwt_auth_middleware(
    mut req: Request,
    next: Next,
) -> Result<Response, StatusCode> {
    let auth_header = req.headers()
        .get("Authorization")
        .and_then(|h| h.to_str().ok())
        .ok_or(StatusCode::UNAUTHORIZED)?;

    let token = auth_header
        .strip_prefix("Bearer ")
        .ok_or(StatusCode::UNAUTHORIZED)?;

    let jwt_service = req.extensions()
        .get::<JwtService>()
        .ok_or(StatusCode::INTERNAL_SERVER_ERROR)?;

    let claims = jwt_service
        .verify_token(token)
        .map_err(|_| StatusCode::UNAUTHORIZED)?;

    req.extensions_mut().insert(claims);
    Ok(next.run(req).await)
}
```


## RBAC (Role-Based Access Control)

```rust
#[derive(Debug, Clone)]
pub enum Permission {
    Read,
    Write,
    Delete,
    Admin,
}

#[derive(Debug, Clone)]
pub struct Role {
    name: String,
    permissions: Vec<Permission>,
}

pub struct RbacService {
    roles: HashMap<String, Role>,
}

impl RbacService {
    pub fn check_permission(&self, user_roles: &[String], required: Permission) -> bool {
        user_roles.iter().any(|role_name| {
            self.roles
                .get(role_name)
                .map(|role| role.permissions.contains(&required))
                .unwrap_or(false)
        })
    }
}
```


## Workflow

### Step 1: Choose Auth Strategy

```
Use case:
  → API/SPA? JWT
  → Service-to-service? API Key or mTLS
  → Traditional web? Session Cookie
  → Third-party login? OAuth 2.0
  → Microservices? mTLS + JWT
```

### Step 2: Implement Securely

```
Security checklist:
  → Strong password hashing (Argon2)
  → Secure token generation (crypto random)
  → HTTPS only in production
  → Validate all inputs
  → Rate limiting on auth endpoints
  → Audit logging
```

### Step 3: Handle Token Lifecycle

```
Token management:
  → Issue: Generate with expiry
  → Refresh: Before expiry
  → Revoke: Blacklist or store state
  → Rotate: Periodic key rotation
```


## Review Checklist

When implementing auth:

- [ ] Passwords hashed with Argon2 (not bcrypt/MD5)
- [ ] JWT tokens have expiration
- [ ] API keys have scope limitations
- [ ] HTTPS enforced in production
- [ ] Rate limiting on login endpoints
- [ ] Audit logging for auth events
- [ ] Token refresh mechanism
- [ ] Secure session storage (Redis with encryption)
- [ ] IP whitelisting for API keys
- [ ] Concurrent session limits


## Verification Commands

```bash
# Test JWT generation
cargo test jwt_generation

# Verify password hashing
cargo test password_hashing

# Check token expiration
cargo test token_expiry

# Load test auth endpoints
wrk -t4 -c100 -d30s http://localhost:3000/auth/login
```


## Common Pitfalls

### 1. Weak Password Hashing

**Symptom**: Fast brute-force attacks

```rust
// ❌ Bad: MD5/SHA256 (too fast)
let hash = format!("{:x}", md5::compute(password));

// ✅ Good: Argon2 (designed for passwords)
let hash = Argon2::default().hash_password(password.as_bytes(), &salt)?;
```

### 2. No Token Expiration

**Symptom**: Stolen tokens valid forever

```rust
// ❌ Bad: no expiration
let claims = Claims { sub: user_id, exp: None };

// ✅ Good: reasonable expiry
let claims = Claims {
    sub: user_id,
    exp: now + 3600, // 1 hour
};
```

### 3. Storing Tokens in LocalStorage

**Symptom**: XSS vulnerability

```javascript
// ❌ Bad: accessible to XSS
localStorage.setItem('token', jwt);

// ✅ Good: HTTP-only cookie
// Set-Cookie: token=...; HttpOnly; Secure; SameSite=Strict
```


## Related Skills

- **rust-web** - Web framework integration
- **rust-middleware** - Middleware patterns
- **rust-cache** - Token storage with Redis
- **rust-error** - Error handling
- **rust-database** - User storage


## Localized Reference

- **Chinese version**: [SKILL_ZH.md](./SKILL_ZH.md) - 完整中文版本，包含所有内容
