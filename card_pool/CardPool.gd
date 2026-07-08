extends Resource
## CardPool — defines the available card pool for a run.
## Generates card choices dynamically based on game state,
## rarity weights, and room modifiers.
##
## Used by Main and WaveManager to populate the CardSelection UI
## after each wave completes.

## Available card type categories
enum CardCategory {
	TOWER,         # Places a new tower
	STATUS_EFFECT,  # Applies a temporary buff/debuff
	SPECIAL,        # Unique card (e.g., Combo Meal, Health Inspector)
}

## Rarity weights: higher value = more likely to appear
@export var common_weight: float = 0.6
@export var uncommon_weight: float = 0.3
@export var rare_weight: float = 0.1

## All known card definitions in the game
@export var all_cards: Array[Dictionary] = [
	# --- Tower cards (card_type = CardCategory.TOWER) ---
	{
		"name": "Goblin Fry Cook",
		"description": "Fast short-range grease attack. Deals area splash damage.",
		"cost": 25,
		"card_type": CardCategory.TOWER,
		"icon_color": Color(0.9, 0.8, 0.2, 1),
		"rarity": "common",
		"tower_scene": "res://tower/GoblinFryCook.tscn",
	},
	{
		"name": "Pizza Trebuchet",
		"description": "Slow splash-damage tower. Launches pies at groups of enemies.",
		"cost": 50,
		"card_type": CardCategory.TOWER,
		"icon_color": Color(0.9, 0.5, 0.2, 1),
		"rarity": "uncommon",
		"tower_scene": "res://tower/PizzaTrebuchet.tscn",
	},
	{
		"name": "Soup Spill",
		"description": "Creates a slowing puddle. Damages and slows enemies in the area.",
		"cost": 35,
		"card_type": CardCategory.TOWER,
		"icon_color": Color(0.4, 0.7, 0.9, 1),
		"rarity": "uncommon",
		"tower_scene": "res://tower/SoupSpill.tscn",
	},
	{
		"name": "Health Inspector",
		"description": "Temparily scares enemies backward on all lanes.",
		"cost": 40,
		"card_type": CardCategory.SPECIAL,
		"icon_color": Color(0.8, 0.8, 0.1, 1),
		"rarity": "rare",
	},
	{
		"name": "Combo Meal",
		"description": "Replay the last tower card you placed. Free.",
		"cost": 0,
		"card_type": CardCategory.SPECIAL,
		"icon_color": Color(0.6, 0.9, 0.4, 1),
		"rarity": "uncommon",
	},
	{
		"name": "Enchanted Vending Machine",
		"description": "Passively generates gold over time.",
		"cost": 60,
		"card_type": CardCategory.TOWER,
		"icon_color": Color(0.7, 0.4, 0.9, 1),
		"rarity": "rare",
		"tower_scene": "res://tower/VendingMachine.tscn",
	},
	{
		"name": "Angry Dishwasher",
		"description": "Fast melee attacker. Short range, high damage.",
		"cost": 45,
		"card_type": CardCategory.TOWER,
		"icon_color": Color(0.5, 0.5, 0.7, 1),
		"rarity": "uncommon",
		"tower_scene": "res://tower/Dishwasher.tscn",
	},
	{
		"name": "Customer Control",
		"description": "Slows all enemies to 40% speed for 3 seconds.",
		"cost": 15,
		"card_type": CardCategory.STATUS_EFFECT,
		"icon_color": Color(0.3, 0.6, 1.0, 1),
		"rarity": "uncommon",
	},
]

## Cards that have been placed this run (to avoid duplicate tower types)
var _placed_towers: Array[String] = []

## The last tower card placed (for Combo Meal)
var _last_tower_card: Dictionary = {}

## Whether to include placed towers again in the pool
@export var allow_duplicate_towers: bool = true

## --- Card generation ---

