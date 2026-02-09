---
name: rust-error-advanced
description: "Advanced error composition with anyhow, thiserror, context layering, and boundary mapping across modules/services."
---

# Advanced Rust Error Skill

Use this skill to solve Rust tasks in this domain with actionable, production-ready guidance.

## Focus Areas
- Unify error context at module boundaries
- Balance typed errors vs opaque application errors
- Keep logs and user-facing messages clean

## Workflow
1. Define boundary-specific error contracts
2. Apply thiserror/anyhow where appropriate
3. Attach context for observability
4. Verify error propagation paths

## Typical Triggers
- thiserror, anyhow, context, error stack

## Output Expectations
- Provide compilable Rust snippets when code is requested.
- Explain tradeoffs and list assumptions.
- Include concrete verification commands (`cargo check`, `cargo test`, `cargo clippy`) when relevant.

## Localized Reference
- Original Chinese content is preserved in `SKILL_ZH.md`.
