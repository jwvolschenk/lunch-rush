extends Node
## TowerManager — autoload singleton that manages tower placement and lifecycle.
## Towers are placed by clicking on lanes (or placed via card selection).
## Tracks all active towers, handles tower removal, and emits signals.
##
## Tower placement:
##   call place_tower(tower_scene, lane_index, position_x) to add a tower.
## The tower is instantiated and placed on the specified lane at the X position.
##
## Tower removal:
##   call remove_tower(tower) to remove a single tower,
##   or clear_towers_on_lane(lane_index) / clear_all_towers() for bulk removal.

## --- Configuration ---

## The default tower scene used when placing towers via card
@export var default_tower_scene: PackedScene

## --- Tower registry ---

## All active towers across all lanes
var towers: Array[Node2D] = []

## Map of lane_index -> array of towers on that lane
var towers_by_lane: Dictionary = {}

## --- Signals ---

## Emitted when a tower is placed. Args: (tower: Node2D, lane_index: int)
signal tower_placed(tower: Node2D, lane_index: int)

## Emitted when a tower is removed. Args: (tower: Node2D, lane_index: int)
signal tower_removed(tower: Node2D, lane_index: int)

## Emitted when towers are cleared from a lane. Args: (lane_index: int)
signal lane_cleared(lane_index: int)

## Emitted when all towers are cleared.
signal all_towers_cleared

## --- Lifecycle ---

func _ready() -> void:
	print("[TowerManager] Initialized.")

## --- Tower placement ---

## Place a tower on a specific lane at a given X position.
## Returns the instantiated tower node, or null if placement failed.
func place_tower(tower_scene: PackedScene, lane_index: int, at_x: float) -> Node2D:
	if not tower_scene:
		print("[TowerManager] Cannot place: no tower scene provided.")
		return null
	
	var lane_manager := get_node("/root/LaneManager")
	if not lane_manager:
		print("[TowerManager] Cannot place: LaneManager not found.")
		return null
	
	var lane: Node2D = lane_manager.get_lane(lane_index)
	if not lane:
		print("[TowerManager] Cannot place: invalid lane index %d." % lane_index)
		return null
	
	# Clamp X to valid lane range
	var clamped_x = clamp(at_x, 0.0, lane_manager.lane_spacing * (lane_manager.lane_count - 1) + 800.0)
	
	var tower := tower_scene.instantiate()
	tower.position.x = clamped_x
	tower.position.y = lane.y + 40.0
	
	# Set the tower's reference to this lane
	if tower.has_method("place_on_lane"):
		tower.place_on_lane(lane, clamped_x)
	else:
		tower.set("lane", lane)
		tower.set("tower_x", clamped_x)
	
	add_child(tower)
	towers.append(tower)
	
	# Track on lane
	if not towers_by_lane.has(lane_index):
		towers_by_lane[lane_index] = []
	towers_by_lane[lane_index].append(tower)
	
	tower_placed.emit(tower, lane_index)
	SoundManager.play_sfx("tower_place")
	print("[TowerManager] Tower placed on lane %d at x=%.0f." % [lane_index, clamped_x])
	
	return tower

## Place a tower on a random lane at a random X position
func place_tower_random(tower_scene: PackedScene) -> Node2D:
	var lane_manager := get_node("/root/LaneManager")
	if not lane_manager or not lane_manager.lanes:
		print("[TowerManager] No lanes available for placement.")
		return null
	
	var lane_index = randi() % lane_manager.lane_count
	var max_x = lane_manager.lane_spacing * lane_manager.lane_count
	var at_x = randf() * max_x * 0.8 + max_x * 0.1  # 10%-90% of lane width
	
	return place_tower(tower_scene, lane_index, at_x)

## Place the default tower on a specific lane
func place_default_tower(lane_index: int, at_x: float) -> Node2D:
	return place_tower(default_tower_scene, lane_index, at_x)

## --- Tower removal ---

## Remove a single tower
func remove_tower(tower: Node2D) -> void:
	if not tower or not (tower in towers):
		return
	
	var lane_index = _find_tower_lane(tower)
	
	towers.erase(tower)
	if lane_index >= 0 and lane_index in towers_by_lane:
		towers_by_lane[lane_index].erase(tower)
	
	tower_removed.emit(tower, max(lane_index, 0))
	
	if tower.has_method("remove"):
		tower.remove()
	elif tower.has_method("queue_free"):
		tower.queue_free()
	
	print("[TowerManager] Tower removed.")

## Remove all towers from a specific lane
func clear_towers_on_lane(lane_index: int) -> void:
	var lane_towers = towers_by_lane.get(lane_index, [])
	for tower in lane_towers:
		remove_tower(tower)
	
	if lane_index in towers_by_lane:
		towers_by_lane[lane_index] = []
	
	lane_cleared.emit(lane_index)
	print("[TowerManager] All towers cleared from lane %d." % lane_index)

## Remove all towers globally
func clear_all_towers() -> void:
	var all_towers = towers.duplicate()
	for tower in all_towers:
		remove_tower(tower)
	
	towers_by_lane.clear()
	
	all_towers_cleared.emit()
	print("[TowerManager] All towers cleared.")

## --- Query helpers ---

## Get all active towers
func get_all_towers() -> Array[Node2D]:
	return towers

## Get towers on a specific lane
func get_towers_on_lane(lane_index: int) -> Array[Node2D]:
	return towers_by_lane.get(lane_index, [])

## Get the count of active towers
func get_tower_count() -> int:
	return towers.size()

## Get the count of towers on a specific lane
func get_tower_count_on_lane(lane_index: int) -> int:
	return towers_by_lane.get(lane_index, []).size()

## Check if a position (in world space) is within range of any tower
## Returns the nearest tower to the point, or null
func find_nearest_tower_to_point(point: Vector2) -> Node2D:
	var best_tower: Node2D = null
	var best_distance := INF
	
	for tower in towers:
		if not tower.is_alive:
			continue
		var tower_pos = tower.global_position
		var distance = tower_pos.distance_to(point)
		if distance < best_distance:
			best_distance = distance
			best_tower = tower
	
	return best_tower

## Find all towers that can target a specific enemy
func get_towers_targeting(enemy: Node2D) -> Array[Node2D]:
	var result: Array[Node2D] = []
	for tower in towers:
		if not tower.is_alive:
			continue
		if tower.has_method("is_in_range") and tower.is_in_range(enemy):
			result.append(tower)
	return result

## --- Internal ---

func _find_tower_lane(tower: Node2D) -> int:
	for lane_index in towers_by_lane:
		if tower in towers_by_lane[lane_index]:
			return lane_index
	return -1
