#!/usr/bin/env bash
set -euo pipefail

# Backward-compatible entry point for the installer contract test.
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
exec bash "$SCRIPT_DIR/test-local-install.sh"
