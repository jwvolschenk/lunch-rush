extends Node
## WaveConfigLoader — singleton that loads wave configurations from resources or files.
##
## Responsibilities:
##   1. Load Resource resources from a directory (res://waves/).
##   2. Load wave data from external JSON files for non-Godot-editable waves.
##   3. Provide get_wave(index) API for WaveManager.
##   4. Support dynamic wave generation for room-modified waves and endless play.
##
## Usage:
##   Put .tres Resource resources in res://waves/ for auto-loading.
##   Put .json files in res://waves/ for procedural wave definitions.
##   WaveManager calls WaveConfigLoader.get_wave(wave_index) to fetch wave data.

## --- Configuration ---

## Directory to scan for Resource resources
const WAVE_RESOURCE_DIR := "res://waves/"

## Directory to scan for JSON wave definitions
const WAVE_JSON_DIR := "res://waves/json/"

## List of loaded Resource resources (index = wave index)
var _loaded_waves: Array[Resource] = []

## Map of JSON file names to their parsed Resource
var _json_waves: Dictionary = {}

## Base escalation parameters used when no config file defines a wave
var _base_hp_scale: float = 1.0
var _base_speed_scale: float = 1.0
var _base_enemy_count: int = 3
var _base_spawn_interval: float = 2.0

## Growth rates for procedural escalation
var _hp_growth_rate: float = 0.10
var _speed_growth_rate: float = 0.05
var _count_growth_rate: int = 2
var _interval_reduction: float = 0.10

## Maximum predefined waves from file resources
var _max_file_waves: int = 0

## Whether initialization has run
var _initialized: bool = false

## --- Signals ---

## Emitted when waves are successfully loaded. Args: (count: int)
signal waves_loaded(count: int)

## Emitted when a wave fails to load. Args: (index: int, error: Error)
signal wave_load_failed(index: int, error: Error)

## --- Properties ---

## Number of pre-defined waves loaded from files/resources
var loaded_wave_count: int:
	get: return _loaded_waves.size()

## Whether waves have been initialized
var is_initialized: bool:
	get: return _initialized

## --- Lifecycle ---

func _ready() -> void:
	_load_all_waves()
	_initialized = true

## Initialize with explicit wave list (called by WaveManager when it has its own @export waves).
## This allows WaveManager to pass in editor-configured waves instead of relying on file scan.
func initialize(wave_resources: Array[Resource], max_waves: int = 0) -> void:
	_loaded_waves = wave_resources.duplicate()
	_max_file_waves = wave_resources.size()
	_initialized = true
	waves_loaded.emit(_loaded_waves.size())
	print("[WaveConfigLoader] Initialized with %d loaded waves." % _loaded_waves.size())

## --- Loading ---

## Load all available wave configurations from resources and JSON files.
func _load_all_waves() -> void:
	_loaded_waves.clear()
	_json_waves.clear()

	# Load Resource resource files from res://waves/
	var resource_waves := _load_resource_waves()
	for wave in resource_waves:
		_loaded_waves.append(wave)

	_loaded_waves.sort_custom(func(a, b): return _wave_sort_key(a) < _wave_sort_key(b))
	_max_file_waves = _loaded_waves.size()

	# Load JSON wave definitions from res://waves/json/
	_load_json_waves()

	print("[WaveConfigLoader] Loaded %d wave configs (%d resources, %d jsons)." % [
		_loaded_waves.size(),
		resource_waves.size(),
		_json_waves.size()
	])

	waves_loaded.emit(_loaded_waves.size())

## Load Resource resources from the wave directory.
## Scans for .tres files that extend Resource.
func _load_resource_waves() -> Array[Resource]:
	var waves: Array[Resource] = []
	var dir := DirAccess.open(WAVE_RESOURCE_DIR)

	if not dir:
		print("[WaveConfigLoader] No wave resource directory at %s (procedural waves will be used)." % WAVE_RESOURCE_DIR)
		return waves

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres") or file_name.ends_with(".tscn"):
			var full_path := WAVE_RESOURCE_DIR + file_name
			var resource = load(full_path)
			if resource and resource is Resource:
				waves.append(resource)
			elif resource:
				push_warning("[WaveConfigLoader] Skipping non-Resource resource: %s" % full_path)
		file_name = dir.get_next()
	dir.list_dir_end()

	return waves

