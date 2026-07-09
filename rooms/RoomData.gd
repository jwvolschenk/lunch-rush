class_name RoomData
extends Resource
## RoomData — scriptable resource defining a room (level) type.
## Each room has a unique visual theme and a gameplay modifier.
##
## Used by RoomSelector to present choices between waves.
## The selected room applies its modifier to the next wave.

## Name of this room (e.g. "Pantry")
@export var room_name: String = "Default Room"

## Short description shown in the room selector UI
@export var description: String = "A standard room."

## Room type enum for gameplay logic
enum RoomType {
	PANTRY,
	FREEZER,
	LAVA_KITCHEN,
	VIP_TABLE,
	CURSED_BUFFET,
}

@export var room_type: RoomType = RoomType.PANTRY

## Visual theme colors for this room
@export var bg_color: Color = Color(0.1, 0.1, 0.1, 1.0)
@export var accent_color: Color = Color(0.8, 0.6, 0.2, 1.0)
@export var border_color: Color = Color(0.3, 0.3, 0.3, 1.0)

## Gameplay modifier for the next wave
## positive = harder, negative = easier
@export var enemy_hp_modifier: float = 1.0
@export var enemy_speed_modifier: float = 1.0
@export var enemy_count_modifier: int = 0
@export var gold_bonus: int = 0

## Apply the room's modifier to wave configuration in GameState.
## Call this after the player selects a room.
func apply_modifier(wave: Dictionary) -> Dictionary:
	wave["enemy_hp"] *= enemy_hp_modifier
	wave["enemy_speed"] *= enemy_speed_modifier
	wave["enemy_count"] += enemy_count_modifier
	wave["gold_reward"] = int(wave.get("gold_reward", 25) * (1.0 + gold_bonus * 0.01))
	return wave
