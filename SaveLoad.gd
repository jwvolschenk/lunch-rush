extends Node
## SaveLoad — autoload singleton for persisting high-score and run data.
## Saves score, waves_completed, and gold earned on game-over.
## Loads best run data on start. Uses JSON serialization via FileAccess.
##
## Usage:
##   SaveLoad.save_run(score, waves_completed, gold_earned)
##   SaveLoad.get_best_run() -> Dictionary with best stats or empty dict
##   SaveLoad.get_high_score() -> int
##   SaveLoad.get_best_waves() -> int
##   SaveLoad.get_best_gold() -> int

const SAVE_PATH := "user://savegame.json"
const SAVE_VERSION := 1

## The last known best run data, loaded on _ready
var _best_run: Dictionary = {}

## Emitted when best run data changes (after a new high score)
signal best_run_updated(new_best: Dictionary)

## --- Lifecycle ---

func _ready() -> void:
	_load_best_run()

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
