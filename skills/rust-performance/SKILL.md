---
name: rust-performance
description: Performance optimization expert covering profiling, benchmarking, memory allocation, SIMD, cache optimization, false sharing, lock contention, and NUMA-aware programming.
metadata:
  triggers:
    - performance
    - optimization
    - benchmark
    - profiling
    - allocation
    - SIMD
    - cache
    - slow
    - latency
    - throughput
---


## Optimization Priority

```
1. Algorithm choice      (10x - 1000x)   ← Biggest impact
2. Data structure        (2x - 10x)
3. Reduce allocations    (2x - 5x)
4. Cache optimization    (1.5x - 3x)
5. SIMD/parallelism      (2x - 8x)
```

**Warning**: Premature optimization is the root of all evil. Make it work first, then optimize hot paths.


## Solution Patterns

### Pattern 1: Pre-allocation

```rust
// ❌ Bad: grows dynamically
let mut vec = Vec::new();
for i in 0..1000 {
    vec.push(i);
}

// ✅ Good: pre-allocate known size
let mut vec = Vec::with_capacity(1000);
for i in 0..1000 {
    vec.push(i);
}
```

### Pattern 2: Avoid Unnecessary Clones

```rust
// ❌ Bad: unnecessary clone
fn process(item: &Item) {
    let data = item.data.clone();
    // use data...
}

// ✅ Good: use reference
fn process(item: &Item) {
    let data = &item.data;
    // use data...
}
```

### Pattern 3: Batch Operations

```rust
// ❌ Bad: multiple database calls
for user_id in user_ids {
    db.update(user_id, status)?;
}

// ✅ Good: batch update
db.update_all(user_ids, status)?;
```

### Pattern 4: Small Object Optimization

```rust
use smallvec::SmallVec;

// ✅ No heap allocation for ≤16 items
let mut vec: SmallVec<[u8; 16]> = SmallVec::new();
```

### Pattern 5: Parallel Processing

```rust
use rayon::prelude::*;

let sum: i32 = data
    .par_iter()
    .map(|x| expensive_computation(x))
    .sum();
```


## Profiling Tools

| Tool | Purpose |
|------|---------|
| `cargo bench` | Criterion benchmarks |
| `perf` / `flamegraph` | CPU flame graphs |
| `heaptrack` | Allocation tracking |
| `valgrind --tool=cachegrind` | Cache analysis |
| `dhat` | Heap allocation profiling |


## Common Optimizations

### Anti-Patterns to Fix

| Anti-Pattern | Why Bad | Correct Approach |
|--------------|---------|------------------|
| Clone to avoid lifetimes | Performance cost | Proper ownership design |
| Box everything | Indirection overhead | Prefer stack allocation |
| HashMap for small data | Hash overhead too high | Vec + linear search |
| String concatenation in loop | O(n²) | `with_capacity` or `format!` |
| LinkedList | Cache-unfriendly | `Vec` or `VecDeque` |


## Advanced: False Sharing

### Symptom

```rust
// ❌ Problem: multiple AtomicU64 in one struct
struct ShardCounters {
    inflight: AtomicU64,
    completed: AtomicU64,
}
```

- One CPU core at 90%+
- High LLC miss rate in perf
- Many atomic RMW operations
- Adding threads makes it slower

### Diagnosis

```bash
# Perf analysis
perf stat -d your_program
# Look for LLC-load-misses and locked-instrs

# Flamegraph
cargo flamegraph
# Find atomic fetch_add hotspots
```

### Solution: Cache Line Padding

```rust
// ✅ Each field in separate cache line
#[repr(align(64))]
struct PaddedAtomicU64(AtomicU64);

struct ShardCounters {
    inflight: PaddedAtomicU64,
    completed: PaddedAtomicU64,
}
```


## Lock Contention Optimization

### Symptom

```rust
// ❌ All threads compete for single lock
let shared: Arc<Mutex<HashMap<String, usize>>> =
    Arc::new(Mutex::new(HashMap::new()));
```

- Most time spent in mutex lock/unlock
- Performance degrades with more threads
- High system time percentage

### Solution: Thread-Local Sharding

```rust
// ✅ Each thread has local HashMap, merge at end
pub fn parallel_count(data: &[String], num_threads: usize)
    -> HashMap<String, usize>
{
    let mut handles = Vec::new();

    for chunk in data.chunks(data.len() / num_threads) {
        handles.push(thread::spawn(move || {
            let mut local = HashMap::new();
            for key in chunk {
                *local.entry(key.clone()).or_insert(0) += 1;
            }
            local  // Return local counts
        }));
    }

    // Merge all local results
    let mut result = HashMap::new();
    for handle in handles {
        for (k, v) in handle.join().unwrap() {
            *result.entry(k).or_insert(0) += v;
        }
    }
    result
}
```


