# GODOT_MCP.md — Godot MCP Server for Lunch Rush

External-process MCP server (`@coding-solo/godot-mcp`) that launches, runs, and
debugs Godot from OpenCode. Paired with codedb for code navigation — use both.

**Server:** `npx -y @coding-solo/godot-mcp` (stdio, configured in `.opencode/opencode.json`)
**Project path:** `/home/jwvolschenk/repos/games/lunch-rush`
**Godot binary:** `/usr/local/bin/godot` (set via `GODOT_PATH`)

## Verification gate (required every cycle)

Agents must pass **both** checks before marking work done (`SOLO_AGENT.md` rule 7):

| Step | Tool | What it catches |
|---|---|---|
| 1. Compile | `./scripts/check_godot.sh` | Parse errors, missing scripts, bad `project.godot` |
| 2. Runtime | `run_project` + `get_debug_output` | Autoload `_ready` failures, missing resources, signal bugs |

```
./scripts/check_godot.sh
run_project(projectPath="/home/jwvolschenk/repos/games/lunch-rush")
get_debug_output()
stop_project()
```

`get_debug_output()` must be free of `SCRIPT ERROR` and `ERROR` lines caused by
the current codebase state. Warnings are acceptable unless they indicate a broken
feature. Fix → re-run both steps until clean.

Fallback (no MCP): `./scripts/runtime_smoke_godot.sh`

## Tool cheat sheet

| Tool | When to use | Key params |
|---|---|---|
| `get_godot_version` | Confirm Godot version before deep work | none |
| `get_project_info` | First look at project metadata (autoloads, main scene, settings) | `projectPath` |
| `list_projects` | Find Godot projects in a directory tree | `directory`, `recursive` |
| `launch_editor` | Open the project in the Godot editor (headless not useful here) | `projectPath` |
| `run_project` | Run the game and capture stdout/stderr output | `projectPath`, `scene?` |
| `get_debug_output` | Fetch latest debug/error output from a running instance | none |
| `stop_project` | Stop a running game instance | none |
| `create_scene` | Create a new `.tscn` file programmatically | `projectPath`, `scenePath`, `rootNodeType?` |
| `add_node` | Add a node to an existing scene | `projectPath`, `scenePath`, `parentNodePath`, `nodeType`, `nodeName` |
| `load_sprite` | Assign a texture to a Sprite2D node | `projectPath`, `scenePath`, `nodePath`, `texturePath` |
| `save_scene` | Persist scene changes (or save as variant) | `projectPath`, `scenePath`, `newPath?` |
| `export_mesh_library` | Export scene as MeshLibrary resource | `projectPath`, `scenePath`, `outputPath` |
| `get_uid` | Get UID for a file (Godot 4.4+) | `projectPath`, `filePath` |
| `update_project_uids` | Resave resources to fix UID references | `projectPath` |

## Workflow: Debug and fix errors

This is the primary use case. Follow this sequence:

### 1. Run the project and capture output

```
run_project(projectPath="/home/jwvolschenk/repos/games/lunch-rush")
```

This launches the game headless and streams errors, warnings, and script
failures to the MCP output. For a specific scene:

```
run_project(projectPath="...", scene="res://Main.tscn")
```

### 2. Read the debug output

```
get_debug_output()
```

Call this after `run_project` to get accumulated errors. Look for:
- `SCRIPT ERROR` — parse/runtime GDScript failures (line + file + message)
- `ERROR` — engine-level failures (missing resources, bad node paths)
- `WARNING` — deprecations, missing properties, type mismatches

### 3. Navigate to the error with codedb

Use codedb to find and read the failing code:

```
codedb_outline("wave/WaveManager.gd")       # find the function
codedb_read("wave/WaveManager.gd", 45, 60)   # read the error line range
codedb_word("on_enemy_killed")               # trace the call chain
```

### 4. Fix the code (edit tools or direct file write)

Make the fix, then re-run to verify:

```
run_project(projectPath="...")
get_debug_output()
```

### 5. Stop when done

```
stop_project()
```

## Workflow: Validate after a refactor

```
run_project(projectPath="/home/jwvolschenk/repos/games/lunch-rush")
get_debug_output()    # check for new SCRIPT ERRORs
stop_project()
```

Also run the compile check for static validation:

```bash
./scripts/check_godot.sh
# or: godot --headless --path . --check-only --quit
```

`run_project` catches runtime errors that `--check-only` misses (autoload
_ready failures, signal wiring, missing resources at load time).

## Workflow: Scene authoring

The MCP tools can create scenes and add nodes programmatically. Useful for
scaffolding, but prefer editing `.tscn` files directly for complex scenes
(the text format is more precise).

```
create_scene(projectPath="...", scenePath="res://tower/NewTower.tscn", rootNodeType="Node2D")
add_node(projectPath="...", scenePath="res://tower/NewTower.tscn", parentNodePath="root", nodeType="Sprite2D", nodeName="Sprite")
add_node(projectPath="...", scenePath="res://tower/NewTower.tscn", parentNodePath="root", nodeType="CollisionShape2D", nodeName="Hitbox")
save_scene(projectPath="...", scenePath="res://tower/NewTower.tscn")
```

**Important:** `add_node` only accepts simple class identifiers (e.g.
`Sprite2D`, `Area2D`). Paths like `res://evil.gd` are rejected for security.

## Workflow: UID management (Godot 4.4+)

After renaming or moving files, UIDs can desync:

```
get_uid(projectPath="...", filePath="res://enemy/Enemy.gd")
update_project_uids(projectPath="...")
```

## Combining godot-mcp + codedb

The two servers complement each other:

| Task | codedb | godot-mcp |
|---|---|---|
| Find where a function is defined | `codedb_symbol` | — |
| Trace who calls a function | `codedb_callers` | — |
| Check blast radius before editing | `codedb_deps` | — |
| Run the game and see runtime errors | — | `run_project` + `get_debug_output` |
| Validate a fix works | — | `run_project` |
| Create/scaffold scenes | — | `create_scene` + `add_node` |
| Recently changed files | `codedb_hot` | — |

**Typical fix cycle:**
1. `get_debug_output()` — see the error
2. `codedb_outline` + `codedb_read` — find the code
3. Make the fix
4. `run_project` + `get_debug_output()` — verify

## Gotchas

| Topic | Detail |
|---|---|
| **Headless only** | This MCP server runs Godot headless — no GUI, no rendering. Visual bugs need the editor. |
| **projectPath required** | Almost every tool needs the full project path. Use `/home/jwvolschenk/repos/games/lunch-rush`. |
| **scene paths** | Scene paths in `run_project` use `res://` format (e.g. `res://Main.tscn`). |
| **Run + get_debug_output** | `run_project` starts the game; call `get_debug_output()` separately to read accumulated output. |
| **stop_project** | Always stop a running project before starting another or before finishing work. |
| **Autoload errors** | Autoload `_ready` errors appear at runtime in `get_debug_output()` but not in `--check-only`. |
| **Node type validation** | `add_node`/`create_scene` reject anything that isn't a simple identifier (no paths, no dots). |
| **npx cold start** | First `run_project` call may be slow while npx downloads the package. Subsequent calls are instant. |

---

**Maintainers:** update this file when godot-mcp adds new tools or when
project-specific workflows are discovered. Keep it concise — every line loads
every OpenCode session.
