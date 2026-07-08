extends "res://tower/Tower.gd"
## Pizza Trebuchet — slow splash-damage tower that launches fire pies.
## Orange ColorRect sprite, 300px range, 8 damage, 3s cooldown.

func _on_ready_setup() -> void:
	range = 300.0
	damage = 8.0
	cooldown = 3.0
	food_type = 3  # SPICE (fire pie = spicy)
	projectile_scene = load("res://projectile/fire_pie.tscn")

func _build_visual() -> void:
	var sprite := ColorRect.new()
	sprite.set_size(Vector2(40, 40))
	sprite.color = Color(0.95, 0.55, 0.1)
	sprite.position = Vector2(-20, -20)
	add_child(sprite)
