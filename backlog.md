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

## --- Cycle 94 PLAN: dependency and tooling freshness ---

## --- Cycle 98 PLAN: backlog candidates decomposed ---

## Bug: starter deck card_type uses magic numbers instead of enum

## Bug: _get_starter_cards() card_type literals (1, 1, 2) don't match _get_starter_deck() types (0, 0, 0, 0, 0, 2, 3) — inconsistent tower vs status classification

## Design: room data hardcoded in _get_room_choices() doesn't match room_*.tres files — gameplay modifiers differ between code and resource files

## Design: SoundManager has no pre-flight audio validation — missing audio files silently break SFX/music at runtime with no developer feedback

- [x] (cycle 98) Fix magic number literals in main.gd._get_starter_cards() and DeckManager.gd._get_starter_deck(): replace hardcoded card_type integers (1, 2, 3) with CardType enum constants from preload("res://card_pool/Card.gd") — acceptance: all card_type values in both functions use CardType.TOWER, CardType.STATUS_EFFECT, or CardType.SPECIAL; game compiles with --check-only; no change to card behavior
- [ ] (cycle 98) Consolidate _get_starter_cards() from main.gd into DeckManager.gd._get_starter_deck(): remove the duplicate starter card definition in main.gd, have main.gd call DeckManager.get_starter_cards() instead, and ensure the combined deck contains all 7 starter cards (5 tower + Combo Meal + Emergency Ration) — acceptance: _get_starter_cards() removed from main.gd, game still shows correct 3 starter cards at start, Godot --check-only passes
- [ ] (cycle 98) Replace hardcoded room data in main.gd._get_room_choices() with loading from res://rooms/room_*.tres resource files: for each of the 5 rooms (Pantry, Freezer, Lava Kitchen, VIP Table, Cursed Buffet), load the corresponding .tres via load() and merge its RoomData fields — acceptance: no hardcoded enemy_hp_modifier/enemy_speed_modifier/gold_bonus values remain in _get_room_choices(); output RoomData matches the .tres file values exactly; game compiles clean
- [ ] (cycle 98) Add pre-flight audio validation in SoundManager._ready(): after _load_folder() completes, enumerate all known audio file paths from game code (search for all load() calls referencing res://audio/ in .gd files), compare against loaded streams, push push_warning for each missing file, and log a summary count — acceptance: warnings appear at startup for any missing audio files; game still runs with no audio (graceful degradation); no crashes when audio folder is empty or missing
