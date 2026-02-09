---
name: rust-ownership
description: "Ownership, borrowing, and lifetime troubleshooting for Rust compiler errors such as move-after-use and invalid references."
---

# Rust Ownership Skill

Use this skill to solve Rust tasks in this domain with actionable, production-ready guidance.

## Focus Areas
- Fix borrow-checker and move semantics errors
- Design APIs around ownership boundaries
- Reduce unnecessary cloning

## Workflow
1. Locate the ownership boundary
2. Replace moves with borrows where valid
3. Adjust lifetime/return ownership strategy
4. Re-run checks and tests

## Typical Triggers
- ownership, borrow, lifetime, move, clone

## Output Expectations
- Provide compilable Rust snippets when code is requested.
- Explain tradeoffs and list assumptions.
- Include concrete verification commands (`cargo check`, `cargo test`, `cargo clippy`) when relevant.

## Localized Reference
- Original Chinese content is preserved in `SKILL_ZH.md`.
