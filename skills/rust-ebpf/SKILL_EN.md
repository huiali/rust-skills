---
name: rust-ebpf
description: "eBPF development in Rust for kernel/user-space programs, maps, events, and performance-safe observability."
---

# Rust eBPF Skill

Use this skill for domain-specific, production-ready Rust guidance.

## Core Question

**How do we satisfy verifier constraints while preserving useful observability or policy behavior?**

## Solution Patterns

- Keep eBPF programs small with explicit bounds
- Use maps with stable key/value schemas
- Split kernel and user-space responsibilities clearly

## Workflow

1. Reproduce and isolate the issue with a minimal failing case.
2. Choose a domain-appropriate safe design and constraints.
3. Implement with explicit ownership, error, and boundary contracts.
4. Validate behavior with tests and operational checks.

## Review Checklist

- [ ] Correct behavior for success and failure paths.
- [ ] Domain invariants and boundaries are explicit.
- [ ] Errors and diagnostics are actionable.
- [ ] Performance/operational impact is measured.
- [ ] Regression tests cover the changed behavior.

## Common Pitfalls

- Verifier rejection from unchecked memory access
- Map cardinality blowups
- Kernel/user ABI drift

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo build --release
```

## Related Skills

- `rust-unsafe`
- `rust-observability`
- `rust-performance`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.

