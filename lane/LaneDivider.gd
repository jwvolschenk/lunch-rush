extends Node2D
## LaneDivider — visual barrier between lanes that enemies cannot cross.
## Renders a vertical wall segment between two lanes.
## In the current architecture enemies are confined to their lane (horizontal-only),
## so the wall is primarily visual but documents the constraint.

## --- Configuration ---
## Opacity of the divider wall (0.0 = invisible, 1.0 = fully opaque)
@export var wall_opacity: float = 0.6

## Wall color
@export var wall_color: Color = Color(0.15, 0.15, 0.15, 1.0)

## Width of the wall in pixels
@export var wall_width: float = 6.0

## Height of the wall in pixels (extends above/below lane)
@export var wall_height: float = 80.0

## --- Internal ---
var _wall: ColorRect

func _ready() -> void:
	_wall = get_node("DividerWall")
	if _wall:
		_wall.size.x = wall_width
		_wall.size.y = wall_height
		_wall.color = wall_color
		_wall.color.a = wall_opacity

## Update the wall visual properties at runtime
func update_wall(opacity: float, width: float, height: float) -> void:
	wall_opacity = opacity
	wall_width = width
	wall_height = height
	wall_opacity = opacity
	if _wall:
		_wall.size.x = width
		_wall.size.y = height
		_wall.color.a = opacity
