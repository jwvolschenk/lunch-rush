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

- [x] Audio: play enemy_death SFX in Enemy._on_death() — enemy_death.wav exists but is never called

- [x] Audio: play tower_place SFX in TowerManager.place_tower() — tower_place.wav exists but is never called

- [ ] Audio: play hit SFX in Projectile._hit() — hit.wav exists but is never called on projectile impact

- [ ] Audio: play background music at game start — GameState.start_run() should call SoundManager.play_music("background")

- [ ] Audio: wire tower fire SFX in Tower._fire() — sfx_name is set per-tower but never played from Tower base

- [ ] Fix: GoblinFryCook missing food_type (defaults to 0 = no craving effect on grease projectiles)

- [ ] Fix: undeclared `_pending_unlocks` variable in main.gd (used at lines 157, 159, 480 without `var` declaration)

- [ ] Feature: wire victory overlay unlock data — victory_overlay.show_victory() doesn't receive unlocks (6th param is always default)
