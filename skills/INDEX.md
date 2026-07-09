# Skill Index

Reusable artifacts produced across cycles.

## Godot compile check

- **Script:** `scripts/check_godot.sh`
- **Purpose:** Verify `project.godot` parses and all GDScript compiles (`godot --check-only`)
- **Usage:** `./scripts/check_godot.sh` (requires Godot 4.7+ on `PATH`, or set `GODOT_BIN`)
- **Notes:** Temporarily swaps main scene to `scripts/empty.tscn` to avoid headless crashes; restores `project.godot` on exit.
