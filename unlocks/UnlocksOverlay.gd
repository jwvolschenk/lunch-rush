extends Control
## UnlocksOverlay — full-screen overlay announcing newly unlocked items.
## Shows a "PERK UNLOCKED!" title with a scrollable list of new items
## (towers, cards, gold bonuses) and auto-fades after 2 seconds.

signal unlocks_showed

@onready var overlay_bg: ColorRect = $overlay_bg
@onready var panel: PanelContainer = $Panel
@onready var scroll_container: ScrollContainer = $Panel/ScrollContainer
@onready var v_box: VBoxContainer = $Panel/ScrollContainer/VBoxContainer
@onready var title_label: Label = $Panel/Title

var _fade_timer: float = 2.0
var _elapsed: float = 0.0
var _fading_out: bool = false


## Show the unlocks overlay with the given data.
## unlock_data must contain:
##   new_towers   -> Array of tower names
##   new_cards    -> Array of card names
##   new_gold_bonus -> int (optional)
func show_unlocks(unlock_data: Dictionary) -> void:
	v_box.clear()

	# Populate unlocked items
	var new_towers = unlock_data.get("new_towers", [])
	var new_cards = unlock_data.get("new_cards", [])
	var new_gold_bonus = unlock_data.get("new_gold_bonus", 0)

	if new_towers.size() > 0:
		_add_section_header("New Towers:")
		for tower_name in new_towers:
			_add_unlock_item(tower_name, "Tower unlocked", Color(1.0, 0.85, 0.2, 1))

	if new_cards.size() > 0:
		_add_section_header("New Cards:")
		for card_name in new_cards:
			_add_unlock_item(card_name, "Card unlocked", Color(0.2, 1.0, 0.5, 1))

	if new_gold_bonus > 0:
		_add_unlock_item("Gold Bonus", "Starting gold: +%d" % new_gold_bonus, Color(1.0, 0.9, 0.1, 1), Color(1.0, 0.75, 0.1, 1))

	# Show overlay
	overlay_bg.visible = true
	panel.visible = true
	_fading_out = false
	_elapsed = 0.0
	title_label.visible = true
	title_label.text = "PERK UNLOCKED!"
	title_label.theme_override_colors/font_color = Color(0.95, 0.75, 0.1, 1)

	unlocks_showed.emit()


func _add_section_header(text: String) -> void:
	var header = Label.new()
	header.text = text
	header.theme_override_font_sizes/normal_font_size = 16
	header.theme_override_colors/font_color = Color(0.95, 0.75, 0.1, 1)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.custom_minimum_size = Vector2i(0, 24)
	v_box.add_child(header)


func _add_unlock_item(name: String, description: String, icon_color: Color, text_color: Color = Color(0.95, 0.95, 0.95, 1)) -> void:
	var item = HBoxContainer.new()
	item.alignment = BoxContainer.ALIGNMENT_BEGIN
	item.custom_constants/separation = 12
	item.custom_minimum_size = Vector2i(0, 0)

	# Colored icon
	var icon_rect = ColorRect.new()
	icon_rect.custom_minimum_size = Vector2i(30, 30)
	icon_rect.color = icon_color
	item.add_child(icon_rect)

	# Name and description labels
	var name_label = Label.new()
	name_label.text = name
	name_label.theme_override_font_sizes/normal_font_size = 16
	name_label.theme_override_colors/font_color = text_color
	name_label.custom_minimum_size = Vector2i(0, 20)

	var desc_label = Label.new()
	desc_label.text = description
	desc_label.theme_override_font_sizes/normal_font_size = 12
	desc_label.theme_override_colors/font_color = Color(0.7, 0.7, 0.7, 1)
	desc_label.custom_minimum_size = Vector2i(0, 16)

	var text_col = VBoxContainer.new()
	text_col.orientation = VBoxContainer.ORIENTATION_VERTICAL
	text_col.add_child(name_label)
	text_col.add_child(desc_label)
	item.add_child(text_col)

	v_box.add_child(item)


func _process(delta: float) -> void:
	if not overlay_bg.visible:
		return

	if not _fading_out:
		_elapsed += delta
		if _elapsed >= _fade_timer:
			_fading_out = true

	if _fading_out:
		var progress = (_elapsed - _fade_timer) / 0.5
		if progress >= 1.0:
			hide_unlocks()
		else:
			var fade_alpha = 1.0 - progress
			overlay_bg.color.a = fade_alpha
			panel.visible = fade_alpha > 0.1
			title_label.visible = fade_alpha > 0.5
	else:
		overlay_bg.color.a = 0.65


func hide_unlocks() -> void:
	overlay_bg.visible = false
	panel.visible = false
	_fading_out = false
	_elapsed = 0.0
	title_label.visible = true
	title_label.text = "PERK UNLOCKED!"
	title_label.theme_override_colors/font_color = Color(0.95, 0.75, 0.1, 1)
