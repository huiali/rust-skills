---
name: rust-const
description: Const generics and compile-time computation expert covering const fn, type-level computation, const evaluation, MaybeUninit arrays, and compile-time validation.
metadata:
  triggers:
    - const
    - const generics
    - compile-time
    - const fn
    - MaybeUninit
    - type-level computation
    - const evaluation
---


## Solution Patterns

### Pattern 1: Basic Const Generics

```rust
// Generic over array size
struct Buffer<T, const N: usize> {
    data: [T; N],
}

impl<T: Default + Copy, const N: usize> Buffer<T, N> {
    fn new() -> Self {
        Self {
            data: [T::default(); N],
        }
    }
}

// Usage
let buf: Buffer<u8, 1024> = Buffer::new();
```

### Pattern 2: Const Functions

```rust
const fn fibonacci(n: u32) -> u64 {
    match n {
        0 => 0,
        1 => 1,
        _ => {
            let mut a = 0;
            let mut b = 1;
            let mut i = 2;
            while i <= n {
                let tmp = a + b;
                a = b;
                b = tmp;
                i += 1;
            }
            b
        }
    }
}

// Computed at compile time
const FIB_10: u64 = fibonacci(10);

// Also works in array sizes
const ARRAY: [u8; fibonacci(5) as usize] = [0; fibonacci(5) as usize];
```

### Pattern 3: MaybeUninit for Large Arrays

```rust
use std::mem::MaybeUninit;

// Stack overflow risk for large arrays
fn bad_large_array() -> [u8; 1024 * 1024] {
    [0; 1024 * 1024]  // Stack overflow!
}

// ✅ Good: Use heap
fn good_large_array() -> Box<[u8; 1024 * 1024]> {
    Box::new([0; 1024 * 1024])
}

// ✅ Good: MaybeUninit for uninitialized memory
fn uninit_array<const N: usize>() -> Box<[u8; N]> {
    let mut data: Box<[MaybeUninit<u8>; N]> =
        Box::new(unsafe { MaybeUninit::uninit().assume_init() });

    for elem in &mut data[..] {
        elem.write(0);
    }

    unsafe { Box::from_raw(Box::into_raw(data) as *mut [u8; N]) }
}
```

### Pattern 4: Compile-Time Validation

```rust
const fn validate_config(size: usize, alignment: usize) -> bool {
    size > 0 && alignment.is_power_of_two()
}

struct Config<const SIZE: usize, const ALIGN: usize> {
    _phantom: PhantomData<[u8; SIZE]>,
}

impl<const SIZE: usize, const ALIGN: usize> Config<SIZE, ALIGN> {
    const fn new() -> Self {
        assert!(validate_config(SIZE, ALIGN), "Invalid configuration");
        Self { _phantom: PhantomData }
    }
}

// Compile-time validation
const CONFIG: Config<1024, 8> = Config::new();
// const BAD: Config<0, 3> = Config::new();  // Compile error!
```

### Pattern 5: Type-Level State Machine

```rust
struct Uninitialized;
struct Initialized;

struct StateMachine<State, const N: usize> {
    buffer: [u8; N],
    _state: PhantomData<State>,
}

impl<const N: usize> StateMachine<Uninitialized, N> {
    fn new() -> Self {
        Self {
            buffer: [0; N],
            _state: PhantomData,
        }
    }

    fn initialize(self) -> StateMachine<Initialized, N> {
        StateMachine {
            buffer: self.buffer,
            _state: PhantomData,
        }
    }
}

impl<const N: usize> StateMachine<Initialized, N> {
    fn process(&mut self) {
        // Only available when initialized
    }
}
```


## Const Fn Capabilities

### What Works in Const Fn

```rust
const fn works() {
    // ✅ Arithmetic
    let x = 1 + 2;

    // ✅ Conditionals
    if x > 0 { }

    // ✅ Loops
    let mut i = 0;
    while i < 10 { i += 1; }

    // ✅ Match
    match x {
        0 => {},
        _ => {},
    }

    // ✅ Calling other const fn
    const fn helper() -> i32 { 42 }
    let y = helper();
}
```

### Current Limitations

```rust
const fn limitations() {
    // ❌ Heap allocation (not yet stable)
    // let v = Vec::new();

    // ❌ Trait objects
    // let obj: &dyn Trait = ...;

    // ❌ Mutable references in const (limited)
    // let mut x = 5;
    // let r = &mut x;

    // ❌ Floating point (improving)
    // const F: f64 = 3.14;
}
```


## Workflow

### Step 1: Identify Const Opportunities

```
Can be const if:
  → Value known at compile time
  → No heap allocation needed
  → No dynamic dispatch
  → Pure computation (no I/O)
```

### Step 2: Choose Pattern

```
Need:
  → Fixed-size array? Const generic
  → Compile-time computation? Const fn
  → Large array? MaybeUninit + Box
  → Validation? Const assertion
  → Type-level state? PhantomData + const generic
```

### Step 3: Verify Benefits

```
Const advantages:
  ✅ Zero runtime cost
  ✅ Compile-time validation
  ✅ Better optimization
  ✅ Smaller binary (sometimes)

Drawbacks:
  ❌ Longer compile time
  ❌ Limited feature set
  ❌ Complex error messages
```


## Review Checklist

When using const:

- [ ] Computation actually benefits from compile-time execution
- [ ] No stack overflow from large arrays
- [ ] MaybeUninit used correctly for uninitialized memory
- [ ] Const fn doesn't violate limitations
- [ ] Compile-time assertions provide useful errors
- [ ] Generic const parameters reasonably bounded
- [ ] Not overusing const (readability tradeoff)


## Verification Commands

```bash
# Check const evaluation
cargo build --release
cargo asm my_module::my_const_fn

# Verify array sizes
cargo check

# Test const assertions
cargo test --lib
```


## Common Pitfalls

### 1. Stack Overflow

**Symptom**: Segmentation fault

```rust
// ❌ Bad: large array on stack
let arr = [0u8; 1024 * 1024];  // Stack overflow!

// ✅ Good: heap allocation
let arr = Box::new([0u8; 1024 * 1024]);
```

### 2. Uninitialized Memory

**Symptom**: Undefined behavior

```rust
// ❌ Bad: reading uninitialized
let mut arr: [u8; 100];
println!("{}", arr[0]);  // UB!

// ✅ Good: explicit initialization
let arr = [0u8; 100];
```

### 3. Const Generic Mismatch

**Symptom**: Type mismatch errors

```rust
// ❌ Bad: mismatched sizes
fn process<const N: usize>(data: [u8; N]) {
    let other: [u8; 10] = data;  // Error if N != 10
}

// ✅ Good: use generic consistently
fn process<const N: usize>(data: [u8; N]) -> [u8; N] {
    data
}
```


## Related Skills

- **rust-type-driven** - Type-level programming
- **rust-performance** - Zero-cost abstractions
- **rust-unsafe** - MaybeUninit safety
- **rust-macro** - Compile-time code generation


## Localized Reference

- **Chinese version**: [SKILL_ZH.md](./SKILL_ZH.md) - 完整中文版本，包含所有内容
