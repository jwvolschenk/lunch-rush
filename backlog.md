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
