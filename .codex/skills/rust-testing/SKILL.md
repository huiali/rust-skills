---
name: rust-testing
description: "Rust testing expert for unit, integration, async, property-based, concurrency, and benchmark testing workflows."---

# Rust Testing Skill

Use this skill for detailed, production-ready guidance in this Rust domain.

## Core Question

**How do we keep tests deterministic, fast, and meaningful?**

## Solution Patterns

- Use unit tests for logic, integration for contracts
- Use property tests for invariants
- Use loom/criterion for concurrency/perf confidence

## Workflow

1. Reproduce and isolate the issue with a minimal failing case.
2. Choose the smallest safe design that satisfies constraints.
3. Implement with explicit ownership, errors, and boundaries.
4. Verify with tests, linting, and scenario-specific checks.

## Review Checklist

- [ ] Correct behavior for both success and failure paths.
- [ ] Ownership and API boundaries are explicit.
- [ ] Error handling and diagnostics are actionable.
- [ ] Performance-sensitive paths are measured.
- [ ] Regression tests cover the changed behavior.

## Common Pitfalls

- Fixing flakes with sleep
- Over-mocking
- Slow tests in default CI path

## Verification Commands

```bash
cargo test
cargo test -- --nocapture
cargo bench
cargo nextest run
```

## Related Skills

- `rust-concurrency`
- `rust-performance`
- `rust-database`
