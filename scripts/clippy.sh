#!/bin/bash
set -e

# Rust Clippy Linter
# Strict linting for code quality

echo "🔎 Running clippy with strict warnings..."
cargo clippy -- -D warnings "$@"

if [ $? -eq 0 ]; then
    echo "✅ Clippy passed with no warnings!"
else
    echo "❌ Clippy found issues!"
    exit 1
fi

