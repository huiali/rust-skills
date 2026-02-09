---
name: rust-dpdk
description: "High-performance packet processing in Rust with DPDK, NUMA-aware tuning, and low-latency networking patterns."
---

# Rust DPDK Skill

Use this skill for domain-specific, production-ready Rust guidance.

## Core Question

**How do we maximize packet throughput while keeping latency and memory behavior predictable?**

## Solution Patterns

- Pin worker threads by NUMA/socket topology
- Use preallocated mempools and bounded queues
- Keep packet path lock-free and branch-light

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

- Cross-socket memory access penalties
- Unbounded burst size causing latency spikes
- Excessive copies in packet pipeline

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo bench
```

## Related Skills

- `rust-performance`
- `rust-resource`
- `rust-concurrency`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.

