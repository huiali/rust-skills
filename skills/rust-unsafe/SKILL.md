---
name: rust-unsafe
description: Unsafe code and FFI expert covering raw pointers (*mut, *const), FFI patterns, transmute, union, #[repr(C)], SAFETY comments, soundness rules, and undefined behavior prevention.
metadata:
  triggers:
    - unsafe
    - raw pointer
    - FFI
    - extern
    - transmute
    - union
    - repr(C)
    - MaybeUninit
    - NonNull
    - SAFETY comment
    - soundness
    - undefined behavior
    - UB
---


## When Unsafe is Justified

| Use Case | Example | Justified? |
|----------|---------|-----------|
| FFI calls to C | `extern "C" { fn libc_malloc(size: usize) -> *mut c_void; }` | ✅ Yes |
| Low-level abstractions | Internal implementation of `Vec`, `Arc` | ✅ Yes |
| Performance optimization (measured) | Hot path with proven bottleneck | ⚠️ Verify first |
| Escaping borrow checker | Don't know why you need it | ❌ No |


## SAFETY Comment Requirements

**Every unsafe block must include a SAFETY comment:**

```rust
// SAFETY: ptr must be non-null and properly aligned.
// This function is only called after a null check.
unsafe { *ptr = value; }

/// # Safety
///
/// * `ptr` must be properly aligned and not null
/// * `ptr` must point to initialized memory of type T
/// * The memory must not be accessed after this function returns
pub unsafe fn write(ptr: *mut T, value: &T) { ... }
```


## Solution Patterns

### Pattern 1: FFI with Safe Wrapper

```rust
use std::ffi::{CStr, CString};
use std::os::raw::c_char;

extern "C" {
    fn c_function(s: *const c_char) -> i32;
}

// ✅ Safe wrapper
pub fn safe_c_function(s: &str) -> Result<i32, Box<dyn Error>> {
    let c_str = CString::new(s)?;
    // SAFETY: c_str is a valid null-terminated string created from Rust data.
    // The pointer is valid for the duration of this call.
    let result = unsafe { c_function(c_str.as_ptr()) };
    Ok(result)
}
```

### Pattern 2: Raw Pointer with Validation

```rust
use std::ptr::NonNull;

struct Buffer {
    ptr: NonNull<u8>,
    len: usize,
}

impl Buffer {
    pub fn write(&mut self, index: usize, value: u8) -> Result<(), String> {
        if index >= self.len {
            return Err("index out of bounds".to_string());
        }

        // SAFETY: We've checked index is within bounds.
        // ptr is NonNull and points to valid memory.
        unsafe {
            self.ptr.as_ptr().add(index).write(value);
        }
        Ok(())
    }
}
```

### Pattern 3: Uninitialized Memory

```rust
use std::mem::MaybeUninit;

// ✅ Safe uninitialized memory handling
fn create_buffer(size: usize) -> Vec<u8> {
    let mut buffer: Vec<MaybeUninit<u8>> = Vec::with_capacity(size);

    for i in 0..size {
        buffer.push(MaybeUninit::new(0));
    }

    // SAFETY: All elements have been initialized to 0.
    unsafe { std::mem::transmute(buffer) }
}

// ❌ Avoid: deprecated pattern
fn bad_buffer(size: usize) -> Vec<u8> {
    let mut v = Vec::with_capacity(size);
    unsafe { v.set_len(size); }  // UB if not initialized!
    v
}
```

### Pattern 4: Repr(C) for FFI

```rust
#[repr(C)]
pub struct Point {
    pub x: f64,
    pub y: f64,
}

#[repr(C)]
pub enum Status {
    Success = 0,
    Error = 1,
}

// SAFETY: Layout matches C struct exactly
extern "C" {
    fn process_point(p: *const Point) -> Status;
}
```


## 47 Unsafe Rules Reference

### General Principles (3 rules)

