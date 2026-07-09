extends Node2D
## Main — root scene for the game.
## Connects core systems (GameState, LaneManager) and drives
## the top-level game loop.

## --- Core system references ---

const ROOM_DATA_SCRIPT = preload("res://rooms/RoomData.gd")
const CRAVING_TYPE = preload("res://enums/CravingType.gd")


var lane_manager: LaneManager
var hud: Control

## --- Camera ---
var camera_controller: Node2D

## --- Card selection ---
var card_selection: Control

## --- Room selection ---
var room_selector: Control

## --- Game-over overlay ---
var game_over_overlay: Control

## --- Victory overlay ---
var victory_overlay: Control
## --- Unlock display ---
var unlocks_overlay: Control

## --- Pending unlocks ---
var _pending_unlocks: Dictionary = {}
var _next_wave_ready: bool = true


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

# Reference the victory overlay
	victory_overlay = $VictoryOverlay
	if victory_overlay:
		GameState.victory.connect(_on_victory)
		victory_overlay.restart_requested.connect(_on_restart)
		victory_overlay.quit_requested.connect(_on_quit)
	
	# Reference the HUD
	hud = $HUD
	if hud:
		print("[Main] HUD loaded.")
	
# Reference the camera controller
	camera_controller = $CameraController
	if camera_controller:
		print("[Main] Camera controller loaded.")
	
	# Reference the unlocks overlay
	unlocks_overlay = $UnlocksOverlay
	
# Connect game state signals
	GameState.state_changed.connect(_on_state_changed)
	GameState.health_depleted.connect(_on_game_over)
	WaveManager.wave_complete.connect(_on_wave_complete)
	WaveManager.wave_complete.connect(_on_wave_completed_check_unlocks)
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
	
	# Connect tower placement preview signal
	InputManager.tower_placement_requested.connect(_on_tower_placement_requested)
	InputManager.tower_placement_cancelled.connect(_on_tower_placement_cancelled)
	
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
	if camera_controller and GameState.state == GameState.GameMode.PLAYING:
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
		GameState.GameMode.PLAYING:
			print("[Main] State: PLAYING")
			if card_selection:
				card_selection.hide_cards()
			if room_selector:
				room_selector.hide_rooms()
			if hud:
				hud.show_hand()
		GameState.GameMode.WAVE_COMPLETE:
			print("[Main] State: WAVE_COMPLETE")
			# Show card selection first (3 card choices for the player)
			if card_selection:
				_show_card_selection()
			if room_selector:
				room_selector.hide_rooms()
		GameState.GameMode.ROOM_SELECTING:
			print("[Main] State: ROOM_SELECTING")
			# Room selector is the active UI — don't hide it
			if card_selection:
				card_selection.hide_cards()
		GameState.GameMode.GAME_OVER:
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
					GameState.health,
					SaveLoad.get_high_score(),
					_pending_unlocks
				)
				_pending_unlocks = {}
			if hud:
				hud.hide_hand()
		GameState.GameMode.VICTORY:
			print("[Main] State: VICTORY — All waves completed!")
			if card_selection:
				card_selection.hide_cards()
			if room_selector:
				room_selector.hide_rooms()
			if victory_overlay:
				victory_overlay.show_victory(
					GameState.score,
					GameState.wave,
					GameState.gold,
					GameState.health,
					SaveLoad.get_high_score(),
					_pending_unlocks
				)
				_pending_unlocks = {}
			if hud:
				hud.hide_hand()

