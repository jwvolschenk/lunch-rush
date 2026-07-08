extends Node
## SaveLoad — autoload singleton for persisting high-score and run data.
## Saves score, waves_completed, and gold earned on game-over.
## Loads best run data on start. Uses JSON serialization via FileAccess.
## Also stores unlocked tower/card variants and starting gold bonus for meta-progression.
##
## Usage:
##   SaveLoad.save_run(score, waves_completed, gold_earned)
##   SaveLoad.get_best_run() -> Dictionary with best stats or empty dict
##   SaveLoad.get_high_score() -> int
##   SaveLoad.get_best_waves() -> int
##   SaveLoad.get_best_gold() -> int
##   SaveLoad.check_unlocks(waves) -> Dictionary of new unlocks
##   SaveLoad.get_unlocked_towers() -> Array[String]
##   SaveLoad.get_unlocked_cards() -> Array[String]
##   SaveLoad.get_unlocked_gold_bonus() -> int

const SAVE_PATH := "user://savegame.json"
const SAVE_VERSION := 1
const UNLOCK_PATH := "user://unlocks.json"
const UNLOCK_SAVE_VERSION := 1

const TOWER_UNLOCK_MILESTONES := {
	"Pizza Trebuchet": 3,
	"Soup Spill": 5,
	"Spicy Sauce Cannon": 7,
	"Health Inspector": 9,
	"Enchanted Vending Machine": 12,
	"Angry Dishwasher": 4,
	"Pizza Delivery": 8,
}

const CARD_UNLOCK_MILESTONES := {
	"Health Inspector": 9,
	"Combo Meal": 3,
	"Customer Control": 5,
	"Kitchen Upgrade": 2,
	"Emergency Ration": 4,
	"Cheat Code": 10,
}

const STARTING_GOLD_BONUS_MILESTONES := {
	3: 5,
	5: 10,
	8: 20,
	10: 30,
	13: 50,
	16: 75,
	20: 100,
}

## The last known best run data, loaded on _ready
var _best_run: Dictionary = {}

## Emitted when best run data changes (after a new high score)
signal best_run_updated(new_best: Dictionary)

## Emitted when a new unlock is discovered
signal unlock_found(unlock_type: String, unlock_name: String)

## --- Unlock data ---

## Set of unlocked tower names (e.g. "Pizza Trebuchet")
var unlocked_towers: Array[String] = []

## Set of unlocked card names (e.g. "Health Inspector")
var unlocked_cards: Array[String] = []

## Bonus starting gold from meta-progression (added on top of base 100)
var starting_gold_bonus: int = 0

## --- Lifecycle ---

func _ready() -> void:
	_load_best_run()
	_load_unlocks()

## --- Public API ---

## Save the current run's stats as a candidate for best run.
## If score exceeds the previous best, persists it as the new high score.
func save_run(p_score: int, p_waves: int, p_gold: int) -> void:
	var current_best := get_high_score()
	if p_score > current_best:
		var new_best := {
			"version": SAVE_VERSION,
			"score": p_score,
			"waves": p_waves,
			"gold": p_gold,
			"timestamp": Time.get_unix_time_from_system(),
		}
		var json_string := JSON.stringify(new_best)
		var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		if file != null:
			file.store_string(json_string)
			file.close()
			_best_run = new_best
			best_run_updated.emit(new_best)
			print("[SaveLoad] New high score! Score: %d, Waves: %d, Gold: %d" % [p_score, p_waves, p_gold])

## Get the best run data loaded from disk.
## Returns a dictionary with keys: score, waves, gold, timestamp.
## Returns an empty dictionary if no save exists.
func get_best_run() -> Dictionary:
	return _best_run.duplicate()

## Get the best (highest) score recorded.
## Returns 0 if no save exists.
func get_high_score() -> int:
	if _best_run and "score" in _best_run:
		return int(_best_run["score"])
	return 0

## Get the number of waves survived in the best run.
## Returns 0 if no save exists.
func get_best_waves() -> int:
	if _best_run and "waves" in _best_run:
		return int(_best_run["waves"])
	return 0

## Get the gold earned in the best run.
## Returns 0 if no save exists.
func get_best_gold() -> int:
	if _best_run and "gold" in _best_run:
		return int(_best_run["gold"])
	return 0

## Get the unlocked starting gold bonus.
func get_unlocked_gold_bonus() -> int:
	return starting_gold_bonus

## Get all unlocked tower names.
func get_unlocked_towers() -> Array[String]:
	return unlocked_towers.duplicate()

