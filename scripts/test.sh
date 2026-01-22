#!/bin/bash
set -e

# Rust Test Runner
# Run unit tests, integration tests, and doc tests

echo "🧪 Running Rust tests..."

# Library tests
echo "📚 Library tests:"
cargo test --lib --message-format=short "$@"

# Doc tests
echo "📖 Documentation tests:"
cargo test --doc --message-format=short "$@"

# Integration tests (if any)
if [ -d "tests" ]; then
    echo "🔗 Integration tests:"
    cargo test --test '*' --message-format=short "$@"
fi

echo "✅ All tests passed!"

