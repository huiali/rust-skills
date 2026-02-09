---
name: rust-const
description: "Const generics and compile-time programming skill for Rust APIs with static guarantees, zero-cost constraints, and const-evaluable design patterns."
---

# Rust Const Skill

## Core Question

**Which invariants should move from runtime checks to compile-time guarantees?**

## Design Strategy

- Use const generics when shape/limits are part of API semantics.
- Keep const parameters small and meaningful (`N`, `CAPACITY`, `WIDTH`).
- Prefer readable compile-time constraints over clever type puzzles.

## Practical Patterns

### 1. Compile-time sized containers

```rust
pub struct RingBuf<T, const N: usize> {
    data: [Option<T>; N],
    head: usize,
    tail: usize,
}
```

### 2. Const-checked configuration

```rust
pub struct Block<const SIZE: usize>;

impl<const SIZE: usize> Block<SIZE> {
    pub const fn validate() {
        assert!(SIZE.is_power_of_two());
    }
}
```

### 3. Static protocol/layout constraints

- Encode wire-size assumptions as const parameters.
- Prevent invalid combinations with type-level constructors.

## Common Pitfalls

- Overusing const generics where a normal value parameter is clearer.
- Hard-to-read error messages from deeply nested generic constraints.
- Mixing runtime and compile-time validation inconsistently.

## Review Checklist

- [ ] Const parameters represent real domain invariants.
- [ ] Compiler errors remain understandable for users.
- [ ] API remains ergonomic at call sites.
- [ ] Runtime overhead is reduced or eliminated meaningfully.
- [ ] Tests include boundary values for const parameters.

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo fmt
```

## Related Skills

- `rust-type-driven`
- `rust-zero-cost`
- `rust-lifetime-complex`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.
