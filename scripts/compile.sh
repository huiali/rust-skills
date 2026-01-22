#!/bin/bash
set -euo pipefail

# Rust Code Compilation Checker
# Fast type checking without full compilation

echo "🔍 Running cargo check..."
cargo check --all-targets --message-format=short "$@"

echo "✅ All checks passed!"
