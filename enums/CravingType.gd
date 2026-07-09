class_name CravingType

## CravingType — food types used by the craving system.
## Enemies have a random craving; matching projectiles apply a slow debuff,
## mismatching ones apply an enrage buff.

enum Type {
	NONE,
	GREASE,
	SOUP,
	SPICE,
	PIZZA,
}

const NONE = Type.NONE
const GREASE = Type.GREASE
const SOUP = Type.SOUP
const SPICE = Type.SPICE
const PIZZA = Type.PIZZA

## Convert food_type strings (e.g. "grease", "soup") to CravingType int values.
static func food_type_to_int(food_type) -> int:
	if food_type is int:
		return food_type
	if food_type is String:
		match food_type:
			"grease": return Type.GREASE
			"soup": return Type.SOUP
			"spice": return Type.SPICE
			"pizza": return Type.PIZZA
			"none", "": return Type.NONE
	return Type.NONE