| Rule | Description |
|------|-------------|
| G-01 | Don't use unsafe to escape compiler safety checks |
| G-02 | Don't blindly use unsafe for performance |
| G-03 | Don't create "Unsafe" aliases for types/methods |

### Memory Layout (6 rules)

| Rule | Description |
|------|-------------|
| M-01 | Choose appropriate memory layout for struct/tuple/enum |
| M-02 | Don't modify memory variables of other processes |
| M-03 | Don't let String/Vec auto-deallocate memory from other processes |
| M-04 | Prefer reentrant versions of C-API or syscalls |
| M-05 | Use third-party crates for bit fields |
| M-06 | Use `MaybeUninit<T>` for uninitialized memory |

### Raw Pointers (6 rules)

| Rule | Description |
|------|-------------|
| P-01 | Don't share raw pointers across threads |
| P-02 | Prefer `NonNull<T>` over `*mut T` |
| P-03 | Use `PhantomData<T>` to mark variance and ownership |
| P-04 | Don't dereference pointers cast to misaligned types |
| P-05 | Don't manually convert immutable pointers to mutable |
| P-06 | Use `ptr::cast` instead of `as` for pointer casts |

### Unions (2 rules)

| Rule | Description |
|------|-------------|
| U-01 | Avoid unions except for C interop |
| U-02 | Don't use union variants with different lifetimes |

### FFI (18 rules)

| Rule | Description |
|------|-------------|
| F-01 | Avoid passing strings directly to C |
| F-02 | Carefully read `std::ffi` types documentation |
| F-03 | Implement Drop for wrapped C pointers |
| F-04 | Handle panics across FFI boundaries |
| F-05 | Use portable type aliases from `std` or `libc` |
| F-06 | Ensure C-ABI string compatibility |
| F-07 | Don't implement Drop for types passed to extern code |
| F-08 | Handle errors properly in FFI |
| F-09 | Use references instead of raw pointers in safe wrappers |
| F-10 | Exported functions must be thread-safe |
| F-11 | Be careful with references to `repr(packed)` fields |
| F-12 | Document invariant assumptions for C parameters |
| F-13 | Ensure consistent data layout for custom types |
| F-14 | FFI types should have stable layout |
| F-15 | Validate robustness of external values |
| F-16 | Separate data and code for C closures |
| F-17 | Use opaque types instead of `c_void` |
| F-18 | Avoid passing trait objects to C |

### Safe Abstractions (11 rules)

| Rule | Description |
|------|-------------|
| S-01 | Be aware of memory safety issues from panics |
| S-02 | Unsafe code authors must verify safety invariants |
| S-03 | Don't expose uninitialized memory in public APIs |
| S-04 | Avoid double-free from panics |
| S-05 | Consider safety when manually implementing Auto Traits |
| S-06 | Don't expose raw pointers in public APIs |
| S-07 | Provide safe alternatives for performance |
| S-08 | Returning mutable reference from immutable parameter is wrong |
| S-09 | Add SAFETY comment before each unsafe block |
| S-10 | Add Safety section to public unsafe function docs |
| S-11 | Use `assert!` instead of `debug_assert!` in unsafe functions |

### I/O Safety (1 rule)

| Rule | Description |
|------|-------------|
| I-01 | Ensure I/O safety when using raw handles |


## Workflow

### Step 1: Question the Need

```
Do I really need unsafe?
  → Can I use safe abstractions?
  → Is this for FFI? (justified)
  → Is this for measured performance? (profile first)
  → Am I fighting the borrow checker? (redesign instead)
```

### Step 2: Write SAFETY Comments

```
For every unsafe block:
1. Document preconditions
2. Explain why they hold
3. Reference invariants maintained

For public unsafe functions:
1. Add /// # Safety section
2. List all requirements
3. Document consequences of violations
```

### Step 3: Validate with Tools

```bash
# Detect undefined behavior
cargo +nightly miri test

# Memory leak detection
valgrind ./target/release/program

# Data race detection
RUST_BACKTRACE=1 cargo test --features tsan
```

