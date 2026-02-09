---
name: rust-anti-pattern
description: Rust anti-patterns and common mistakes expert. Handles code review issues with clone abuse, unwrap in production, String misuse, index loops, and refactoring guidance.
metadata:
  triggers:
    - anti-pattern
    - common mistake
    - clone abuse
    - unwrap
    - code review
    - code smell
    - refactor
    - bad pattern
---


## Top 5 Beginner Mistakes

| Rank | Mistake | Correct Approach |
|------|---------|------------------|
| 1 | Using `.clone()` to escape borrow checker | Use references |
| 2 | Using `.unwrap()` in production code | Use `?` or `with_context()` |
| 3 | Everything is `String` | Use `&str`, `Cow<str>` when needed |
| 4 | Index-based loops | Use iterators `.iter()`, `.enumerate()` |
| 5 | Fighting lifetimes | Redesign data structure |


## Common Anti-Patterns

### Anti-Pattern 1: Clone Everywhere

```rust
// ❌ Bad: escaping borrow checker
fn process(user: User) {
    let name = user.name.clone();  // Why clone?
    // ...
}

// ✅ Good: use references
fn process(user: &User) {
    let name = &user.name;  // Just borrow
}
```

**When clone is actually needed:**
- Truly need independent copy
- API design requires owned value
- Data flow requirements

### Anti-Pattern 2: Unwrap in Production

```rust
// ❌ Bad: may panic
let config = File::open("config.json").unwrap();

// ✅ Good: propagate error
let config = File::open("config.json")?;

// ✅ Good: with context
let config = File::open("config.json")
    .context("failed to open config")?;
```

### Anti-Pattern 3: String Everywhere

```rust
// ❌ Bad: unnecessary allocation
fn greet(name: String) {
    println!("Hello, {}", name);
}

// ✅ Good: borrow is enough
fn greet(name: &str) {
    println!("Hello, {}", name);
}

// When String is actually needed: ownership or mutation required
```

### Anti-Pattern 4: Index Loops

```rust
// ❌ Bad: error-prone, inefficient
for i in 0..items.len() {
    println!("{}: {}", i, items[i]);
}

// ✅ Good: direct iteration
for item in &items {
    println!("{}", item);
}

// ✅ Good: with index
for (i, item) in items.iter().enumerate() {
    println!("{}: {}", i, item);
}
```

### Anti-Pattern 5: Excessive Unsafe

```rust
// ❌ Bad: unsafe for convenience
unsafe {
    let ptr = data.as_mut_ptr();
    // ... complex memory operations
}

// ✅ Good: find safe abstractions
let mut data: Vec<u8> = vec![0; size];
// Vec handles memory management
```


## Solution Patterns

### Pattern 1: Avoiding Clone

```rust
// ❌ Anti-pattern: clone to satisfy borrow checker
fn process_data(data: &Data) -> String {
    let cloned = data.items.clone();
    cloned.into_iter().map(|x| x.to_string()).collect()
}

// ✅ Solution: use references properly
fn process_data(data: &Data) -> String {
    data.items.iter().map(|x| x.to_string()).collect()
}
```

### Pattern 2: Proper Error Handling

```rust
// ❌ Anti-pattern: unwrap chain
fn load_config() -> Config {
    let content = std::fs::read_to_string("config.toml").unwrap();
    toml::from_str(&content).unwrap()
}

// ✅ Solution: Result propagation
fn load_config() -> Result<Config, Box<dyn Error>> {
    let content = std::fs::read_to_string("config.toml")?;
    Ok(toml::from_str(&content)?)
}

// ✅ Solution: with context (anyhow)
fn load_config() -> anyhow::Result<Config> {
    let content = std::fs::read_to_string("config.toml")
        .context("failed to read config file")?;
    toml::from_str(&content)
        .context("failed to parse config")
}
```

### Pattern 3: String vs &str

```rust
// ❌ Anti-pattern: String parameters everywhere
struct Config {
    host: String,
    port: String,
    path: String,
}

impl Config {
    fn new(host: String, port: String, path: String) -> Self {
        Self { host, port, path }
    }
}

// ✅ Solution: accept &str, store String
impl Config {
    fn new(host: impl Into<String>, port: u16, path: impl Into<String>) -> Self {
        Self {
            host: host.into(),
            port: port.to_string(),
            path: path.into(),
        }
    }
}
```

### Pattern 4: Iterator-Based Processing

```rust
// ❌ Anti-pattern: manual indexing
fn sum_even(nums: &[i32]) -> i32 {
    let mut sum = 0;
    for i in 0..nums.len() {
        if nums[i] % 2 == 0 {
            sum += nums[i];
        }
    }
    sum
}

// ✅ Solution: iterator chain
fn sum_even(nums: &[i32]) -> i32 {
    nums.iter()
        .filter(|&&n| n % 2 == 0)
        .sum()
}
```


## Code Smell Quick Reference

