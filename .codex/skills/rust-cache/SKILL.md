---
name: rust-cache
description: 'Caching and distributed storage expert covering Redis, connection pools,
  TTL strategies,

  cache patterns (Cache-Aside, Write-Through), invalidation, and performance optimization.

  '
metadata:
  triggers:
  - cache
  - caching
  - Redis
  - TTL
  - cache invalidation
  - connection pool
  - distributed cache
  - cache-aside
  - write-through
---

# Caching and Distributed Storage Expert

## Core Question

**How do you design effective caching strategies that improve performance without compromising data consistency?**

Caching can improve read performance by 95%+, but requires careful TTL management and invalidation strategies.

---

## Solution Patterns

### Pattern 1: Cache Manager with Connection Pool

```rust
use redis::{aio::ConnectionManager, AsyncCommands};
use serde::{de::DeserializeOwned, Serialize};
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::RwLock;

pub struct CacheManager {
    config: CacheConfig,
    redis: Option<ConnectionManager>,
    stats: Arc<RwLock<CacheStats>>,
}

impl CacheManager {
    pub async fn new(config: CacheConfig) -> Result<Self, CacheError> {
        let redis = if config.enabled && config.redis.enabled {
            let client = redis::Client::open(config.redis.url.as_str())
                .map_err(|e| CacheError::Connection(format!("Redis connection failed: {}", e)))?;

            // Timeout control for remote Redis
            let timeout = Duration::from_secs(30);

            match tokio::time::timeout(timeout, ConnectionManager::new(client)).await {
                Ok(Ok(conn)) => Some(conn),
                Ok(Err(e)) => return Err(CacheError::Connection(format!("Redis failed: {}", e))),
                Err(_) => return Err(CacheError::Timeout(format!("Redis timeout ({}s)", timeout.as_secs()))),
            }
        } else {
            None
        };

        Ok(Self {
            config,
            redis,
            stats: Arc::new(RwLock::new(CacheStats::new())),
        })
    }

    pub async fn get<T: DeserializeOwned>(&self, key: &str) -> Result<Option<T>, CacheError> {
        if !self.config.enabled {
            return Ok(None);
        }

        // Update stats
        {
            let mut stats = self.stats.write().await;
            stats.total_requests += 1;
        }

        if let Some(mut redis) = self.redis.clone() {
            match redis.get::<&str, Vec<u8>>(key).await {
                Ok(bytes) if !bytes.is_empty() => {
                    {
                        let mut stats = self.stats.write().await;
                        stats.redis_hits += 1;
                    }
                    self.deserialize(&bytes)
                }
                Ok(_) => {
                    let mut stats = self.stats.write().await;
                    stats.redis_misses += 1;
                    Ok(None)
                }
                Err(e) => {
                    log::warn!("Redis read failed: key={}, error={}", key, e);
                    let mut stats = self.stats.write().await;
                    stats.redis_misses += 1;
                    Ok(None)  // Cache failures shouldn't block business logic
                }
            }
        } else {
            Ok(None)
        }
    }

    pub async fn set<T: Serialize>(
        &self,
        key: &str,
        value: &T,
        ttl: Option<u64>,
    ) -> Result<(), CacheError> {
        if !self.config.enabled {
            return Ok(());
        }

        let bytes = self.serialize(value)?;

        if let Some(mut redis) = self.redis.clone() {
            let ttl_seconds = ttl.unwrap_or(self.config.default_ttl);
            match redis.set_ex::<&str, Vec<u8>, ()>(key, bytes, ttl_seconds).await {
                Ok(_) => log::debug!("Redis write: key={}, ttl={}s", key, ttl_seconds),
                Err(e) => log::warn!("Redis write failed: key={}, error={}", key, e),
            }
        }

        Ok(())
    }

    fn serialize<T: Serialize>(&self, value: &T) -> Result<Vec<u8>, CacheError> {
        serde_json::to_vec(value).map_err(|e| {
            CacheError::Serialization(format!("Serialization failed: {}", e))
        })
    }

    fn deserialize<T: DeserializeOwned>(&self, bytes: &[u8]) -> Result<Option<T>, CacheError> {
        if bytes.is_empty() {
            return Ok(None);
        }

        match serde_json::from_slice(bytes) {
            Ok(value) => Ok(Some(value)),
            Err(e) => {
                log::warn!("Deserialization failed: {}", e);
                Ok(None)  // Corrupted data should be skipped, not error
            }
        }
    }
}

#[derive(Debug, Clone, Default)]
pub struct CacheStats {
    pub total_requests: u64,
    pub redis_hits: u64,
    pub redis_misses: u64,
}

impl CacheStats {
    pub fn hit_rate(&self) -> f64 {
        if self.total_requests == 0 {
            0.0
        } else {
            self.redis_hits as f64 / self.total_requests as f64 * 100.0
        }
    }
}
```

