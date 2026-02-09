---
name: rust-gpu
description: "GPU programming patterns in Rust including memory movement, compute kernels, and host-device coordination."
---

# Rust GPU Skill

Use this skill for domain-specific, production-ready Rust guidance.

## Core Question

**How do we structure host-device computation to minimize transfer overhead and maximize parallel efficiency?**

## Solution Patterns

- Batch transfers and overlap compute with I/O
- Use contiguous layouts and coalesced access patterns
- Measure occupancy and kernel bottlenecks before tuning

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

- Frequent small host-device transfers
- Divergent kernels reducing warp efficiency
- Ignoring synchronization costs

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo bench
```

## Related Skills

- `rust-performance`
- `rust-zero-cost`
- `rust-resource`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.

