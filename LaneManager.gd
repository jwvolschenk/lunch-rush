extends Node
## LaneManager — autoload singleton that manages all lanes.
## Creates lanes at startup, provides enemy spawn helpers,
## and tracks which lane each enemy is on.
##
## The default config is 2 lanes, but lane_count is @exported
## so designers can tweak it in the editor.

## --- Configuration ---
## Number of lanes to create (default 2)
@export var lane_count: int = 2

## Vertical spacing between lanes
@export var lane_spacing: float = 160.0

## Vertical offset to center lanes on screen
@export var center_offset: float = 0.0

## Whether to show divider walls between lanes
@export var show_lane_dividers: bool = true

## --- Lane instances ---
var lanes: Array[Lane] = []

## Divider wall nodes between lanes
var _dividers: Array[Node2D] = []

## --- Signals ---
## Emitted when a new enemy spawns on any lane
signal enemy_spawned(enemy: Node2D, lane_index: int)
## Emitted when an enemy reaches the kitchen on any lane
signal enemy_reached_kitchen(enemy: Node2D, lane_index: int)
## Emitted when an enemy dies on any lane
signal enemy_died(enemy: Node2D, lane_index: int)

## Emitted when all lanes have no enemies (all enemies cleared)
signal wave_complete()

## --- Lifecycle ---
func _ready() -> void:
	_build_lanes()

## Preload the lane divider scene
const _LANE_DIVIDER_SCENE := preload("res://lane/LaneDivider.tscn")

## --- Lane management ---

## Create all lanes based on lane_count
func _build_lanes() -> void:
	# Clear any existing lanes
	for lane in lanes:
		lane.queue_free()
	lanes.clear()
	
	# Remove existing dividers
	for divider in _dividers:
		divider.queue_free()
	_dividers.clear()
	
	var total_height = (lane_count - 1) * lane_spacing
	var start_y = 360.0 - total_height / 2.0 + center_offset
	
	for i in range(lane_count):
		var lane_scene := load("res://lane/Lane.tscn") as PackedScene
		var lane := lane_scene.instantiate() as Lane
		lane.y = start_y + i * lane_spacing
		add_child(lane)
		lanes.append(lane)
	
	# Add divider walls between adjacent lanes
	if show_lane_dividers and lane_count > 1:
		_add_lane_dividers(start_y)
	
	print("[LaneManager] Built %d lanes." % lane_count)

## Add visual divider walls between adjacent lanes
func _add_lane_dividers(start_y: float) -> void:
	for i in range(lane_count - 1):
		var divider_scene := load("res://lane/LaneDivider.tscn") as PackedScene
		var divider := divider_scene.instantiate() as Node2D
		# Position between this lane and the next, centered horizontally
		var divider_y = start_y + i * lane_spacing + lane_spacing / 2.0
		divider.position = Vector2(0.0, divider_y)
		# Place in front of lanes (add_child last = top of Z order)
		add_child(divider)
		_dividers.append(divider)
	print("[LaneManager] Added %d lane dividers." % (lane_count - 1))

## Get a lane by index
func get_lane(index: int) -> Lane:
	if 0 <= index < lanes.size():
		return lanes[index]
	push_warning("LaneManager: lane index %d out of range [0..%d]" % [index, lanes.size()])
	return null

## Get all lanes
func get_all_lanes() -> Array[Lane]:
	return lanes

## --- Enemy spawn helpers ---

## Spawn an enemy on a specific lane
func spawn_enemy_on_lane(enemy_scene: PackedScene, lane_index: int) -> Node2D:
	var lane := get_lane(lane_index)
	if not lane:
		return null
	var enemy := lane.spawn_enemy(enemy_scene)
	
	# Connect lane signals
	lane.enemy_reached_kitchen.connect(
		func(e): enemy_reached_kitchen.emit(e, lane_index)
	)
	lane.enemy_died.connect(
		func(e): enemy_died.emit(e, lane_index)
	)
	
	enemy_spawned.emit(enemy, lane_index)
	return enemy

## Spawn an enemy on a random lane
func spawn_enemy_random(enemy_scene: PackedScene) -> Variant:
	var lane_index = randi() % lane_count
	return spawn_enemy_on_lane(enemy_scene, lane_index)

## Count total enemies across all lanes
func total_enemy_count() -> int:
	var total := 0
	for lane in lanes:
		total += lane.get_enemy_count()
	return total

## Check if any lane has enemies
func has_active_enemies() -> bool:
	for lane in lanes:
		if lane.has_enemies():
			return true
	return false

## Force all enemies on a specific lane to the kitchen (for testing)
func flush_lane(lane_index: int) -> int:
	var lane := get_lane(lane_index)
	if not lane:
		return 0
	var count := lane.get_enemy_count()
	for enemy in lane.get_enemies():
		lane.remove_enemy(enemy)
	return count

## Rebuild lanes (e.g. after changing lane_count at runtime)
func rebuild_lanes() -> void:
	_build_lanes()
