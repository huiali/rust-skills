---
name: rust-lifetime-complex
description: Advanced lifetime expert covering HRTB, GAT, 'static bounds, trait object constraints, type system conflicts, and lifetime elision edge cases.triggers: - lifetime - HRTB - GAT - higher-ranked - 'static - trait object - one type is more general - lifetime conflict--- # Advanced Lifetime and Type System Expert ## Core Question **Why won't this type conversion compile?** The type system's boundaries are often surprising.
---


## Solution Patterns

### Pattern 1: HRTB (Higher-Ranked Trait Bounds)

```rust
// Problem: Concrete lifetime vs generic lifetime

// ❌ This doesn't work with dyn
type ClosureFn<T> = dyn for<'a> FnOnce(&'a mut Connection) -> BoxFuture<'a, T>;

// ✅ Solution: Keep HRTB in generic bounds
async fn with_connection<F, T, Fut>(f: F) -> Result<T, Error>
where
    F: for<'c> FnOnce(&'c mut Connection) -> Fut,
    Fut: Future<Output = Result<T, Error>>,
{
    let mut conn = get_connection().await?;
    f(&mut conn).await
}

// Usage
with_connection(|conn| async move {
    query("SELECT * FROM users").fetch_all(conn).await
}).await?;
```

### Pattern 2: GAT + Object Safety

```rust
// Problem: GAT makes trait non-object-safe

// ❌ Can't use dyn with GAT
trait Repository {
    type Row<'a>: RowView<'a>;  // GAT
    fn query<'a>(&'a self) -> Vec<Self::Row<'a>>;
}
// let repo: Box<dyn Repository> = ...;  // Error!

// ✅ Solution: Layered architecture
trait InternalRepo {
    type Row<'a>: RowView<'a>;  // GAT for internal use
    fn query_borrowed<'a>(&'a self) -> Vec<Self::Row<'a>>;
}

trait PublicRepo: Send + Sync {
    fn query(&self) -> Vec<RowDto>;  // Owned data
}

// Adapter converts borrowed -> owned
impl<T: InternalRepo> PublicRepo for T {
    fn query(&self) -> Vec<RowDto> {
        self.query_borrowed()
            .into_iter()
            .map(|row| row.to_dto())
            .collect()
    }
}
```

### Pattern 3: Static Bound Conflicts

```rust
// Problem: 'static requirement conflicts with borrowing

// ❌ Can't borrow when 'static required
async fn bad_resolver(&self, ctx: &Context) -> Result<&Data> {
    // Error: lifetime 'a not 'static
}

// ✅ Solution: Return owned data
async fn good_resolver(&self, ctx: &Context) -> Result<DataDto> {
    let borrowed = self.repo.query().await?;
    Ok(borrowed.to_owned_dto())
}

// Alternative: Use Arc for shared ownership
async fn shared_resolver(&self) -> Result<Arc<Data>> {
    Ok(Arc::clone(&self.cached_data))
}
```

### Pattern 4: Lifetime Elision Edge Cases

```rust
// Problem: Compiler can't infer lifetime

// ❌ Ambiguous lifetime
struct Parser<'a> {
    input: &'a str,
}

impl<'a> Parser<'a> {
    fn parse(&self) -> Result<&str, Error> {
        // Which lifetime? 'a or 'self?
        // Compiler can't tell
    }
}

// ✅ Explicit lifetime annotation
impl<'a> Parser<'a> {
    fn parse<'b>(&'b self) -> Result<&'a str, Error> {
        // Returns data from input, not self
        Ok(&self.input[..10])
    }
}
```

### Pattern 5: Async + Lifetime Conflicts

```rust
// Problem: Holding references across await

// ❌ Can't hold borrow across await
async fn bad_async() {
    let data = get_data();
    let borrowed = &data.field;

    some_async_call().await;  // Error: data might move

    use_borrowed(borrowed);
}

// ✅ Solution 1: Clone before await
async fn good_async_clone() {
    let data = get_data();
    let owned = data.field.clone();

    some_async_call().await;  // OK

    use_owned(&owned);
}

// ✅ Solution 2: Drop borrow before await
async fn good_async_scope() {
    let data = get_data();
    let value = {
        let borrowed = &data.field;
        extract_value(borrowed)
    };  // borrow dropped

    some_async_call().await;  // OK
}
```


## Common Conflict Patterns

| Pattern | Cause | Solution |
|---------|-------|----------|
| HRTB → dyn | Concrete vs universal lifetime | Use generic functions |
| GAT → dyn | Variable-sized associated types | Layered design with owned DTOs |
| 'static + borrow | Lifetime contradiction | Return owned data |
| Async + borrow | Future holds state across await | Clone or drop before await |
| Closure capture + Send | Lifetime issues | Use 'static or Arc |


## When to Give Up Borrowing

### Performance vs Maintainability

```rust
// Decision factors:
fn should_use_owned() -> bool {
    // ✅ Use owned if:
    // - Complex lifetime interactions
    // - API boundaries
    // - Async contexts
    // - Multi-threaded sharing

    // ✅ Keep borrowing if:
    // - Large data structures
    // - Hot path performance
    // - Simple lifetime relationships
    // - Internal implementation only

    true
}
```

### Rule of Thumb

1. **API layer**: Default to owned data
2. **Internal impl**: Borrow when beneficial
3. **Performance hotspot**: Profile first, then optimize
4. **High complexity**: Fall back to owned


## Workflow

### Step 1: Diagnose Error

```
Common errors:
  "one type is more general" → HRTB + dyn conflict
  "lifetime may not live long enough" → Borrow exceeds scope
  "cannot be made into object" → GAT or HRTB in trait
  "does not live long enough" → Early drop
```

### Step 2: Choose Strategy

```
Options:
  → Simplify: Remove abstraction
  → Split: Separate borrowed/owned layers
  → Clone: Accept allocation cost
  → Arc: Shared ownership
  → Redesign: Change data flow
```

### Step 3: Validate Solution

```
Check:
  → Compiles without hacky workarounds
  → Reasonable complexity
  → Performance acceptable
  → Maintainable long-term
```


## Debugging Techniques

### Minimize

```rust
// Reduce to minimal reproduction
// Remove generics, traits, async one by one
// Find the core conflict
```

### Explicit Lifetimes

```rust
// Write out all lifetime parameters
// Makes relationships visible
fn explicit<'a, 'b>(x: &'a str, y: &'b str) -> &'a str {
    x
}
```

### Accept Reality

```rust
// Not all designs can compile
// Sometimes owned data is the answer
// Complexity has limits
```


## Review Checklist

When dealing with complex lifetimes:

- [ ] HRTB not used with dyn trait objects
- [ ] GAT traits have owned alternative for object safety
- [ ] 'static bounds justified and documented
- [ ] Async functions don't hold borrows across await
- [ ] Lifetime elision not hiding ambiguity
- [ ] Complex lifetimes have explicit annotations
- [ ] Considered owned data alternative
- [ ] Design simplification explored first


## Verification Commands

```bash
# Check for lifetime errors
cargo check

# Expand to see generated code
cargo expand

# Verify no borrow checker issues
cargo clippy
```


## Related Skills

- **rust-ownership** - Basic lifetime fundamentals
- **rust-async** - Async lifetime patterns
- **rust-type-driven** - Type-level design
- **rust-trait** - Trait object constraints
- **rust-performance** - When to optimize with borrowing


## Localized Reference

- **Chinese version**: [SKILL_ZH.md](./SKILL_ZH.md) - 完整中文版本，包含所有内容
