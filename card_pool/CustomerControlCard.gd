extends Resource
## CustomerControlCard — a spell card that slows all enemies on screen for 3 seconds.
##
## card_type: STATUS_EFFECT (value 1)
## cost: 15 gold
## cooldown: 1 wave (enforced by CardPool: one use per wave)
##
## Effect: applies a 0.4x speed multiplier to all active enemies for 3 seconds.
## Icon: blue shimmer color.

## Card type: status effect
enum CardType {
	TOWER,
	STATUS_EFFECT,
	SPECIAL,
}

## Card name
@export var name: String = "Customer Control"

## Short description shown in card selection UI
@export var description: String = "Slows all enemies to 40% speed for 3 seconds."

## Gold cost
@export var cost: int = 15

## Card type (status effect)
@export var card_type: int = CardType.STATUS_EFFECT

## Icon color (blue shimmer)
@export var icon_color: Color = Color(0.3, 0.6, 1.0, 1)

## Rarity
@export var rarity: String = "uncommon"

## Cooldown in number of waves (1 wave = usable every other wave)
@export var cooldown_waves: int = 1

## Whether this card has been used and is on cooldown
var _used_this_wave: bool = false

## Apply the customer control effect: slow all enemies on all lanes.
## tower_manager: unused but required by signature.
## game_state: GameState reference, used to deduct gold cost.
## Returns true if effect applied (including when cooldown blocks it).
func apply_effect(tower_manager, game_state) -> bool:
	# Deduct gold cost from GameState
	if game_state and game_state.has_method("deduct_gold"):
		game_state.deduct_gold(cost)

	# Get all lanes and slow enemies
	var lane_manager = get_tree().get_root().get_node_or_null("LaneManager")
	if not lane_manager:
		print("[CustomerControlCard] No LaneManager found.")
		return false

	var total_slowed = 0
	var all_lanes = []
	if lane_manager.has_method("get_all_lanes"):
		all_lanes = lane_manager.get_all_lanes()

	for lane in all_lanes:
		if lane and lane.has_method("get_enemies"):
			var enemies = lane.get_enemies()
			for enemy in enemies:
				if enemy and enemy.is_alive and enemy.has_method("apply_slow"):
					enemy.apply_slow(0.4, 3.0)
					total_slowed += 1

	print("[CustomerControlCard] Slowed %d enemies for 3 seconds." % total_slowed)
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
