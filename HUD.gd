extends Control
## HUD — displays gold, score, wave, and health from GameState.
## Connects to GameState signals for reactive updates.

@onready var _gold_label: Label = $Panel/GoldLabel
@onready var _score_label: Label = $Panel/ScoreLabel
@onready var _wave_label: Label = $Panel/WaveLabel
@onready var _health_label: Label = $Panel/HealthLabel

func _ready() -> void:
	GameState.gold_changed.connect(_on_gold_changed)
	GameState.score_changed.connect(_on_score_changed)
	GameState.wave_changed.connect(_on_wave_changed)
	GameState.health_changed.connect(_on_health_changed)
	_update_labels()

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
