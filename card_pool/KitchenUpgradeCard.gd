extends Resource
## KitchenUpgradeCard — a STATUS_EFFECT card that buffs all placed towers.
##
## card_type: STATUS_EFFECT (value 1)
## cost: 20 gold
## rarity: uncommon
##
## Effect: all towers gain +50% attack speed (halved cooldown) and +25% damage
## for 10 seconds.
## Icon: golden-orange color.

enum CardType {
	TOWER,
	STATUS_EFFECT,
	SPECIAL,
}

@export var name: String = "Kitchen Upgrade"

@export var description: String = "All towers gain +50% attack speed and +25% damage for 10s."

@export var cost: int = 20

@export var card_type: int = CardType.STATUS_EFFECT

@export var icon_color: Color = Color(1.0, 0.7, 0.2, 1)

@export var rarity: String = "uncommon"

## Duration of the buff in seconds
@export var buff_duration: float = 10.0

## Attack speed multiplier (1.5 = 50% faster)
@export var attack_speed_multiplier: float = 0.5

## Damage multiplier (1.25 = 25% more damage)
@export var damage_multiplier: float = 1.25

## Buffed towers tracking
var _buffed_towers: Array[Node2D] = []
var _original_stats: Dictionary = {}

## Apply the kitchen upgrade effect: buff all placed towers.
## tower_manager: unused but required by signature.
## game_state: GameState reference, used to deduct gold cost.
## Returns true if effect applied.
func apply_effect(tower_manager, game_state) -> bool:
	# Deduct gold cost from GameState
	if game_state and game_state.has_method("deduct_gold"):
		game_state.deduct_gold(cost)

	# Get all active towers
	var all_towers = []
	if TowerManager and TowerManager.has_method("get_all_towers"):
		all_towers = TowerManager.get_all_towers()
	else:
		print("[KitchenUpgradeCard] No TowerManager found.")
		return false

	if all_towers.is_empty():
		print("[KitchenUpgradeCard] No towers to buff.")
		return false

	# Store original stats and apply buffs
	_buffed_towers = all_towers.duplicate()
	_original_stats.clear()

	for tower in all_towers:
		if tower and tower.has_method("is_alive") and tower.is_alive:
			_original_stats[tower.get_instance_id()] = {
				"damage": tower.damage,
				"cooldown": tower.cooldown,
			}
			tower.damage *= damage_multiplier
			tower.cooldown *= attack_speed_multiplier

	print("[KitchenUpgradeCard] Buffed %d towers for %.0fs." % [all_towers.size(), buff_duration])

	# Schedule buff expiry
	var tree = get_tree()
	if tree:
		var timer = tree.create_timer(buff_duration)
		timer.connect("timeout", _on_buff_end)

	return true

## Restore original tower stats after the buff duration expires.
func _on_buff_end() -> void:
	for tower in _buffed_towers:
		if tower and tower.is_alive and tower.get_instance_id() in _original_stats:
			var stats = _original_stats[tower.get_instance_id()]
			tower.damage = stats["damage"]
			tower.cooldown = stats["cooldown"]

	print("[KitchenUpgradeCard] Buff expired. Tower stats restored.")

	_buffed_towers.clear()
	_original_stats.clear()

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
