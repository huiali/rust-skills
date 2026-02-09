---
name: rust-skill
description: "Main Rust routing skill for compile errors, ownership, lifetimes, async, concurrency, and performance issues. Use when a Rust task needs end-to-end diagnosis and solution planning."
---

# Rust Expert Skill

Use this skill to solve Rust tasks in this domain with actionable, production-ready guidance.

## Focus Areas
- Route the task to the right Rust sub-skill quickly
- Provide safe and idiomatic baseline solutions first
- Escalate to advanced performance or unsafe patterns only when needed

## Workflow
1. Classify the problem domain and constraints
2. Propose a minimal correct implementation
3. Refine for ergonomics, performance, and reliability
4. Provide cargo commands to validate the fix

## Typical Triggers
- rust, cargo, compile error
- ownership, borrow, lifetime
- async, tokio, send, sync
- result, error handling, performance

## Output Expectations
- Provide compilable Rust snippets when code is requested.
- Explain tradeoffs and list assumptions.
- Include concrete verification commands (`cargo check`, `cargo test`, `cargo clippy`) when relevant.

## Localized Reference
- Original Chinese content is preserved in `SKILL_ZH.md`.
