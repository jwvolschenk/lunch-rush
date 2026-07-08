extends "res://enemy/Enemy.gd"
## Hungry Goblin — a basic enemy with 40 HP and 60px/s speed.
## ColorRect sprite with green fill.

func _on_ready_setup() -> void:
	max_hp = 40.0
	speed = 60.0
	gold_reward = 10
	score_reward = 10

func _process(delta: float) -> void:
	# Standard walk bob: oscillate Y position to simulate walking steps
	if is_alive and not _is_dying:
		var bob := sin(Time.get_ticks_msecs() * 0.01) * 2.0
		# Apply bob to the sprite child (first child is the ColorRect sprite)
		var sprite := get_child(0)
		if sprite:
			sprite.position.y = bob
