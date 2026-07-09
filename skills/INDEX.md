# Skill Index

Reusable artifacts produced across cycles.

## Godot verification (required before DONE:)

Two-step gate — both must pass (`SOLO_AGENT.md`, `GODOT_MCP.md`):

| Step | Script / tool | Purpose |
|---|---|---|
| 1. Compile | `./scripts/check_godot.sh` | Parse/compile check (`--check-only`) |
| 2. Runtime | godot-mcp `run_project` + `get_debug_output` + `stop_project` | Catch autoload `_ready`, missing resources, signal bugs |
| 2 fallback | `./scripts/runtime_smoke_godot.sh` | Headless runtime smoke when MCP unavailable |
| Both | `./scripts/verify_godot.sh` | Runs step 1 + step 2 fallback in one command |

**Typical fix cycle:** `get_debug_output()` → `codedb_outline`/`codedb_read` → fix → `./scripts/verify_godot.sh`

## Godot compile check

- **Script:** `scripts/check_godot.sh`
- **Purpose:** Verify `project.godot` parses and all GDScript compiles (`godot --check-only`)
- **Usage:** `./scripts/check_godot.sh` (requires Godot 4.7+ on `PATH`, or set `GODOT_BIN`)
- **Notes:** Temporarily swaps main scene to `scripts/empty.tscn` to avoid headless crashes; restores `project.godot` on exit.
