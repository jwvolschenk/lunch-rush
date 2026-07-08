extends "res://enemy/Enemy.gd"
## Ogre Brute — a high-HP tank enemy.
## Slow-moving, heavily armored, but drops a large gold reward.
## Served as a mid-wave boss-type enemy that forces players to bring
## sustained-damage towers instead of burst-only.

func _on_ready_setup() -> void:
	max_hp = 200.0
	speed = 25.0
	gold_reward = 50
	score_reward = 50

func _process(delta: float) -> void:
	# Heavy, lumbering stride: minimal bob for a brutal feel
	if is_alive and not _is_dying:
		var sprite := get_child(0)
		if sprite:
			var bob := sin(Time.get_ticks_msecs() * 0.005) * 1.5
			sprite.position.y = bob
