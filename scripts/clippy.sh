#!/bin/bash
set -euo pipefail

# Rust Clippy Linter
# Strict linting for code quality

echo "🔎 Running clippy with strict warnings..."
cargo clippy --all-targets -- -D warnings "$@"

echo "✅ Clippy passed with no warnings!"
