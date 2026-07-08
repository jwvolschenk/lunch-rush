extends Node2D
## Main — root scene for the game.
## Connects core systems (GameState, LaneManager) and drives
## the top-level game loop.

## --- Core system references ---
var lane_manager: LaneManager

## --- Card selection ---
var card_selection: CardSelection

## --- Room selection ---
var room_selector: RoomSelector

## --- Lifecycle ---
func _ready() -> void:
	# Reference the autoload
	lane_manager = LaneManager
	
	# Reference the card selection UI
	card_selection = $CardSelection
	
	# Reference the room selector
	room_selector = $RoomSelector
	if room_selector:
		room_selector.room_selected.connect(_on_room_selected)
	
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
			if card_selection:
				card_selection.hide_cards()
		GameState.GameState.WAVE_COMPLETE:
			print("[Main] State: WAVE_COMPLETE")
			# Show room selection first; cards appear after room is picked
			if room_selector:
				var rooms = _get_room_choices()
				room_selector.show_rooms(rooms)
		GameState.GameState.GAME_OVER:
			print("[Main] State: GAME_OVER")
			if card_selection:
				card_selection.hide_cards()

## --- Room choices ---
func _get_room_choices() -> Array:
	return [
		{
			"room_name": "Pantry",
			"description": "Standard pantry. Balanced room with no modifiers.",
			"room_type": 0,
			"bg_color": Color(0.1, 0.1, 0.1, 1),
			"accent_color": Color(0.6, 0.6, 0.3, 1),
			"border_color": Color(0.3, 0.3, 0.3, 1),
			"enemy_hp_modifier": 1.0,
			"enemy_speed_modifier": 1.0,
			"enemy_count_modifier": 0,
			"gold_bonus": 0,
		},
		{
			"room_name": "Freezer",
			"description": "Enemies move slower but have more HP. Gold bonus.",
			"room_type": 1,
			"bg_color": Color(0.1, 0.15, 0.25, 1),
			"accent_color": Color(0.3, 0.7, 0.9, 1),
			"border_color": Color(0.2, 0.3, 0.5, 1),
			"enemy_hp_modifier": 1.2,
			"enemy_speed_modifier": 0.75,
			"enemy_count_modifier": 0,
			"gold_bonus": 20,
		},
		{
			"room_name": "Lava Kitchen",
			"description": "Enemies are tougher and faster. Higher gold reward.",
			"room_type": 2,
			"bg_color": Color(0.25, 0.05, 0.05, 1),
			"accent_color": Color(0.9, 0.3, 0.1, 1),
			"border_color": Color(0.5, 0.1, 0.05, 1),
			"enemy_hp_modifier": 1.5,
			"enemy_speed_modifier": 1.2,
			"enemy_count_modifier": 1,
			"gold_bonus": 50,
		},
	]

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

## --- Room selection callback ---
func _on_room_selected(room_data: Resource) -> void:
	print("[Main] Room selected: %s" % room_data.room_name)
	GameState.current_room = room_data
	# Transition to WAVE_COMPLETE_SHOW_CARDS to trigger card display
	_show_card_selection()

## --- Card selection display ---
func _show_card_selection() -> void:
	if card_selection:
		var starter_cards = _get_starter_cards()
		card_selection.show_cards(starter_cards)

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