### Pattern 2: Cache Key Design

```rust
use sha2::{Digest, Sha256};

pub struct CacheKeyBuilder;

impl CacheKeyBuilder {
    /// Build namespaced key
    /// Format: {namespace}:{entity}:{id}
    pub fn build(namespace: &str, entity: &str, id: impl std::fmt::Display) -> String {
        format!("{}:{}:{}", namespace, entity, id)
    }

    /// Build list cache key with query hash
    /// Format: {namespace}:{entity}:list:{query_hash}
    pub fn list_key(namespace: &str, entity: &str, query: &str) -> String {
        let mut hasher = Sha256::new();
        hasher.update(query.as_bytes());
        let hash = format!("{:x}", hasher.finalize());
        format!("{}:{}:list:{}", namespace, entity, &hash[..8])
    }

    /// Build pattern matching key
    /// Format: {namespace}:{entity}:*
    pub fn pattern(namespace: &str, entity: &str) -> String {
        format!("{}:{}:*", namespace, entity)
    }

    /// Build versioned key
    /// Format: {namespace}:{entity}:{id}:v{version}
    pub fn versioned(namespace: &str, entity: &str, id: impl std::fmt::Display, version: u64) -> String {
        format!("{}:{}:{}:v{}", namespace, entity, id, version)
    }
}

// Usage examples
fn example_key_usage() {
    // Single entity
    let key = CacheKeyBuilder::build("myapp", "user", 123);
    // myapp:user:123

    // List query
    let key = CacheKeyBuilder::list_key("myapp", "posts", "tag=rust&sort=date");
    // myapp:posts:list:a3f2d8e1

    // Pattern for deletion
    let pattern = CacheKeyBuilder::pattern("myapp", "user");
    // myapp:user:*
}
```

### Pattern 3: Cache-Aside Pattern (Lazy Loading)

```rust
pub struct CacheBreaker<K, T> {
    manager: Arc<CacheManager>,
    _phantom: std::marker::PhantomData<(K, T)>,
}

impl<K, T> CacheBreaker<K, T>
where
    K: std::fmt::Display + Clone + Send + Sync,
    T: DeserializeOwned + Serialize + Clone,
{
    pub fn new(manager: Arc<CacheManager>) -> Self {
        Self {
            manager,
            _phantom: std::marker::PhantomData
        }
    }

    /// Get data with cache protection
    pub async fn get_or_load<F, Fut>(&self, key: &str, loader: F) -> Result<Option<T>, CacheError>
    where
        F: FnOnce() -> Fut,
        Fut: std::future::Future<Output = Result<Option<T>, CacheError>>,
    {
        // 1. Try cache first
        if let Some(cached) = self.manager.get::<T>(key).await? {
            return Ok(Some(cached));
        }

        // 2. Cache miss, load from data source
        let result = loader().await?;

        // 3. Write back to cache
        if let Some(ref value) = result {
            self.manager.set(key, value, None).await?;
        }

        Ok(result)
    }
}

// Usage
async fn get_user(cache: &CacheBreaker<UserId, User>, id: UserId) -> Result<Option<User>> {
    let key = format!("user:{}", id);

    cache.get_or_load(&key, || async move {
        database.fetch_user(id).await
    }).await
}
```

