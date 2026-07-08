# Backlog

# Tasks the solo-agent loop works through. Each cycle: the reflect
# phase regenerates candidates, the plan phase structures them here,
# the execute phase picks the next unchecked item as a goal.

- [ ] (sample) Add a README quickstart section

# --- Cycle 4 reflect additions ---

# Phase: scaffold the project toward the Godot game goal

- [ ] Remove all Python code (lunch_rush/, pyproject.toml, tests/) and replace with Godot project.godot, icon, and .gdignore skeleton
- [ ] Create a blank "Lunch Rush" project in Godot 4 with the main scene (Main.tscn) and a root script (main.gd)
- [ ] Implement a basic 2D game loop: a GameState.gd autoload (autoload singleton) managing game state (score, waves, player health)
- [ ] Implement a Lane system: 2-3 lanes with enemies spawning from the right and moving left toward the kitchen
- [ ] Implement a Tower base class (Tower.tscn + Tower.gd) with placement, attack range, damage, and fire rate
- [ ] Implement an Enemy base class (Enemy.tscn + Enemy.gd) with HP, speed, and lane-based movement
- [ ] Implement one concrete tower: "Goblin Fry Cook" — short-range grease attack with area damage
- [ ] Implement one concrete enemy: "Hungry Goblin" with basic AI (walk toward kitchen)
- [ ] Implement a wave system: spawn waves of enemies with increasing difficulty between waves
- [ ] Implement the card/recipe UI: after each wave, present 3 card choices to the player
- [ ] Implement the craving system: enemies have food preferences that slow them when fed correctly
- [ ] Add a simple card deck system: player starts with a deck, draws cards, plays cards to place towers
- [ ] Implement run progression: after a run ends (all health lost), show summary and offer restart
- [ ] Replace README.md with Godot project README: how to open, controls, game overview
- [ ] Add basic placeholder art (colored rectangles) for towers, enemies, lanes, and UI

# --- Cycle 5 reflect additions ---

## Theme: core gameplay loop — make a minimally playable demo

- [ ] Implement GameState autoload (score, wave, health, gold) with clear signals for UI updates
- [ ] Implement Lane system with 2 lanes: enemies spawn right, walk left; lane rendering and spawn point config
- [ ] Implement Enemy base scene (ColorRect sprite) with HP bar, lane movement, and kitchen-reach detection
- [ ] Implement Tower base scene + Tower.gd with range circle, targeting, damage, cooldown, and fire animation
- [ ] Implement Goblin Fry Cook concrete tower: 3 tiles range, grease projectile with area splash, 1.5s cooldown
- [ ] Implement Hungry Enemy concrete type: 40 HP, 60px/s speed, standard walk animation toward kitchen
- [ ] Implement WaveManager autoload: spawns escalating waves (count, HP, speed), shows "Wave Complete" overlay
- [ ] Implement card selection UI: 3-card choice panel after each wave, click-to-continue
- [ ] Implement player deck: starts with 5 cards, draws from deck each turn, discard pile
- [ ] Implement craving mechanic: random enemy craving, feeding matching food applies slow debuff
- [ ] Add gold economy: gold per kill, gold display on HUD, tower costs
- [ ] Build camera system: pan/zoom across lanes with smooth follow on enemy movement

DONE: 12 tasks — core gameplay loop: game state, lanes, towers, enemies, waves, cards, cravings, gold economy, camera