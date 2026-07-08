extends Node2D
## Tower — base class for all tower types.
## Towers sit on lanes, target enemies in range, and fire projectiles.
##
## Child scenes should override _on_ready_setup() to customize
## appearance, stats, and projectile type.

## --- Configuration ---

## Range in pixels
@export var range: float = 200.0

## Damage dealt per hit
@export var damage: float = 5.0

## Cooldown between shots in seconds
@export var cooldown: float = 1.5

## The projectile scene to instantiate on attack
@export var projectile_scene: PackedScene

## --- Internal state ---

## The lane this tower is placed on
var lane: Lane = null

## The X position on the lane where this tower is placed
var tower_x: float = 0.0

## Whether the tower is currently attacking
var is_attacking: bool = false

## Timer for cooldown
var _fire_timer: float = 0.0

## The currently targeted enemy (if any)
var _target: Node2D = null

## --- Signals ---

## Emitted when this tower fires a projectile
signal tower_fired(tower: Node2D, projectile: Node2D, target: Node2D)

## Emitted when this tower loses its target
signal tower_target_lost(tower: Node2D)

## --- Lifecycle ---

func _ready() -> void:
	_on_ready_setup()
	_build_visual()

## Override in child scenes to customize visual appearance
func _build_visual() -> void:
	pass

## Override in child scenes to customize initial stats
func _on_ready_setup() -> void:
	pass

## --- Tower state ---

var is_alive: bool = true

## Check if an enemy is in range of this tower
func is_in_range(enemy: Node2D) -> bool:
	if not enemy:
		return false
	var enemy_pos = enemy.global_position
	var tower_pos = global_position
	var distance = tower_pos.distance_to(enemy_pos)
	return distance <= range

## Find the nearest enemy in range, prioritizing enemies closest to the kitchen
func find_target() -> Node2D:
	if not lane:
		return null
	
	var best_target: Node2D = null
	var best_kitchen_distance := INF
	
	for enemy in lane.get_enemies():
		if not enemy.is_alive:
			continue
		if not is_in_range(enemy):
			continue
		
		var kitchen_distance = enemy.position.x
		if kitchen_distance < best_kitchen_distance:
			best_kitchen_distance = kitchen_distance
			best_target = enemy
	
	return best_target

## Start targeting and begin firing
func start_targeting() -> void:
	_target = find_target()
	if _target:
		is_attacking = true
		_fire_timer = 0

## Stop targeting (e.g., tower removed or all enemies dead)
func stop_targeting() -> void:
	if _target:
		tower_target_lost.emit(self)
		_target = null
	is_attacking = false

## Try to fire at the current target
func _try_fire() -> void:
	if not is_attacking or not _target or not _target.is_alive:
		_target = find_target()
		if not _target:
			return
		_fire_timer = cooldown
		return
	
	if not is_in_range(_target):
		_target = find_target()
		if not _target:
			return
		_fire_timer = cooldown
		return
	
	_fire()

## Fire a projectile at the current target
func _fire() -> void:
	if not projectile_scene:
		print("[Tower] No projectile_scene assigned.")
		return
	
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position + Vector2(0, 20)
	projectile.target = _target
	projectile.damage = damage
	add_sibling(projectile)
	
	tower_fired.emit(self, projectile, _target)
	_fire_timer = cooldown

## Place this tower at a specific position on a lane
func place_on_lane(lane_node: Lane, at_x: float) -> void:
	lane = lane_node
	tower_x = at_x
	position.x = at_x
	position.y = lane.y + 40.0
	global_position = position

## Remove this tower (called by TowerManager on removal)
func remove() -> void:
	is_alive = false
	stop_targeting()
	queue_free()

## Called from _process each frame
func _process(delta: float) -> void:
	if not is_alive:
		return
	
	_fire_timer -= delta
	if _fire_timer <= 0:
		_try_fire()
