# CODEDB.md — Code Navigation for Lunch Rush

Godot 4.7 roguelite deckbuilder tower defence (`Dungeon Deli`). OpenCode auto-loads
this file every session via `.opencode/opencode.json`.

**Index root:** `/home/jwvolschenk/repos/games/lunch-rush`  
**Re-index:** `codedb index .` or MCP `codedb_index` after large refactors or
`.codedbignore` changes. Snapshot: `codedb.snapshot` at project root.

## Tool cheat sheet

| Tool | When to use |
|---|---|
| `codedb_outline` | **Always first** on a `.gd` file — main.gd is 560+ lines |
| `codedb_symbol` | Jump to `class_name` defs (`CravingType`, `CardPool`, `Tower`, `Lane`) |
| `codedb_word` | Trace enum/type usage (`CravingType`, `CardType`, `food_type`) |
| `codedb_callers` | Who references a function or type (limited for autoload globals) |
| `codedb_deps` | Blast radius before editing a script or scene |
| `codedb_search` | Substring search (e.g. `check-only`, `tower_scene`, `craving`) |
| `codedb_query` | Chain ops: `[{"op":"word","word":"place_tower"},{"op":"read","context_lines":3}]` |
| `codedb_hot` | Recently touched files — good after another cycle's commits |

Prefer codedb over grep: `.codedbignore` excludes binaries, audio, and agent
workflow markdown so hits stay in game source.

## Architecture at a glance

```
MainMenu.tscn  →  Main.tscn + main.gd  (game loop hub)
                      ├─ lane/          lanes, spawn markers
                      ├─ tower/         tower scenes + Tower.gd base
                      ├─ enemy/         Enemy.gd + per-type subclasses + EnemyData *.tres
                      ├─ projectile/    Projectile.gd + food-type variants
                      ├─ wave/          WaveManager.gd, WaveConfigLoader.gd
                      ├─ waves/         wave_1.tres … wave_20.tres
                      ├─ card_pool/     Card.gd model + CardPool.gd + card scripts
                      ├─ card_selection/ post-wave card picker UI
                      ├─ rooms/         RoomData.gd + room_*.tres + RoomSelector
                      └─ UI overlays    HUD, game_over/, victory/, unlocks/
```

**Autoloads** (see `project.godot` `[autoload]` — globals, not found via callers):

| Singleton | Role |
|---|---|
| `GameState` | Score, health, gold, wave counters, room modifiers, game mode |
| `WaveManager` | Wave spawn queue, countdown, enemy lifecycle signals |
| `CardPool` | Card definitions, weighted draw, tower placement tracking |
| `DeckManager` | Deck / hand / discard, starter deck |
| `TowerManager` | Place towers on lanes |
| `LaneManager` | Lane layout, enemy lists per lane |
| `SaveLoad` | Persist unlocks, high scores |
| `SoundManager` | SFX/music buses |
| `InputManager` | Input state machine |
| `HUD` | In-run UI |

## Entry points (read these first)

| File | Why |
|---|---|
| `project.godot` | Main scene, autoload list, input actions, engine version |
| `main.gd` | **Central orchestrator** — wires signals, card/room flow, wave hooks |
| `GameState.gd` | Run state, room modifiers, victory/game-over signals |
| `wave/WaveManager.gd` | Spawning, wave completion, card-selection handoff |
| `enemy/Enemy.gd` | Movement, damage, **craving** display and debuff logic |
| `tower/Tower.gd` | Targeting, firing, `food_type` on projectiles |
| `projectile/Projectile.gd` | Damage, splash, `_apply_craving_effect` |
| `card_pool/CardPool.gd` | All card definitions (~300 lines) — outline before read |
| `card_pool/Card.gd` | `CardType` enum — canonical card data model |
| `enums/CravingType.gd` | **Single source** for craving ints + `food_type_to_int()` |
| `DeckManager.gd` | `_get_starter_deck()` — starter cards (prefer over `main._get_starter_cards`) |
| `rooms/RoomData.gd` + `rooms/room_*.tres` | Room modifiers (should match `main._get_room_choices`) |

Scenes (`.tscn`) are indexed for structure; **logic lives in sibling `.gd` files**.

## Navigation patterns

### Implementing a gameplay feature

1. `codedb_outline main.gd` — find the handler (`_on_card_selected`, `_on_wave_complete`, …)
2. `codedb_word` the signal or method name to see autoload call sites
3. `codedb_outline` on the subsystem file (`tower/`, `enemy/`, `card_pool/`)
4. `codedb_read` only the line range you need

