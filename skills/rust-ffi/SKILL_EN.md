---
name: rust-ffi
description: "Rust FFI interoperability skill for C/C++ boundaries, ABI safety, ownership transfer, error conversion, and panic/exception containment."
---

# Rust FFI Skill

## Core Question

**How do we define a stable ABI boundary without memory ownership ambiguity?**

## Boundary Rules

- Mark exported symbols with explicit ABI (`extern "C"`).
- Keep FFI data layouts explicit (`#[repr(C)]`).
- Avoid exposing Rust-specific types directly (`String`, `Vec<T>`, trait objects).

## Ownership Contracts

- Define who allocates and who frees every cross-boundary object.
- Provide paired create/free functions for foreign callers.
- Avoid implicit ownership transfer.

## Error and Panic Handling

- Never let Rust panics cross FFI boundaries.
- Map internal errors to ABI-safe error codes.
- Provide structured error retrieval if needed.

## C++ Interop Notes

- Handle exception boundaries explicitly (no exception crossing into Rust).
- Keep unwind strategy compatible with compiler/runtime settings.

## Common Pitfalls

- `repr(Rust)` structs used in C ABI.
- Returning borrowed pointers with unclear lifetime ownership.
- Missing free function for heap-allocated return values.
- Panic crossing foreign frames.

## Review Checklist

- [ ] ABI and data layout are explicit and documented.
- [ ] Ownership transfer is unambiguous.
- [ ] Panics/exceptions are contained at boundary.
- [ ] Error mapping is stable and testable.
- [ ] Cross-language tests validate create/use/free lifecycle.

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo test --features ffi-integration
```

## Related Skills

- `rust-unsafe`
- `rust-resource`
- `rust-performance`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.
