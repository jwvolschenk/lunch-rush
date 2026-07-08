extends Node2D
## Main — root scene for the game.
## Connects core systems (GameState, LaneManager) and drives
## the top-level game loop.

## --- Core system references ---
var lane_manager: LaneManager

## --- Card selection ---
var card_selection: CardSelection

## --- Lifecycle ---
func _ready() -> void:
	# Reference the autoload
	lane_manager = LaneManager
	
	# Reference the card selection UI
	card_selection = $CardSelection
	
	# Connect game state signals
	GameState.state_changed.connect(_on_state_changed)
	GameState.health_depleted.connect(_on_game_over)
	
	# Connect card selection signal
	card_selection.card_selected.connect(_on_card_selected)
	
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
			# Hide card selection when returning to PLAYING
			if card_selection:
				card_selection.hide_cards()
		GameState.GameState.WAVE_COMPLETE:
			print("[Main] State: WAVE_COMPLETE")
			# Show card selection with starter cards
			if card_selection:
				var starter_cards = _get_starter_cards()
				card_selection.show_cards(starter_cards)
		GameState.GameState.GAME_OVER:
			print("[Main] State: GAME_OVER")
			if card_selection:
				card_selection.hide_cards()

## --- Starter card definitions ---
func _get_starter_cards() -> Array:
	return [
		{
			"name": "Goblin Fry Cook",
			"description": "Fast short-range grease attack. Deals area splash damage.",
			"cost": 25,
			"card_type": 1,
			"icon_color": Color(0.9, 0.8, 0.2, 1),
		},
		{
			"name": "Pizza Trebuchet",
			"description": "Slow splash-damage tower. Launches pies at groups of enemies.",
			"cost": 50,
			"card_type": 1,
			"icon_color": Color(0.9, 0.5, 0.2, 1),
		},
		{
			"name": "Soup Spill",
			"description": "Creates a slowing puddle that damages and slows enemies.",
			"cost": 35,
			"card_type": 2,
			"icon_color": Color(0.4, 0.7, 0.9, 1),
		},
	]

## --- Card selection callback ---
func _on_card_selected(card_data: Dictionary) -> void:
	print("[Main] Selected card: %s (cost: %d)" % [card_data.name, card_data.cost])
	GameState.gold -= card_data.cost
	# Apply the card effect (place tower or apply buff)
	_apply_card_effect(card_data)
	# Transition back to PLAYING
	GameState.state = GameState.GameState.PLAYING

## --- Apply a card effect ---
func _apply_card_effect(card_data: Dictionary) -> void:
	match card_data.card_type:
		1:  # Tower card — place on first available lane
			print("[Main] Placing tower: %s" % card_data.name)
		2:  # Status effect card
			print("[Main] Applying effect: %s" % card_data.name)
		_:
			print("[Main] Unknown card type for: %s" % card_data.name)

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
