extends Resource
## ComboMealCard — special card that replays the last tower card placed.
##
## When played, checks CardPool._last_tower_card for the previously placed
## tower card data and re-calls tower placement with the same stats
## (tower_scene, cost, name) on a random available lane.
##
## card_type: CardCategory.SPECIAL (value 2 in CardPool.CardCategory)
## cost: 0 (free replay of the last tower)
##
## Fields:
## last_placed_tower: Dictionary reference to the last tower card placed,
##   copied from CardPool.get_last_tower_card() at play time.

## Card type: special (replay last tower)
enum CardType {
	NONE,
	TOWER,
	STATUS_EFFECT,
	SPECIAL,
	COMBO_MEAL,  # Replay last placed tower card
}

## Name of this card
@export var name: String = "Combo Meal"

## Short description
@export var description: String = "Replay the last tower card placed. Free."

## Gold cost (always 0 for combo meal)
@export var cost: int = 0

## Card category
@export var card_type: int = CardType.SPECIAL

## Icon color for the card selection UI
@export var icon_color: Color = Color(0.6, 0.9, 0.4, 1)

## Rarity used by CardPool for weighted selection
@export var rarity: String = "uncommon"

## Reference to the last placed tower card data (populated at play time)
var last_placed_tower: Dictionary = {}

## Path to the tower scene of the last placed tower
var last_tower_scene_path: String = ""

## --- Effect dispatch ---

## Apply the combo meal effect: replay the last placed tower card.
## tower_manager: reference to TowerManager to place the tower.
## gameState: reference to GameState to check gold (always 0 cost).
## Returns true if the last tower was found and placed.
func apply_effect(tower_manager, game_state) -> bool:
	# Load the last tower card from CardPool
	var pool := CardPool
	if not pool or not pool.has_method("get_last_tower_card"):
		print("[ComboMealCard] No CardPool available.")
		return false

	last_placed_tower = pool.get_last_tower_card()

	# Check if there is a previous tower to replay
	if not last_placed_tower or last_placed_tower.is_empty():
		print("[ComboMealCard] No previous tower card to replay.")
		return false

	# Extract tower scene path from the stored card data
	last_tower_scene_path = last_placed_tower.get("tower_scene", "")
	if not last_tower_scene_path or last_tower_scene_path.is_empty():
		print("[ComboMealCard] Last tower card has no tower_scene.")
		return false

	# Validate tower manager
	if not tower_manager or not tower_manager.has_method("place_tower"):
		print("[ComboMealCard] No valid TowerManager to place tower.")
		return false

	# Load the tower scene
	var tower_scene = load(last_tower_scene_path)
	if not tower_scene:
		print("[ComboMealCard] Failed to load tower scene: %s" % last_tower_scene_path)
		return false

	# Get a random available lane from LaneManager
	var lane_manager := get_tree().get_root().get_node_or_null("LaneManager")
	var lane_index = 0
	if lane_manager and lane_manager.has_method("lane_count") and lane_manager.lane_count > 0:
		lane_index = randi() % lane_manager.lane_count
	else:
		print("[ComboMealCard] No LaneManager found, using lane 0.")

	# Place tower at a random position on the lane
	var max_x = 1400.0  # Approximate lane spacing * lane_count
	var at_x = randf() * max_x * 0.8 + max_x * 0.1

	var tower = tower_manager.place_tower(tower_scene, lane_index, at_x)
	if tower:
		print("[ComboMealCard] Combo Meal! Replayed '%s' on lane %d." % [
			last_placed_tower.get("name", "Unknown"), lane_index
		])
		return true
	else:
		print("[ComboMealCard] Failed to place replayed tower '%s'." % [
			last_placed_tower.get("name", "Unknown")
		])
		return false

## Get card data as a dictionary for the card selection UI.
## Matches the format expected by CardPool and CardSelection.show_cards().
func to_dict() -> Dictionary:
	var data := {
		"name": name,
		"description": description,
		"cost": cost,
		"card_type": card_type,
		"icon_color": icon_color,
		"rarity": rarity,
	}
	# Only include tower_scene for Combo Meal if we have a valid last tower
	if last_tower_scene_path and not last_tower_scene_path.is_empty():
		data["tower_scene"] = last_tower_scene_path
	return data
