#!/usr/bin/env bash
# Runtime smoke test — headless fallback when godot-mcp is unavailable.
# Launches the project's main scene briefly and fails on SCRIPT ERROR / ERROR.
# Prefer godot-mcp run_project + get_debug_output when MCP is connected.
#
# Usage: ./scripts/runtime_smoke_godot.sh [project_dir]
# Exit 0 on success, non-zero on failure.

set -euo pipefail

PROJECT_DIR="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
TIMEOUT_SECS="${GODOT_RUNTIME_TIMEOUT:-12}"
GODOT_BIN="${GODOT_BIN:-godot}"

if ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
	echo "error: godot not found on PATH" >&2
	exit 127
fi

MAIN_SCENE="$(grep -E '^run/main_scene=' "$PROJECT_DIR/project.godot" | sed 's/^run\/main_scene="\(.*\)"/\1/' || true)"
if [[ -z "$MAIN_SCENE" ]]; then
	echo "error: run/main_scene not set in project.godot" >&2
	exit 1
fi

echo "Runtime smoke test: $PROJECT_DIR"
echo "Scene: $MAIN_SCENE"
echo "Using: $("$GODOT_BIN" --version 2>&1 | head -1)"

LOG="$(mktemp)"
trap 'rm -f "$LOG"' EXIT

set +e
timeout "$TIMEOUT_SECS" "$GODOT_BIN" \
	--headless \
	--display-driver headless \
	--audio-driver Dummy \
	--path "$PROJECT_DIR" \
	--scene "$MAIN_SCENE" \
	>"$LOG" 2>&1
STATUS=$?
set -e

if grep -E 'handle_crash: Program crashed' "$LOG" >/dev/null; then
	echo "Runtime smoke test failed: godot crashed" >&2
	tail -30 "$LOG" >&2
	exit 134
fi

if grep -E 'SCRIPT ERROR:|^ERROR:' "$LOG" >/dev/null; then
	echo "Runtime smoke test failed — errors in output:" >&2
	grep -E 'SCRIPT ERROR:|^ERROR:' "$LOG" | sort -u | head -40 >&2
	echo >&2
	echo "Use godot-mcp (see GODOT_MCP.md) for interactive debug: run_project → get_debug_output → fix → stop_project" >&2
	exit 1
fi

if [[ $STATUS -eq 124 ]]; then
	# Timeout is expected — game loop keeps running; we only care about startup errors.
	echo "Runtime smoke test passed (no startup errors within ${TIMEOUT_SECS}s)."
	exit 0
fi

echo "Runtime smoke test passed."
exit 0
