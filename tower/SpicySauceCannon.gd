extends "res://tower/Tower.gd"
## Spicy Sauce Cannon — burns enemies with spicy sauce projectiles.
## Red-orange ColorRect sprite with SPICE food-type projectile that
## applies burn/dot damage to enemies.

func _on_ready_setup() -> void:
	range = 180.0
	damage = 4.0
	cooldown = 1.5
	projectile_scene = load("res://projectile/spicy_sauce_projectile.tscn")
	sfx_name = "splash"

func _build_visual() -> void:
	var sprite := ColorRect.new()
	sprite.set_size(Vector2(40, 40))
	sprite.color = Color(0.95, 0.35, 0.05, 1)
	sprite.position = Vector2(-20, -20)
	add_child(sprite)
