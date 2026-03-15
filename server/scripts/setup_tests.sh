#!/usr/bin/env bash
# Run this script once to install Go test dependencies and verify tests pass.
# Usage: cd server && bash scripts/setup_tests.sh

set -e

echo "=== Installing test dependencies ==="
go mod tidy

echo ""
echo "=== Running tests ==="
go test ./... -v -count=1 2>&1

echo ""
echo "=== Test coverage ==="
go test ./... -coverprofile=coverage.out 2>&1
go tool cover -func=coverage.out | tail -5
