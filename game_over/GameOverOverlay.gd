extends Control
## GameOverOverlay — full-screen panel showing run stats and offering restart.
## Displays score, waves survived, gold earned, and remaining health.
## Emits restart signal when the player confirms.

signal restart_requested
signal quit_requested

var _stats: Dictionary = {}

@onready var _panel: PanelContainer = $Panel
@onready var _overlay: ColorRect = $overlay_bg
@onready var _score_label: Label = $Panel/ScoreLabel
@onready var _wave_label: Label = $Panel/WaveLabel
@onready var _gold_label: Label = $Panel/GoldLabel
@onready var _health_label: Label = $Panel/HealthLabel

## Show the game-over overlay with run statistics.
func show_game_over(score: int, waves_survived: int, gold_earned: int, health_remaining: int) -> void:
	_score_label.text = "Score: %d" % score
	_wave_label.text = "Waves Survived: %d" % waves_survived
	_gold_label.text = "Gold Earned: %d" % gold_earned
	_health_label.text = "Health Remaining: %d" % health_remaining
	_panel.visible = true
	_overlay.visible = true

func hide_game_over() -> void:
	_panel.visible = false
	_overlay.visible = false

func _on_restart_pressed() -> void:
	restart_requested.emit()

func _on_quit_pressed() -> void:
	quit_requested.emit()
