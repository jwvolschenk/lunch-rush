extends "res://tower/Tower.gd"
## Goblin Fry Cook — fast short-range tower that fires grease projectiles
## with area splash damage. Yellow ColorRect sprite with grease attack visual.

## --- Customization ---

## Called by Tower._ready() before _build_visual() to customize stats
func _on_ready_setup() -> void:
	range = 150.0
	damage = 3.0
	cooldown = 1.5
	food_type = 1  # GREASE

## Called by Tower._ready() after _on_ready_setup() to create visuals
func _build_visual() -> void:
	var sprite := ColorRect.new()
	sprite.set_size(Vector2(40, 40))
	sprite.color = Color(0.95, 0.85, 0.1)
	sprite.position = Vector2(-20, -20)
	add_child(sprite)
