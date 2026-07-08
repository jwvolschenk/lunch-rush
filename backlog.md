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

- [x] Spicy Sauce Cannon tower — explicit GOAL.md tower (line 20). Implement as concrete tower with burn/dot damage type, 220 range, 4 dmg, 2.5s cooldown. Red-orange visual, projectile with burn effect.

- [x] Dishwasher tower — referenced in CardPool.gd line 77 but no Dishwasher.tscn scene exists. Implement as fast melee tower (range=80, dmg=12, cooldown=0.8s), high risk/reward short-range attacker.

- [x] Enemy variety: Ogre Brute — add OgreBrute.gd/.tscn as a high-HP tank enemy (200 HP, slow speed, high gold reward). Adds enemy diversity beyond Hungry Goblin.

- [ ] Enemy variety: Ghost Chef — add GhostChef.gd/.tscn as a floating enemy that partially phases through towers (50% dodge chance for 2s, medium HP 80, medium speed).

- [ ] Enemy variety: Slime Runner — add SlimeRunner.gd/.tscn as a fast low-HP enemy (30 HP, 150 speed, low gold). Creates speed-vs-tower tradeoff for players.

- [ ] Food buff cards: "Kitchen Upgrade" — add a new STATUS_EFFECT card type that buffs all placed towers (e.g., +50% attack speed for 10s or +25% damage for 15s). Extends card variety beyond tower cards.

- [ ] Food buff cards: "Emergency Ration" — add a new STATUS_EFFECT card that heals the kitchen for 10 HP. Adds strategic decision between offense and survival.

- [ ] WaveConfig data files: Add 5 hand-crafted WaveConfig resources with escalating difficulty (waves 1-5) including varied enemy compositions to replace pure random escalation.
