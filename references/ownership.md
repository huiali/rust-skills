# Ownership and Borrowing in Rust

Ownership is Rust's core mechanism for memory safety without garbage collection.

## Core Rules

1. **Each value has a single owner** at any time
2. **When owner goes out of scope, value is dropped**
3. **Only one mutable reference OR any number of immutable references**

## Ownership Transfer (Move)

```rust
fn main() {
    let s1 = String::from("hello");
    let s2 = s1;  // s1 is moved to s2
    
    // println!("{}", s1);  // ❌ Error! s1 is no longer valid
    println!("{}", s2);  // ✅ OK
}
```

### When Move Happens

- Assigning values
- Passing to functions
- Returning from functions

```rust
fn takes_ownership(s: String) {
    println!("{}", s);
}  // s is dropped here

fn main() {
    let s = String::from("hello");
    takes_ownership(s);  // s is moved into the function
    // println!("{}", s);  // ❌ Error! s is no longer valid
}
```

## Borrowing

### Immutable References

```rust
fn calculate_length(s: &String) -> usize {
    s.len()
}  // s goes out of scope, but doesn't drop the value

fn main() {
    let s = String::from("hello");
    let len = calculate_length(&s);  // Immutable reference
    println!("Length: {}", len);
    println!("{}", s);  // ✅ Still valid
}
```

### Mutable References

```rust
fn change(s: &mut String) {
    s.push_str(", world");
}

fn main() {
    let mut s = String::from("hello");
    change(&mut s);  // Mutable reference
    println!("{}", s);  // ✅ "hello, world"
}
```

### Mutable Reference Rules

```rust
fn main() {
    let mut s = String::from("hello");
    
    let r1 = &mut s;  // ✅ First mutable reference
    // let r2 = &mut s;  // ❌ Error! Can't have two mutable refs
    // let r3 = &s;      // ❌ Error! Can't have immutable while mutable
    
    println!("{}", r1);
}
```

## The Slice Type

### String Slices

```rust
fn first_word(s: &String) -> &str {
    let bytes = s.as_bytes();
    for (i, &byte) in bytes.iter().enumerate() {
        if byte == b' ' {
            return &s[0..i];
        }
    }
    &s[..]
}

fn main() {
    let s = String::from("hello world");
    let word = first_word(&s);
    println!("First word: {}", word);
}
```

### Array Slices

```rust
fn sum_slice(slice: &[i32]) -> i32 {
    slice.iter().sum()
}

fn main() {
    let arr = [1, 2, 3, 4, 5];
    let sum = sum_slice(&arr[1..4]);  // Sum [2, 3, 4]
    println!("Sum: {}", sum);
}
```

## Lifetime Elision

Rust has lifetime elision rules that make common patterns ergonomic.

### Elided Lifetimes

```rust
// These are equivalent:
fn first(s: &str) -> &str { &s[0..1] }
fn first_explicit<'a>(s: &'a str) -> &'a str { &s[0..1] }
```

### Lifetime Annotations

```rust
fn longest<'a>(s1: &'a str, s2: &'a str) -> &'a str {
    if s1.len() > s2.len() { s1 } else { s2 }
}

fn main() {
    let s1 = String::from("hello");
    let s2 = String::from("world");
    let result = longest(&s1, &s2);
    println!("Longest: {}", result);
}
```

## Structs with References

```rust
struct User<'a> {
    name: &'a str,
    email: &'a str,
}

impl<'a> User<'a> {
    fn new(name: &'a str, email: &'a str) -> Self {
        User { name, email }
    }
}

fn main() {
    let name = String::from("Alice");
    let email = String::from("alice@example.com");
    
    let user = User::new(&name, &email);
    println!("User: {} <{}>", user.name, user.email);
}
```

## Interior Mutability

Use `RefCell` or `Cell` when you need mutability through immutable references.

```rust
use std::cell::RefCell;

struct Config {
    values: RefCell<Vec<u32>>,
}

impl Config {
    fn add_value(&self, value: u32) {
        let mut values = self.values.borrow_mut();
        values.push(value);
    }
    
    fn get_values(&self) -> Vec<u32> {
        self.values.borrow().clone()
    }
}
```

## Smart Pointers

### Box<T> - Heap Allocation

```rust
fn main() {
    let b = Box::new(42);
    println!("{}", b);  // Dereferences automatically
}
```

### Rc<T> - Reference Counting

```rust
use std::rc::Rc;

fn main() {
    let a = Rc::new(String::from("hello"));
    println!("Count: {}", Rc::strong_count(&a));  // 1
    
    {
        let b = Rc::clone(&a);
        println!("Count: {}", Rc::strong_count(&a));  // 2
        println!("{}", b);
    }
    
    println!("Count: {}", Rc::strong_count(&a));  // 1
}
```

### Arc<T> - Atomic Reference Counting

```rust
use std::sync::Arc;

fn main() {
    let data = Arc::new(vec![1, 2, 3]);
    
    let handles: Vec<_> = (0..3).map(|i| {
        let data = Arc::clone(&data);
        std::thread::spawn(move || {
            println!("Thread {}: {:?}", i, data);
        })
    }).collect();
    
    for handle in handles {
        handle.join().unwrap();
    }
}
```

## Common Patterns

### Clone on Write

```rust
fn modify_string(s: &mut String) {
    // Only clone if we need mutability
    let s = std::mem::take(s);
    *s = s.to_uppercase();
}
```

### Return Owned Values

```rust
fn extract_name(user: &User) -> String {
    user.name.to_string()  // Return owned String, not &str
}
```

### Avoid Dangling References

```rust
// ❌ Bad - returns reference to local variable
fn bad_reference() -> &String {
    let s = String::from("hello");
    &s  // Error! s will be dropped
}

// ✅ Good - return owned value
fn good_reference() -> String {
    let s = String::from("hello");
    s  // Ownership transferred
}
```

## Summary Table

| Scenario | Solution |
|----------|----------|
| Transfer ownership | Move (implicit) |
| Borrow without transfer | Immutable reference `&T` |
| Mutate through reference | Mutable reference `&mut T` |
| Partial ownership | Slices `&[T]`, `&str` |
| Heap allocation | `Box<T>` |
| Shared ownership (single-threaded) | `Rc<T>` |
| Shared ownership (multi-threaded) | `Arc<T>` |
| Mutability through immutable | `RefCell<T>`, `Cell<T>` |

