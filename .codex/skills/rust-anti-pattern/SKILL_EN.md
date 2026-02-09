---
name: rust-anti-pattern
description: "Rust anti-pattern and code smell detection for clone abuse, unwrap misuse, String overuse, indexing loops, unsafe overreach, and refactor strategy in production code reviews."
---

# Rust Anti-Pattern and Common Mistakes

## Core Question

**Does this pattern hide a deeper design issue?**

Code that compiles is not automatically good code. Anti-patterns are patterns that work but should not be your default.

## Top 5 Beginner Mistakes

| Rank | Mistake | Better Practice |
|---|---|---|
| 1 | Use `.clone()` to bypass borrow checker pressure | Redesign ownership and use references |
| 2 | Use `.unwrap()` in production code | Use `?`, `map_err`, and context |
| 3 | Use `String` everywhere | Prefer `&str`, use owned data only when required |
| 4 | Write index-based loops by default | Use iterators and `enumerate()` |
| 5 | Fight lifetimes directly | Redesign data flow and ownership boundaries |

## Common Anti-Patterns

### 1. Clone Abuse

```rust
// Bad: clone used as an escape hatch
fn process(user: User) {
    let name = user.name.clone();
    // ...
}

// Better: borrow instead
fn process(user: &User) {
    let name = &user.name;
}
```

Use `clone` when:
- You truly need an independent copy.
- API boundaries require ownership transfer.
- You intentionally decouple object lifetimes.

### 2. Unwrap in Production Paths

```rust
// Bad
let config = std::fs::read_to_string("config.json").unwrap();

// Better
let config = std::fs::read_to_string("config.json")?;

// Better with context
let config = std::fs::read_to_string("config.json")
    .map_err(|e| format!("failed to read config.json: {e}"))?;
```

Rules:
- `unwrap` is acceptable in short-lived prototypes/tests where panic is intentional.
- In library/service code, return errors with context.

### 3. String Everywhere

```rust
// Bad: unnecessary allocation at call site
fn greet(name: String) {
    println!("Hello, {name}");
}

// Better
fn greet(name: &str) {
    println!("Hello, {name}");
}
```

Prefer:
- `&str` for read-only input.
- `String` for ownership + mutation.
- `Cow<'a, str>` when mixed owned/borrowed behavior is useful.

### 4. Index-Based Loop Defaults

```rust
// Bad
for i in 0..items.len() {
    println!("{}: {}", i, items[i]);
}

// Better
for item in &items {
    println!("{item}");
}

// Better with index
for (i, item) in items.iter().enumerate() {
    println!("{}: {}", i, item);
}
```

### 5. Unsafe Overreach

```rust
// Bad: unsafe used where safe abstractions exist
unsafe {
    let ptr = data.as_mut_ptr();
    // pointer manipulation
}

// Better: prefer safe container operations
let data = vec![0u8; size];
```

Use `unsafe` only when:
- No safe abstraction can meet the requirement.
- Invariants are explicit and testable.
- The unsafe surface is minimized and encapsulated.

## Code Smell Quick Scan

| Symptom | Likely Problem | Refactor Direction |
|---|---|---|
| Many `.clone()` calls | Ownership model is unclear | Make data flow explicit |
| Many `.unwrap()` calls | Missing error design | Introduce typed/structured errors |
| Many `pub` fields | Broken encapsulation | Private fields + smart constructors |
| Deep nested branches | Missing abstraction | Extract functions/traits |
| Long functions (> 50 lines) | Too many responsibilities | Split by behavior |
| Giant match blocks | Type boundaries are weak | Add domain types / polymorphism |

## Outdated Style -> Modern Style

| Outdated | Modern |
|---|---|
| Manual index loops | Iterator chains and adapters |
| `collect::<Vec<_>>()` then iterate again | Keep iterator pipeline when possible |
| `lazy_static!` for simple init | `std::sync::OnceLock` |
| `mem::transmute` for conversion | `From` / `TryFrom` / explicit casts |
| Hand-written linked list for general use | `Vec` / `VecDeque` |
| Manual interior mutability hacks | `Cell` / `RefCell` / `Mutex` |

## Review Checklist

- [ ] No unjustified `.clone()` calls.
- [ ] No `.unwrap()`/`.expect()` in production-critical paths without rationale.
- [ ] Public fields are justified by explicit invariants.
- [ ] Index loops replaced by iterators where appropriate.
- [ ] `&str` preferred over `String` for borrowed inputs.
- [ ] `#[must_use]` warnings are not ignored.
- [ ] Every unsafe block has a `SAFETY:` explanation.
- [ ] Oversized functions are split into coherent units.

## Decision Questions

1. Is this code fighting Rust or using Rust?
2. Is this `clone` essential or compensating for weak ownership design?
3. Can this `unwrap` panic in a real production path?
4. Is there a more idiomatic standard-library or ecosystem pattern?

## Localized Reference

- Original Chinese content is preserved in `SKILL_ZH.md`.
