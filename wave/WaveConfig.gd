class_name WaveConfig
extends Resource
## WaveConfig — scriptable resource defining a single wave's composition.
##
## Used by WaveManager to instantiate enemies with correct stats
## and spawn timing, without hardcoded data.
##
## Fields:
##   enemies:   list of { enemy_data, count } dictionaries
##   hp_scale:  multiplier applied to each enemy's max_hp
##   speed_scale: multiplier applied to each enemy's speed
##   spawn_interval: seconds between enemy spawns
##   description: optional display name shown in UI

## List of enemy entries: [{ "enemy_data": EnemyData, "count": int }, ...]
@export var enemies: Array = []

## HP multiplier for this wave's enemies
@export var hp_scale: float = 1.0

## Speed multiplier for this wave's enemies
@export var speed_scale: float = 1.0

## Seconds between each enemy spawn in this wave
@export var spawn_interval: float = 1.5

## Human-readable description of this wave (used in UI)
@export var description: String = ""

## Total number of enemies in this wave
func get_total_enemies() -> int:
	var total: int = 0
	for entry in enemies:
		total += entry.get("count", 0)
	return total

## Get all unique enemy types configured for this wave
func get_enemy_types() -> Array[Resource]:
	var types: Array[Resource] = []
	for entry in enemies:
		var data = entry.get("enemy_data", null)
		if data and not data in types:
			types.append(data)
	return types

## Check whether this wave has any enemy entries
func is_empty() -> bool:
	return enemies.is_empty()