| Symptom | Indicates | Refactoring Direction |
|---------|-----------|----------------------|
| Many `.clone()` | Unclear ownership | Clarify data flow |
| Many `.unwrap()` | Missing error handling | Add Result handling |
| Many `pub` fields | Broken encapsulation | Private + accessors |
| Deep nesting | Complex logic | Extract methods |
| Long functions (>50 lines) | Too many responsibilities | Split responsibilities |
| Huge enums | Missing abstraction | Trait + types |


## Outdated → Modern Patterns

| Outdated | Modern |
|----------|--------|
| Index loop `.items[i]` | `.iter().enumerate()` |
| `collect::<Vec<_>>()` then iterate | Chain iterators |
| `lazy_static!` | `std::sync::OnceLock` |
| `mem::transmute` conversion | `as` or `TryFrom` |
| Custom linked list | `Vec` or `VecDeque` |
| Manual unsafe cell | `Cell`, `RefCell` |


## Workflow

### Step 1: Identify Anti-Patterns

```
Code review checklist:
  → Lots of .clone()? Check ownership design
  → .unwrap() in lib code? Need error handling
  → Index loops? Should use iterators
  → pub fields with invariants? Need encapsulation
  → >50 line functions? Should split
```

### Step 2: Ask Key Questions

```
1. Is this fighting Rust or working with Rust?
   Fighting → Redesign
   Working with → Continue

2. Is this clone necessary?
   Escaping borrow checker → Warning sign
   Actually need copy → Keep

3. Will this unwrap panic?
   Might panic → Use ?
   Never panics → expect("reason")

4. Is there a more idiomatic way?
   Check std library patterns
   Review other Rust code
```

### Step 3: Refactor

```
Identified anti-pattern?
  ↓
Understand the root cause
  ↓
Find idiomatic alternative
  ↓
Refactor incrementally
  ↓
Test thoroughly
```


## Review Checklist

When reviewing code:

- [ ] No unreasonable `.clone()`
- [ ] Library code has no `.unwrap()`
- [ ] No `pub` fields with invariants
- [ ] No index loops when iterators available
- [ ] Using `&str` instead of `String` when sufficient
- [ ] Not ignoring `#[must_use]` warnings
- [ ] `unsafe` has SAFETY comments
- [ ] No giant functions (>50 lines)
- [ ] Error handling uses Result not panic
- [ ] No premature optimization


## Verification Commands

```bash
# Check for common issues
cargo clippy

# Specific anti-pattern lints
cargo clippy -- -W clippy::clone_on_copy \
                -W clippy::unwrap_used \
                -W clippy::expect_used

# Check for complexity
cargo clippy -- -W clippy::cognitive_complexity

# Find todos and fixmes
rg "TODO|FIXME|XXX|HACK" --type rust
```


## Common Pitfalls

### 1. Clone to Compile

**Symptom**: Lots of `.clone()` calls

```rust
// ❌ Bad: cloning to satisfy compiler
fn process(items: &Vec<Item>) -> Vec<String> {
    let items_clone = items.clone();
    items_clone.into_iter().map(|i| i.name).collect()
}

// ✅ Good: proper borrowing
fn process(items: &[Item]) -> Vec<String> {
    items.iter().map(|i| i.name.clone()).collect()
}

// ✅ Better: no clone at all
fn process(items: &[Item]) -> Vec<&str> {
    items.iter().map(|i| i.name.as_str()).collect()
}
```

### 2. Error Handling Shortcuts

**Symptom**: Unwrap/expect in production code

```rust
// ❌ Bad: panic on error
let data = fetch_data().unwrap();
let parsed: Config = serde_json::from_str(&data).expect("bad JSON");

// ✅ Good: proper error propagation
fn load_data() -> Result<Config, Box<dyn Error>> {
    let data = fetch_data()?;
    let parsed = serde_json::from_str(&data)?;
    Ok(parsed)
}
```

### 3. String Allocation Waste

**Symptom**: Unnecessary String allocations

```rust
// ❌ Bad: allocating for no reason
fn log_message(level: String, msg: String) {
    println!("[{}] {}", level, msg);
}

// ✅ Good: borrow when possible
fn log_message(level: &str, msg: &str) {
    println!("[{}] {}", level, msg);
}
```


## Self-Check Questions

### 1. Is this code fighting Rust?

- Fighting → Redesign approach
- Working with → Continue

### 2. Is this clone necessary?

- To escape borrow checker → Warning sign
- Actually need independent copy → OK

### 3. Will this unwrap panic?

- Might panic → Use `?`
- Never panics → `expect("reason")`

### 4. Is there a more idiomatic way?

- Reference other Rust codebases
- Check std library APIs


## Related Skills

- **rust-coding** - Idiomatic patterns to follow
- **rust-ownership** - Understanding borrowing to avoid clones
- **rust-error** - Proper error handling patterns
- **rust-performance** - When optimization matters
- **rust-refactoring** - Systematic code improvement


## Localized Reference

- **Chinese version**: [SKILL_ZH.md](./SKILL_ZH.md) - 完整中文版本，包含所有内容