## --- Room choices ---
func _get_room_choices() -> Array:
	var rooms: Array = []
	
	var pantry = ROOM_DATA_SCRIPT.new()
	pantry.room_name = "Pantry"
	pantry.description = "Standard pantry. Balanced room with no modifiers."
	pantry.room_type = ROOM_DATA_SCRIPT.RoomType.PANTRY
	pantry.bg_color = Color(0.1, 0.1, 0.1, 1)
	pantry.accent_color = Color(0.6, 0.6, 0.3, 1)
	pantry.border_color = Color(0.3, 0.3, 0.3, 1)
	pantry.enemy_hp_modifier = 1.0
	pantry.enemy_speed_modifier = 1.0
	pantry.enemy_count_modifier = 0
	pantry.gold_bonus = 0
	rooms.append(pantry)
	
	var freezer = ROOM_DATA_SCRIPT.new()
	freezer.room_name = "Freezer"
	freezer.description = "Enemies move slower but have more HP. Gold bonus."
	freezer.room_type = ROOM_DATA_SCRIPT.RoomType.FREEZER
	freezer.bg_color = Color(0.1, 0.15, 0.25, 1)
	freezer.accent_color = Color(0.3, 0.7, 0.9, 1)
	freezer.border_color = Color(0.2, 0.3, 0.5, 1)
	freezer.enemy_hp_modifier = 1.2
	freezer.enemy_speed_modifier = 0.75
	freezer.enemy_count_modifier = 0
	freezer.gold_bonus = 20
	rooms.append(freezer)
	
	var lava = ROOM_DATA_SCRIPT.new()
	lava.room_name = "Lava Kitchen"
	lava.description = "Enemies are tougher and faster. Higher gold reward."
	lava.room_type = ROOM_DATA_SCRIPT.RoomType.LAVA_KITCHEN
	lava.bg_color = Color(0.25, 0.05, 0.05, 1)
	lava.accent_color = Color(0.9, 0.3, 0.1, 1)
	lava.border_color = Color(0.5, 0.1, 0.05, 1)
	lava.enemy_hp_modifier = 1.5
	lava.enemy_speed_modifier = 1.2
	lava.enemy_count_modifier = 1
	lava.gold_bonus = 50
	rooms.append(lava)
	
	var vip = ROOM_DATA_SCRIPT.new()
	vip.room_name = "VIP Table"
	vip.description = "Premium dining experience. Fast enemies but lots of gold."
	vip.room_type = ROOM_DATA_SCRIPT.RoomType.VIP_TABLE
	vip.bg_color = Color(0.2, 0.15, 0.3, 1)
	vip.accent_color = Color(0.8, 0.5, 0.9, 1)
	vip.border_color = Color(0.4, 0.3, 0.6, 1)
	vip.enemy_hp_modifier = 1.1
	vip.enemy_speed_modifier = 1.3
	vip.enemy_count_modifier = 0
	vip.gold_bonus = 100
	rooms.append(vip)
	
	var cursed := ROOM_DATA_SCRIPT.new()
	cursed.room_name = "Cursed Buffet"
	cursed.description = "A haunted feast. Enemies are wild but gold is plentiful."
	cursed.room_type = ROOM_DATA_SCRIPT.RoomType.CURSED_BUFFET
	cursed.bg_color = Color(0.15, 0.05, 0.15, 1)
	cursed.accent_color = Color(0.5, 0.2, 0.7, 1)
	cursed.border_color = Color(0.3, 0.15, 0.35, 1)
	cursed.enemy_hp_modifier = 1.3
	cursed.enemy_speed_modifier = 1.1
	cursed.enemy_count_modifier = 2
	cursed.gold_bonus = 75
	rooms.append(cursed)
	
	return rooms

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
	preload("res://card_pool/CardPool.gd").record_card_played(card_data)
	# Discard the played card from hand
	DeckManager.discard_card(card_data)
# Signal WaveManager that a card was selected (primes next wave start)
	GameState.state = GameState.GameMode.ROOM_SELECTING
	_show_unlocks_overlay()
	_show_room_selector()

## --- Continue handler (called after player clicks overlay to confirm) ---
func _on_continue_requested() -> void:
	GameState.state = GameState.GameMode.ROOM_SELECTING
	_show_unlocks_overlay()
	_show_room_selector()

## --- Apply a card effect ---
func _apply_card_effect(card_data: Dictionary) -> void:
	# Combo Meal: replay the last placed tower card
	if card_data.get("name", "") == "Combo Meal":
		_apply_combo_meal(card_data)
		return
	match card_data.card_type:
		1:  # Tower card — place on first available lane
			_place_tower_from_card(card_data)
		2:  # Status effect card
			_apply_status_effect(card_data)
		_:
			print("[Main] Unknown card type for: %s" % card_data.name)

## --- Combo Meal: replay last placed tower ---
func _apply_combo_meal(card_data: Dictionary) -> void:
	var last_tower = preload("res://card_pool/CardPool.gd").get_last_tower_card()
	if not last_tower or last_tower.is_empty():
		print("[Main] Combo Meal: no previous tower to replay.")
		return

	var tower_scene_path = last_tower.get("tower_scene", "")
	if not tower_scene_path or tower_scene_path.is_empty():
		print("[Main] Combo Meal: last tower has no tower_scene.")
		return

	var tower_scene = load(tower_scene_path)
	if not tower_scene:
		print("[Main] Combo Meal: failed to load scene: %s" % tower_scene_path)
		return

	var lane_manager := get_tree().get_root().get_node_or_null("LaneManager")
	var lane_index = 0
	if lane_manager and lane_manager.has_method("lane_count") and lane_manager.lane_count > 0:
		lane_index = randi() % lane_manager.lane_count

	var max_x = 1400.0
	var at_x = randf() * max_x * 0.8 + max_x * 0.1

	var tower = TowerManager.place_tower(tower_scene, lane_index, at_x)
	if tower:
		print("[Main] Combo Meal! Replayed '%s' on lane %d." % [
			last_tower.get("name", "Unknown"), lane_index
		])
	else:
		print("[Main] Combo Meal: failed to place tower.")

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

