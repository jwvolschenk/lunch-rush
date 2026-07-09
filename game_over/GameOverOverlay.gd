# class_name removed: this script is an autoload singleton
extends Control
## GameOverOverlay — full-screen panel showing run stats and offering restart.
## Displays score, waves survived, gold earned, and remaining health.
## Also shows an Unlocks panel with earned perks when new unlocks are available.
## Emits restart signal when the player confirms.

signal restart_requested
signal quit_requested

var _stats: Dictionary = {}
var _new_unlocks: Dictionary = {}

@onready var _panel: PanelContainer = $Panel
@onready var _overlay: ColorRect = $overlay_bg
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

## Show the game-over overlay with run statistics.
## If unlocks are available, shows the Unlocks panel with earned perks.
func show_game_over(score: int, waves_survived: int, gold_earned: int, health_remaining: int, high_score: int = -1, unlocks: Dictionary = {}) -> void:
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
	_new_unlocks = unlocks

	if unlocks and unlocks.has("new_towers") and unlocks.new_towers.size() > 0:
		_populate_unlocks_panel(unlocks)

	if high_score >= 0:
		_high_score_panel.visible = true
		_high_score_label.text = "High Score: %d" % high_score
		if score > high_score:
			_new_high_score_label.text = "New High Score!"
			_new_high_score_label.visible = true
		else:
			_new_high_score_label.text = ""
			_new_high_score_label.visible = false
	else:
		_high_score_panel.visible = false

func _populate_unlocks_panel(unlocks: Dictionary) -> void:
	_unlocks_vbox.clear()

	# Section header
	var section_label = Label.new()
	section_label.text = "Perks Earned This Run"
	section_label.add_theme_font_size_override("normal_font_size", 16)
	section_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_unlocks_vbox.add_child(section_label)

	var new_towers = unlocks.get("new_towers", [])
	var new_cards = unlocks.get("new_cards", [])
	var new_gold_bonus = unlocks.get("new_gold_bonus", 0)

	if new_towers.size() > 0:
		var tower_label = Label.new()
		tower_label.text = "New Towers:"
		tower_label.add_theme_font_size_override("normal_font_size", 14)
		tower_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1))
		_unlocks_vbox.add_child(tower_label)
		for tower_name in new_towers:
			var tower_item = Label.new()
			tower_item.text = "  " + tower_name
			tower_item.add_theme_font_size_override("normal_font_size", 13)
			_unlocks_vbox.add_child(tower_item)

	if new_cards.size() > 0:
		var card_label = Label.new()
		card_label.text = "New Cards:"
		card_label.add_theme_font_size_override("normal_font_size", 14)
		card_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.5, 1))
		_unlocks_vbox.add_child(card_label)
		for card_name in new_cards:
			var card_item = Label.new()
			card_item.text = "  " + card_name
			card_item.add_theme_font_size_override("normal_font_size", 13)
			_unlocks_vbox.add_child(card_item)

	if new_gold_bonus > 0:
		var gold_label = Label.new()
		gold_label.text = "Starting Gold Bonus: +%d" % new_gold_bonus
		gold_label.add_theme_font_size_override("normal_font_size", 14)
		gold_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.1, 1))
		_unlocks_vbox.add_child(gold_label)

	_unlocks_panel.visible = true

func hide_game_over() -> void:
	_panel.visible = false
	_overlay.visible = false
	_unlocks_panel.visible = false

func _on_restart_pressed() -> void:
	restart_requested.emit()

func _on_quit_pressed() -> void:
	quit_requested.emit()
