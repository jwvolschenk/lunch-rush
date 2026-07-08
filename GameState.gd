extends Node
## GameState — autoload singleton managing score, wave, health, and gold.
## All mutations emit signals so UI can listen and update reactively.

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

## --- Wave configuration (set by WaveManager between waves) ---
var wave_enemy_count: int = 0
var wave_enemy_hp: float = 1.0
var wave_enemy_speed: float = 60.0
var wave_gold_reward: int = 25

## --- Methods ---

func start_run() -> void:
	score = 0
	wave = 0
	health = 20
	gold = 100
	state = GameState.PLAYING

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
