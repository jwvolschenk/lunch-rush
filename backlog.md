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

- [x] Wire room selector flow: RoomSelector emits room_selected signal but nothing in Main.tscn calls _on_room_selected() — add the signal connection and show_rooms() call between card selection and wave start
- [x] Fix room modifier application: GameState._apply_room_modifier() modifies wave_enemy_count/hp/speed/gold_reward on the GameState object but WaveManager.start_wave() only reads from WaveConfig — pass room modifier from GameState.current_room into WaveManager.start_wave()
- [x] Clamp EmergencyRationCard heal to max_hp: game_state.health += heal_amount can exceed 20 (max health), breaking the game's HP cap
- [x] Add EnemyData resources for SlimeRunner, GhostChef, and OgreBrute (EnemyData_HungryGoblin.tres and EnemyData_PizzaDelivery.tres already exist)
- [x] Add Pizza Delivery tower scene: GOAL.md lists it as a core tower but only PizzaTrebuchet exists — create PizzaDelivery.tscn + PizzaDelivery.gd
- [x] Add 10 more waves (wave_6 through wave_15) to WaveConfig resources with varied enemy compositions (Ogre Brute + Slime Runner, Ghost Chef waves, mixed waves)
- [x] Add health cap in EmergencyRationCard: clamp healed HP to GameState.max_hp (20) to prevent HP overflow
- [x] Add visible craving indicator on enemies: show a small food icon above enemies so player can target with matching food towers
- [x] Add a "Cheat Code" card (e.g., "Health Inspector" as a one-time boss-killer) — GOAL.md references it but it's not in the starter deck
- [x] Fix KitchenUpgradeCard timer leak: if played twice within 10s, the old timer's _on_buff_end fires after the new buff ends, resetting tower stats prematurely
