extends Resource
## Card — scriptable resource defining a single card's data.
## Serves as the canonical card data model, used by the card selection UI,
## DeckManager, CardPool, and TowerManager during card placement.
##
## Fields map directly to the card selection UI display (name, description,
## cost, icon_color) and to gameplay systems (card_type, tower_scene).
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

