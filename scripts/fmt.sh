#!/bin/bash
set -euo pipefail

# Rust Code Formatter
# Check and format code according to rustfmt

echo "📐 Checking code format..."

# Check all targets (lib, bins, tests, examples)
if cargo fmt --check --all-targets "$@"; then
    echo "✅ Code is properly formatted!"
else
    echo "⚠️  Code needs formatting. Running formatter..."
    cargo fmt --all-targets "$@"
    echo "✅ Code formatted successfully!"
fi
