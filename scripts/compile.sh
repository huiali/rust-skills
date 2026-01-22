#!/bin/bash
set -e

# Rust Code Compilation Checker
# Fast type checking without full compilation

echo "🔍 Running cargo check..."
cargo check --message-format=short "$@"

if [ $? -eq 0 ]; then
    echo "✅ All checks passed!"
else
    echo "❌ Check failed!"
    exit 1
fi

