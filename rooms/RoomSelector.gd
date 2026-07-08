extends Control
## RoomSelector — overlay panel that presents 2-3 room choices between waves.
## Each room shows its name, description, and modifier preview.
## Clicking a room applies its modifier and returns to PLAYING state.

signal room_selected(room_data: RoomData)

## Available room options for the current wave transition
var _rooms: Array = []
var _selected: bool = false

@onready var _panel: PanelContainer = $Panel
@onready var _overlay: ColorRect = $overlay_bg
@onready var _room_containers: Array = [
	$Panel/Room1,
	$Panel/Room2,
	$Panel/Room3,
]
@onready var _room_names: Array = [
	$Panel/Room1/RoomName,
	$Panel/Room2/RoomName,
	$Panel/Room3/RoomName,
]
@onready var _room_descs: Array = [
	$Panel/Room1/RoomDesc,
	$Panel/Room1/RoomDesc,
	$Panel/Room1/RoomDesc,
]
@onready var _room_modifiers: Array = [
	$Panel/Room1/Modifier,
	$Panel/Room2/Modifier,
	$Panel/Room3/Modifier,
]
@onready var _room_accents: Array = [
	$Panel/Room1/RoomAccent,
	$Panel/Room2/RoomAccent,
	$Panel/Room3/RoomAccent,
]

func show_rooms(room_list: Array) -> void:
	_rooms = room_list
	_selected = false
	for i in range(min(room_list.size(), 3)):
		var room = room_list[i]
		_room_names[i].text = room.room_name
		_room_descs[i].text = room.description
		_modifiers_text(i, _format_modifier(room))
		_room_accents[i].color = room.accent_color
		_room_containers[i].visible = true
	# Hide excess room slots
	for i in range(room_list.size(), 3):
		_room_containers[i].visible = false
	_panel.visible = true
	_overlay.visible = true

func hide_rooms() -> void:
	_panel.visible = false
	_overlay.visible = false
	_selected = false

func _modifiers_text(index: int, text: String) -> void:
	_room_modifiers[index].text = text

func _format_modifier(room: RoomData) -> String:
	var parts := []
	if room.enemy_hp_modifier != 1.0:
		var pct := int((room.enemy_hp_modifier - 1.0) * 100)
		parts.append("HP %s%d%%" % ["" if pct > 0 else "", pct])
	if room.enemy_speed_modifier != 1.0:
		var pct := int((room.enemy_speed_modifier - 1.0) * 100)
		parts.append("Speed %s%d%%" % ["" if pct > 0 else "", pct])
	if room.enemy_count_modifier != 0:
		parts.append("Enemies %s%d" % ["" if room.enemy_count_modifier > 0 else "", room.enemy_count_modifier])
	if room.gold_bonus != 0:
		parts.append("Gold +%d" % room.gold_bonus)
	return ", ".join(parts) if parts.size() > 0 else "No modifiers"

func _on_room1_clicked() -> void:
	_on_room_selected(0)

func _on_room2_clicked() -> void:
	_on_room_selected(1)

func _on_room3_clicked() -> void:
	_on_room_selected(2)

func _on_room_selected(index: int) -> void:
	if _selected or index >= _rooms.size():
		return
	_selected = true
	room_selected.emit(_rooms[index])
	hide_rooms()
