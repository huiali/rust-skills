---
name: rust-ownership
description: 'Ownership, borrowing, and lifetime expert. Handles compiler errors E0382,
  E0597, E0506, E0507,

  E0515, E0716, E0106 and provides systematic solutions for memory safety patterns.

  '
metadata:
  triggers:
  - ownership
  - borrow
  - lifetime
  - move
  - clone
  - Copy
  - E0382
  - E0597
  - E0506
---

# Ownership & Lifetime Expert

## Core Question

**Who owns this data, and for how long can it be accessed?**

Understanding ownership is understanding half of Rust. Every value has exactly one owner at any given time.

---

## Solution Patterns

### Pattern 1: Value Moved After Use

```rust
let s1 = String::from("hello");
let s2 = s1;
// println!("{}", s1); // Compile error!
```

**Root Cause**: Ownership transferred from `s1` to `s2`, `s1` is no longer valid.

**Solutions**:
- Need two copies → use `clone()`
- Only need to read → pass by reference `&s1`
- `s2` is temporary → consider redesign

### Pattern 2: Borrow Conflict

```rust
let mut s = String::from("hello");
let r1 = &s;
let r2 = &mut s; // Conflict!
// println!("{}", r1);
```

**Root Cause**: Immutable and mutable borrows coexist.

**Solutions**:
- Ensure mutable borrow completes before creating new borrows
- Restructure code organization

### Pattern 3: Lifetime Mismatch

```rust
fn longest<'a>(s1: &'a str, s2: &'a str) -> &'a str {
    if s1.len() > s2.len() { s1 } else { s2 }
}
```

**Root Cause**: Return value lifetime must be tied to one of the inputs.

**Key Solutions**:
1. Clarify each reference's lifetime
2. Use named lifetimes to express relationships
3. Prefer returning owned types

---

## Workflow

### Step 1: Who Owns the Data?

| Situation | Owner |
|-----------|-------|
| Function parameter | Caller owns |
| Function-local variable | Function owns (destroyed on return) |
| Struct field | Struct instance owns |
| `Arc<T>` | Multiple shared owners |

### Step 2: Is Borrowing Appropriate?

| Operation | Borrow Type | Notes |
|-----------|-------------|-------|
| Read-only | `&T` | Multiple can coexist |
| Needs mutation | `&mut T` | Only one at a time |
| Will original be modified during borrow? | If yes, that's the issue |

### Step 3: Can Lifetimes Be Avoided?

```
Return String instead of &str
    ↓
Use owned collections instead of slices
    ↓
Use Arc/Rc for shared ownership
    ↓
Lifetimes aren't always necessary
```

---

## Smart Pointer Selection

| Scenario | Choice | Reason |
|----------|--------|--------|
| Heap-allocate single value | `Box<T>` | Simple and direct |
| Single-threaded shared reference counting | `Rc<T>` | Lightweight |
| Multi-threaded shared reference counting | `Arc<T>` | Atomic operations |
| Need runtime borrow checking | `RefCell<T>` | Single-threaded interior mutability |
| Multi-threaded interior mutability | `Mutex<T>` or `RwLock<T>` | Thread-safe |

---

## Common Pitfalls

| Anti-Pattern | Problem | Correct Approach |
|--------------|---------|------------------|
| `.clone()` everywhere | Hides ownership issues | Think about actual ownership needs |
| `'static` for everything | Too loose and imprecise | Use actual required lifetimes |
| `Box::leak()` memory leaks | Memory waste | Use proper lifetime management |
| Fighting the borrow checker | Digging your own hole | Understand and work with compiler design |

---

## Practical Guidance

### Common Beginner Questions

