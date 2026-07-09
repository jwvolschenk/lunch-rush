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
	_unlocks_vbox.clear()

	var new_towers = unlocks.get("new_towers", [])
	var new_cards = unlocks.get("new_cards", [])
	var new_gold_bonus = unlocks.get("new_gold_bonus", 0)
	var has_unlocks = new_towers.size() > 0 or new_cards.size() > 0 or new_gold_bonus > 0

	if has_unlocks:
		_unlocks_panel.visible = true
		if new_towers.size() > 0:
			var header = Label.new()
			header.text = "New Towers:"
			header.theme_override_font_sizes/normal_font_size = 16
			header.theme_override_colors/font_color = Color(0.95, 0.75, 0.1, 1)
			_unlocks_vbox.add_child(header)
			for tower_name in new_towers:
				_add_unlock_item(tower_name, "Tower unlocked")
		if new_cards.size() > 0:
			var header = Label.new()
			header.text = "New Cards:"
			header.theme_override_font_sizes/normal_font_size = 16
			header.theme_override_colors/font_color = Color(0.95, 0.75, 0.1, 1)
			_unlocks_vbox.add_child(header)
			for card_name in new_cards:
				_add_unlock_item(card_name, "Card unlocked")
		if new_gold_bonus > 0:
			_add_unlock_item("Gold Bonus", "Starting gold: +%d" % new_gold_bonus)
	else:
		_unlocks_panel.visible = false

func hide_victory() -> void:
	_panel.visible = false
	_overlay.visible = false

func _add_unlock_item(name_text: String, description_text: String) -> void:
	var item_hbox = HBoxContainer.new()
	item_hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	item_hbox.custom_constants/separation = 12

	var icon_rect = ColorRect.new()
	icon_rect.custom_minimum_size = Vector2i(10, 10)
	icon_rect.color = Color(1.0, 0.85, 0.2, 1)
	item_hbox.add_child(icon_rect)

	var name_label = Label.new()
	name_label.text = name_text
	name_label.theme_override_font_sizes/normal_font_size = 14
	name_label.theme_override_colors/font_color = Color(0.95, 0.95, 0.95, 1)
	item_hbox.add_child(name_label)

	var desc_label = Label.new()
	desc_label.text = description_text
	desc_label.theme_override_font_sizes/normal_font_size = 11
	desc_label.theme_override_colors/font_color = Color(0.7, 0.7, 0.7, 1)
	item_hbox.add_child(desc_label)

	_unlocks_vbox.add_child(item_hbox)

func _on_restart_pressed() -> void:
	restart_requested.emit()

func _on_quit_pressed() -> void:
	quit_requested.emit()
