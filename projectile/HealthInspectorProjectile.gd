extends "res://projectile/Projectile.gd"
## Health Inspector projectile — fired by HealthInspector tower.
## White/blue ColorRect with pushback effect (pushback=80px).
## Scares enemies backward toward spawn on hit.

func _on_ready_setup() -> void:
	speed = 450.0
	damage = 1.0
	splash_radius = 0.0
	pushback = 80.0
	food_type = 0  # none (not food-based)

## Build the projectile visual: white/blue ColorRect
func _build_visual() -> void:
	var sprite := ColorRect.new()
	sprite.set_size(Vector2(20, 20))
	sprite.color = Color(0.3, 0.5, 0.95, 1)
	sprite.position = Vector2(-10, -10)
	add_child(sprite)

func _ready() -> void:
	_build_visual()
