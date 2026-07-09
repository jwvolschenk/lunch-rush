#!/usr/bin/env bash
# Full Godot verification: compile check + runtime smoke test.
# OpenCode agents with godot-mcp should also run MCP step 2 manually — see GODOT_MCP.md.
#
# Usage: ./scripts/verify_godot.sh [project_dir]
# Exit 0 only when both steps pass.

set -euo pipefail

PROJECT_DIR="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Step 1/2: compile check ==="
"$SCRIPT_DIR/check_godot.sh" "$PROJECT_DIR"

echo
echo "=== Step 2/2: runtime smoke test ==="
if [[ "${SKIP_RUNTIME:-}" == "1" ]]; then
	echo "SKIP_RUNTIME=1 — skipping runtime smoke test."
	echo "Run godot-mcp manually: run_project → get_debug_output → stop_project (GODOT_MCP.md)"
	exit 0
fi

"$SCRIPT_DIR/runtime_smoke_godot.sh" "$PROJECT_DIR"

echo
echo "All verification steps passed."
echo "OpenCode agents: also confirm via godot-mcp get_debug_output() when MCP is connected."
