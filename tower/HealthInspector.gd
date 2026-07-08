extends "res://tower/Tower.gd"
## Health Inspector — concrete tower that scares enemies backward on hit (pushback effect).
## Blue/white sprite. cooldown=4.0, range=250.
## Referenced in GOAL.md as a core tower type.

func _on_ready_setup() -> void:
	range = 250.0
	damage = 1.0
	cooldown = 4.0
	food_type = 0  # none
	projectile_scene = load("res://projectile/HealthInspectorProjectile.tscn")

func _build_visual() -> void:
	var sprite := ColorRect.new()
	sprite.set_size(Vector2(40, 40))
	sprite.color = Color(0.25, 0.45, 0.9, 1)
	sprite.position = Vector2(-20, -20)
	add_child(sprite)
