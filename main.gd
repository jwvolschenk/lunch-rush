extends Node2D
## Main — root scene for the game.
## Connects core systems (GameState, LaneManager) and drives
## the top-level game loop.

## --- Core system references ---
var lane_manager: LaneManager
var hud: Control

## --- Camera ---
var camera_controller: CameraController

## --- Card selection ---
var card_selection: CardSelection

## --- Room selection ---
var room_selector: RoomSelector

## --- Game-over overlay ---
var game_over_overlay: GameOverOverlay

## --- Wave management ---
var _next_wave_ready: bool = false

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
	
	# Reference the game-over overlay
	game_over_overlay = $GameOverOverlay
	if game_over_overlay:
		game_over_overlay.restart_requested.connect(_on_restart)
		game_over_overlay.quit_requested.connect(_on_quit)
	
	# Reference the HUD
	hud = $HUD
	if hud:
		print("[Main] HUD loaded.")
	
	# Reference the camera controller
	camera_controller = $CameraController
	if camera_controller:
		print("[Main] Camera controller loaded.")
	
	# Connect game state signals
	GameState.state_changed.connect(_on_state_changed)
	GameState.health_depleted.connect(_on_game_over)
	
	# Connect wave signals
	WaveManager.wave_started.connect(_on_wave_started)
	WaveManager.wave_complete.connect(_on_wave_complete)
	WaveManager.enemy_spawned.connect(_on_enemy_spawned)
	WaveManager.enemy_died.connect(_on_enemy_died)
	
	# Connect card selection signal
	card_selection.card_selected.connect(_on_card_selected)
	
	# Connect continue requested signal
	card_selection.continue_requested.connect(_on_continue_requested)
	
	# Connect lane signals
	LaneManager.enemy_reached_kitchen.connect(_on_enemy_reached_kitchen)
	LaneManager.enemy_died.connect(_on_enemy_died)
	
	# Connect WaveManager to LaneManager for enemy death tracking
	LaneManager.enemy_died.connect(WaveManager._on_enemy_died)
	
	# Start the run
	GameState.start_run()
	_start_first_wave()
	print("[Main] Game started.")

## --- Wave progression ---

## Start the very first wave after the run begins.
func _start_first_wave() -> void:
	WaveManager.start_wave(0)
	_next_wave_ready = true
	print("[Main] Wave 1 started.")

## --- Per-frame updates ---
func _process(delta: float) -> void:
	if camera_controller and GameState.state == GameState.GameState.PLAYING:
		_collect_all_enemies()

var _all_enemies: Array[Node2D] = []

func _collect_all_enemies() -> void:
	_all_enemies.clear()
	var all_lanes = LaneManager.get_all_lanes()
	for lane in all_lanes:
		for enemy in lane.get_enemies():
			if enemy and not enemy.is_queued_for_deletion():
				_all_enemies.append(enemy)
	if camera_controller:
		camera_controller.update_target(_all_enemies)

## --- State management ---
func _on_state_changed(new_state: int) -> void:
	match GameState.state:
		GameState.GameState.PLAYING:
			print("[Main] State: PLAYING")
			if card_selection:
				card_selection.hide_cards()
			if room_selector:
				room_selector.hide_rooms()
		GameState.GameState.WAVE_COMPLETE:
			print("[Main] State: WAVE_COMPLETE")
			# Show card selection first (3 card choices for the player)
			if card_selection:
				_show_card_selection()
			if room_selector:
				room_selector.hide_rooms()
		GameState.GameState.GAME_OVER:
			print("[Main] State: GAME_OVER")
			if card_selection:
				card_selection.hide_cards()
			if room_selector:
				room_selector.hide_rooms()
			if game_over_overlay:
				game_over_overlay.show_game_over(
					GameState.score,
					GameState.waves_completed,
					GameState.gold,
					GameState.health
				)

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
	# Apply the card effect (place tower or apply buff)
	_apply_card_effect(card_data)
	# Notify CardPool to record this card
	CardPool.record_card_played(card_data)
	# Discard the played card from hand
	DeckManager.discard_card(card_data)
	# Signal WaveManager that a card was selected (primes next wave start)
	var wave_started = WaveManager.on_card_selected()
	# Transition back to PLAYING after card is selected
	# Only if wave wasn't already started (room selector will handle it)
	if not wave_started:
		GameState.state = GameState.GameState.PLAYING
		# Show room selector overlay (player can still choose room)
		_show_room_selector()

## --- Continue handler (called after player clicks overlay to confirm) ---
func _on_continue_requested() -> void:
	_show_room_selector()