## Get all unlocked card names.
func get_unlocked_cards() -> Array[String]:
	return unlocked_cards.duplicate()

## Check for new unlocks based on waves survived in the current run.
## Returns a dictionary with keys: new_towers (Array), new_cards (Array), new_gold_bonus (int).
## Call this after game-over with the waves survived.
func check_unlocks(waves_survived: int) -> Dictionary:
	var result := {
		"new_towers": Array[String](),
		"new_cards": Array[String](),
		"new_gold_bonus": 0,
	}

	# Check tower unlocks
	for tower_name in TOWER_UNLOCK_MILESTONES:
		var required_wave = TOWER_UNLOCK_MILESTONES[tower_name]
		if waves_survived >= required_wave and not unlocked_towers.has(tower_name):
			unlocked_towers.append(tower_name)
			result.new_towers.append(tower_name)
			unlock_found.emit("tower", tower_name)
			print("[SaveLoad] Unlocked tower: %s (wave %d+)" % [tower_name, required_wave])

	# Check card unlocks
	for card_name in CARD_UNLOCK_MILESTONES:
		var required_wave = CARD_UNLOCK_MILESTONES[card_name]
		if waves_survived >= required_wave and not unlocked_cards.has(card_name):
			unlocked_cards.append(card_name)
			result.new_cards.append(card_name)
			unlock_found.emit("card", card_name)
			print("[SaveLoad] Unlocked card: %s (wave %d+)" % [card_name, required_wave])

	# Check starting gold bonus milestones
	for required_wave in STARTING_GOLD_BONUS_MILESTONES:
		if waves_survived >= required_wave:
			var bonus = STARTING_GOLD_BONUS_MILESTONES[required_wave]
			if starting_gold_bonus < bonus:
				result.new_gold_bonus = bonus
				starting_gold_bonus = bonus
				unlock_found.emit("gold_bonus", str(bonus))
				print("[SaveLoad] Starting gold bonus increased to +%d" % bonus)

	# Persist unlocks
	save_unlocks()

	return result

## --- Internal ---

func _load_best_run() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("[SaveLoad] Failed to open save file: " + SAVE_PATH)
		return
	var json_string := file.get_as_text()
	file.close()
	if json_string.is_empty():
		return
	var result := JSON.parse_string(json_string)
	if result != null and typeof(result) == TYPE_DICTIONARY:
		if "version" in result and result["version"] == SAVE_VERSION:
			_best_run = result
			print("[SaveLoad] Loaded best run: score=%d, waves=%d, gold=%d" % [
				_best_run["score"], _best_run["waves"], _best_run["gold"]])
		else:
			push_warning("[SaveLoad] Save version mismatch. Expected %d, got %s" % [SAVE_VERSION, result["version"]])
			_best_run = {}
	else:
		push_warning("[SaveLoad] Invalid save file format.")
		_best_run = {}

func _load_unlocks() -> void:
	if not FileAccess.file_exists(UNLOCK_PATH):
		return
	var file := FileAccess.open(UNLOCK_PATH, FileAccess.READ)
	if file == null:
		push_warning("[SaveLoad] Failed to open unlock file: " + UNLOCK_PATH)
		return
	var json_string := file.get_as_text()
	file.close()
	if json_string.is_empty():
		return
	var result := JSON.parse_string(json_string)
	if result != null and typeof(result) == TYPE_DICTIONARY:
		if "version" in result and result["version"] == UNLOCK_SAVE_VERSION:
			if "unlocked_towers" in result:
				unlocked_towers = Array(result["unlocked_towers"])
			if "unlocked_cards" in result:
				unlocked_cards = Array(result["unlocked_cards"])
			if "starting_gold_bonus" in result:
				starting_gold_bonus = int(result["starting_gold_bonus"])
			print("[SaveLoad] Loaded unlocks: towers=%d, cards=%d, gold_bonus=+%d" % [
				unlocked_towers.size(), unlocked_cards.size(), starting_gold_bonus])
		else:
			push_warning("[SaveLoad] Unlock version mismatch. Expected %d, got %s" % [UNLOCK_SAVE_VERSION, result.get("version", "unknown")])
	else:
		push_warning("[SaveLoad] Invalid unlock file format.")

func save_unlocks() -> void:
	var data := {
		"version": UNLOCK_SAVE_VERSION,
		"unlocked_towers": unlocked_towers,
		"unlocked_cards": unlocked_cards,
		"starting_gold_bonus": starting_gold_bonus,
	}
	var json_string := JSON.stringify(data)
	var file := FileAccess.open(UNLOCK_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(json_string)
		file.close()
