# Backlog

# Tasks the solo-agent loop works through. Each cycle: the reflect
# phase regenerates candidates, the plan phase structures them here,
# the execute phase picks the next unchecked item as a goal.


# --- Cycle 4 reflect additions ---

# Phase: scaffold the project toward the Godot game goal


# --- Cycle 5 reflect additions ---

## Theme: core gameplay loop — make a minimally playable demo


DONE: 12 tasks — core gameplay loop: game state, lanes, towers, enemies, waves, cards, cravings, gold economy, camera

# --- Cycle 6 reflect additions ---

## Theme: core gameplay entities — enemies, towers, wave management

# --- Cycle 7 reflect additions ---

# Phase: bridge infrastructure to gameplay — add what's missing between the scaffolding and the backlog items

## Theme: TowerManager, projectiles, and visual polish


DONE: 2 tasks — TowerManager (tower placement/lifecycle), Projectile base class (tower attacks)

# --- Cycle 8 reflect additions ---

## Theme: wiring infrastructure into playable game — scene hierarchy, input, wave data, cards


DONE: 6 tasks — WaveManager with wave data, card data model, input system, Main.tscn wiring, gold HUD, Goblin Fry Cook tower

# --- Cycle 9 reflect additions ---

## Theme: card selection, wave flow, game-over, and craving mechanic


DONE: 5 tasks — card selection UI, wave-complete flow, player deck system, game-over overlay, craving mechanic

# --- Cycle 10 reflect additions ---

## Theme: genuinely missing systems from GOAL.md scope — enemy variety, rooms, card pool, extra towers, combo mechanic


## Theme: cycle 10 — bridge the gap between infrastructure and playable gameplay


# --- Cycle 3 reflect additions ---

## Theme: bridge infrastructure to playable game


# --- Cycle 11 reflect additions ---

## Theme: quality-of-life systems and missing GOAL.md towers

# --- Cycle 29 reflect additions ---

## Theme: fill the gap between GOAL.md scope and current implementation

# --- Cycle 33 reflect additions ---

## Theme: fix unreachable room selector, hook save system, and add missing enemy

# --- Cycle 36 reflect additions ---

## Theme: core gameplay polish — make the game actually fun and complete

## Theme: missing GOAL.md content — towers, waves, and visual polish

## Theme: cycle 41 — polish and bugfixes toward a genuinely playable game

## Theme: cycle 44 — missing entry point and reward feedback

## Theme: cycle 46 — core gameplay polish and UX fixes

# --- Cycle 49 reflect additions ---

## Theme: meta-progression, audio polish, wave completion, and bugfixes

# --- Cycle 53 reflect additions ---

## Theme: critical fixes, quality-of-life, and gameplay polish

## Critical: missing preload and broken resource paths

## Critical: Tower base class blocks child per-frame logic

## Core gameplay: wave end condition

## Core gameplay: Tower._fire projectile parent

## Core gameplay: first room selector

## Card system: dead code and disconnected hand

## Polish: audio assets
## Core gameplay: EnemyData preload path

## Critical: missing project config and scene hierarchy


## Critical: runtime bugs


## Core gameplay polish: wave progress bar


## Core gameplay polish: enemy death feedback


## Missing tower: PizzaTrebuchet projectile


## Gameplay mechanic: SpicySauceCannon burn DoT


## Gameplay mechanic: HealthInspector pushback on hit


## UI polish: wave countdown timing fix


## Meta-progression: unlock display between waves

## --- Cycle 63 reflect additions ---

## Theme: audio polish — wire up missing game sound effects

## --- Cycle 67 reflect additions ---

## Critical: missing variable and dead code

## Critical: wave sorting bug (alphabetical instead of numeric)

## Critical: Tower._process not called by subclasses (towers can't attack)

## Critical: missing lane_count property in TowerManager

## Core gameplay: Tower proactive re-targeting

## Core gameplay: connect _on_wave_complete to WaveManager

## --- Cycle 69 reflect additions ---

- [x] Critical: Open and compile in Godot 4.7 (directive d4)
- [x] Critical: declare _next_wave_ready variable in main.gd
- [x] Critical: fix WaveConfigLoader wave sort order (numeric not alphabetical)
- [x] Critical: Tower._process — child classes override without calling super() (already done: no child class overrides _process, so no super() call needed)
- [x] Critical: fix TowerManager missing lane_count property
- [x] Core gameplay: Tower proactive re-targeting (re-evaluate target each fire tick)
- [x] Core gameplay: connect _on_wave_complete signal to WaveManager.wave_complete
- [x] Core gameplay: enemy death visual feedback (hit flash + screen shake)
- [x] Core gameplay: craving indicator visibility (enlarged ring + glow pulse)
- [x] Core gameplay: continue button on main menu (from game over screen)
- [x] Core gameplay: victory overlay receives unlock data from GameState

## --- Cycle 68 reflect additions ---

## Theme: compile fixes — get the project to open in Godot 4.7

## Theme: static analysis gaps — class_name on non-autoload scripts not resolving during --check-only

- [x] Critical: fix "class_name hides autoload" in CameraController.gd, CardSelection.gd, RoomSelector.gd, GameOverOverlay.gd (already done in cycle 72 — class_name removed from all 4 autoload scripts)
- [x] Critical: fix WaveConfigLoader autoload not resolving during static analysis (autoload methods resolved as GDScriptNativeClass) — fixed by correcting Godot 3→4 API: `ResourceLoader.exists()` → `ResourceLoader.resource_exists()`; `class_name` cannot be used on autoload scripts in Godot 4.x
- [ ] Critical: fix RoomData type not found in RoomSelector.gd (extends Resource, add preload in RoomSelector.gd)
- [ ] Critical: fix "Only identifier can be assignment target" in GameOverOverlay.gd:65 (syntax error)
- [ ] Core gameplay: fix all remaining ext_resource ID mismatches across .tscn scene files
- [ ] Core gameplay: fix Scene parent references using IDs instead of names in packed scene format
- [ ] Core gameplay: ensure all scene files have consistent ext_resource format (quoted string IDs)
- [ ] Polish: add placeholder art to towers, enemies, and rooms for visual feedback during development
