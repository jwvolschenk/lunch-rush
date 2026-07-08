extends "res://enemy/Enemy.gd"
## Hungry Goblin — a basic enemy with 40 HP and 60px/s speed.
## ColorRect sprite with green fill.

func _on_ready_setup() -> void:
	max_hp = 40.0
	speed = 60.0
	gold_reward = 10
	score_reward = 10
	craving = 1  # GREASE — goblins love grease
