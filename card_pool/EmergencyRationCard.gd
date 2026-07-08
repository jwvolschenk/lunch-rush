extends Resource
## EmergencyRationCard — a STATUS_EFFECT card that heals the kitchen.
##
## card_type: STATUS_EFFECT (value 1)
## cost: 15 gold
## rarity: uncommon
##
## Effect: restores 10 HP to the kitchen (GameState.health).
## Icon: warm green/white color.

enum CardType {
	TOWER,
	STATUS_EFFECT,
	SPECIAL,
}

@export var name: String = "Emergency Ration"

@export var description: String = "Heal the kitchen for 10 HP."

@export var cost: int = 15

@export var card_type: int = CardType.STATUS_EFFECT

@export var icon_color: Color = Color(0.4, 0.9, 0.5, 1)

@export var rarity: String = "uncommon"

## Amount of HP to restore
@export var heal_amount: int = 10

## Apply the ration effect: heal the kitchen.
## tower_manager: unused but required by signature.
## game_state: GameState reference, used to restore HP.
## Returns true if effect applied.
func apply_effect(tower_manager, game_state) -> bool:
	if not game_state:
		print("[EmergencyRationCard] No GameState found.")
		return false

	var old_health = game_state.health
	var new_health = old_health + heal_amount
	game_state.health = min(new_health, 20)
	print("[EmergencyRationCard] Healed kitchen for %d HP. Health: %d -> %d." % [heal_amount, old_health, game_state.health])
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
