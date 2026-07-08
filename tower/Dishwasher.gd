extends "res://tower/Tower.gd"
## Dishwasher — fast short-range melee tower with high damage output.
## Steel-gray ColorRect sprite, fires steel-blue melee projectiles.
## High risk/reward: must be placed close to enemies to deal damage.

func _on_ready_setup() -> void:
	range = 80.0
	damage = 12.0
	cooldown = 0.8
	food_type = 0  # no craving effect for this tower
	projectile_scene = load("res://projectile/DishwasherMelee.tscn")

func _build_visual() -> void:
	var sprite := ColorRect.new()
	sprite.set_size(Vector2(40, 40))
	sprite.color = Color(0.55, 0.58, 0.62, 1)
	sprite.position = Vector2(-20, -20)
	add_child(sprite)