## Get a pool of `count` cards for the current wave.
## Uses rarity-weighted random selection, skipping already-placed towers
## unless allow_duplicate_towers is true.
func get_card_pool(count: int = 3) -> Array[Dictionary]:
	var available := _get_available_cards()
	var selected: Array[Dictionary] = []
	var pool := available.duplicate()

	for _i in range(min(count, pool.size())):
		var card := _pick_from_pool(pool)
		if card:
			selected.append(card)
			pool = _remove_card(pool, card)

	# Pad with starter cards if pool is exhausted
	while selected.size() < count and pool.is_empty():
		var starter := _get_starter_card(selected)
		if starter and not selected.has(starter):
			selected.append(starter)
		break

	return selected

## Get the last placed tower card for Combo Meal replay.
func get_last_tower_card() -> Dictionary:
	return _last_tower_card.duplicate()

## Mark a card as placed (used when the player selects a card).
func record_card_played(card: Dictionary) -> void:
	if card.get("card_type") == CardCategory.TOWER:
		_last_tower_card = card.duplicate()
		var tower_name = card.get("name", "")
		if not allow_duplicate_towers and not _placed_towers.has(tower_name):
			_placed_towers.append(tower_name)

## Clear the pool state (call at the start of a new run).
func reset() -> void:
	_placed_towers.clear()
	_last_tower_card = {}

## --- Internal helpers ---

## Get cards that are available (not already placed as towers).
func _get_available_cards() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for card in all_cards:
		if card.get("card_type") == CardCategory.TOWER:
			var tower_name = card.get("name", "")
			if allow_duplicate_towers or not _placed_towers.has(tower_name):
				result.append(card)
		else:
			result.append(card)
	return result

## Pick a random card from the pool, weighted by rarity.
func _pick_from_pool(pool: Array[Dictionary]) -> Dictionary:
	if pool.is_empty():
		return null

	var total_weight := 0.0
	var weighted_cards: Array = []

	for card in pool:
		var rarity = card.get("rarity", "common")
		var weight := 1.0
		match rarity:
			"common": weight = common_weight
			"uncommon": weight = uncommon_weight
			"rare": weight = rare_weight
		total_weight += weight
		for _j in range(1):  # each card gets one weighted slot
			weighted_cards.append([card, weight])

	if total_weight <= 0:
		return pool[randi() % pool.size()]

	var roll = randf() * total_weight
	var cumulative := 0.0
	for entry in weighted_cards:
		cumulative += entry[1]
		if roll <= cumulative:
			return entry[0]

	return pool[randi() % pool.size()]

## Remove a specific card from a pool array.
func _remove_card(pool: Array[Dictionary], card: Dictionary) -> Array[Dictionary]:
	var result = pool.duplicate()
	for i in range(result.size()):
		if result[i] == card:
			result.remove_at(i)
			break
	return result

## Get a default starter card when the pool is exhausted.
func _get_starter_card(already_selected: Array) -> Dictionary:
	var starters = [
		{
			"name": "Goblin Fry Cook",
			"description": "Fast short-range grease attack. Deals area splash damage.",
			"cost": 25,
			"card_type": CardCategory.TOWER,
			"icon_color": Color(0.9, 0.8, 0.2, 1),
			"rarity": "common",
		},
		{
			"name": "Pizza Trebuchet",
			"description": "Slow splash-damage tower. Launches pies at groups of enemies.",
			"cost": 50,
			"card_type": CardCategory.TOWER,
			"icon_color": Color(0.9, 0.5, 0.2, 1),
			"rarity": "uncommon",
		},
		{
			"name": "Soup Spill",
			"description": "Creates a slowing puddle. Damages and slows enemies in the area.",
			"cost": 35,
			"card_type": CardCategory.TOWER,
			"icon_color": Color(0.4, 0.7, 0.9, 1),
			"rarity": "uncommon",
		},
	]
	for starter in starters:
		var duplicate := false
		for s in already_selected:
			if s.get("name") == starter.name:
				duplicate = true
				break
		if not duplicate:
			return starter
	return {}
