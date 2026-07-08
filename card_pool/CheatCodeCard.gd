extends Resource
## CheatCodeCard — a SPECIAL card that instantly kills all enemies on screen.
##
## One-time-use boss-killer. When played, destroys every enemy on all lanes
## regardless of their HP. Costs 75 gold, rare rarity.
##
## card_type: SPECIAL (value 2 in CardCategory)
## cost: 75 gold
## rarity: rare

enum CardType {
	NONE,
	TOWER,
	STATUS_EFFECT,
	SPECIAL,
}

@export var name: String = "Cheat Code"

@export var description: String = "Instantly kills all enemies on screen. One-time boss killer."

@export var cost: int = 75

@export var card_type: int = CardType.SPECIAL

@export var icon_color: Color = Color(1.0, 0.2, 1.0, 1)

@export var rarity: String = "rare"

## Whether this card has already been used (one-time use)
var _used: bool = false

## Apply the cheat code effect: kill all enemies on all lanes.
## tower_manager: unused but required by signature.
## game_state: GameState reference, used to deduct gold cost.
## Returns true if the effect was applied successfully.
func apply_effect(tower_manager, game_state) -> bool:
	if _used:
		print("[CheatCodeCard] Cheat Code already used this run.")
		return false

	# Deduct gold cost
	if game_state and game_state.has_method("deduct_gold"):
		game_state.deduct_gold(cost)

	# Kill all enemies on all lanes
	var lane_manager = get_tree().get_root().get_node_or_null("LaneManager")
	if not lane_manager:
		print("[CheatCodeCard] No LaneManager found.")
		return false

	var all_lanes = []
	if lane_manager.has_method("get_all_lanes"):
		all_lanes = lane_manager.get_all_lanes()

	var total_killed = 0
	for lane in all_lanes:
		if lane and lane.has_method("get_enemies"):
			var enemies = lane.get_enemies()
			for enemy in enemies:
				if enemy and enemy.has_method("is_alive") and enemy.is_alive:
					if enemy.has_method("take_damage"):
						enemy.take_damage(9999)
					total_killed += 1

	_used = true
	print("[CheatCodeCard] Cheat Code used! Killed %d enemies." % total_killed)
	return true

## Get card data as a dictionary for the card selection UI.
func to_dict() -> Dictionary:
	var data = {
		"name": name,
		"description": description,
		"cost": cost,
		"card_type": card_type,
		"icon_color": icon_color,
		"rarity": rarity,
	}
	return data
