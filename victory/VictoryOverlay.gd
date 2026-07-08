extends Control
## VictoryOverlay — full-screen panel showing victory message and run stats.
## Displays when the player completes all waves (wave 20).
## Shows score, waves survived, gold earned, and offers restart/menu options.

signal restart_requested
signal quit_requested

var _stats: Dictionary = {}

@onready var _panel: PanelContainer = $Panel
@onready var _overlay: ColorRect = $overlay_bg
@onready var _title_label: Label = $Panel/TitleLabel
@onready var _score_label: Label = $Panel/ScoreLabel
@onready var _wave_label: Label = $Panel/WaveLabel
@onready var _gold_label: Label = $Panel/GoldLabel
@onready var _health_label: Label = $Panel/HealthLabel
@onready var _high_score_panel: PanelContainer = $HighScorePanel
@onready var _high_score_label: Label = $HighScorePanel/HighScoreLabel
@onready var _new_high_score_label: Label = $HighScorePanel/NewHighScoreLabel
@onready var _unlocks_panel: PanelContainer = $Panel/UnlocksPanel
@onready var _unlocks_title: Label = $Panel/UnlocksPanel/UnlocksTitle
@onready var _unlocks_vbox: VBoxContainer = $Panel/UnlocksPanel/UnlocksScroll/UnlocksVBox

## Show the victory overlay with run statistics.
func show_victory(score: int, waves_survived: int, gold_earned: int, health_remaining: int, high_score: int = -1, unlocks: Dictionary = {}) -> void:
	_stats = {
		"score": score,
		"waves": waves_survived,
		"gold": gold_earned,
		"health": health_remaining,
	}
	_score_label.text = "Score: %d" % score
	_wave_label.text = "Waves Survived: %d" % waves_survived
	_gold_label.text = "Gold Earned: %d" % gold_earned
	_health_label.text = "Health Remaining: %d" % health_remaining
	_panel.visible = true
	_overlay.visible = true
	_high_score_panel.visible = false
	_unlocks_panel.visible = false

func hide_victory() -> void:
	_panel.visible = false
	_overlay.visible = false

func _on_restart_pressed() -> void:
	restart_requested.emit()

func _on_quit_pressed() -> void:
	quit_requested.emit()
