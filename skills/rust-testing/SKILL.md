---
name: rust-testing
description: Rust testing expert for unit tests, integration tests, async tests, property-based testing, concurrency testing with loom, benchmarks with criterion, and flaky test diagnosis. Use when working with cargo test, tokio tests, mock/mocking, proptest, or coverage-oriented test strategy.
---

# Rust Testing Skill

Use this skill to design, fix, and scale Rust test suites.

## Workflow

1. Classify the failure: logic bug, race condition, timing, environment, or API contract mismatch.
2. Reproduce minimally with deterministic inputs and isolated fixtures.
3. Choose the right test type: unit, integration, property, concurrency, or benchmark.
4. Add assertions on behavior and error messages, not just happy-path output.
5. Keep tests fast in CI and isolate slow tests behind feature flags or ignored markers.

## Patterns

### Unit tests

- Test pure logic first.
- Prefer table-driven cases for edge conditions.
- Keep setup local to the test unless shared fixtures are clearly cheaper.

### Integration tests

- Validate public API contracts, not internal implementation details.
- Use temporary resources and explicit teardown.
- Cover serialization formats and version compatibility boundaries.

### Async tests

- Use `#[tokio::test]` with explicit runtime flavor when needed.
- Avoid `sleep` for synchronization; prefer channels, barriers, or notifications.
- Enforce timeouts to avoid hanging CI jobs.

### Property-based tests

- Use `proptest` for invariants and shrinking counterexamples.
- Start with small domains and increase complexity only after stable runs.

### Concurrency tests

- Use `loom` to explore interleavings for lock/order correctness.
- Minimize shared mutable state in the tested unit.

### Benchmarks

- Use `criterion` for statistically meaningful performance checks.
- Separate correctness tests from performance tests.

## Commands

```bash
cargo test
cargo test -- --nocapture
cargo test --test <integration_test_name>
cargo test <module_or_case_name>
cargo bench
```

## Guardrails

- Do not fix flaky tests with arbitrary sleeps.
- Do not assert on unstable text that can change across toolchains unless necessary.
- Keep tests hermetic where possible.
