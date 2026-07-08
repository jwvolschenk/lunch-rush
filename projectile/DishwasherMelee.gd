extends "res://projectile/Projectile.gd"
## Melee projectile fired by the Dishwasher tower.
## Very high speed for instant-hit feel. Steel-blue ColorRect visual.

func _on_ready_setup() -> void:
	speed = 800.0
	damage = 12.0
	splash_radius = 0.0

func _build_visual() -> void:
	var sprite := ColorRect.new()
	sprite.set_size(Vector2(14, 14))
	sprite.color = Color(0.45, 0.52, 0.68, 1)
	sprite.position = Vector2(-7, -7)
	add_child(sprite)

func _ready() -> void:
	_build_visual()
