---
name: rust-coding
description: "Rust coding standards skill for API ergonomics, module design, naming conventions, testability, and maintainability in production codebases."
---

# Rust Coding Standards Skill

## Core Question

**How do we keep Rust code easy to change, easy to review, and hard to misuse?**

## Coding Principles

- Design APIs to make invalid states hard to represent.
- Prefer small, composable functions over large multi-purpose routines.
- Keep ownership and error behavior explicit at boundaries.
- Optimize readability first, then optimize hot paths with evidence.

## Project Structure Guidelines

Recommended layering:
- `domain`: core business types and invariants.
- `service`: use-case orchestration.
- `infra`: external integrations (DB, HTTP, cache).
- `interface`: handler/controller/CLI entry points.

Module rules:
- Avoid giant `mod.rs` files; split by behavior.
- Keep public surface minimal (`pub(crate)` by default).
- Re-export intentionally to shape stable APIs.

## API Ergonomics Patterns

- Accept `&str` instead of `String` when ownership is not required.
- Accept slices (`&[T]`) instead of `Vec<T>` in read-only APIs.
- Use builder patterns for complex constructors.
- Prefer domain-specific types over primitive obsession.

```rust
pub struct UserId(String);

impl UserId {
    pub fn parse(value: &str) -> Result<Self, &'static str> {
        if value.is_empty() { return Err("empty user id"); }
        Ok(Self(value.to_owned()))
    }
}
```

## Error and Logging Conventions

- Return typed errors in reusable modules.
- Add context at boundary crossings (I/O, parsing, RPC).
- Log once at boundary layers; avoid duplicate logs in deep internals.

## Review Checklist

- [ ] Public API contracts are clear and minimal.
- [ ] Naming follows domain language and Rust conventions.
- [ ] Functions have single, testable responsibilities.
- [ ] Errors include actionable context.
- [ ] Tests cover critical behavior and edge cases.

## Common Pitfalls

- Excessive `.clone()` to bypass ownership design.
- Large enums/modules with mixed responsibilities.
- `unwrap` usage in production paths.
- Hidden side effects in “helper” utilities.

## Verification Commands

```bash
cargo fmt --check
cargo clippy -- -D warnings
cargo test
cargo doc --no-deps
```

## Related Skills

- `rust-anti-pattern`
- `rust-error`
- `rust-type-driven`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.