### Pattern 4: Pattern-Based Batch Deletion

```rust
impl CacheManager {
    /// Batch delete with pattern matching using SCAN
    /// Avoids blocking with DEL command
    pub async fn delete_pattern(&self, pattern: &str) -> Result<usize, CacheError> {
        let mut deleted_count = 0;

        if let Some(redis) = &self.redis {
            let mut cursor: u64 = 0;

            loop {
                let result: std::result::Result<(u64, Vec<String>), redis::RedisError> =
                    redis::cmd("SCAN")
                        .arg(cursor)
                        .arg("MATCH")
                        .arg(pattern)
                        .arg("COUNT")
                        .arg(100)
                        .query_async(&mut redis.clone())
                        .await;

                match result {
                    Ok((new_cursor, keys)) => {
                        if !keys.is_empty() {
                            let del_result: std::result::Result<(), redis::RedisError> =
                                redis::cmd("DEL")
                                    .arg(&keys)
                                    .query_async(&mut redis.clone())
                                    .await;

                            if del_result.is_ok() {
                                deleted_count += keys.len();
                            }
                        }
                        cursor = new_cursor;
                        if cursor == 0 {
                            break;
                        }
                    }
                    Err(e) => {
                        log::warn!("Redis SCAN failed: {}", e);
                        break;
                    }
                }
            }

            log::info!("Batch delete completed: pattern={}, deleted={}", pattern, deleted_count);
        }

        Ok(deleted_count)
    }
}

// Usage
async fn invalidate_user_cache(cache: &CacheManager, user_id: u64) -> Result<()> {
    // Delete all user-related cache entries
    let pattern = format!("myapp:user:{}:*", user_id);
    cache.delete_pattern(&pattern).await?;
    Ok(())
}
```

### Pattern 5: Cache Avalanche Protection with TTL Jitter

```rust
use rand::Rng;

/// Add random jitter to TTL to prevent cache avalanche
fn calculate_jitter_ttl(base_ttl: u64) -> u64 {
    let jitter_range = (base_ttl as f64 * 0.1)..(base_ttl as f64 * 0.2);
    let jitter_seconds = rand::thread_rng().gen_range(jitter_range);
    (base_ttl as f64 + jitter_seconds) as u64
}

pub async fn set_with_jitter(
    cache: &CacheManager,
    key: &str,
    value: &impl Serialize,
    base_ttl: u64,
) -> Result<(), CacheError> {
    let ttl = calculate_jitter_ttl(base_ttl);
    cache.set(key, value, Some(ttl)).await
}

// Usage
async fn cache_with_protection(cache: &CacheManager) -> Result<()> {
    // Cache 1000 items with 1 hour base TTL
    // Actual TTLs will range from 3600s to 4320s (10-20% jitter)
    for i in 0..1000 {
        let key = format!("item:{}", i);
        set_with_jitter(&cache, &key, &i, 3600).await?;
    }
    Ok(())
}
```

---

## Cache Strategy Selection

| Strategy | Use Case | Pros | Cons |
|----------|----------|------|------|
| **Cache-Aside** | Read-heavy, eventual consistency OK | Simple, reliable | Potential stale data |
| **Write-Through** | Strong consistency required | Data always fresh | Write latency increases |
| **Write-Behind** | High write throughput | Fast writes | Data loss risk |
| **Refresh-Ahead** | Predictable access patterns | No cache misses | Complex, may waste resources |

---

## Workflow

### Step 1: Choose Cache Strategy

```
Consider:
  → Read/write ratio? Read-heavy = Cache-Aside
  → Consistency requirements? Strong = Write-Through
  → Write performance critical? High throughput = Write-Behind
  → Predictable access? Refresh-Ahead
```

### Step 2: Design TTL Strategy

```
TTL tiers:
  → Hot data (high frequency): 5-15 minutes
  → Medium data (moderate frequency): 1 hour
  → Cold data (low frequency): 24 hours
  → Static data (rarely changes): 7 days
  → Always add jitter (10-20%) to prevent avalanche
```

