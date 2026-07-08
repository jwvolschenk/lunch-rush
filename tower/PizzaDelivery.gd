extends "res://tower/Tower.gd"
## Pizza Delivery — a support tower that delivers pizzas to hungry enemies.
## Feeding an enemy its craving food slows or distracts them, buying the
## player time. Blue color, moderate range, fast cooldown, low damage.
## Ideal for crowd control and craving-aware play.

func _on_ready_setup() -> void:
	range = 250.0
	damage = 3.0
	cooldown = 0.8
	food_type = 2  # SOUP (pizza with soup sauce — the twist)
	projectile_scene = load("res://projectile/fire_pie.tscn")
	sfx_name = "pie_launch"

func _build_visual() -> void:
	var sprite := ColorRect.new()
	sprite.set_size(Vector2(40, 40))
	sprite.color = Color(0.2, 0.7, 0.9)
	sprite.position = Vector2(-20, -20)
	add_child(sprite)
