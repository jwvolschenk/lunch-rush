extends "res://enemy/Enemy.gd"
## PizzaDelivery — a fast enemy on a pizza scooter.
## Zooms toward the kitchen fast, craving pizza. Feeding pizza slows them;
## wrong food enrages them. A fast, threatening enemy that rewards
## craving-aware play.

const BOB_RATE: float = 9.0

func _on_ready_setup() -> void:
	max_hp = 45.0
	speed = 140.0
	gold_reward = 15
	score_reward = 15

func _process(delta: float) -> void:
	if _is_dying or not is_alive:
		return

	# Scooter bob animation — faster than goblin
	var sprite := get_child(0)
	if sprite:
		var t := Time.get_ticks_msecs() * 0.001
		var bob := sin(t * BOB_RATE) * 3.0
		sprite.position.y = bob
