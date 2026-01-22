#!/bin/bash
set -e

# Rust Code Formatter
# Check and format code according to rustfmt

echo "📐 Checking code format..."
if cargo fmt --check "$@"; then
    echo "✅ Code is properly formatted!"
else
    echo "⚠️  Code needs formatting. Running formatter..."
    cargo fmt "$@"
    echo "✅ Code formatted successfully!"
fi

