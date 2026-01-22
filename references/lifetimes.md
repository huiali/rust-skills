# Lifetime Annotations Guide

Lifetimes tell the compiler how references relate to each other, ensuring references are always valid.

## Basic Lifetimes

### Syntax

```rust
&'a str      // Reference with lifetime 'a
&'a T        // Generic reference with lifetime 'a
```

### Example

```rust
// 'a represents the shorter of x and y's lifetimes
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}
```

## When Lifetimes Are Required

### Structs with References

```rust
// ImportantAnnotation must not outlive the text it references
struct ImportantExcerpt<'a> {
    part: &'a str,
}

fn main() {
    let novel = String::from("Call me Ishmael. Some years ago...");
    let first_sentence = novel.split('.').next().unwrap();
    
    let excerpt = ImportantExcerpt {
        part: first_sentence,
    };
    
    println!("Excerpt: {}", excerpt.part);
}
```

### Methods

```rust
impl<'a> ImportantExcerpt<'a> {
    fn announce_and_return_part(&self, announcement: &str) -> &str {
        println!("Attention please: {}", announcement);
        self.part
    }
}
```

## Lifetime Elision

Rust applies three elision rules automatically.

### Rule 1: Input Lifetimes

```rust
// These are equivalent:
fn foo(s: &str) -> &str { s }
fn foo<'a>(s: &'a str) -> &'a str { s }
```

### Rule 2: Output Lifetimes from Input

```rust
// fn first_word(s: &str) -> &str { ... }
// Becomes:
fn first_word<'a>(s: &'a str) -> &'a str { ... }
```

### Rule 3: Single Input Lifetime

```rust
// fn method(&self) -> &str { ... }
// Becomes:
fn method<'a>(&'a self) -> &'a str { ... }
```

## Static Lifetime

```rust
// Lives for entire program duration
let s: &'static str = "I live forever!";

// String literal has static lifetime
fn print_message() -> &'static str {
    "Hello, world!"
}
```

## Multiple Lifetimes

```rust
fn both_ends<'a, 'b>(s1: &'a str, s2: &'b str) -> &'a str {
    if s1.len() > s2.len() { s1 } else { s2 }
}

fn main() {
    let s1 = String::from("long string");
    let s2 = String::from("short");
    
    let result = both_ends(&s1, &s2);
    println!("{}", result);
}
```

## Common Patterns

### Multiple Parameters, Different Lifetimes

```rust
fn compare_and_print<'a, 'b>(s1: &'a str, s2: &'b str) {
    if s1 == s2 {
        println!("Same!");
    } else {
        println!("Different: '{}' vs '{}'", s1, s2);
    }
}
```

### Struct Containing Multiple References

```rust
struct Book<'a> {
    title: &'a str,
    author: &'a str,
    year: u32,
}

impl<'a> Book<'a> {
    fn describe(&self) -> String {
        format!("{} by {} ({})", self.title, self.author, self.year)
    }
}
```

### Returning References

```rust
// Return the longer of two string slices
fn choose_longer<'a>(a: &'a str, b: &'a str) -> &'a str {
    if a.len() > b.len() { a } else { b }
}
```

## Common Errors and Fixes

### Error: Dangling Reference

```rust
// ❌ Error
fn bad_function() -> &String {
    let s = String::from("hello");
    &s  // s is dropped when function returns
}

// ✅ Fix: Return owned value
fn good_function() -> String {
    let s = String::from("hello");
    s
}

// ✅ Fix: Use static lifetime if appropriate
fn static_function() -> &'static str {
    "hello"
}
```

### Error: Lifetime Mismatch

```rust
// ❌ Error
fn mismatched_lifetimes<'a, 'b>(x: &'a str, y: &'b str) -> &'a str {
    y  // Return y which has different lifetime than 'a
}

// ✅ Fix: Match lifetimes
fn matched_lifetimes<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}
```

### Error: Missing Lifetime Annotation

```rust
// ❌ Error
struct Container<'a> {
    data: &i32,
    reference: &i32,
}

// ✅ Fix
struct Container<'a> {
    data: &'a i32,
    reference: &'a i32,
}
```

## Advanced: HRTB (Higher-Ranked Trait Bounds)

```rust
// Function that works for any lifetime
fn print_for_any_lifetime<'a>(s: &'a str) {
    println!("{}", s);
}

// HRTB: works with any reference lifetime
fn print_generic<T>(s: &T)
where
    T: std::fmt::Display,
{
    println!("{}", s);
}
```

## Lifetime in Async Context

```rust
async fn fetch_data(url: &str) -> Result<Vec<u8>, reqwest::Error> {
    let response = reqwest::get(url).await?;
    let bytes = response.bytes().await?;
    Ok(bytes.to_vec())
}
```

## GAT (Generic Associated Types) with Lifetimes

```rust
trait LifetimesExample {
    type Output<'a> where Self: 'a;
}

struct Container<'a> {
    data: &'a i32,
}

impl<'a> LifetimesExample for Container<'a> {
    type Output<'b> = &'b i32 where 'b: 'a;
}
```

## Best Practices

### 1. Prefer Returning Owned Types

```rust
// ✅ Better: Return owned String
fn extract_name(user: &User) -> String {
    user.name.to_string()
}

// ❌ Avoid: Returning reference with complex lifetime
fn extract_name_bad(user: &User) -> &str {
    &user.name[..5]  // Requires lifetime annotation
}
```

### 2. Use Lifetimes Only When Needed

```rust
// Don't annotate when not required
fn identity(s: &str) -> &str { s }  // Lifetime inferred automatically

// Only add explicit annotations when necessary
fn first_word<'a>(s: &'a str) -> &'a str { /* ... */ }
```

### 3. Keep Lifetimes Short and Clear

```rust
// ✅ Good: Descriptive lifetime names
fn find_common_prefix<'a, 'b>(s1: &'a str, s2: &'b str) -> &'a str { ... }

// ❌ Avoid: Single-letter names when multiple lifetimes exist
fn process<'a, 'b, 'c, 'd>(x: &'a str, y: &'b str, z: &'c str) -> &'d str { ... }
```

## Summary

| Situation | Example |
|-----------|---------|
| Function with one reference | `fn foo<'a>(s: &'a str) -> &'a str` |
| Struct with reference | `struct Foo<'a> { s: &'a str }` |
| Multiple references | `fn foo<'a, 'b>(x: &'a str, y: &'b str)` |
| Static data | `&'static str` |
| Elision applies | `fn foo(s: &str) -> &str` (lifetime inferred) |

