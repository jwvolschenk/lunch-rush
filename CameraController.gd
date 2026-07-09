# class_name removed: this script is an autoload singleton
extends Node2D
## CameraController — Camera2D system for the tower defence game.
##
## Smoothly follows the average position of active enemies,
## with configurable zoom (mouse wheel) and pan (right-click drag).
## Clamps to the game world bounds defined by lanes.

## --- Target (Camera2D) ---
@onready var _camera: Camera2D = $Camera2D

## --- Configuration ---
## How fast the camera follows the target (0 = instant, 1 = very slow)
@export_range(0.01, 1.0, 0.01) var follow_speed: float = 0.08

## Minimum and maximum zoom levels
@export_range(0.3, 2.0, 0.05) var zoom_min: float = 0.5
@export_range(0.3, 2.0, 0.05) var zoom_max: float = 1.5

## Default zoom (resting state when enemies are spread out)
@export_range(0.3, 2.0, 0.05) var zoom_default: float = 0.8

## Zoom target when enemies are clustered (zooms in)
@export_range(0.3, 2.0, 0.05) var zoom_focus: float = 1.0

## Max distance enemies can be from the center before camera zooms in
@export_range(50.0, 500.0) var zoom_trigger_distance: float = 400.0

## Pan bounds (clamp camera to these world-space bounds)
@export var world_min: Vector2 = Vector2(-200, -100)
@export var world_max: Vector2 = Vector2(1500, 800)

## --- Internal state ---
var _target_position: Vector2 = Vector2.ZERO
var _current_zoom: float = 0.8
var _zoom_target: float = 0.8
var _is_panning: bool = false
var _pan_start: Vector2 = Vector2.ZERO
var _camera_start_pos: Vector2 = Vector2.ZERO
var _has_target: bool = false

## Signal emitted when zoom changes
signal zoom_changed(new_zoom: float)

## --- Lifecycle ---
func _ready() -> void:
	if _camera:
		_camera.enabled = true
		_current_zoom = zoom_default
		_zoom_target = zoom_default
		_camera.zoom = Vector2(_current_zoom, _current_zoom)
		zoom_changed.emit(_current_zoom)
		print("[CameraController] Camera enabled. Bounds: (%.0f,%.0f) -> (%.0f,%.0f)" % [
			world_min.x, world_min.y, world_max.x, world_max.y])
	else:
		push_error("[CameraController] No Camera2D child found.")

func _process(delta: float) -> void:
	if not _camera or not _camera.enabled:
		return
	
	# Smoothly interpolate zoom toward target
	if abs(_current_zoom - _zoom_target) > 0.001:
		_current_zoom += (_zoom_target - _current_zoom) * min(delta * 8.0, 1.0)
		_camera.zoom = Vector2(_current_zoom, _current_zoom)
	else:
		_current_zoom = _zoom_target
	
	# Smoothly follow the target position
	if _has_target and _target_position != Vector2.ZERO:
		var dx = _target_position.x - _camera.position.x
		var dy = _target_position.y - _camera.position.y
		var step = min(delta * follow_speed * 60.0, 1.0)
		_camera.position.x += dx * step
		_camera.position.y += dy * step
	
	# Clamp camera to world bounds
	_camera.position.x = clamp(_camera.position.x, world_min.x, world_max.x)
	_camera.position.y = clamp(_camera.position.y, world_min.y, world_max.y)

func _unhandled_input(event: InputEvent) -> void:
	# Zoom with mouse wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_target = clamp(_zoom_target + 0.1, zoom_min, zoom_max)
			zoom_changed.emit(_zoom_target)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_target = clamp(_zoom_target - 0.1, zoom_min, zoom_max)
			zoom_changed.emit(_zoom_target)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				_is_panning = true
				_pan_start = event.position
			else:
				_is_panning = false
	# Pan with mouse motion (continuous during drag)
	elif _is_panning and event is InputEventMouseMotion:
		var delta = event.position - _pan_start
		_camera.position -= delta / _current_zoom
		_pan_start = event.position

## --- Public API ---

## Update the follow target from all active enemies
func update_target(enemies: Array[Node2D]) -> void:
	if enemies.size() == 0:
		_has_target = false
		return
	
	var avg_x: float = 0
	var avg_y: float = 0
	for enemy in enemies:
		if enemy is Node2D:
			avg_x += enemy.position.x
			avg_y += enemy.position.y
	
	var count = float(enemies.size())
	_target_position = Vector2(avg_x / count, avg_y / count)
	_has_target = true
	
	# Determine zoom target based on enemy spread
	if enemies.size() >= 2:
		var first = enemies[0] as Node2D
		var last = enemies[enemies.size() - 1] as Node2D
		var spread = first.position.distance_to(last.position)
		if spread < zoom_trigger_distance:
			_zoom_target = zoom_focus
		else:
			_zoom_target = zoom_default

## Force a specific zoom level
func set_zoom(level: float) -> void:
	_zoom_target = clamp(level, zoom_min, zoom_max)
	zoom_changed.emit(_zoom_target)

## Reset camera to default position and zoom
func reset_camera() -> void:
	_camera.position = Vector2.ZERO
	_zoom_target = zoom_default
	zoom_changed.emit(zoom_default)

## Shake the screen by a given intensity for a duration.
func screen_shake(intensity: float, duration: float) -> void:
	if not _camera:
		return
	var original = _camera.position
	var steps = int(duration * 30.0)
	if steps < 3:
		steps = 3
	var delta = duration / steps
	var shake_count := 0
	for i in range(steps):
		var t = float(i) / steps
		var envelope = 1.0 - t
		var offset = Vector2(
			(randf() * 2.0 - 1.0) * intensity * envelope,
			(randf() * 2.0 - 1.0) * intensity * envelope
		)
		_camera.position = original + offset
		shake_count += 1
		if shake_count < steps:
			await get_tree().create_timer(delta).timeout
	_camera.position = original
