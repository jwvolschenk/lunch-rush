extends "res://tower/Tower.gd"
## Enchanted Vending Machine — randomly spawns grease, soup, or spice
## projectiles that auto-target the nearest enemy.
## Purple/magenta ColorRect sprite, range=200, cooldown=2.5.

func _on_ready_setup() -> void:
	range = 200.0
	damage = 5.0
	cooldown = 2.5
	projectile_scene = load("res://projectile/grease_projectile.tscn")
	sfx_name = "grease_fire"

## Randomly pick a food type before the parent fires.
## Picks grease(1), soup(2), or spice(3) at random.
func _fire() -> void:
	food_type = randi() % 3 + 1  # 1=grease, 2=soup, 3=spice
	.super()

func _build_visual() -> void:
	var sprite := ColorRect.new()
	sprite.set_size(Vector2(40, 40))
	sprite.color = Color(0.75, 0.0, 0.75)  # magenta/purple
	sprite.position = Vector2(-20, -20)
	add_child(sprite)
