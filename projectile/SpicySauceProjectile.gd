extends "res://projectile/Projectile.gd"
## Spicy sauce projectile — fired by SpicySauceCannon tower.
## Red-orange ColorRect with burn (SPICE) food type.

func _on_ready_setup() -> void:
	speed = 350.0
	damage = 4.0
	splash_radius = 0.0
	sfx_name = "splash"

## Build the projectile visual: red-orange ColorRect
func _build_visual() -> void:
	var sprite := ColorRect.new()
	sprite.set_size(Vector2(18, 18))
	sprite.color = Color(1.0, 0.4, 0.05, 1)
	sprite.position = Vector2(-9, -9)
	add_child(sprite)

func _ready() -> void:
	_build_visual()
