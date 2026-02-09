---
name: rust-unsafe
description: "Unsafe Rust skill for soundness review, pointer invariants, aliasing rules, FFI boundaries, and minimization of unsafe surface area."
---

# Rust Unsafe Skill

## Core Question

**Is this unsafe block necessary, minimal, and provably sound?**

## Unsafe Review Model

For each unsafe block, document:
1. Required invariants.
2. Why safe Rust cannot express this operation.
3. How invariants are enforced before/after block.

Use a mandatory comment style:

```rust
// SAFETY: <why this operation is sound>
unsafe { /* ... */ }
```

## Soundness Boundaries

- Pointer validity and alignment.
- Aliasing and mutability exclusivity.
- Lifetime and ownership transfer across ABI boundaries.
- Panic/unwind behavior around foreign code.

## Encapsulation Pattern

- Keep unsafe in small private modules.
- Expose safe API with validated preconditions.
- Add tests that stress invariants and edge cases.

## Common Pitfalls

- Using `unsafe` to silence borrow checker without proving invariants.
- Returning references tied to unstable raw-memory ownership.
- Mixing panic paths with FFI boundaries unsafely.
- `transmute` where `From/TryFrom` or pointer casts suffice.

## Review Checklist

- [ ] Every unsafe block has `SAFETY:` rationale.
- [ ] Unsafe surface is minimized and encapsulated.
- [ ] Invariants are testable and enforced.
- [ ] FFI/unwind semantics are explicitly handled.
- [ ] Miri/sanitizer or equivalent checks are considered.

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo miri test
```

## Related Skills

- `rust-ffi`
- `rust-performance`
- `rust-resource`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.
