extends "res://tower/Tower.gd"
## Soup Spill — concrete tower that creates slowing puddles on hit.
## Blue ColorRect sprite. damage=2, slow_factor=0.5, slow_duration=5s.

func _on_ready_setup() -> void:
	range = 200.0
	damage = 2.0
	cooldown = 2.0
	food_type = 2  # SOUP
	projectile_scene = load("res://projectile/SoupProjectile.tscn")
	sfx_name = "soup_splash"

func _build_visual() -> void:
	var sprite := ColorRect.new()
	sprite.set_size(Vector2(40, 40))
	sprite.color = Color(0.1, 0.4, 0.95, 1)
	sprite.position = Vector2(-20, -20)
	add_child(sprite)
