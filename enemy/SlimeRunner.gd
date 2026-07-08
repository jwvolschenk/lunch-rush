extends "res://enemy/Enemy.gd"
## Slime Runner — a fast low-HP enemy.
## Squishy, wobbly, and quick. Low HP (30) but very fast (150px/s).
## Creates a speed-vs-tower tradeoff: cheap to spawn but hard to stop
## before they reach the kitchen, rewarding players who build early
## anti-speed defenses (soups, slows) over raw damage towers.

const SLIME_SCALE: float = 1.2
const WOBBLERATE: float = 7.0

func _on_ready_setup() -> void:
	max_hp = 30.0
	speed = 150.0
	gold_reward = 5
	score_reward = 5

func _process(delta: float) -> void:
	if _is_dying or not is_alive:
		return

	# Wobbly, squishy animation — faster bob than goblin
	var sprite := get_child(0)
	if sprite:
		var t := Time.get_ticks_msecs() * 0.001
		var bob := sin(t * WOBBLERATE) * 2.5
		var squash := sin(t * WOBBLERATE * 0.5) * 3.0
		sprite.position.y = bob
		sprite.scale = Vector2(1.0 + squash * 0.03, 1.0 - squash * 0.03)
