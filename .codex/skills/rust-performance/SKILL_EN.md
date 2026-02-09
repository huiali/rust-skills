---
name: rust-performance
description: "Rust performance engineering skill for profiling-driven optimization, allocation control, contention reduction, and latency/throughput tuning."
---

# Rust Performance Skill

## Core Question

**What measured bottleneck should we optimize first, and how do we prove improvement safely?**

## Optimization Workflow

1. Establish baseline metrics (latency, throughput, memory, CPU).
2. Profile to identify hot paths.
3. Apply smallest targeted optimization.
4. Re-measure and verify no correctness regression.

## Common Optimization Levers

- Allocation reduction (`&str`, reuse buffers, arena/pool where justified).
- Data layout and cache locality.
- Lock contention reduction and queue sizing.
- Batch I/O and reduce syscall/chatty network patterns.

## Benchmarking Guidance

- Use representative workloads and data distributions.
- Separate microbenchmarks from end-to-end benchmarks.
- Track p95/p99, not only averages.

## Common Pitfalls

- Optimizing cold code paths.
- Trading maintainability for negligible gains.
- Benchmarking with unrealistic synthetic data only.
- Ignoring GC-like effects from allocator behavior in long runs.

## Review Checklist

- [ ] Baseline and post-change measurements are recorded.
- [ ] Hot path changes are isolated and justified.
- [ ] Correctness tests still pass.
- [ ] No hidden allocation or lock regressions introduced.
- [ ] Observability confirms production impact.

## Verification Commands

```bash
cargo check
cargo test
cargo clippy
cargo bench
```

## Related Skills

- `rust-zero-cost`
- `rust-concurrency`
- `rust-observability`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.
