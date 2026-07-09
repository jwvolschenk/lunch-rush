extends Node
## GameState — autoload singleton managing score, wave, health, and gold.
## All mutations emit signals so UI can update reactively.

## --- Score ---
var score: int = 0:
	set(v):
		score = v
		score_changed.emit(score)

signal score_changed(new_score: int)

## --- Wave ---
var wave: int = 0:
	set(v):
		wave = v
		wave_changed.emit(wave)

signal wave_changed(new_wave: int)

## --- Wave progression ---
## Emitted when a new wave starts (before enemies spawn).
signal wave_started(wave_index: int)

## Emitted when a wave completes (all enemies defeated).
signal wave_completed(wave_index: int)
## Pending unlocks discovered between waves (filled by check_unlocks_between_waves).
var _pending_unlocks: Dictionary = {}
var pending_unlocks: Dictionary:
	get: return _pending_unlocks.duplicate()

## The number of waves completed in the current run.
var waves_completed: int = 0:
	set(v):
		waves_completed = v

## The total waves played (including current)
var waves_played: int = 0:
	set(v):
		waves_played = v

## --- Health (player lives) ---
var max_health: int = 20

var health: int = 20:
	set(v):
		health = v
		health_changed.emit(health)
		if health <= 0:
			health_depleted.emit()

signal health_changed(new_health: int)
signal health_depleted()

## Emitted when the player wins by completing all waves.
signal victory(wave_count: int, score: int, gold_earned: int)

## --- Gold (currency for towers/cards) ---
var gold: int = 100:
	set(v):
		gold = v
		gold_changed.emit(gold)

signal gold_changed(new_gold: int)

## --- Game state machine ---
enum GameMode {
	PLAYING,
	WAVE_COMPLETE,
	GAME_OVER,
	ROOM_SELECTING,
	VICTORY,
}

var state: GameMode = GameMode.PLAYING:
	set(v):
		state = v
		state_changed.emit(state)

signal state_changed(new_state: int)

## --- Room selection (between waves) ---
signal room_selected(room_data: Resource)

## Current room modifier applied to the next wave
var _current_room: Resource = null
var current_room: Resource:
	set(v):
		_current_room = v
		if v:
			_apply_room_modifier(v)
		_room_changed.emit(v)
	get:
		return _current_room

signal _room_changed(room_data: Resource)

## --- Wave configuration (set by WaveManager between waves) ---
var wave_enemy_count: int = 0
var wave_enemy_hp: float = 1.0
var wave_enemy_speed: float = 60.0
var wave_gold_reward: int = 25

## Pending cards generated for card selection between waves
var pending_cards: Array[Dictionary] = []

## Holds a reference to a card that must stay alive until its timer fires.
## Prevents the caller from freeing KitchenUpgradeCard before the timer callback.
var _pending_card: Node2D = null

## Store a reference to a card that must stay alive until its timer fires.
func set_pending_card(card: Node2D) -> void:
	_pending_card = card

## Clear the pending card reference.
func clear_pending_card() -> void:
	_pending_card = null
## --- Room modifier application ---

func _apply_room_modifier(room: Resource) -> void:
	if not room:
		return
	_reset_room_modifiers()
	var enemy_count_mod: int = 0
	var enemy_hp_mod: float = 1.0
	var enemy_speed_mod: float = 1.0
	var gold_bonus: float = 0.0
	if "enemy_count_modifier" in room:
		enemy_count_mod = room.enemy_count_modifier
	if "enemy_hp_modifier" in room:
		enemy_hp_mod = room.enemy_hp_modifier
	if "enemy_speed_modifier" in room:
		enemy_speed_mod = room.enemy_speed_modifier
	if "gold_bonus" in room:
		gold_bonus = room.gold_bonus
	wave_enemy_count += enemy_count_mod
	wave_enemy_hp *= enemy_hp_mod
	wave_enemy_speed *= enemy_speed_mod
	wave_gold_reward = int(wave_gold_reward * (1.0 + gold_bonus * 0.01))

func _reset_room_modifiers() -> void:
	wave_enemy_count = 0
	wave_enemy_hp = 1.0
	wave_enemy_speed = 60.0
	wave_gold_reward = 25

## --- Methods ---

func start_run() -> void:
	score = 0
	wave = 0
	max_health = 20
	health = 20
	gold = 100
	waves_completed = 0
	waves_played = 0
	_reset_room_modifiers()
	
	# Apply meta-progression starting gold bonus
	var bonus = SaveLoad.get_unlocked_gold_bonus()
	if bonus > 0:
		gold += bonus
		print("[GameState] Starting gold bonus: +%d" % bonus)
	
	# Initialize the deck for this run
	DeckManager.reset()
	
	# Reset room — the room selector will set it for the first wave
	_current_room = null
	
	# Start background music
	SoundManager.play_music("background")
	
	# Go to room selector so the player picks a room before the first wave
	state = GameState.ROOM_SELECTING

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)

func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		return true
	return false

## Alias for deduct_gold — used by card scripts.
func deduct_gold(amount: int) -> bool:
	return spend_gold(amount)

func take_damage(amount: int) -> void:
	var old_health = health
	health -= amount
	if health != old_health:
		health_changed.emit(health)
	if health <= 0:
		health_depleted.emit()

func start_wave(wave_index: int) -> void:
	wave_started.emit(wave_index)
	wave = wave_index + 1
	wave_changed.emit(wave)
	waves_played += 1

func complete_wave() -> void:
	wave_completed.emit(wave)
	waves_completed += 1
## Check for unlocks between waves. Called after each wave completes.
## Only checks once per run (when _pending_unlocks is empty) to avoid
## double-unlocking at game-over.
func check_unlocks_between_waves() -> void:
	if _pending_unlocks.size() > 0:
		return  # Already checked this run
	_pending_unlocks = SaveLoad.check_unlocks(waves_completed)
	if _pending_unlocks.get("new_towers", []).size() > 0 or _pending_unlocks.get("new_cards", []).size() > 0:
		print("[GameState] New unlocks: %s towers, %s cards" % [
			_pending_unlocks.get("new_towers", []).size(),
			_pending_unlocks.get("new_cards", []).size()])

## --- Damage flash ---

signal damage_flashed()

func trigger_damage_flash() -> void:
	damage_flashed.emit()

## Transition to VICTORY state and emit victory signal.
func trigger_victory() -> void:
	state = GameMode.VICTORY
	victory.emit(wave, score, gold)
