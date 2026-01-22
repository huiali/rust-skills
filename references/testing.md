# Testing Strategies in Rust

Comprehensive testing ensures code correctness and prevents regressions.

## Test Organization

### Unit Tests

```rust
// In the same file as the code
fn add(a: i32, b: i32) -> i32 {
    a + b
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_add_positive() {
        assert_eq!(add(2, 3), 5);
    }
    
    #[test]
    fn test_add_negative() {
        assert_eq!(add(-1, 1), 0);
    }
    
    #[test]
    #[should_panic(expected = "value must be positive")]
    fn test_add_panics_for_invalid_input() {
        // Test for panic
    }
}
```

### Integration Tests

```rust
// tests/integration_test.rs
use my_crate::add;

#[test]
fn test_integration() {
    let result = add(10, 20);
    assert_eq!(result, 30);
}
```

### Doc Tests

```rust
/// Adds two numbers together.
///
/// # Examples
///
/// ```
/// use my_crate::add;
/// assert_eq!(add(1, 2), 3);
/// ```
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

## Test Assertions

### Basic Assertions

```rust
#[test]
fn test_assertions() {
    assert!(condition);
    assert!(!condition, "Optional message");
    assert_eq!(left, right);
    assert_ne!(left, right);
}
```

### Floating Point Tests

```rust
#[test]
fn test_floating_point() {
    let result = 0.1 + 0.2;
    assert!((result - 0.3).abs() < 1e-10);
}
```

### Custom Assertions

```rust
#[track_caller]
fn assert_within_range(value: i32, min: i32, max: i32) {
    assert!(
        value >= min && value <= max,
        "Value {} not in range [{}, {}]",
        value,
        min,
        max
    );
}
```

## Testing Errors

```rust
fn divide(a: i32, b: i32) -> Result<f64, &'static str> {
    if b == 0 {
        Err("Cannot divide by zero")
    } else {
        Ok(a as f64 / b as f64)
    }
}

#[cfg(test)]
mod error_tests {
    use super::*;
    
    #[test]
    fn test_divide_by_zero() {
        let result = divide(10, 0);
        assert!(result.is_err());
        assert_eq!(result.unwrap_err(), "Cannot divide by zero");
    }
    
    #[test]
    fn test_divide_success() {
        let result = divide(10, 2);
        assert!(result.is_ok());
        assert!((result.unwrap() - 5.0).abs() < 1e-10);
    }
}
```

## Testing Private Functions

```rust
// lib.rs
fn internal_helper(input: &str) -> bool {
    input.starts_with('_')
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_internal() {
        assert!(internal_helper("_private"));
        assert!(!internal_helper("public"));
    }
}
```

## Property-Based Testing

```rust
use proptest::prelude::*;

proptest! {
    #[test]
    fn test_reverse_twice(s: String) {
        let reversed: String = s.chars().rev().collect();
        let double_reversed: String = reversed.chars().rev().collect();
        assert_eq!(s, double_reversed);
    }
    
    #[test]
    fn test_add_commutative(a: i32, b: i32) {
        assert_eq!(a + b, b + a);
    }
}
```

## Mocking

```rust
// Using mockall
#[cfg(test)]
mod tests {
    use super::*;
    use mockall::predicate::*;
    
    #[tokio::test]
    async fn test_with_mock() {
        let mut mock = MockDatabase::new();
        mock.expect_query()
            .with(eq("SELECT * FROM users"))
            .returning(|_| Ok(vec![User { id: 1, name: "Alice" }]));
        
        let result = fetch_users(&mock).await;
        assert!(result.is_ok());
        assert_eq!(result.unwrap().len(), 1);
    }
}
```

## Benchmark Tests

```rust
#![feature(test)]
extern crate test;

use test::Bencher;

#[bench]
fn bench_addition(b: &mut Bencher) {
    b.iter(|| {
        (0..1000).fold(0, |acc, x| acc + x)
    });
}
```

## Running Tests

```bash
# Run all tests
cargo test

# Run specific test
cargo test test_name

# Run tests in specific module
cargo test module_name

# Run doc tests
cargo test --doc

# Run tests with output
cargo test -- --nocapture

# Run tests in release mode
cargo test --release

# Run tests with coverage
cargo tarpaulin
```

## Test Organization Best Practices

```
src/
├── lib.rs
├── module1.rs
├── module2.rs
└── module1/
    └── mod.rs

tests/
├── integration_test1.rs
└── integration_test2.rs

benches/
├── bench1.rs
└── bench2.rs

Cargo.toml
```