## --- Apply a card effect ---
func _apply_card_effect(card_data: Dictionary) -> void:
	match card_data.card_type:
		1:  # Tower card — place on first available lane
			_place_tower_from_card(card_data)
		2:  # Status effect card
			print("[Main] Applying effect: %s" % card_data.name)
		_:
			print("[Main] Unknown card type for: %s" % card_data.name)

## --- Tower placement from card ---
func _place_tower_from_card(card_data: Dictionary) -> void:
	var cost = card_data.get("cost", 0)
	if GameState.gold < cost:
		print("[Main] Not enough gold to place tower '%s' (need %d, have %d)." % [card_data.name, cost, GameState.gold])
		return
	
	if not GameState.spend_gold(cost):
		print("[Main] Failed to spend gold for tower '%s'." % card_data.name)
		return
	
	if not card_data.has("tower_scene"):
		print("[Main] No tower_scene on card: %s" % card_data.name)
		return
	
	var tower_scene = load(card_data.tower_scene)
	if not tower_scene:
		print("[Main] Failed to load tower scene: %s" % card_data.tower_scene)
		return
	
	# Find first available lane (use LaneManager to get valid lanes)
	var lane_index = 0
	if LaneManager.lane_count > 0:
		lane_index = randi() % LaneManager.lane_count
	
	# Place tower at a random position on the lane
	var at_x = randf() * 600.0 + 100.0
	var tower = TowerManager.place_tower(tower_scene, lane_index, at_x)
	
	if tower:
		print("[Main] Placed tower '%s' on lane %d (cost: %d gold)." % [card_data.name, lane_index, cost])
	else:
		print("[Main] Failed to place tower '%s'." % card_data.name)

## --- Room selection callback ---
func _on_room_selected(room_data: Resource) -> void:
	print("[Main] Room selected: %s" % room_data.room_name)
	GameState.current_room = room_data
	# Start the next wave after room is selected
	WaveManager.start_next_wave()
	GameState.state = GameState.GameState.PLAYING
	if room_selector:
		room_selector.hide_rooms()

## --- Card selection display ---
func _show_card_selection() -> void:
	if not card_selection:
		return
	
	# Priority: use pending cards generated by WaveManager for this wave transition
	if "pending_cards" in GameState and GameState.pending_cards.size() > 0:
		card_selection.show_cards(GameState.pending_cards)
		# Clear pending cards so they're not shown again
		GameState.pending_cards.clear()
		return
	
	# Fallback 1: use current deck hand
	var hand = DeckManager.get_hand()
	if hand and hand.size() > 0:
		card_selection.show_cards(hand)
		return
	
	# Fallback 2: show starter pool
	var starter_cards = _get_starter_cards()
	card_selection.show_cards(starter_cards)

## --- Room selection display ---
func _show_room_selector() -> void:
	if room_selector:
		var rooms = _get_room_choices()
		room_selector.show_rooms(rooms)

## --- Callbacks ---
func _on_game_over() -> void:
	print("[Main] Game over! Health depleted.")
	WaveManager.reset()
	GameState.state = GameState.GameState.GAME_OVER

func _on_wave_started(wave_config: WaveConfig, wave_index: int) -> void:
	print("[Main] Wave %d started: %s" % [wave_index + 1, wave_config.description])

func _on_wave_complete(wave_index: int) -> void:
	print("[Main] Wave %d complete! Awarded %d gold." % [
		wave_index + 1, GameState.wave_gold_reward
	])
	GameState.waves_completed += 1
	# Draw cards from deck into hand for the next wave
	DeckManager.draw_for_wave()

func _on_enemy_spawned(enemy: Node2D, lane_index: int) -> void:
	pass

func _on_enemy_reached_kitchen(enemy: Node2D, lane_index: int) -> void:
	print("[Main] Enemy reached kitchen on lane %d." % lane_index)
	GameState.take_damage(1)

func _on_enemy_died(enemy: Node2D, lane_index: int) -> void:
	print("[Main] Enemy died on lane %d." % lane_index)
	var gold = 10
	if enemy and "gold_reward" in enemy:
		gold = enemy.gold_reward
	GameState.add_gold(gold)
	GameState.add_score(10)

## --- Restart / Quit ---
func _on_restart() -> void:
	print("[Main] Restarting run...")
	if game_over_overlay:
		game_over_overlay.hide_game_over()
	GameState.start_run()
	_start_first_wave()

func _on_quit() -> void:
	print("[Main] Quitting to menu...")
	if game_over_overlay:
		game_over_overlay.hide_game_over()
	get_tree().change_scene_to_file("res://main.tscn")