## Load JSON wave definitions from the json subdirectory.
## Each JSON file defines one wave with enemy data and scaling.
func _load_json_waves() -> void:
	var dir := DirAccess.open(WAVE_JSON_DIR)
	if not dir:
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".json"):
			var full_path := WAVE_JSON_DIR + file_name
			var parsed = _parse_json_wave(full_path)
			if parsed:
				_json_waves[file_name.replace(".json", "")] = parsed
		file_name = dir.get_next()
	dir.list_dir_end()

## Parse a single JSON file into a Resource resource.
func _parse_json_wave(file_path: String) -> Resource:
	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_warning("[WaveConfigLoader] Could not open JSON wave file: %s" % file_path)
		return null

	var contents := file.get_as_text()
	file.close()

	var json_result = JSON.parse_string(contents)
	if not json_result or not typeof(json_result) == TYPE_DICTIONARY:
		push_warning("[WaveConfigLoader] Invalid JSON in %s" % file_path)
		return null

	var wave := Resource.new()

	if "description" in json_result:
		wave.description = json_result["description"]

	if "hp_scale" in json_result:
		wave.hp_scale = float(json_result["hp_scale"])

	if "speed_scale" in json_result:
		wave.speed_scale = float(json_result["speed_scale"])

	if "spawn_interval" in json_result:
		wave.spawn_interval = float(json_result["spawn_interval"])

	if "enemies" in json_result and json_result["enemies"] is Array:
		wave.enemies = []
		for enemy_entry in json_result["enemies"]:
			var entry: Dictionary = {
				"enemy_data": enemy_entry.get("enemy_data", null),
				"count": int(enemy_entry.get("count", 1)),
			}
			wave.enemies.append(entry)

	return wave

## --- Wave API ---

## Get the Resource for a given wave index.
## Returns the loaded wave if available, or generates one procedurally.
##
## If the index is beyond loaded waves, room modifiers are applied
## to generate a modified wave on the fly.
func get_wave(index: int) -> Resource:
	if not _initialized:
		_load_all_waves()

	# Return a pre-loaded wave if available
	if index >= 0 and index < _loaded_waves.size():
		return _loaded_waves[index]

	# Generate dynamically for waves beyond the pre-loaded set
	return _generate_dynamic_wave(index)

