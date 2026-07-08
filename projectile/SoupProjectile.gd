extends "res://projectile/Projectile.gd"
## Soup projectile — fired by Soup Spill tower.
## Blue ColorRect with slow effect on hit (slow_factor=0.5, duration=5s).

func _on_ready_setup() -> void:
	speed = 380.0
	damage = 2.0
	splash_radius = 40.0
	sfx_name = "soup_splash"

func _build_visual() -> void:
	var sprite := ColorRect.new()
	sprite.set_size(Vector2(18, 18))
	sprite.color = Color(0.15, 0.5, 0.95, 1)
	sprite.position = Vector2(-9, -9)
	add_child(sprite)

func _ready() -> void:
	_build_visual()
