# Backlog Candidates

# Planner inbox: coarse themes from REFLECT and orchestrator seeds.
# PLAN decomposes these into backlog.md, then clears this file.
# The executor never reads this file.

## Archived (cycle 98)

- Consolidate duplicate starter card definitions between Main.tscn._get_starter_cards() and DeckManager.gd._get_starter_deck() into a single canonical source in DeckManager.gd, remove hardcoded card_type literals and use CardCategory enum constants — DECOMPOSED into 2 tasks in backlog.md

- Replace hardcoded room data in Main.tscn._get_room_choices() with loading from existing room_*.tres resource files in res://rooms/ (5 files exist but are unused — values differ from hardcoded), aligning gameplay modifiers with designer intent — DECOMPOSED into 1 task in backlog.md

- Add pre-flight audio validation in SoundManager: enumerate all expected audio files at startup, push push_warning for any missing files, and ensure the game handles missing SFX/music gracefully (no crashes, just silent skips) — DECOMPOSED into 1 task in backlog.md