### Step 3: Implement Invalidation

```
Options:
  → Time-based: Let TTL expire (simplest)
  → Event-based: Invalidate on writes (accurate)
  → Pattern-based: Delete by pattern (bulk invalidation)
  → Version-based: Include version in key (no deletion needed)
```

---

## Review Checklist

When implementing caching:

- [ ] Cache failures don't block business logic (graceful degradation)
- [ ] Connection pool properly configured (avoid exhaustion)
- [ ] TTL set on all cache entries (prevent unbounded growth)
- [ ] TTL jitter applied to prevent avalanche
- [ ] Cache keys use namespaces to avoid conflicts
- [ ] Invalidation strategy covers all write paths
- [ ] Monitoring tracks hit rate, latency, and errors
- [ ] Serialization handles schema evolution
- [ ] Pattern-based deletion uses SCAN (not blocking DEL)
- [ ] Cache size limits configured (memory protection)

---

## Verification Commands

```bash
# Check Redis connection
redis-cli ping

# Monitor cache hit rate
redis-cli INFO stats | grep keyspace

# Check memory usage
redis-cli INFO memory

# Monitor cache operations in real-time
redis-cli MONITOR

# Check TTL distribution
redis-cli --scan --pattern "myapp:*" | xargs -L1 redis-cli TTL

# Test connection pool under load
wrk -t4 -c100 -d30s http://localhost:3000/api/cached-endpoint
```

---

## Common Pitfalls

### 1. Cache Stampede

**Symptom**: Many requests hit database simultaneously when cache expires

```rust
// ❌ Bad: no protection
async fn get_data(cache: &Cache, key: &str) -> Result<Data> {
    if let Some(data) = cache.get(key).await? {
        return Ok(data);
    }

    // All requests execute this simultaneously!
    let data = expensive_db_query().await?;
    cache.set(key, &data, 3600).await?;
    Ok(data)
}

// ✅ Good: use distributed lock
use redis::AsyncCommands;

async fn get_data_protected(cache: &Cache, key: &str) -> Result<Data> {
    if let Some(data) = cache.get(key).await? {
        return Ok(data);
    }

    let lock_key = format!("lock:{}", key);
    let lock_acquired = cache.redis.set_nx(&lock_key, "1").await?;

    if lock_acquired {
        cache.redis.expire(&lock_key, 10).await?;  // 10s lock

        let data = expensive_db_query().await?;
        cache.set(key, &data, 3600).await?;
        cache.redis.del(&lock_key).await?;

        Ok(data)
    } else {
        // Wait and retry
        tokio::time::sleep(Duration::from_millis(100)).await;
        get_data_protected(cache, key).await
    }
}
```

### 2. Missing TTL

**Symptom**: Redis memory grows unbounded

```rust
// ❌ Bad: no TTL
cache.redis.set("user:123", &user_data).await?;

// ✅ Good: always set TTL
cache.redis.set_ex("user:123", &user_data, 3600).await?;
```

### 3. Cache Inconsistency

**Symptom**: Stale data in cache after database update

```rust
// ❌ Bad: update DB but forget cache
async fn update_user(db: &Database, user: &User) -> Result<()> {
    db.update_user(user).await?;
    // Cache still has old data!
    Ok(())
}

// ✅ Good: invalidate cache after write
async fn update_user(db: &Database, cache: &Cache, user: &User) -> Result<()> {
    db.update_user(user).await?;

    let key = format!("user:{}", user.id);
    cache.delete(&key).await?;

    Ok(())
}
```

---

## Related Skills

- **rust-async** - Async Redis operations
- **rust-concurrency** - Connection pool management
- **rust-performance** - Performance optimization with caching
- **rust-error** - Error handling for cache failures
- **rust-observability** - Cache metrics and monitoring

---

## Localized Reference

- **Chinese version**: [SKILL_ZH.md](./SKILL_ZH.md) - 完整中文版本，包含所有内容
