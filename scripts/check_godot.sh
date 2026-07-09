#!/usr/bin/env bash
# Verify the Godot project parses and all scripts compile.
# Usage: ./scripts/check_godot.sh [project_dir]
# Exit 0 on success, non-zero on failure.
#
# Uses scripts/empty.tscn as a temporary main scene during --check-only so
# Godot validates scripts/autoloads without loading the full game scene tree
# (some scene formats can trigger headless crashes during check-only).

set -euo pipefail

PROJECT_DIR="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
TIMEOUT_SECS="${GODOT_CHECK_TIMEOUT:-120}"
EMPTY_SCENE="res://scripts/empty.tscn"

if ! command -v godot >/dev/null 2>&1; then
	echo "error: godot not found on PATH (install Godot 4.7+ or set GODOT_BIN)" >&2
	exit 127
fi

GODOT_BIN="${GODOT_BIN:-godot}"
PROJECT_GODOT="$PROJECT_DIR/project.godot"
BACKUP_GODOT=""

if [[ ! -f "$PROJECT_GODOT" ]]; then
	echo "error: no project.godot in $PROJECT_DIR" >&2
	exit 1
fi

if [[ -f "$PROJECT_DIR/.gdignore" ]]; then
	echo "error: .gdignore at project root blocks Godot from opening this folder" >&2
	exit 1
fi

if [[ ! -f "$PROJECT_DIR/scripts/empty.tscn" ]]; then
	echo "error: missing bootstrap scene $EMPTY_SCENE" >&2
	exit 1
fi

restore_project_godot() {
	if [[ -n "$BACKUP_GODOT" && -f "$BACKUP_GODOT" ]]; then
		mv -f "$BACKUP_GODOT" "$PROJECT_GODOT"
	fi
}
trap restore_project_godot EXIT

echo "Checking Godot project: $PROJECT_DIR"
echo "Using: $("$GODOT_BIN" --version 2>&1 | head -1)"

BACKUP_GODOT="$(mktemp)"
cp "$PROJECT_GODOT" "$BACKUP_GODOT"
if grep -q '^run/main_scene=' "$PROJECT_GODOT"; then
	sed -i "s|^run/main_scene=.*|run/main_scene=\"$EMPTY_SCENE\"|" "$PROJECT_GODOT"
else
	printf '\nrun/main_scene="%s"\n' "$EMPTY_SCENE" >> "$PROJECT_GODOT"
fi

LOG="$(mktemp)"
trap 'rm -f "$LOG"; restore_project_godot' EXIT

set +e
timeout "$TIMEOUT_SECS" "$GODOT_BIN" \
	--headless \
	--display-driver headless \
	--audio-driver Dummy \
	--path "$PROJECT_DIR" \
	--check-only \
	--quit \
	>"$LOG" 2>&1
STATUS=$?
set -e

if [[ $STATUS -eq 124 ]]; then
	echo "error: godot --check-only timed out after ${TIMEOUT_SECS}s" >&2
	cat "$LOG" >&2
	exit 124
fi

if grep -E 'Error parsing.*project\.godot|Failed to load script|Failed to instantiate an autoload|SCRIPT ERROR: Parse Error|SCRIPT ERROR: Compile Error|Parse Error:' "$LOG" >/dev/null; then
	echo "Godot check failed:" >&2
	grep -E 'Error parsing.*project\.godot|Failed to load script|Failed to instantiate an autoload|SCRIPT ERROR: Parse Error|SCRIPT ERROR: Compile Error|Parse Error:' "$LOG" | head -40 >&2
	exit 1
fi

if grep -E 'handle_crash: Program crashed' "$LOG" >/dev/null; then
	echo "error: godot crashed during --check-only" >&2
	tail -30 "$LOG" >&2
	exit 134
fi

if [[ $STATUS -ne 0 ]]; then
	echo "Godot exited with status $STATUS" >&2
	cat "$LOG" >&2
	exit "$STATUS"
fi

echo "Godot project check passed."
exit 0
