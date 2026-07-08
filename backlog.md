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
- [x] Fix WaveManager.gd missing WaveConfig preload (get_wave returns WaveConfig type without preload)

## Critical: Tower base class blocks child per-frame logic
- [x] Make Tower._process virtual / document super._process requirement for child tower scripts

## Core gameplay: wave end condition
- [x] Add wave 20 victory condition (game over screen with victory message instead of endless waves)

## Core gameplay: Tower._fire projectile parent
- [x] Fix Tower._fire: get_parent() is TowerManager, not a Lane — projectiles spawn in wrong node tree

## Core gameplay: first room selector
- [x] Ensure first wave triggers room selector (start_run sets Pantry directly, bypasses room selector)

## Card system: dead code and disconnected hand
- [x] Remove dead Card.apply_effect / from_dict methods (CardPool uses dictionary dispatch, never calls them)
- [x] Wire DeckManager hand into HUD or card selection UI (hand exists but has no visual representation)

## Polish: audio assets
- [x] Add placeholder audio assets (SFX for tower fire, wave complete, enemy death, card pick)
- [x] Fix SoundManager.sfx_paths to use existing files or add placeholder audio
## Core gameplay: EnemyData preload path
- [ ] Fix WaveManager._generate_default_waves: preload("res://enemy/EnemyData.gd") should be "res://enemy/EnemyData_HungryGoblin.tres"

## Critical: missing project config and scene hierarchy


## Critical: runtime bugs


## Core gameplay polish: wave progress bar


## Core gameplay polish: enemy death feedback


## Missing tower: PizzaTrebuchet projectile


## Gameplay mechanic: SpicySauceCannon burn DoT


## Gameplay mechanic: HealthInspector pushback on hit


## UI polish: wave countdown timing fix


## Meta-progression: unlock display between waves