**1. "When should I use references vs ownership?"**
   - Function parameters: use references (unless consuming)
   - Function returns: use references (if caller doesn't need ownership)
   - Storage: consider lifetime complexity

**2. "How do I add lifetime annotations?"**
   - Most cases: compiler can infer
   - Need explicit: structs, trait impls, methods returning references
   - Use meaningful names: `'connection`, `'file`

**3. "Why doesn't this borrow work?"**
   - Mutable borrows make original inaccessible
   - Check borrow scope ranges
   - Consider code reorganization

---

## Error Code Quick Reference

| Code | Meaning | Don't Say | Ask Instead |
|------|---------|-----------|-------------|
| E0382 | Use of moved value | "clone it" | Who should own this data? |
| E0597 | Lifetime too short | "extend lifetime" | Are scope boundaries correct? |
| E0506 | Borrow not ended before mutation | "end borrow first" | Where should mutation occur? |
| E0507 | Move out of reference | "clone before move" | Why move from reference? |
| E0515 | Return non-owned data | "return owned" | Should caller own the data? |
| E0716 | Temporary value lifetime insufficient | "bind to variable" | Why is this temporary? |
| E0106 | Missing lifetime parameter | "add 'a" | What's the lifetime relationship? |

---

## Thinking Process

When encountering ownership issues, follow these steps:

**1. What's this data's role in the domain?**
   - Entity (unique identity) → owned
   - Value object (interchangeable) → clone/copy acceptable
   - Temporary computation result → consider refactor

**2. Is ownership design intentional or accidental?**
   - Intentional → work within constraints
   - Accidental → consider redesign

**3. Fix symptom or redesign?**
   - If failed 3 times → escalate to design level

---

## Trace Up (Design Analysis)

When ownership errors persist, trace to design level:

```
E0382 (moved value)
    ↑ Ask: What design choice led to this ownership pattern?
    ↑ Check: Is this an entity or value object?
    ↑ Check: Are there other constraints?

Persistent E0382 → rust-resource: Should use Arc/Rc for sharing?
Persistent E0597 → rust-type-driven: Are scope boundaries correct?
E0506/E0507 → rust-mutability: Should use interior mutability?
```

---

## Trace Down (Implementation)

From design decisions to implementation:

```
"Data needs immutable sharing"
    ↓ Multi-threaded: Arc<T>
    ↓ Single-threaded: Rc<T>

"Data needs exclusive ownership"
    ↓ Return owned value

"Data is temporary use only"
    ↓ Use references within scope

"Need to pass data between functions"
    ↓ Consider lifetimes or return owned
```

---

## Review Checklist

When reviewing ownership-related code:

- [ ] Each value has a clear owner
- [ ] Borrows don't outlive the borrowed data
- [ ] Mutable and immutable borrows don't overlap
- [ ] Lifetime annotations accurately reflect data relationships
- [ ] Smart pointer choice matches threading requirements
- [ ] `.clone()` is used intentionally, not to avoid compiler errors
- [ ] Lifetime elision is leveraged where possible
- [ ] Complex lifetime scenarios are documented

---

## Verification Commands

```bash
# Check compilation
cargo check

# Run tests
cargo test

# Check for common mistakes
cargo clippy -- -W clippy::clone_on_copy -W clippy::unnecessary_clone

# Verify no memory leaks in tests
cargo test --features leak-check
```

---

## Common Pitfalls

### 1. Clone Abuse

**Symptom**: `.clone()` everywhere to satisfy compiler

**Fix**: Understand actual ownership requirements, use references where possible

### 2. Lifetime Overuse

**Symptom**: Complex lifetime annotations everywhere

**Fix**: Return owned types, use smart pointers

### 3. Fighting Borrow Checker

**Symptom**: Constantly rewriting to satisfy compiler

**Fix**: Step back and redesign data flow

---

## Related Skills

- **rust-mutability** - Interior mutability patterns (Cell, RefCell)
- **rust-concurrency** - Send/Sync and thread safety
- **rust-unsafe** - Raw pointers and manual memory management
- **rust-lifetime-complex** - Advanced lifetime patterns (HRTB, GAT)
- **rust-resource** - Resource management and RAII patterns
- **rust-type-driven** - Type-driven design

---

## Localized Reference

- **Chinese version**: [SKILL_ZH.md](./SKILL_ZH.md) - 完整中文版本，包含所有内容
