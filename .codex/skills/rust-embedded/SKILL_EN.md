---
name: rust-embedded
description: "Embedded Rust and no_std skill for constrained-memory systems, ISR safety, HAL integration, and deterministic real-time behavior."
---

# Rust Embedded Skill

## Core Question

**How do we meet timing and memory constraints without sacrificing safety?**

## Platform Strategy

- Start from target constraints: MCU class, RAM/flash budget, interrupt model.
- Use `no_std` with HAL/PAC crates appropriate to board/chip.
- Keep interrupt and shared-state model explicit and minimal.

## ISR and Concurrency Rules

- Keep ISR handlers short and deterministic.
- Move heavy work to task/main loop using lock-free or bounded queue handoff.
- Use critical sections intentionally and minimally.

## Memory Footprint Control

- Avoid hidden allocations in hot/interrupt paths.
- Prefer static buffers with explicit capacity.
- Track binary size regressions in CI.

## Reliability Patterns

- Watchdog integration for recovery.
- Brownout/reset-safe startup path.
- Panic strategy consistent with deployment needs.

## Common Pitfalls

- Blocking in interrupt context.
- Unbounded buffers in constrained systems.
- Feature-flag sprawl causing unpredictable binary growth.
- Unsafe register access without invariant wrappers.

## Review Checklist

- [ ] ISR paths are bounded and non-blocking.
- [ ] Memory allocations are controlled and justified.
- [ ] Startup/reset behavior is deterministic.
- [ ] Peripheral access patterns are race-safe.
- [ ] Hardware-in-loop or board-level tests exist.

## Verification Commands

```bash
cargo check --target <target-triple>
cargo test
cargo clippy
cargo build --release --target <target-triple>
```

## Related Skills

- `rust-unsafe`
- `rust-performance`
- `rust-resource`

## Localized Reference

- Original Chinese version is preserved in `SKILL_ZH.md`.
