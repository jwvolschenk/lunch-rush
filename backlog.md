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

- [x] Implement meta-progression: add a persistent unlock system between runs (store unlocked tower variants, card variants, starting gold bonus in SaveLoad.json). After game-over, show "Unlocks" panel with earned perks. Unlock new towers at wave milestones (e.g., unlock Pizza Trebuchet at wave 3, Soup Spill at wave 5).

- [ ] Fix KitchenUpgradeCard timer leak: replace `get_tree().create_timer()` with a proper `Timer` node child. The current approach creates an auto-deleting SceneTreeTimer that can fire after the card's reference is cleared, causing null crashes when the timer's timeout fires on a freed object.

- [ ] Add PizzaDelivery enemy to waves 10-15: currently PizzaDelivery.tres exists in enemy/ but is not referenced in any wave config. Add it to waves 10, 13, 14, 15 as a late-game threat (fast, moderate HP, moderate gold).

- [ ] Add tower attack SFX: have each tower's projectile play its own SFX on fire via SoundManager. Wire up `SoundManager.play_sfx("tower_fire_<type>")` in each projectile's `_process` or `fire()` method. Use existing sfx files or add new ones for tower types.

- [ ] Add wave completion SFX: when a wave completes, play a satisfying SFX via SoundManager and briefly flash the HUD with a "Wave Complete!" notification that fades out.

- [ ] Fix EmergencyRationCard health cap: the card currently caps at 20 HP (`min(new_health, 20)`) but GameState health can start at 30. Fix to use `GameState.max_health` or a configurable cap (e.g., `min(new_health, 30)` or `game_state.max_health`).

- [ ] Add player-driven craving system: enemies should have their craving type displayed as a visible icon (not just a colored dot), and the card selection UI should show which food type each pending card's projectile will use, so the player can strategically match cravings.

- [ ] Add new wave configs for waves 16-20: currently only 15 wave .tres files exist. Add configs for waves 16-20 with increasingly difficult enemy mixes to give the game more depth and a longer single run.
