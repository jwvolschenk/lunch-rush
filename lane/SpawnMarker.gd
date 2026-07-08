extends Node2D
## SpawnMarker — visual indicator for enemy spawn position on a lane.
## Displays a pulsing ring at the spawn point.

## Preload the marker scene
const _SPAWN_MARKER_SCENE := preload("res://lane/SpawnMarker.tscn")

## Pulse animation
var _pulse_timer: float = 0.0
var _pulse_speed: float = 3.0
var _pulse_amount: float = 0.15

## Whether the marker should be visible
var _visible: bool = false

## Position the marker at the lane's spawn point
func position_at(spawn_pos: Vector2) -> void:
	position = spawn_pos

## Show or hide the marker
func set_visible(visible: bool) -> void:
	_visible = visible
	visible = visible

## Update pulse animation (call every frame)
func _process(delta: float) -> void:
	if not visible or not _visible:
		return
	
	_pulse_timer += delta * _pulse_speed
	var scale = 1.0 + sin(_pulse_timer) * _pulse_amount
	$SpawnRing.scale = Vector2(scale, scale)