### Step 4: Build Safe Wrappers

```
Raw unsafe code
  ↓
Safe private functions (validate inputs)
  ↓
Safe public API (no unsafe visible)
```


## Common Errors and Fixes

| Error | Fix |
|-------|-----|
| Null pointer dereference | Check for null before dereferencing |
| Use after free | Ensure lifetime validity |
| Data race | Add synchronization |
| Alignment violation | Use `#[repr(C)]`, check alignment |
| Invalid bit pattern | Use `MaybeUninit` |
| Missing SAFETY comment | Add comment |


## Deprecated Patterns

| Deprecated | Modern Alternative |
|-----------|-------------------|
| `mem::uninitialized()` | `MaybeUninit<T>` |
| `mem::zeroed()` (for reference types) | `MaybeUninit<T>` |
| Raw pointer arithmetic | `NonNull<T>`, `ptr::add` |
| `CString::new().unwrap().as_ptr()` | Store `CString` first |
| `static mut` | `AtomicT` or `Mutex` |
| Manual extern declarations | `bindgen` |


## FFI Tools

| Direction | Tool |
|-----------|------|
| C → Rust | `bindgen` |
| Rust → C | `cbindgen` |
| Python | `PyO3` |
| Node.js | `napi-rs` |
| C++ | `cxx` |


## Review Checklist

When reviewing unsafe code:

- [ ] Unsafe usage is justified (FFI, low-level abstraction, measured perf)
- [ ] Every unsafe block has SAFETY comment
- [ ] Public unsafe functions document Safety requirements
- [ ] Raw pointers are validated before dereferencing
- [ ] No raw pointer sharing across threads without sync
- [ ] FFI boundaries properly handle panics
- [ ] Memory layout explicitly specified for FFI types
- [ ] Uninitialized memory uses `MaybeUninit`
- [ ] Safe public API wraps unsafe internals
- [ ] Tested with Miri for undefined behavior


## Verification Commands

```bash
# Check for undefined behavior
cargo +nightly miri test

# Run with address sanitizer
RUSTFLAGS="-Z sanitizer=address" cargo +nightly test

# Check FFI bindings
cargo check --features ffi

# Verify memory safety
valgrind --leak-check=full ./target/release/program

# Documentation check
cargo doc --no-deps --open
```


## Common Pitfalls

### 1. Dangling Pointers

**Symptom**: Use-after-free, segfault

```rust
// ❌ Bad: pointer outlives data
fn bad() -> *const i32 {
    let x = 42;
    &x as *const i32  // Dangling!
}

// ✅ Good: proper lifetime management
fn good(x: &i32) -> *const i32 {
    x as *const i32  // Lifetime tied to input
}
```

### 2. Uninitialized Memory

**Symptom**: Undefined behavior, random values

```rust
// ❌ Bad: reading uninitialized memory
let x: i32;
unsafe { println!("{}", x); }  // UB!

// ✅ Good: use MaybeUninit
let mut x = MaybeUninit::<i32>::uninit();
x.write(42);
let x = unsafe { x.assume_init() };  // Safe
```

### 3. Invalid Repr

**Symptom**: FFI crashes, data corruption

```rust
// ❌ Bad: default repr with FFI
struct Point { x: f64, y: f64 }
extern "C" { fn use_point(p: Point); }

// ✅ Good: explicit C layout
#[repr(C)]
struct Point { x: f64, y: f64 }
extern "C" { fn use_point(p: Point); }
```


## Related Skills

- **rust-ownership** - Lifetime and borrowing fundamentals
- **rust-ffi** - Advanced FFI patterns
- **rust-performance** - When unsafe optimization is justified
- **rust-coding** - SAFETY comment conventions
- **rust-concurrency** - Thread-safe unsafe patterns


## Localized Reference

- **Chinese version**: [SKILL_ZH.md](./SKILL_ZH.md) - 完整中文版本，包含所有内容
