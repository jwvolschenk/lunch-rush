extends "res://enemy/Enemy.gd"
## Ghost Chef — a floating enemy that partially phases through towers.
## Has a 50% dodge chance for 2s after taking damage, making it
## frustrating for tower-only strategies and rewarding craving-aware play.

## Duration of the dodge phase after taking damage
const DODGE_DURATION: float = 2.0

## Whether the ghost is currently phasing (dodging attacks)
var _is_dodging: bool = false

## Timer counting down the dodge phase
var _dodge_timer: float = 0.0

func _on_ready_setup() -> void:
	max_hp = 80.0
	speed = 90.0
	gold_reward = 25
	score_reward = 25

func _process(delta: float) -> void:
	if _is_dying or not is_alive:
		return

	# Count down dodge timer
	if _dodge_timer > 0:
		_dodge_timer -= delta
		if _dodge_timer <= 0:
			_dodge_timer = 0.0
			_is_dodging = false

	# Floating bob animation
	var sprite := get_child(0)
	if sprite:
		var bob := sin(Time.get_ticks_msecs() * 0.004) * 3.0
		sprite.position.y = bob

## Override take_damage to implement dodge logic
func take_damage(amount: float) -> void:
	if _is_dodging:
		# 50% chance to dodge during the active dodge window
		if randf() < 0.5:
			_flash_dodge()
			return

	# Apply damage and start dodge timer
	super.take_damage(amount)
	_is_dodging = true
	_dodge_timer = DODGE_DURATION

## Visual effect when dodging — brief transparency flash
func _flash_dodge() -> void:
	var sprite := get_child(0)
	if sprite:
		var original_color := sprite.color
		sprite.color.a = 0.3
		await get_tree().create_timer(0.15).timeout
		sprite.color = original_color
