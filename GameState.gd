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

## The number of waves completed in the current run.
var waves_completed: int = 0:
	set(v):
		waves_completed = v

## The total waves played (including current)
var waves_played: int = 0:
	set(v):
		waves_played = v

## --- Health (player lives) ---
var health: int = 20:
	set(v):
		health = v
		health_changed.emit(health)
		if health <= 0:
			health_depleted.emit()

signal health_changed(new_health: int)
signal health_depleted()

## --- Gold (currency for towers/cards) ---
var gold: int = 100:
	set(v):
		gold = v
		gold_changed.emit(gold)

signal gold_changed(new_gold: int)

## --- Game state machine ---
enum GameState {
	PLAYING,
	WAVE_COMPLETE,
	GAME_OVER
}

var state: GameState = GameState.PLAYING:
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

## --- Room modifier application ---

func _apply_room_modifier(room: Resource) -> void:
	if not room:
		return
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

## --- Methods ---

func start_run() -> void:
	score = 0
	wave = 0
	health = 20
	gold = 100
	waves_completed = 0
	waves_played = 0
	state = GameState.PLAYING
	
	# Start the first wave
	GameState.state = GameState.WAVE_COMPLETE
	var room = RoomData.new()
	room.room_name = "Pantry"
	room.enemy_hp_modifier = 1.0
	room.enemy_speed_modifier = 1.0
	room.enemy_count_modifier = 0
	room.gold_bonus = 0
	current_room = room
	GameState.state = GameState.PLAYING

func add_score(amount: int) -> void:
	score += amount

func add_gold(amount: int) -> void:
	gold += amount

func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		return true
	return false

func take_damage(amount: int) -> void:
	health -= amount
