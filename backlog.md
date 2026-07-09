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


## --- Cycle 68 reflect additions ---

## Theme: compile fixes — get the project to open in Godot 4.7

## Theme: static analysis gaps — class_name on non-autoload scripts not resolving during --check-only

## --- Cycle 77 reflect additions ---

## Critical: PizzaDelivery enemy missing scene file (enemy/PizzaDelivery.tscn) — wave_10 references it, game crashes

## Tower: Dishwasher tower script has no scene file and incomplete melee attack implementation

## Tower: VendingMachine tower script incomplete — doesn't randomize food_type per shot as described in card pool

## Gameplay: craving matching broken — tower food_type strings (e.g. "grease") not converted to enum ints for projectile comparison

## Critical: missing project.godot — project cannot open in Godot without it

## Bug: input_manager.tscn has broken ExtResource ID format (ext1_ instead of ext_)

## Code quality: CardPool.gd duplicates CravingType enum from enums/CravingType.gd

## --- Cycle 81 reflect additions ---

## Theme: cycle 81 — code quality and gameplay mechanics improvements

## Gameplay: craving food_type conversion — CardPool defines tower food_type as strings ("grease", "soup", "spice") but Projectile._apply_craving_effect compares food_type as int against CravingType enum values (GREASE=1, SOUP=2, SPICE=3, PIZZA=4). Need a food_type_to_int() helper that converts food_type strings/int to the matching CravingType enum value so the craving match/mismatch system actually works at runtime.

## Code quality: remove duplicate CravingType enum — card_pool/CardPool.gd (line 4) and card_selection/CardSelection.gd (line 4) each define their own CravingType enum that duplicates enums/CravingType.gd. Replace both with a `const CRAVING_TYPE = preload("res://enums/CravingType.gd")` and reference via `CRAVING_TYPE.GREASE` etc., keeping a single source of truth.

## Code quality: SaveLoad dictionary iteration — TOWER_UNLOCK_MILESTONES and CARD_UNLOCK_MILESTONES are plain dictionaries; GDScript dict iteration order is non-deterministic so tower/card unlock order varies between runs. Replace with sorted arrays or sorted iteration to ensure consistent, deterministic unlock progression.

## --- Cycle 83 reflect additions ---

## Cycle 81 — decomposed into 3 concrete tasks below

## --- Cycle 83 reflect additions ---

## Documentation (orchestrator seed, cycle 83)

## Cycle 87 — autoload and bugfix additions
## --- Cycle 90 PLAN ---

## Bug: starter deck card_type values use wrong enum constant

- [x] Fix starter deck `card_type` in DeckManager.gd to use CardCategory.TOWER (0) instead of STATUS_EFFECT (1) for tower cards — all 5 tower entries (Goblin Fry Cook, Pizza Trebuchet, Soup Spill, Spicy Sauce Cannon, Health Inspector) use `card_type: 1` which maps to STATUS_EFFECT; change to `card_type: 0` matching CardCategory.TOWER from CardPool.gd. Combo Meal already uses card_type: 2 (SPECIAL) which is correct and should not be changed. Acceptance: all tower cards in starter deck use card_type: 0; starter deck size unchanged.

- [x] Fix GameState._apply_room_modifier() to use wave base values for multiplier instead of accumulated state — `wave_gold_reward = int(wave_gold_reward * (1.0 + gold_bonus * 0.01))` multiplies against current (potentially already-modified) wave_gold_reward; should multiply against the wave's base value (from wave resource) instead. Similarly wave_enemy_hp *= and wave_enemy_speed *= compound incorrectly. Store wave base values before applying room modifiers. Acceptance: room modifiers apply multiplicatively against clean wave base values, not against accumulated modifier state; wave_gold_reward baseline resets between room selections.

- [ ] Replace SaveLoad.TOWER_UNLOCK_MILESTONES, CARD_UNLOCK_MILESTONES, and STARTING_GOLD_BONUS_MILESTONES from const Dictionary to const Array of sorted dictionaries — GDScript dict iteration order is non-deterministic so tower/card unlock order varies between runs. Acceptance: milestones iterate in deterministic sorted order (by wave number for gold bonus, by name for towers/cards); functionality unchanged; unlock detection logic still works correctly.

