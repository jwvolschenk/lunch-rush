extends Node
## DeckManager — autoload singleton managing the player's deck.
## The deck holds all cards the player can draw from. On each wave
## transition the player draws N cards into their hand. Played cards
## move to a discard pile; when the draw pile empties it is shuffled
## back into the deck from the discard pile.

## Number of cards to draw each wave
@export var cards_to_draw: int = 3

## The deck (draw pile) — cards available to draw
var deck: Array[Dictionary] = []

## The player's current hand
var hand: Array[Dictionary] = []

## Discarded cards (when deck is empty, these are reshuffled)
var discard: Array[Dictionary] = []

## Signal emitted when the hand changes (cards drawn or discarded)
signal hand_changed

## Signal emitted when the deck is reshuffled from discard
signal deck_reshuffled

## --- Lifecycle ---

## Reset all deck state for a new run.
func reset() -> void:
	deck = _get_starter_deck()
	hand.clear()
	discard.clear()
	# Draw initial hand of 3
	draw(3)
	hand_changed.emit()
	print("[DeckManager] Deck reset. Deck=%d, Hand=%d" % [deck.size(), hand.size()])

## --- Drawing ---

## Draw N cards from deck into hand.
## Returns the cards drawn (may be fewer than requested if deck is empty).
func draw(count: int = 1) -> Array[Dictionary]:
	var cards := []
	for _i in range(count):
		if deck.is_empty():
			_try_reshuffle()
			if deck.is_empty():
				break
		var card = deck.pop_back()
		hand.append(card)
		cards.append(card)
	hand_changed.emit()
	if cards.is_empty():
		print("[DeckManager] Deck empty, nothing to draw.")
	return cards

## Draw the configured number of cards each wave.
func draw_for_wave() -> Array[Dictionary]:
	return draw(cards_to_draw)

## --- Discarding ---

## Move a card from hand to discard pile.
func discard_card(card: Dictionary) -> bool:
	if card in hand:
		hand.erase(card)
		discard.append(card)
		hand_changed.emit()
		return true
	return false

## Discard the entire hand (e.g. at wave end).
func discard_hand() -> void:
	for card in hand:
		discard.append(card)
	hand.clear()
	hand_changed.emit()

## --- Deck reshuffle ---

## If the deck is empty, shuffle discard into the deck.
func _try_reshuffle() -> void:
	if deck.is_empty() and not discard.is_empty():
		reshuffle_deck()

## Shuffle all discard pile cards back into the deck.
func reshuffle_deck() -> void:
	if discard.is_empty():
		return
	# Shuffle: Fisher-Yates
	for i in range(discard.size() - 1, 0, -1):
		var j = randi() % (i + 1)
		discard.swap(i, j)
	deck = discard.duplicate()
	discard.clear()
	print("[DeckManager] Deck reshuffled from %d discard cards." % deck.size())
	deck_reshuffled.emit()

## --- Query ---

## Get the current hand
func get_hand() -> Array[Dictionary]:
	return hand.duplicate()

## Get the current deck size
func get_deck_size() -> int:
	return deck.size()

## Get the current discard size
func get_discard_size() -> int:
	return discard.size()

## Check if the draw pile is empty
func is_deck_empty() -> bool:
	return deck.is_empty()

## Check if the player has any cards in hand
func has_cards_in_hand() -> bool:
	return not hand.is_empty()

## Get a card by name from the hand. Returns null if not found.
func find_card_in_hand(name: String) -> Dictionary:
	for card in hand:
		if card.get("name", "") == name:
			return card
	return null

## --- Internal ---

## Get the starter deck: a set of tower cards the player begins with.
func _get_starter_deck() -> Array[Dictionary]:
	return [
		{
			"name": "Goblin Fry Cook",
			"description": "Fast short-range grease attack. Deals area splash damage.",
			"cost": 25,
			"card_type": 1,
			"icon_color": Color(0.9, 0.8, 0.2, 1),
			"tower_scene": "res://tower/GoblinFryCook.tscn",
		},
		{
			"name": "Goblin Fry Cook",
			"description": "Fast short-range grease attack. Deals area splash damage.",
			"cost": 25,
			"card_type": 1,
			"icon_color": Color(0.9, 0.8, 0.2, 1),
			"tower_scene": "res://tower/GoblinFryCook.tscn",
		},
		{
			"name": "Pizza Trebuchet",
			"description": "Slow splash-damage tower. Launches pies at groups of enemies.",
			"cost": 50,
			"card_type": 1,
			"icon_color": Color(0.9, 0.5, 0.2, 1),
			"tower_scene": "res://tower/PizzaTrebuchet.tscn",
		},
		{
			"name": "Soup Spill",
			"description": "Creates a slowing puddle. Damages and slows enemies in the area.",
			"cost": 35,
			"card_type": 1,
			"icon_color": Color(0.4, 0.7, 0.9, 1),
			"tower_scene": "res://tower/SoupSpill.tscn",
		},
		{
			"name": "Soup Spill",
			"description": "Creates a slowing puddle. Damages and slows enemies in the area.",
			"cost": 35,
			"card_type": 1,
			"icon_color": Color(0.4, 0.7, 0.9, 1),
			"tower_scene": "res://tower/SoupSpill.tscn",
		},
		{
			"name": "Goblin Fry Cook",
			"description": "Fast short-range grease attack. Deals area splash damage.",
			"cost": 25,
			"card_type": 1,
			"icon_color": Color(0.9, 0.8, 0.2, 1),
			"tower_scene": "res://tower/GoblinFryCook.tscn",
		},
		{
			"name": "Pizza Trebuchet",
			"description": "Slow splash-damage tower. Launches pies at groups of enemies.",
			"cost": 50,
			"card_type": 1,
			"icon_color": Color(0.9, 0.5, 0.2, 1),
			"tower_scene": "res://tower/PizzaTrebuchet.tscn",
		},
		{
			"name": "Soup Spill",
			"description": "Creates a slowing puddle. Damages and slows enemies in the area.",
			"cost": 35,
			"card_type": 1,
			"icon_color": Color(0.4, 0.7, 0.9, 1),
			"tower_scene": "res://tower/SoupSpill.tscn",
		},
	]
