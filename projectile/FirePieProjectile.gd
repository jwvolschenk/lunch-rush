extends "res://projectile/Projectile.gd"
## Fire pie projectile — launched by Pizza Trebuchet.
## Red-orange ColorRect with splash area damage.

## --- Configuration overrides ---

## Food type: 3 = SPICE
@export var food_type: int = 3

## Splash radius visual ring
@export var splash_radius_visual: ColorRect

func _on_ready_setup() -> void:
	speed = 300.0
	damage = 8.0
	splash_radius = 80.0
	sfx_name = "pie_launch"

## Build the projectile visual: red-orange ColorRect with splash ring
func _build_visual() -> void:
	## Splash radius ring
	var ring := ColorRect.new()
	ring.set_size(Vector2(160, 160))
	ring.color = Color(0.95, 0.35, 0.05, 0.25)
	ring.position = Vector2(-80, -80)
	add_child(ring)
	
	## Core sprite
	var sprite := ColorRect.new()
	sprite.set_size(Vector2(20, 20))
	sprite.color = Color(0.95, 0.55, 0.1, 1)
	sprite.position = Vector2(-10, -10)
	add_child(sprite)

func _ready() -> void:
	_build_visual()
