extends Resource
## Card — scriptable resource defining a single card's data.
## Serves as the canonical card data model, used by the card selection UI,
## DeckManager, CardPool, and TowerManager during card placement.
##
## Fields map directly to the card selection UI display (name, description,
## cost, icon_color) and to gameplay systems (card_type, tower_scene).
## The apply_effect() virtual method dispatches card-type-specific logic
## so new card types can be added by subclassing.

## Card type categories matching CardCategory in CardPool.gd
enum CardType {
	TOWER,           # Places a tower on a lane
	STATUS_EFFECT,   # Applies a temporary buff/debuff to enemies or player
	SPECIAL,         # Unique card (Combo Meal, Health Inspector, etc.)
}

## Name of this card (e.g. "Goblin Fry Cook")
@export var name: String = "Card"

## Short description shown in the card selection UI
@export var description: String = ""

## Gold cost to play this card
@export var cost: int = 0

## The card's type (tower, status_effect, or special)
@export var card_type: CardType = CardType.TOWER

## Icon color shown in the card selection UI (visual identifier)
@export var icon_color: Color = Color.WHITE

## Rarity tier used by CardPool for weighted selection
@export var rarity: String = "common"

## Path to the tower scene to instantiate when this card is played
## Only used when card_type == TOWER; ignored for other types
@export var tower_scene: String = ""

## --- Effect dispatch ---

## Apply this card's effect at runtime. Called when the player selects
## this card in the card selection UI. Override in subclasses for
## custom card behavior.
##
## tower_manager: reference to the TowerManager to place towers (for TOWER cards).
## gameState: reference to GameState to update score/gold/health (for all cards).
## Returns true if the effect was applied successfully.
func apply_effect(tower_manager, game_state) -> bool:
	match card_type:
		CardType.TOWER:
			return _apply_tower_effect(tower_manager, game_state)
		CardType.STATUS_EFFECT:
			return _apply_status_effect(game_state)
		CardType.SPECIAL:
			return _apply_special_effect(tower_manager, game_state)
	return false

## --- Tower card effect ---
func _apply_tower_effect(tower_manager, game_state) -> bool:
	if not tower_manager:
		return false
	if game_state and game_state.get("gold", 0) < cost:
		return false
	if game_state and game_state.has_method("deduct_gold"):
		game_state.deduct_gold(cost)
	if tower_manager.has_method("place_tower"):
		tower_manager.place_tower(tower_scene)
		if game_state and game_state.has_method("add_score"):
			game_state.add_score(cost)  # score bonus proportional to cost
		return true
	return false

## --- Status effect card effect ---
func _apply_status_effect(game_state) -> bool:
	if not game_state:
		return false
	return true

## --- Special card effect ---
func _apply_special_effect(tower_manager, game_state) -> bool:
	if not game_state:
		return false
	return true

## --- Helpers for subclasses ---

## Copy this card's data into a Dictionary for UI display.
## Matches the format expected by CardSelection.show_cards().
func to_dict() -> Dictionary:
	return {
		"name": name,
		"description": description,
		"cost": cost,
		"card_type": card_type,
		"icon_color": icon_color,
		"rarity": rarity,
		"tower_scene": tower_scene,
	}

## Create a new Card from a Dictionary (e.g. loaded from CardPool).
static func from_dict(data: Dictionary) -> Resource:
	var card := Card.new()
	card.name = data.get("name", "Card")
	card.description = data.get("description", "")
	card.cost = data.get("cost", 0)
	card.card_type = data.get("card_type", CardType.TOWER)
	card.icon_color = data.get("icon_color", Color.WHITE)
	card.rarity = data.get("rarity", "common")
	card.tower_scene = data.get("tower_scene", "")
	return card
