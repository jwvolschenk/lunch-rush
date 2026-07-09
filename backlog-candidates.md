# Backlog Candidates

# Planner inbox: coarse themes from REFLECT and orchestrator seeds.
# PLAN decomposes these into backlog.md, then clears this file.
# The executor never reads this file.

## Archived (cycle 86 PLAN)

- [x] (orchestrator seed, cycle 83) Survey the project for weakest docs/comments/onboarding and implement one concrete documentation improvement — DONE: added project README, doc-strings to Tower/Enemy/Projectile public APIs
- [x] Critical: HUD not registered in project.godot autloads — DONE: added `HUD="res://HUD.gd"` to [autoload] section
- [x] Critical: `deduct_gold` missing from GameState — DONE: added `deduct_gold` alias to `spend_gold` in GameState.gd
- [x] Logic bug: unlock display between waves — VERIFIED: data flow is correct (`_check_unlocks` → `GameState.check_unlocks_between_waves` → `_pending_unlocks` → `_show_unlocks_overlay` reads `GameState.pending_unlocks`). No bug.
- [x] Tech debt: `food_type_to_int` duplication — DONE: centralized in CravingType.gd as static helper, updated CardPool.gd caller

## Archived (cycle 87 PLAN)

- [x] Critical: 3 autoloads missing — DONE: decomposed into backlog task (register DeckManager, TowerManager, LaneManager in project.godot)
- [x] Bug: CardSelection.gd line 103 CravingType reference — DONE: decomposed into backlog task (replace CravingType. with CRAVING_TYPE.)
