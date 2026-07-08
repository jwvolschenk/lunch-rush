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

## Critical: missing project config and scene hierarchy

- [x] Add project.godot file — Godot cannot load this project without a valid project.godot with autoloads (GameState, LaneManager, WaveManager, TowerManager, DeckManager, SaveLoad, SoundManager) and physics/rendering settings
- [x] Create Main.tscn scene hierarchy — Main.tscn exists but only has 27 lines; needs root Node2D with LaneManager (with 3-4 Lane children + dividers), TowerManager child, WaveManager child, HUD.tscn, CardSelection.tscn, RoomSelector.tscn, GameOverOverlay.tscn, CameraController.tscn, and InputManager child wired up as a proper scene tree

## Critical: runtime bugs

- [x] Fix Tower.gd _fire() using non-existent add_sibling() — Tower.gd line calls `add_sibling(projectile)` which does not exist in GDScript; replace with `add_child(projectile)` to fix tower attacks crashing at runtime
- [x] Fix GameState room modifier stacking — _apply_room_modifier() in GameState.gd accumulates modifiers permanently (+= on enemy_count, *= on enemy_hp/speed) with no reset; add _reset_room_modifiers() called between waves so each room choice starts from baseline

## Core gameplay polish: wave progress bar

- [x] Add wave progress bar to HUD — display remaining enemies in current wave as a filled bar under the enemy count label; fills from right to left as enemies are defeated; shows "Wave X/Y" title above it

## Core gameplay polish: enemy death feedback

- [x] Add enemy death visual feedback — spawn floating +gold and +score labels at the death position (reuse FloatingLabel), add a brief screen flash (0.05s yellow at 0.3 alpha) on damage, add enemy squish animation (scale Y 0→0.1→0 over 0.3s) before queue_free()

## Missing tower: PizzaTrebuchet projectile

- [x] Add fire_pie.tscn / FirePieProjectile.gd scene for PizzaTrebuchet tower — PizzaTrebuchet.gd references "res://projectile/fire_pie.tscn" but fire_pie.tscn exists as a scene without a corresponding .gd script; add FirePieProjectile.gd extending Projectile with splash_radius=80, speed=300, damage=8, SPICE food type, red-orange sprite, and splash radius visual

## Gameplay mechanic: SpicySauceCannon burn DoT

- [ ] Add burn damage-over-time to SpicySauceCannon — modify Projectile._apply_craving_effect() to also apply a burn DoT (1 damage/sec for 3 seconds) when hitting with SPICE food type; add _burn_timer and _burn_damage fields to Enemy.gd; display a small flame icon on burning enemies

## Gameplay mechanic: HealthInspector pushback on hit

- [ ] Add Health Inspector pushback effect on hit — currently Health Inspector's projectile just deals 1 damage; add pushback=200 to its projectile so enemies are pushed backward 200px toward spawn on hit (pushback already exists in Enemy.gd as apply_pushback() but nothing triggers it)

## UI polish: wave countdown timing fix

- [ ] Fix wave countdown countdown phase logic — WaveManager._process() phase calculation uses > 2.0/ > 1.0 checks which are wrong for a 3-second countdown (should show 3, 2, 1 then hide); fix to use >= comparisons: > 2.0=3, > 1.0=2, > 0.0=1, else=0 then hide

## Meta-progression: unlock display between waves

- [ ] Show new unlocks before room selector — after card selection, if new towers/cards were unlocked during the run, show a brief "New Unlocks" overlay between card selection and room selection; list new towers in a scrollable panel with "PERK UNLOCKED" header and fade out after 2 seconds