## --- Apply a STATUS_EFFECT card ---
func _apply_status_effect(card_data: Dictionary) -> void:
	var card_script_path = card_data.get("card_script", "")
	if card_script_path and not card_script_path.is_empty():
		var card_script = load(card_script_path)
		if card_script:
			var card = card_script.new()
			if card.has_method("apply_effect"):
				var success = card.apply_effect(null, GameState)
				print("[Main] Status effect '%s' applied: %s" % [card_data.name, "success" if success else "failed"])
				## KitchenUpgradeCard manages its own lifecycle (free()s itself when timer fires).
				## Other cards without timers are freed automatically when this function returns.
				if card.get_script().get_basename() == "KitchenUpgradeCard":
					GameState.set_pending_card(card)
				else:
					card.free()
				return
			else:
				print("[Main] Card script '%s' has no apply_effect method." % card_script_path)
				return
		else:
			print("[Main] Failed to load card script: %s" % card_script_path)
			return

	print("[Main] Unknown status effect: %s" % card_data.name)

## --- Room selection callback ---
func _on_room_selected(room_data: Resource) -> void:
	print("[Main] Room selected: %s" % room_data.room_name)
	
	# First wave: apply room and start wave 0 directly
	if GameState.wave == 0:
		GameState.current_room = room_data
		WaveManager.start_wave(0)
		_next_wave_ready = true
		GameState.state = GameState.PLAYING
		if room_selector:
			room_selector.hide_rooms()
		print("[Main] Wave 1 started after room selection.")
		return
	
	# Subsequent waves: show card selection first, then room selector
	GameState.current_room = room_data
	WaveManager.on_room_selected()
	GameState.state = GameState.WAVE_COMPLETE
	_show_card_selection()
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
## --- Unlock display between card selection and room selector ---
func _check_unlocks() -> void:
	GameState.check_unlocks_between_waves()

func _show_unlocks_overlay() -> void:
	if not unlocks_overlay:
		return
	var pending = GameState.pending_unlocks
	if pending.size() == 0:
		return
	var has_towers = pending.get("new_towers", []).size() > 0
	var has_cards = pending.get("new_cards", []).size() > 0
	if not has_towers and not has_cards:
		return
	unlocks_overlay.show_unlocks(pending)


## --- Callbacks ---
func _on_game_over() -> void:
	print("[Main] Game over! Health depleted.")
	# Save run and check unlocks
	SaveLoad.save_run(GameState.score, GameState.waves_completed, GameState.gold)
	_pending_unlocks = SaveLoad.check_unlocks(GameState.waves_completed)
	WaveManager.reset()
	GameState.state = GameState.GameMode.GAME_OVER

func _on_victory(wave_count: int, score: int, gold_earned: int) -> void:
	print("[Main] Victory callback! Waves: %d, Score: %d, Gold: %d" % [wave_count, score, gold_earned])

func _on_wave_started(wave_config: Resource, wave_index: int) -> void:
	print("[Main] Wave %d started: %s" % [wave_index + 1, wave_config.description])

func _on_wave_completed_check_unlocks(_wave_index: int) -> void:
	_check_unlocks()
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

## --- Tower placement preview ---

func _on_tower_placement_requested(lane_index: int, position_x: float, tower_scene: PackedScene) -> void:
	print("[Main] Placing tower from preview: lane=%d, x=%.0f" % [lane_index, position_x])
	var tower = TowerManager.place_tower(tower_scene, lane_index, position_x)
	if tower:
		print("[Main] Tower placed on lane %d." % lane_index)
	else:
		print("[Main] Failed to place tower via preview.")

func _on_tower_placement_cancelled() -> void:
	print("[Main] Tower placement cancelled.")

## --- Restart / Quit ---
func _on_restart() -> void:
	print("[Main] Restarting run...")
	if game_over_overlay:
		game_over_overlay.hide_game_over()
	GameState.start_run()
	# Apply meta-progression starting gold bonus
	var gold_bonus = SaveLoad.get_unlocked_gold_bonus()
	if gold_bonus > 0:
		GameState.gold += gold_bonus
		print("[Main] Starting gold bonus: +%d (total: %d)" % [gold_bonus, GameState.gold])
	_start_first_wave()

func _on_quit() -> void:
	print("[Main] Quitting to menu...")
	if game_over_overlay:
		game_over_overlay.hide_game_over()
	get_tree().change_scene_to_file("res://main.tscn")
