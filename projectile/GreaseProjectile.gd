extends "res://projectile/Projectile.gd"
## Grease projectile — fired by Goblin Fry Cook.
## Yellow-green ColorRect with splash area damage.

func _on_ready_setup() -> void:
	speed = 400.0
	damage = 3.0
	splash_radius = 50.0

## Build the projectile visual: yellow-green ColorRect
func _build_visual() -> void:
	var sprite := ColorRect.new()
	sprite.set_size(Vector2(16, 16))
	sprite.color = Color(0.9, 0.8, 0.15)
	sprite.position = Vector2(-8, -8)
	add_child(sprite)

func _ready() -> void:
	_build_visual()
