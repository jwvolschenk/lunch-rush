# class_name removed: this script is an autoload singleton
extends Control

enum CravingType {
	NONE,
	GREASE,
	SOUP,
	SPICE,
	PIZZA,
}
## CardSelection — overlay panel for choosing a card between waves.
## Shows 3 card options with icon, name, cost, and description.
## Clicking a card emits the selected signal and returns to PLAYING state.
## Emitted when the player clicks to continue after selecting a card.
signal continue_requested

signal card_selected(card_data: Dictionary)

## Card data structure:
## { name: String, description: String, cost: int, card_type: int, icon_color: Color, food_type: int }

var cards: Array = []
var _selected: int = -1
var _hovered_card: int = -1

@onready var _panel: PanelContainer = $Panel
@onready var _overlay: ColorRect = $overlay_bg
@onready var _confirm_label: Label = $Panel/Confirm
@onready var _continue_button: Button = $Panel/ContinueButton
@onready var _cards: Array = [
	$Panel/Card1,
	$Panel/Card2,
	$Panel/Card3,
]

@onready var _card_icons: Array = [
	$Panel/Card1/Card1Icon,
	$Panel/Card2/Card2Icon,
	$Panel/Card3/Card3Icon,
]

@onready var _card_names: Array = [
	$Panel/Card1/Card1Name,
	$Panel/Card2/Card2Name,
	$Panel/Card3/Card3Name,
]

@onready var _card_costs: Array = [
	$Panel/Card1/Card1Cost,
	$Panel/Card2/Card2Cost,
	$Panel/Card3/Card3Cost,
]

@onready var _card_descs: Array = [
	$Panel/Card1/Card1Desc,
	$Panel/Card2/Card2Desc,
	$Panel/Card3/Card3Desc,
]

## Runtime labels for food type indicator on each card
var _card_food_labels: Array[Label] = []

## Default modulate values for each card (non-hovered state)
var _default_modulates: Array[Color] = []

## Show the card selection panel with given card options.
func show_cards(card_list: Array) -> void:
	cards = card_list.duplicate()
	_selected = -1
	_hovered_card = -1
	_confirm_label.text = "Click a card to select it"
	_continue_button.disabled = true
	# Clear any leftover food type labels from previous call
	for lbl in _card_food_labels:
		if is_instance_valid(lbl) and lbl.get_parent():
			lbl.get_parent().remove_child(lbl)
			lbl.queue_free()
	_card_food_labels.clear()
	for i in range(min(card_list.size(), 3)):
		var card = card_list[i]
		_card_icons[i].color = card.get("icon_color", Color.WHITE)
		_card_names[i].text = card.get("name", "Unknown")
		_card_costs[i].text = "Cost: %d" % card.get("cost", 0)
		_card_descs[i].text = card.get("description", "")
		_cards[i].visible = true
		# Store default modulate (white = no tint)
		_default_modulates.append(Color.WHITE)
		_cards[i].modulate = Color.WHITE
		# Display food type indicator below cost
		_show_food_type(i, card)
	# Hide any excess card slots
	for i in range(card_list.size(), 3):
		if i < _cards.size():
			_cards[i].visible = false
		_default_modulates.append(Color.WHITE)
	_panel.visible = true
	_overlay.visible = true

func hide_cards() -> void:
	_panel.visible = false
	_overlay.visible = false
	_selected = -1
	_hovered_card = -1
	_confirm_label.text = ""

## Display the food type indicator on a card slot.
func _show_food_type(index: int, card: Dictionary) -> void:
	var food_type = card.get("food_type", CravingType.NONE)
	# Create a label for the food type
	var food_label = Label.new()
	food_label.add_theme_font_size_override("font_size", 11)
	food_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.9))
	food_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	food_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if food_type == CravingType.NONE or food_type < 0:
		food_label.text = ""
		food_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.0))
	else:
		var food_colors: Dictionary = {
			CravingType.GREASE: Color(0.95, 0.85, 0.1, 0.9),
			CravingType.SOUP:   Color(0.2, 0.5, 0.95, 0.9),
			CravingType.SPICE:  Color(0.95, 0.15, 0.15, 0.9),
			CravingType.PIZZA:  Color(0.8, 0.2, 0.85, 0.9),
		}
		var food_names: Dictionary = {
			CravingType.GREASE: "GREASE",
			CravingType.SOUP:   "SOUP",
			CravingType.SPICE:  "SPICE",
			CravingType.PIZZA:  "PIZZA",
		}
		var name = "—"
		if food_type in food_names:
			name = food_names[food_type]
		if food_type in food_colors:
			food_label.add_theme_color_override("font_color", food_colors[food_type])
		food_label.text = name

	food_label.size = Vector2i(180, 16)
	food_label.position = Vector2i(0, 100)
	food_label.custom_minimum_size = Vector2(180, 16)
	_cards[index].add_child(food_label)
	_card_food_labels.append(food_label)

## Called when mouse enters a card slot.
func _on_card1_entered() -> void:
	_set_hover(0)

func _on_card2_entered() -> void:
	_set_hover(1)

func _on_card3_entered() -> void:
	_set_hover(2)

## Called when mouse leaves a card slot.
func _on_card1_exited() -> void:
	_unset_hover()

func _on_card2_exited() -> void:
	_unset_hover()

func _on_card3_exited() -> void:
	_unset_hover()

## Apply hover highlight to a specific card slot.
func _set_hover(index: int) -> void:
	if index >= cards.size():
		return
	if _hovered_card == index:
		return
	# Restore previous hover if different
	if _hovered_card >= 0 and _hovered_card < _default_modulates.size():
		_cards[_hovered_card].modulate = _default_modulates[_hovered_card]
	_hovered_card = index
	_cards[index].modulate = Color(1.0, 1.0, 1.0, 1.0)
	_confirm_label.text = "Click to select %s" % cards[index].get("name", "Unknown")

func _unset_hover() -> void:
	if _hovered_card >= 0 and _hovered_card < _default_modulates.size():
		_cards[_hovered_card].modulate = _default_modulates[_hovered_card]
		if _selected < 0:
			_confirm_label.text = "Click a card to select it"
	_hovered_card = -1

## Handle card 1 click.
func _on_card1_clicked() -> void:
	_on_card_selected(0)

## Handle card 2 click.
func _on_card2_clicked() -> void:
	_on_card_selected(1)

## Handle card 3 click.
func _on_card3_clicked() -> void:
	_on_card_selected(2)

## Process a card selection and emit the signal.
func _on_card_selected(index: int) -> void:
	if index >= cards.size():
		return
	_selected = index
	var card = cards[index]
	
	# Visual feedback: highlight selected card
	for i in range(min(cards.size(), 3)):
		if i == index:
			_cards[i].modulate = Color(1.0, 1.0, 0.8, 1.0)
		else:
			_cards[i].modulate = Color(0.5, 0.5, 0.5, 1.0)
	_confirm_label.text = "Selected: %s — Click to continue" % card.get("name", "Unknown")
	_continue_button.disabled = false
	
	# Emit selection signal
	card_selected.emit(card)

## Called when player clicks the Continue button.
func _on_continue_clicked() -> void:
	hide_cards()
	continue_requested.emit()

## Called when player clicks the overlay to dismiss and continue.
func _on_overlay_clicked() -> void:
	if _selected < 0:
		return  # No card selected yet, ignore
	hide_cards()
	continue_requested.emit()
