extends Node
## InputManager — handles all player input for tower placement and card selection.
##
## Tower placement flow:
##   1. Player selects a tower card (via CardSelection UI or keyboard)
##   2. InputManager enters placement preview mode
##   3. Player moves mouse over lanes to preview tower placement
##   4. Player left-clicks on a lane to confirm placement
##   5. InputManager emits tower_placement_requested signal with lane index and position
##
## Card selection via keyboard:
##   - Keys 1/2/3 select card slot (when card selection UI is visible)
##   - Space confirms selection (when a card is hovered or selected)
##   - Escape cancels placement preview mode
##
## Cursor state management:
##   - NORMAL: default cursor, no active input
##   - PLACING: ghost tower preview follows cursor over lanes
##   - SELECTING: card selection keyboard focus active

## --- Input states ---
enum InputState {
	NORMAL,
	PLACING,
	SELECTING,
}

## --- Signals ---
signal tower_placement_requested(lane_index: int, position_x: float, tower_scene: PackedScene)
signal tower_placement_cancelled
signal card_key_selected(card_index: int)
signal card_confirm_requested

## --- Configuration ---
var current_state: InputState = InputState.NORMAL
var active_tower_scene: PackedScene = null
var hovered_lane_index: int = -1
var _preview_node: Node2D = null
var pending_tower_scene: PackedScene = null

## --- Lifecycle ---
func _ready() -> void:
	set_process_input(true)
	print("[InputManager] Initialized.")

## --- Input handling ---
func _unhandled_input(event: InputEvent) -> void:
	if current_state == InputState.PLACING:
		_handle_placement_input(event)
		return
	if current_state == InputState.SELECTING:
		_handle_card_selection_input(event)
		return

## --- Tower placement preview ---
func _handle_placement_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_update_preview_position(event.global_position)
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_confirm_placement()
		return
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed) \
	or (event is InputEventKey and event.keycode == 27 and event.pressed):
		_cancel_placement()
		return

func _update_preview_position(mouse_pos: Vector2) -> void:
	var lane_manager := get_node("/root/LaneManager")
	if not lane_manager or not lane_manager.lanes:
		return
	var best_lane = -1
	var best_distance := INF
	for i in range(lane_manager.lanes.size()):
		var lane = lane_manager.lanes[i]
		if not lane:
			continue
		var lane_y = lane.global_position.y
		var hit_zone = 80.0
		if abs(mouse_pos.y - lane_y) < hit_zone:
			var lane_center_x = lane_manager.lane_spacing * i + lane_manager.lane_spacing / 2.0
			var distance = abs(mouse_pos.x - lane_center_x)
			if distance < lane_manager.lane_spacing / 2.0 and distance < best_distance:
				best_distance = distance
				best_lane = i
	if best_lane != hovered_lane_index:
		hovered_lane_index = best_lane
		if _preview_node and best_lane >= 0:
			var lane = lane_manager.lanes[best_lane]
			_preview_node.position.x = mouse_pos.x
			_preview_node.position.y = lane.global_position.y + 40.0
			_preview_node.visible = true
		elif _preview_node:
			_preview_node.visible = false

func _confirm_placement() -> void:
	if hovered_lane_index < 0 or not pending_tower_scene:
		_cancel_placement()
		return
	var lane_manager := get_node("/root/LaneManager")
	if not lane_manager or hovered_lane_index >= lane_manager.lanes.size():
		_cancel_placement()
		return
	var lane = lane_manager.lanes[hovered_lane_index]
	tower_placement_requested.emit(
		hovered_lane_index,
		lane.global_position.x + lane_manager.lane_spacing * hovered_lane_index,
		pending_tower_scene
	)
	print("[InputManager] Tower placement requested: lane=%d, tower=%s" % [
		hovered_lane_index,
		"res://tower/" + pending_tower_scene.resource_path.get_file().get_basename() if pending_tower_scene and pending_tower_scene.resource_path else "unknown"
	])

func _cancel_placement() -> void:
	if _preview_node:
		_preview_node.queue_free()
		_preview_node = null
	hovered_lane_index = -1
	current_state = InputState.NORMAL
	pending_tower_scene = null
	tower_placement_cancelled.emit()
	print("[InputManager] Tower placement cancelled.")

## --- Card selection keyboard support ---
func _handle_card_selection_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == Key.KEY_1:
			card_key_selected.emit(0)
		elif event.keycode == Key.KEY_2:
			card_key_selected.emit(1)
		elif event.keycode == Key.KEY_3:
			card_key_selected.emit(2)
		elif event.keycode == 256:
			card_confirm_requested.emit()

## --- Public API ---
func start_placement(tower_scene: PackedScene) -> void:
	pending_tower_scene = tower_scene
	current_state = InputState.PLACING
	hovered_lane_index = -1
	_create_preview_ghost(tower_scene)
	print("[InputManager] Placement mode started. Hover over a lane to place, click to confirm, ESC/right-click to cancel.")

func cancel_placement() -> void:
	if current_state == InputState.PLACING:
		_cancel_placement()

func start_card_selection() -> void:
	current_state = InputState.SELECTING
	print("[InputManager] Card selection mode active. Press 1/2/3 to select, Space to confirm.")

func end_card_selection() -> void:
	current_state = InputState.NORMAL

func get_hovered_lane() -> int:
	return hovered_lane_index

func is_placing() -> bool:
	return current_state == InputState.PLACING

## --- Ghost preview ---
func _create_preview_ghost(tower_scene: PackedScene) -> void:
	if _preview_node:
		_preview_node.queue_free()
		_preview_node = null
	if tower_scene:
		_preview_node = tower_scene.instantiate()
		if _preview_node:
			_preview_node.modulate = Color(1.0, 1.0, 1.0, 0.4)
			_preview_node.visible = false
			add_child(_preview_node)
			print("[InputManager] Preview ghost created.")
