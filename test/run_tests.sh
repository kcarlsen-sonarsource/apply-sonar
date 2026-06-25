#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

BATS="$SCRIPT_DIR/bats/bats-core/bin/bats"

if [[ ! -x "$BATS" ]]; then
    echo "ERROR: bats not found at $BATS" >&2
    echo "Run: git submodule update --init --recursive" >&2
    exit 1
fi

cd "$PROJECT_ROOT"

echo "Running BATS tests..."
echo "======================================"

"$BATS" --tap "$SCRIPT_DIR"/test_*.bats