## NUMA Awareness

### Problem

```rust
// Multi-socket server, memory allocated on remote NUMA node
let pool = ArenaPool::new(num_threads);
// Rayon work-stealing causes tasks to run on any thread
// Cross-NUMA access causes severe memory migration latency
```

### Solution

```rust
// 1. NUMA node binding
let numa_node = detect_numa_node();
let pool = NumaAwarePool::new(numa_node);

// 2. Use unified allocator (jemalloc)
#[global_allocator]
static ALLOC: jemallocator::Jemalloc = jemallocator::Jemalloc;

// 3. Avoid cross-NUMA object clones
// Borrow directly, don't copy data
```

### Tools

```bash
# Check NUMA topology
numactl --hardware

# Bind to NUMA node
numactl --cpunodebind=0 --membind=0 ./my_program
```


## Data Structure Selection

| Scenario | Choice | Reason |
|----------|--------|--------|
| High-concurrency writes | DashMap or sharding | Reduces lock contention |
| Read-heavy, few writes | RwLock<HashMap> | Read locks don't block |
| Small dataset | Vec + linear search | HashMap overhead higher |
| Fixed keys | Enum + array | Zero hash overhead |

### Read-Heavy Example

```rust
// ✅ Many reads, few updates
struct Config {
    map: RwLock<HashMap<String, ConfigValue>>,
}

impl Config {
    pub fn get(&self, key: &str) -> Option<ConfigValue> {
        self.map.read().unwrap().get(key).cloned()
    }

    pub fn update(&self, key: String, value: ConfigValue) {
        self.map.write().unwrap().insert(key, value);
    }
}
```


## Common Performance Traps

| Trap | Symptom | Solution |
|------|---------|----------|
| Adjacent atomic variables | False sharing | `#[repr(align(64))]` |
| Global Mutex | Lock contention | Thread-local + merge |
| Cross-NUMA allocation | Memory migration | NUMA-aware allocation |
| Frequent small allocations | Allocator pressure | Object pooling |
| Dynamic string keys | Extra allocations | Use integer IDs |


## Review Checklist

When optimizing performance:

- [ ] Profiled to identify bottleneck
- [ ] Bottleneck confirmed with measurements
- [ ] Algorithm is optimal for use case
- [ ] Data structure appropriate
- [ ] Unnecessary allocations removed
- [ ] Parallelism exploited where beneficial
- [ ] Cache-friendly data layout
- [ ] Lock contention minimized
- [ ] Benchmarks show improvement
- [ ] Code still readable and maintainable


## Verification Commands

```bash
# Benchmark
cargo bench

# Profile with perf
perf stat -d ./target/release/your_program

# Generate flamegraph
cargo flamegraph --release

# Heap profiling
valgrind --tool=dhat ./target/release/your_program

# Cache analysis
valgrind --tool=cachegrind ./target/release/your_program

# NUMA topology
numactl --hardware
```


## Common Pitfalls

### 1. Premature Optimization

**Symptom**: Optimizing before profiling

**Fix**: Profile first, optimize hot paths only

### 2. Micro-optimizing Cold Paths

**Symptom**: Spending time on code that rarely runs

**Fix**: Focus on hot loops (90% of time in 10% of code)

### 3. Trading Readability for Minimal Gains

**Symptom**: Complex code for <5% improvement

**Fix**: Only optimize if gain is significant (>20%)


## Performance Diagnostic Workflow

```
1. Identify symptom (slow, high CPU, high memory)
   ↓
2. Profile with appropriate tool
   - CPU → perf/flamegraph
   - Memory → heaptrack/dhat
   - Cache → cachegrind
   ↓
3. Find hotspot (function/line)
   ↓
4. Understand why it's slow
   - Algorithm? Data structure? Allocation?
   ↓
5. Apply targeted optimization
   ↓
6. Benchmark to confirm improvement
   ↓
7. Repeat if not fast enough
```


## Related Skills

- **rust-concurrency** - Parallel processing patterns
- **rust-async** - Async performance optimization
- **rust-unsafe** - Zero-cost abstractions with unsafe
- **rust-coding** - Writing performant idiomatic code
- **rust-anti-pattern** - Performance anti-patterns to avoid


## Localized Reference

- **Chinese version**: [SKILL_ZH.md](./SKILL_ZH.md) - 完整中文版本，包含所有内容
