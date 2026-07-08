extends Control
## CardSelection — overlay panel for choosing a card between waves.
## Shows 3 card options with icon, name, cost, and description.
## Clicking a card emits the selected signal and returns to PLAYING state.

signal card_selected(card_data: Dictionary)

## Card data structure:
## { name: String, description: String, cost: int, card_type: int, icon_color: Color }

var cards: Array = []
var _selected: bool = false

@onready var _panel: PanelContainer = $Panel
@onready var _overlay: ColorRect = $overlay_bg
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

## Show the card selection panel with given card options.
func show_cards(card_list: Array) -> void:
	cards = card_list
	_selected = false
	for i in range(min(card_list.size(), 3)):
		var card = card_list[i]
		_card_icons[i].color = card.get("icon_color", Color.WHITE)
		_card_names[i].text = card.get("name", "Unknown")
		_card_costs[i].text = "Cost: %d" % card.get("cost", 0)
		_card_descs[i].text = card.get("description", "")
	_cards[i].visible = true
	# Hide any excess card slots
	for i in range(card_list.size(), 3):
		_cards[i].visible = false
	_panel.visible = true
	_overlay.visible = true

func hide_cards() -> void:
	_panel.visible = false
	_overlay.visible = false
	_selected = false

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
	if _selected or index >= cards.size():
		return
	_selected = true
	card_selected.emit(cards[index])
	hide_cards()
