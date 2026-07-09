class_name CravingType

## CravingType — food types used by the craving system.
## Enemies have a random craving; matching projectiles apply a slow debuff,
## mismatching ones apply an enrage buff.

enum CravingType {
	NONE,
	GREASE,
	SOUP,
	SPICE,
	PIZZA,
}

## Convert food_type strings (e.g. "grease", "soup") to CravingType int values.
static func food_type_to_int(food_type) -> int:
	if food_type is int:
		return food_type
	if food_type is String:
		match food_type:
			"grease": return CravingType.GREASE
			"soup": return CravingType.SOUP
			"spice": return CravingType.SPICE
			"pizza": return CravingType.PIZZA
			"none", "": return CravingType.NONE
	return CravingType.NONE