## Continuous Integration

```yaml
# .github/workflows/rust.yml
name: Rust

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: cargo test --all-features
      - name: Run clippy
        run: cargo clippy --all-targets -- -D warnings
      - name: Check formatting
        run: cargo fmt --check
```

## Summary

| Test Type | Purpose | Location |
|-----------|---------|----------|
| Unit | Test individual functions | In-source `#[cfg(test)]` |
| Integration | Test module interactions | `tests/` directory |
| Doc | Verify documentation examples | In doc comments |
| Property | Test properties across inputs | `proptest!` macro |
| Benchmark | Measure performance | `benches/` directory |
## Modern Testing Tools

### rstest - Fixture-based testing

```rust
use rstest::*;

#[fixture]
fn fibonacci_input() -> u32 {
    10
}

#[rstest]
fn test_fibonacci[
    fibonacci_input,
    // Parameters from fixture
    case(0, 0),
    case(1, 1),
    case(2, 1),
    case(3, 2),
    case(4, 3),
    case(5, 5),
    case(6, 8),
    case(7, 13),
    case(8, 21),
    case(9, 34),
    case(10, 55),
](n: u32, expected: u64) {
    assert_eq!(fibonacci(n), expected);
}
```

### proptest - Property-based testing

```rust
use proptest::prelude::*;

proptest! {
    #[test]
    fn test_sort_properties(vec in prop::collection::vec(0..1000i32, 0..100)) {
        let mut sorted = vec.clone();
        sorted.sort();
        
        // Check it's sorted
        assert!(sorted.windows(2).all(|w| w[0] <= w[1]));
        
        // Check it has same elements
        assert_eq!(sorted.len(), vec.len());
        let mut sorted_copy = sorted;
        sorted_copy.sort();
        assert_eq!(sorted, sorted_copy);
    }
    
    #[test]
    fn test_add_commutative(a in 0i64..10000, b in 0i64..10000) {
        assert_eq!(a + b, b + a);
    }
}
```

### quickcheck - Quick property testing

```rust
use quickcheck::{QuickCheck, TestResult};

fn property_add_commutative(a: i32, b: i32) -> TestResult {
    if a == i32::MAX || b == i32::MAX {
        return TestResult::discard();
    }
    TestResult::from_bool(a + b == b + a)
}

#[test]
fn test_quickcheck() {
    QuickCheck::new().tests(1000).quickcheck(property_add_commutative);
}
```

### mockall - Mocking

```rust
use mockall::{mock, predicate::*};

mock! {
    Database {
        fn connect() -> Result<Connection, Error>;
        fn query(&self, sql: &str) -> Result<Vec<Row>, Error>;
    }
}

#[test]
fn test_with_mock() {
    let mut mock = MockDatabase::new();
    
    mock.expect_connect()
        .returning(|| Ok(Connection::new()));
    
    mock.expect_query()
        .with(eq("SELECT * FROM users"))
        .returning(|_| Ok(vec![Row::new("user1")]));
    
    let result = mock.query("SELECT * FROM users");
    assert!(result.is_ok());
}
```

### tempfile - Temporary test data

```rust
use tempfile::TempDir;

#[test]
fn test_with_temp_file() {
    let temp_dir = TempDir::new().unwrap();
    let file_path = temp_dir.path().join("test.txt");
    
    std::fs::write(&file_path, "test data").unwrap();
    
    let content = std::fs::read_to_string(&file_path).unwrap();
    assert_eq!(content, "test data");
    
    // Automatically cleaned up when temp_dir goes out of scope
}
```

### assert_fs - Filesystem testing

```rust
use assert_fs::prelude::*;
use assert_fs::TempDir;

#[test]
fn test_config_file() -> Result<(), Box<dyn std::error::Error>> {
    let temp = TempDir::new()?;
    let file = temp.child("config.json");
    
    file.write_str(r#"{"port": 8080}"#)?;
    
    let content = file.read_string()?;
    assert!(content.contains("8080"));
    
    Ok(())
}
```

---

## Test Organization Best Practices

```
src/
├── lib.rs
├── main.rs
└── ...
    ├── module_a.rs
    └── module_a/
        └── tests.rs  // Integration tests for module_a

tests/
├── integration_a.rs
└── integration_b.rs

benches/
└── benchmark.rs
```