### Adding a tower or enemy

- **Tower:** copy pattern from `tower/GoblinFryCook.gd` + `.tscn`, register card in `CardPool.gd` `all_cards`
- **Enemy:** `enemy/EnemyData.gd` resource + `enemy/EnemyData_*.tres` + thin subclass `.gd`
- `codedb_symbol Tower` / `codedb_symbol Enemy` for base-class APIs

### Craving / food-type bugs

Canonical enum: `enums/CravingType.gd` with `food_type_to_int()`.

```
codedb_word CravingType path_glob=**/*.gd
```

Known pitfall: `projectile/Projectile.gd` `food_type` must match enemy craving
ints (GREASE=1, SOUP=2, …). String `"grease"` must go through `food_type_to_int()`.
Do **not** re-declare `CravingType` in `CardPool.gd` or `CardSelection.gd`.

### Card / deck changes

- Card model: `card_pool/Card.gd` (`CardType.TOWER`, `STATUS_EFFECT`, `SPECIAL`)
- Pool weights: `card_pool/CardPool.gd`
- Hand state: `DeckManager.gd`
- UI: `card_selection/CardSelection.gd`
- **Duplication alert:** `main._get_starter_cards()` vs `DeckManager._get_starter_deck()` — consolidate into DeckManager

### Room / wave data

- Wave configs: `waves/wave_N.tres` (indexed); loader: `wave/WaveConfigLoader.gd`
- Room resources: `rooms/room_*.tres`
- Runtime room pick: `main._get_room_choices()` — verify values match `.tres` files

### UI / overlays

`HUD.gd`, `game_over/GameOverOverlay.gd`, `victory/VictoryOverlay.gd`, `unlocks/UnlocksOverlay.gd` — each pairs `.gd` + `.tscn`.

## Verification

No orchestrator verify gate — agent owns checks:

```bash
# Preferred: compile/parse check (uses scripts/empty.tscn bootstrap; restores project.godot)
./scripts/check_godot.sh

# Manual equivalent
godot --headless --path . --check-only --quit
```

**Opening in editor:** requires `project.godot` at repo root and **no** `.gdignore` in the root (that file tells Godot to ignore the folder). Use Godot 4.7+.

`project.godot` must use Godot 4 `Object(InputEventKey,...)` input format — Godot 3 `InputActionEvent` syntax prevents the editor from loading the project. Scene files must use path-based `parent="."` / `parent="VBox"` node refs; numeric `parent=1` crashes Godot 4.7 headless.

Backlog tasks often cite `--check-only` as acceptance criteria. Some runtime `SCRIPT ERROR` lines during autoload `_ready` are expected in headless check; the script only fails on parse/compile errors.

## Gotchas

| Topic | Detail |
|---|---|
| **Indexed** | `*.gd`, `*.tscn`, `*.tres`, `project.godot` |
| **Not indexed** | `.godot/`, `*.import`, `*.gd.uid`, `audio/`, images, agent workflow md |
| **Autoloads** | Used as bare globals (`GameState.add_gold`) — `codedb_callers` may show 0 hits |
| **main.gd size** | 30+ functions — never read whole file; outline → targeted read |
| **Scene IDs** | `.tscn` `ext_resource` ID typos break loads — search filename in scenes |
| **Scene parents** | Use `parent="."` / `parent="VBox"` — numeric `parent=1` crashes Godot 4.7 |
| **`.gdignore`** | A root `.gdignore` prevents Godot from recognizing the project folder |
| **Enum drift** | Use `preload("res://enums/CravingType.gd")` and `preload("res://card_pool/Card.gd")` |
| **Room data** | Hardcoded `main._get_room_choices()` may drift from `rooms/room_*.tres` |
| **Audio** | `audio/` excluded from index; `SoundManager` paths won't appear in codedb_search |

## Active backlog hotspots (cycle 98+)

When picking up pending tasks, start here:

- `main._get_starter_cards()` → consolidate into `DeckManager`
- `main._get_room_choices()` → load from `rooms/room_*.tres`
- `SoundManager` — missing audio file warnings at startup
- Magic `card_type` literals → `Card.CardType` enum constants

---

**Maintainers:** update this file when you learn new navigation shortcuts or fix
structural issues. Humans can queue a `directives.md` entry to review and improve
it. Keep edits concise — every line loads every session.
