extends Node2D
## Projectile — base class for all tower attack projectiles.
## Moves toward its target, deals damage on collision, then self-destructs.
##
## Usage:
##   Instantiate from Tower._fire(), set target and damage,
##   then add as sibling to the tower's node tree.

## --- Configuration ---

## Speed in pixels per second
@export var speed: float = 400.0

## Damage to deal on hit
@export var damage: float = 5.0

## Splash radius for area damage (0 = single target only)
@export var splash_radius: float = 0.0

## Food type this projectile represents (for craving checks).
## 0=none, 1=grease, 2=soup, 3=spice, 4=pizza (matches CravingType enum).
var food_type: int = 0

## Pushback distance in pixels (0 = no pushback).
## When > 0, pushes the enemy backward (toward spawn) on hit.
var pushback: float = 0.0

## SFX name to play on fire. Set by the firing Tower before the projectile
## is instantiated. Maps to a key in SoundManager's loaded SFX dictionary.
var sfx_name: String = ""

## --- Internal state ---

## The target enemy (set by the firing tower)
var target: Node2D = null

## Whether this projectile is still active
var is_alive: bool = true

## --- Signals ---

## Emitted when this projectile hits an enemy. Args: (projectile, enemy, splash_enemies)
signal projectile_hit(projectile: Node2D, enemy: Node2D, splash_enemies: Array[Node2D])

## Emitted when this projectile is destroyed (hit or expired). Args: (projectile)
signal projectile_destroyed(projectile: Node2D)

## --- Lifecycle ---

func _ready() -> void:
	_build_visual()
	_fire_sfx()

## Play the tower-specific fire SFX for this projectile.
func _fire_sfx() -> void:
	if sfx_name.is_empty():
		return
	SoundManager.play_sfx(sfx_name)

## Override in child scenes to customize visual appearance
func _build_visual() -> void:
	pass

func _process(delta: float) -> void:
	if not is_alive:
		return
	
	if not target or not target.is_alive:
		target = _find_new_target()
	
	if target and target.is_alive:
		_move_toward_target(delta)
	else:
		_destroy()

## --- Movement ---

## Move this projectile toward its current target
func _move_toward_target(delta: float) -> void:
	if not target:
		_destroy()
		return
	
	var direction = (target.global_position - global_position).normalized()
	global_position += direction * speed * delta
	
	## Check if projectile has reached the target
	var distance = global_position.distance_to(target.global_position)
	if distance < 10.0:
		_hit()

## Find a new target if the current one is dead or lost
func _find_new_target() -> Node2D:
	## Look at all lanes for active enemies
	var lane_manager = get_tree().get_root().get_node("LaneManager")
	if not lane_manager:
		return null
	
	for lane in lane_manager.lanes:
		for enemy in lane.get_enemies():
			if enemy.is_alive:
				return enemy
	return null

## --- Collision ---

## Deal damage when this projectile reaches its target
func _hit() -> void:
	var splash_enemies: Array[Node2D] = []
	
	if target and target.is_alive:
		## Deal damage to primary target
		if target.has_method("take_damage"):
			target.take_damage(damage)
		
		## Apply pushback effect to primary target
		if pushback > 0 and target.has_method("apply_pushback"):
			target.apply_pushback(pushback)
		
		## Apply craving effect to primary target
		_apply_craving_effect(target)
		
		## Apply splash damage to nearby enemies if configured
		if splash_radius > 0:
			splash_enemies = _get_enemies_in_splash_area()
			for enemy in splash_enemies:
				if enemy != target and enemy.has_method("take_damage"):
					enemy.take_damage(damage)
					if pushback > 0 and enemy.has_method("apply_pushback"):
						enemy.apply_pushback(pushback)
					_apply_craving_effect(enemy)
		
		projectile_hit.emit(self, target, splash_enemies)
	
	_destroy()

## Get enemies within splash radius of the current position
func _get_enemies_in_splash_area() -> Array[Node2D]:
	var result: Array[Node2D] = []
	var lane_manager = get_tree().get_root().get_node("LaneManager")
	if not lane_manager:
		return result
	
	for lane in lane_manager.lanes:
		for enemy in lane.get_enemies():
			if not enemy.is_alive:
				continue
			var distance = global_position.distance_to(enemy.global_position)
			if distance <= splash_radius:
				result.append(enemy)
	return result

## Apply craving-based debuff/buff to an enemy based on food_type vs their craving.
func _apply_craving_effect(enemy: Node2D) -> void:
	if food_type == 0 or not enemy.has_method("craving"):
		return
	if enemy.craving == food_type:
		## Matching craving: slow for 5 seconds
		enemy.apply_slow(0.7, 5.0)
		print("[Projectile] Hit enemy with matching craving — slow!")
	else:
		## Mismatching craving: enrage for 3 seconds
		enemy.apply_enrage(1.2, 3.0)
		print("[Projectile] Hit enemy with wrong craving — enrage!")

## --- Destruction ---

## Destroy this projectile and clean up
func _destroy() -> void:
	if not is_alive:
		return
	is_alive = false
	projectile_destroyed.emit(self)
	queue_free()
