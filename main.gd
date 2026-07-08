extends Node2D
## Main — root scene for the game.
## Connects core systems (GameState, LaneManager) and drives
## the top-level game loop.

## --- Core system references ---
var lane_manager: LaneManager

## --- Lifecycle ---
func _ready() -> void:
	# Reference the autoload
	lane_manager = LaneManager
	
	# Connect game state signals
	GameState.state_changed.connect(_on_state_changed)
	GameState.health_depleted.connect(_on_game_over)
	
	# Connect lane signals
	LaneManager.enemy_reached_kitchen.connect(_on_enemy_reached_kitchen)
	LaneManager.enemy_died.connect(_on_enemy_died)
	
	# Start the run
	GameState.start_run()
	print("[Main] Game started.")

## --- State management ---
func _on_state_changed(new_state: int) -> void:
	match GameState.state:
		GameState.GameState.PLAYING:
			print("[Main] State: PLAYING")
		GameState.GameState.WAVE_COMPLETE:
			print("[Main] State: WAVE_COMPLETE")
		GameState.GameState.GAME_OVER:
			print("[Main] State: GAME_OVER")

## --- Callbacks ---
func _on_game_over() -> void:
	print("[Main] Game over! Health depleted.")
	GameState.state = GameState.GameState.GAME_OVER

func _on_enemy_reached_kitchen(enemy: Node2D, lane_index: int) -> void:
	print("[Main] Enemy reached kitchen on lane %d." % lane_index)
	GameState.take_damage(1)

func _on_enemy_died(enemy: Node2D, lane_index: int) -> void:
	print("[Main] Enemy died on lane %d." % lane_index)
	GameState.add_gold(10)
	GameState.add_score(10)
