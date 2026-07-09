class_name Lane
extends Node2D
## Lane — a single lane for enemy movement.
## Each lane is a horizontal row with a spawn point on the right
## and the kitchen (end point) on the left.
##
## Enemies instance onto this node and walk toward the kitchen.
## When they reach the kitchen end, they emit a reached_kitchen signal.

## --- Configuration ---
## Y-position of the lane (set by LaneManager)
@export var y: float = 300.0

## Total width of the lane in world pixels
@export var lane_width: float = 1280.0

## Distance from right edge where enemies spawn
@export var spawn_offset: float = 100.0

## Whether to show spawn point markers on this lane
@export var show_spawn_marker: bool = true

## --- Computed properties ---
## Spawn point (right side of screen)
var spawn_position: Vector2:
	get:
		return Vector2(lane_width - spawn_offset, y)

## Kitchen (left side) threshold — enemies reaching this are "at the kitchen"
const KITCHEN_THRESHOLD: float = -50.0

## --- Lane children ---
# Track enemies currently on this lane
var enemies: Array[Node2D] = []

# Spawn marker visual indicator
var _spawn_marker: Node2D = null

## --- Signals ---
## Emitted when an enemy reaches the kitchen (left edge)
signal enemy_reached_kitchen(enemy: Node2D)
## Emitted when an enemy dies on this lane
signal enemy_died(enemy: Node2D)

## --- Lifecycle ---
func _ready() -> void:
	position.y = y
	_setup_spawn_marker()

## Set up the spawn point marker visual
func _setup_spawn_marker() -> void:
	if not show_spawn_marker:
		return
	var marker_scene := load("res://lane/SpawnMarker.tscn") as PackedScene
	_spawn_marker = marker_scene.instantiate()
	_spawn_marker.position = spawn_position
	_spawn_marker.set_visible(true)
	add_child(_spawn_marker)

## --- Enemy management ---

## Add an enemy to this lane
func spawn_enemy(enemy_scene: PackedScene) -> Node2D:
	var enemy := enemy_scene.instantiate()
	enemy.position = spawn_position
	add_child(enemy)
	enemies.append(enemy)
	return enemy

## Remove an enemy from this lane (called when enemy dies or reaches kitchen)
func remove_enemy(enemy: Node2D) -> void:
	if enemy in enemies:
		enemies.erase(enemy)
	enemy.queue_free()

## Get all enemies on this lane (for targeting / pathfinding)
func get_enemies() -> Array[Node2D]:
	return enemies

## Get the number of enemies on this lane
func get_enemy_count() -> int:
	return enemies.size()

## Check if this lane has any enemies
func has_enemies() -> bool:
	return not enemies.is_empty()
