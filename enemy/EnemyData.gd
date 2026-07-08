extends Resource
## EnemyData — scriptable resource defining enemy spawn stats.
## Create instances in the editor or via preload to configure
## enemy types without touching code.
##
## Used by WaveManager to instantiate enemies with correct stats
## and by the Tower system to award gold/score on kill.

## Name of this enemy type (e.g. "Hungry Goblin")
@export var name: String = "Enemy"

## Maximum HP
@export var max_hp: float = 40.0

## Movement speed toward the kitchen (pixels per second)
@export var speed: float = 60.0

## Gold reward awarded to the player on death
@export var gold_reward: int = 10

## Score awarded to the player on death
@export var score_reward: int = 10

## Craving food type: greed/soup/spice
## Matching craving applies slow debuff; wrong food applies enrage
@export var craving: CravingType = CravingType.GREASE

enum CravingType {
	GREASE,
	SOUP,
	SPICE,
}

## Color used for the enemy's sprite (visual feedback)
@export var tint_color: Color = Color(0.4, 0.8, 0.4, 1.0)

## Path to a custom scene overriding the default Enemy.tscn
## Leave empty to use the default Enemy scene
@export var custom_scene: String = ""
