extends Control
## HUD — displays gold, score, wave, health, and wave progress from GameState/WaveManager.
## Connects to GameState signals for reactive updates; periodically updates wave progress.

var _progress_update_timer: float = 0.0
var _progress_update_interval: float = 0.25

@onready var _gold_label: Label = $Panel/GoldLabel
@onready var _score_label: Label = $Panel/ScoreLabel
@onready var _wave_label: Label = $Panel/WaveLabel
@onready var _health_label: Label = $Panel/HealthLabel
@onready var _enemy_count_label: Label = $Panel/EnemyCountLabel
@onready var _next_spawn_label: Label = $Panel/NextSpawnLabel
@onready var _wave_countdown_label: Label = $WaveCountdownLabel

func _ready() -> void:
	GameState.gold_changed.connect(_on_gold_changed)
	GameState.score_changed.connect(_on_score_changed)
	GameState.wave_changed.connect(_on_wave_changed)
	GameState.health_changed.connect(_on_health_changed)
	_update_labels()

func _process(delta: float) -> void:
	if GameState.state != GameState.GameState.PLAYING:
		return
	_progress_update_timer += delta
	if _progress_update_timer >= _progress_update_interval:
		_progress_update_timer = 0.0
		_update_wave_progress()

func _update_wave_progress() -> void:
	if not _enemy_count_label or not _next_spawn_label:
		return
	if not WaveManager.is_wave_active:
		_enemy_count_label.text = "Enemies: -"
		_next_spawn_label.text = "Next: -s"
		return
	
	var remaining = WaveManager.active_enemy_count + WaveManager.remaining_to_spawn()
	_enemy_count_label.text = "Enemies: %d" % remaining
	
	var time_remaining = _get_time_to_next_spawn()
	if time_remaining > 0:
		_next_spawn_label.text = "Next: %.1fs" % time_remaining
	else:
		_next_spawn_label.text = "Next: done"

func _get_time_to_next_spawn() -> float:
	if not WaveManager._current_wave_config or WaveManager._spawn_queue.is_empty():
		return 0.0
	var interval = WaveManager._current_wave_config.spawn_interval
	var elapsed = WaveManager._spawn_timer
	return max(0.0, interval - elapsed)

func _update_labels() -> void:
	if _gold_label:
		_gold_label.text = "Gold: %d" % GameState.gold
	if _score_label:
		_score_label.text = "Score: %d" % GameState.score
	if _wave_label:
		_wave_label.text = "Wave: %d" % GameState.wave
	if _health_label:
		_health_label.text = "Health: %d" % GameState.health

func _on_gold_changed(new_gold: int) -> void:
	if _gold_label:
		_gold_label.text = "Gold: %d" % new_gold

func _on_score_changed(new_score: int) -> void:
	if _score_label:
		_score_label.text = "Score: %d" % new_score

func _on_wave_changed(new_wave: int) -> void:
	if _wave_label:
		_wave_label.text = "Wave: %d" % new_wave

func _on_health_changed(new_health: int) -> void:
	if _health_label:
		_health_label.text = "Health: %d" % new_health

## --- Wave countdown display ---

func show_wave_countdown(text: String) -> void:
	if not _wave_countdown_label:
		return
	_wave_countdown_label.text = text
	_wave_countdown_label.visible = true

func hide_wave_countdown() -> void:
	if _wave_countdown_label:
		_wave_countdown_label.visible = false
