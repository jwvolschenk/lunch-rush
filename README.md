# Lunch Rush: Dungeon Deli

A roguelite deckbuilder tower defence game built in Godot 4.

Run a magical dungeon deli while waves of hungry monsters storm your kitchen. Serve them the right food to slow them down, or the wrong food to make them angry and fast.

## Quickstart

1. Open this folder in Godot 4 (File > Open > select the project root).
2. Press **F5** to play.
3. Click on lanes to place towers that attack incoming enemies.
4. After each wave, select a new card to strengthen your deck.
5. Survive as many waves as you can — if health hits zero, it's game over.

### Project structure

- `GameState.gd` — autoload managing score, waves, health, gold
- `LaneManager.gd` / `lane/Lane.*` — lane system with enemy spawn points
- `tower/Tower.*` + `TowerManager.gd` — tower placement and lifecycle
- `enemy/Enemy.*` + `HungryGoblin.*` — enemy base class and first enemy type
- `projectile/Projectile.*` — reusable projectile with damage/splash
- `Main.tscn` / `main.gd` — root scene and game loop

## Controls

- **Click** — place towers / select cards
- **WASD / Arrow keys** — move camera
- **Space** — skip wave / confirm selection

## Game Overview

- **Towers**: Chefs, ovens, sauce cannons, and more — each with unique attacks.
- **Cards**: Recipes and kitchen staff that modify your deck.
- **Enemies**: Hungry monsters with cravings — feed them right to slow them, wrong to enrage them.
- **Roguelite runs**: Each dinner service is a fresh run with permadeath.

## Data Models

- **EnemyData** (`enemy/EnemyData.gd`) — scriptable resource for enemy stats (HP, speed, gold/score rewards, craving type, tint color, custom scene path). Configure enemy types in the editor without code changes.

## Building

Requires Godot 4.7+. Open this project folder in the Godot editor and run the project.

Verify the project compiles:

```bash
./scripts/check_godot.sh
```
