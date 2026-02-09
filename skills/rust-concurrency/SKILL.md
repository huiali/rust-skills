---
name: rust-concurrency
description: "Threading and async concurrency guidance for Send/Sync, channels, locking, and race/deadlock prevention."
---

# Rust Concurrency Skill

Use this skill to solve Rust tasks in this domain with actionable, production-ready guidance.

## Focus Areas
- Diagnose Send/Sync trait bound failures
- Design safe thread and task communication
- Prevent deadlocks and contention

## Workflow
1. Classify as thread or async model
2. Choose synchronization/message passing primitives
3. Constrain shared state access
4. Stress-test concurrency paths

## Typical Triggers
- thread, send, sync, mutex, channel, deadlock

## Output Expectations
- Provide compilable Rust snippets when code is requested.
- Explain tradeoffs and list assumptions.
- Include concrete verification commands (`cargo check`, `cargo test`, `cargo clippy`) when relevant.

## Localized Reference
- Original Chinese content is preserved in `SKILL_ZH.md`.