## Generate a dynamic Resource for waves beyond what is defined in files.
## Applies room modifiers if the current room has them.
func _generate_dynamic_wave(index: int) -> Resource:
	var wave := Resource.new()

	var hp_scale = 1.0 + (index * _hp_growth_rate)
	var speed_scale = 1.0 + (index * _speed_growth_rate)
	var enemy_count = _base_enemy_count + (index * _count_growth_rate)
	var spawn_interval = max(0.3, _base_spawn_interval - (index * _interval_reduction))

	wave.hp_scale = hp_scale
	wave.speed_scale = speed_scale
	wave.spawn_interval = spawn_interval

	# Use varied enemy types based on wave progression
	var available_enemies: Array[Dictionary] = []

	# Hungry Goblin — available from wave 0
	var goblin_data_path := "res://enemy/EnemyData_HungryGoblin.tres"
	if ResourceLoader.exists(goblin_data_path):
		available_enemies.append({
			"path": goblin_data_path,
			"min_wave": 0,
			"weight": 10,
		})

	# Slime Runner — available from wave 3
	var slime_data_path := "res://enemy/EnemyData_SlimeRunner.tres"
	if ResourceLoader.exists(slime_data_path):
		available_enemies.append({
			"path": slime_data_path,
			"min_wave": 3,
			"weight": 3,
		})

	# Ghost Chef — available from wave 5
	var ghost_data_path := "res://enemy/EnemyData_GhostChef.tres"
	if ResourceLoader.exists(ghost_data_path):
		available_enemies.append({
			"path": ghost_data_path,
			"min_wave": 5,
			"weight": 2,
		})

	# Ogre Brute — available from wave 7
	var ogre_data_path := "res://enemy/EnemyData_OgreBrute.tres"
	if ResourceLoader.exists(ogre_data_path):
		available_enemies.append({
			"path": ogre_data_path,
			"min_wave": 7,
			"weight": 1,
		})

	# Pizza Delivery — available from wave 10
	var pizza_data_path := "res://enemy/EnemyData_PizzaDelivery.tres"
	if ResourceLoader.exists(pizza_data_path):
		available_enemies.append({
			"path": pizza_data_path,
			"min_wave": 10,
			"weight": 1,
		})

	# Pick the primary enemy type for this wave based on index
	var primary_idx := 0
	for i in range(available_enemies.size() - 1, -1, -1):
		if index >= available_enemies[i]["min_wave"]:
			primary_idx = i
			break

	var primary_path: String = available_enemies[primary_idx]["path"]
	var primary_data = load(primary_path) if ResourceLoader.exists(primary_path) else null

	# Build enemy entries: primary type gets the bulk, introduce variety at higher waves
	wave.enemies = []

	if primary_data and ResourceLoader.exists(primary_path):
		var primary_count = enemy_count
		if index >= 3 and primary_idx + 1 < available_enemies.size():
			# Introduce a secondary enemy type from later waves
			var secondary_path = available_enemies[primary_idx + 1]["path"]
			var secondary_data = load(secondary_path) if ResourceLoader.exists(secondary_path) else null
			if secondary_data:
				var secondary_count = max(1, enemy_count / 3)
				primary_count -= secondary_count
				wave.enemies.append({
					"enemy_data": secondary_data,
					"count": secondary_count,
				})

		wave.enemies.append({
			"enemy_data": primary_data,
			"count": max(1, primary_count),
		})
	else:
		wave.enemies = [
			{
				"enemy_data": null,
				"count": enemy_count,
			}
		]

	wave.description = "Wave %d — Dynamic threat" % (index + 1)

	return wave

## Apply room modifiers to a wave config.
## Modifies hp_scale and speed_scale in place, and adds extra enemies.
func apply_room_modifiers(wave: Resource, room: Resource) -> Resource:
	if not room:
		return wave

	var hp_mod := float(room.get("enemy_hp_modifier") if room.get("enemy_hp_modifier") else 1.0)
	var speed_mod := float(room.get("enemy_speed_modifier") if room.get("enemy_speed_modifier") else 1.0)
	var count_add := int(room.get("enemy_count_modifier") if room.get("enemy_count_modifier") else 0)

	wave.hp_scale *= hp_mod
	wave.speed_scale *= speed_mod

	if count_add > 0 and wave.enemies.size() > 0:
		var first_entry = wave.enemies[0]
		for i in range(count_add):
			wave.enemies.append({
				"enemy_data": first_entry.get("enemy_data", null),
				"count": 1,
			})

	return wave

## Get a wave that is guaranteed to have room modifiers applied.
## Used by WaveManager when starting a wave after room selection.
func get_wave_with_room_modifiers(index: int, room: Resource) -> Resource:
	var wave = get_wave(index)
	if room:
		apply_room_modifiers(wave, room)
	return wave

## Re-scan and reload all wave configurations from disk/resources.
## Useful after runtime changes to wave files.
func reload_waves() -> void:
	_loaded_waves.clear()
	_json_waves.clear()
	_load_all_waves()

## Clear all loaded waves and reinitialize with a new set.
## Useful for run transitions between different wave pools.
func reload_with(wave_resources: Array[Resource]) -> void:
	_loaded_waves = wave_resources.duplicate()
	_max_file_waves = _loaded_waves.size()
	waves_loaded.emit(_loaded_waves.size())
	print("[WaveConfigLoader] Reloaded with %d waves." % _loaded_waves.size())

## --- Helpers ---

## Sort key for wave resources (by description or index).
func _wave_sort_key(wave: Resource) -> String:
	if wave.description:
		return wave.description
	return "Wave %d" % _loaded_waves.size()
