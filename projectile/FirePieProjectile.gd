extends "res://projectile/Projectile.gd"
## Fire pie projectile — launched by Pizza Trebuchet.
## Orange ColorRect with splash area damage.

func _on_ready_setup() -> void:
	speed = 350.0
	damage = 8.0
	splash_radius = 75.0

func _build_visual() -> void:
	var sprite := ColorRect.new()
	sprite.set_size(Vector2(20, 20))
	sprite.color = Color(0.95, 0.55, 0.1, 1)
	sprite.position = Vector2(-10, -10)
	add_child(sprite)

func _ready() -> void:
	_build_visual()
