extends Node2D
## Enemy — base class for all enemy types.
## Enemies move left toward the kitchen along their lane.
## When HP reaches zero, the death signal fires and the enemy self-removes.
##
## Child scenes (Hungry Goblin, etc.) should override _on_ready_setup()
## to customize appearance and stats.

## --- Configuration ---

## Maximum HP
@export var max_hp: float = 40.0

## Movement speed toward the kitchen (pixels per second)
@export var speed: float = 60.0

## Food type this enemy craves (0=none, 1=grease, 2=soup, 3=spice).
## Matching food slows the enemy; mismatching food enrages it.
var craving: int = 0

## Gold reward on death
@export var gold_reward: int = 10

## Score reward on death
@export var score_reward: int = 10

## --- Internal state ---

## Backing store for the current_hp property
var _current_hp: float = 40.0

## Current HP (decreases as the enemy takes damage)
var current_hp: float:
	get:
		return _current_hp
	set(v):
		_current_hp = v
		if hp_bar and max_hp > 0:
			var ratio = clamp(_current_hp / max_hp, 0.0, 1.0)
			hp_bar.size.x = 80.0 * ratio
		if _current_hp <= 0:
			_on_death()

## The lane this enemy is currently on
var lane: Lane = null

## Whether the enemy is alive
var is_alive: bool:
	get:
		return current_hp > 0

## --- Signals ---

## Emitted when this enemy dies (HP reaches zero)
signal enemy_dead(enemy: Node2D)

## --- Internal ---

# Health bar background
var hp_bar_bg: ColorRect

# Health bar fill
var hp_bar: ColorRect

var _is_dying: bool = false

## --- Craving indicator ---

## The craving indicator node (ColorRect + Label above the enemy)
var _craving_indicator: ColorRect = null

## Letter label for the craving indicator
var _craving_label: Label = null

## --- Craving / debuff state ---

## Remaining duration of the slow debuff
var _slow_timer: float = 0.0

## Current slow multiplier (starts at 1.0, reduced by slow debuff)
var _slow_factor: float = 1.0

## Remaining duration of the enrage buff
var _enrage_timer: float = 0.0

## Current enrage multiplier (starts at 1.0, increased by enrage buff)
var _enrage_factor: float = 1.0

## Effective speed (base * slow * enrage), updated each frame
var effective_speed: float:
	get:
		return speed * _slow_factor * _enrage_factor

## Apply a slow debuff to this enemy.
## factor: multiplier to apply (e.g. 0.7 = 30% slow).
## duration: how long the slow lasts in seconds.
func apply_slow(factor: float, duration: float) -> void:
	_slow_factor = min(_slow_factor, factor)
	_slow_timer = duration
	_update_hp_bar_color()

## Apply an enrage buff to this enemy.
## factor: multiplier to apply (e.g. 1.2 = 20% faster).
## duration: how long the enrage lasts in seconds.
func apply_enrage(factor: float, duration: float) -> void:
	_enrage_factor = max(_enrage_factor, factor)
	_enrage_timer = duration
	_update_hp_bar_color()

## Reset all debuffs and buffs. Called on death or manual reset.
func clear_debuffs() -> void:
	_slow_timer = 0.0
	_slow_factor = 1.0
	_enrage_timer = 0.0
	_enrage_factor = 1.0
	_update_hp_bar_color()

## Push this enemy backward (toward spawn) by the given distance.
func apply_pushback(distance: float) -> void:
	position.x += distance
	print("[Enemy] Pushed back %dpx" % distance)

## Update the HP bar color based on active debuff/buff state
func _update_hp_bar_color() -> void:
	if not hp_bar:
		return
	if _slow_timer > 0:
		hp_bar.color = Color(0.3, 0.3, 0.9, 1.0)  # blue = slowed
	elif _enrage_timer > 0:
		hp_bar.color = Color(0.9, 0.2, 0.2, 1.0)  # red = enraged
	else:
		hp_bar.color = Color(0.2, 0.8, 0.2, 1.0)  # green = normal

## --- Lifecycle ---

func _ready() -> void:
	_build_hp_bar()
	_build_craving_indicator()
	_on_ready_setup()
	_setup_death_cleanup()
	_assign_random_craving()

func _process(delta: float) -> void:
	if _is_dying or not is_alive:
		return

	# Countdown debuff timers
	if _slow_timer > 0:
		_slow_timer -= delta
		if _slow_timer <= 0:
			_slow_timer = 0.0
			_slow_factor = 1.0
			_update_hp_bar_color()

	if _enrage_timer > 0:
		_enrage_timer -= delta
		if _enrage_timer <= 0:
			_enrage_timer = 0.0
			_enrage_factor = 1.0
			_update_hp_bar_color()

	# Move toward the kitchen (left) using effective speed
	position.x -= effective_speed * delta

	# Check if reached the kitchen threshold
	if lane and position.x <= Lane.KITCHEN_THRESHOLD:
		_on_reached_kitchen()

## Override in child scenes to customize initial appearance and stats
func _on_ready_setup() -> void:
	pass

## --- Random craving assignment ---

func _assign_random_craving() -> void:
	# Pick a random non-NONE craving type: GREASE=1, SOUP=2, SPICE=3, PIZZA=4
	var types = [CravingType.GREASE, CravingType.SOUP, CravingType.SPICE, CravingType.PIZZA]
	craving = types[randi() % types.size()]
	_update_craving_indicator()

## --- HP bar ---

func _build_hp_bar() -> void:
	# Background (dark red) — left-aligned, fixed width
	hp_bar_bg = ColorRect.new()
	hp_bar_bg.anchor_left = 0.5
	hp_bar_bg.anchor_top = 0.0
	hp_bar_bg.anchor_right = 0.5
	hp_bar_bg.anchor_bottom = 0.0
	hp_bar_bg.position = Vector2(-40, -30)
	hp_bar_bg.size = Vector2(80, 8)
	hp_bar_bg.color = Color(0.3, 0.05, 0.05, 0.9)
	hp_bar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hp_bar_bg)

	# Foreground (green, fills from left, shrinks as HP drops)
	hp_bar = ColorRect.new()
	hp_bar.anchor_left = 0.5
	hp_bar.anchor_top = 0.0
	hp_bar.anchor_right = 0.5
	hp_bar.anchor_bottom = 0.0
	hp_bar.position = Vector2(-40, -30)
	hp_bar.size = Vector2(80, 8)
	hp_bar.color = Color(0.2, 0.8, 0.2, 1.0)
	hp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hp_bar)

## --- Damage ---

## Apply damage to this enemy
func take_damage(amount: float) -> void:
	current_hp = max(current_hp - amount, 0.0)

## Apply healing
func heal(amount: float) -> void:
	current_hp = min(current_hp + amount, max_hp)

## --- Death handling ---

func _on_death() -> void:
	if _is_dying:
		return
	_is_dying = true

	enemy_dead.emit(self)
	print("[Enemy] Dead (HP: 0, gold: %d, score: %d)" % [gold_reward, score_reward])

	_spawn_death_labels()
	queue_free()

func _spawn_death_labels() -> void:
	# Parent the labels to whatever parent the enemy has (usually a Lane)
	var parent_node = get_parent()
	if not parent_node:
		return

	# Use the enemy's position in the parent's coordinate space
	var spawn_pos = position

	# Gold popup — golden color
	var gold_label = FloatingLabel.new()
	gold_label.setup("+%d" % gold_reward, Color(1.0, 0.85, 0.1, 1.0), 1.5)
	gold_label.position = Vector2(spawn_pos.x, spawn_pos.y - 40)
	parent_node.add_child(gold_label)

	# Score popup — slightly above and offset
	var score_label = FloatingLabel.new()
	score_label.setup("+%d" % score_reward, Color(1.0, 0.6, 0.1, 1.0), 1.5)
	score_label.position = Vector2(spawn_pos.x, spawn_pos.y - 70)
	parent_node.add_child(score_label)

func _setup_death_cleanup() -> void:
	# Remove from lane's enemy list when freed
	connect("tree_exited", _on_tree_exited)

func _on_tree_exited() -> void:
	if lane and self in lane.enemies:
		lane.enemies.erase(self)

## --- Kitchen reached ---

func _on_reached_kitchen() -> void:
	print("[Enemy] Reached kitchen on lane.")
	if lane:
		lane.enemy_reached_kitchen.emit(self)
	_on_death()

## --- Serialization helpers ---

## Get enemy stats as a dictionary (for wave config)
func get_enemy_stats() -> Dictionary:
	return {
		"max_hp": max_hp,
		"speed": speed,
		"gold_reward": gold_reward,
		"score_reward": score_reward
	}

## --- Craving indicator ---

func _build_craving_indicator() -> void:
	# Small colored circle above the enemy
	_craving_indicator = ColorRect.new()
	_craving_indicator.anchor_left = 0.5
	_craving_indicator.anchor_top = 0.5
	_craving_indicator.anchor_right = 0.5
	_craving_indicator.anchor_bottom = 0.5
	_craving_indicator.position = Vector2(0, -40)
	_craving_indicator.size = Vector2(24, 24)
	_craving_indicator.color = Color(0.5, 0.5, 0.5, 0.9)
	_craving_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_craving_indicator)

	# Letter label showing the craving type
	_craving_label = Label.new()
	_craving_label.anchor_left = 0.5
	_craving_label.anchor_top = 0.5
	_craving_label.anchor_right = 0.5
	_craving_label.anchor_bottom = 0.5
	_craving_label.position = Vector2(0, -40)
	_craving_label.size = Vector2(24, 24)
	_craving_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_craving_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_craving_label.font_size = 14
	_craving_label.add_theme_color_override(
		"font_color", Color(1.0, 1.0, 1.0, 1.0)
	)
	_craving_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_craving_indicator.add_child(_craving_label)

func _update_craving_indicator() -> void:
	if not _craving_indicator or not _craving_label:
		return

	var colors: Dictionary = {
		CravingType.GREASE: Color(0.95, 0.85, 0.1, 0.9),
		CravingType.SOUP: Color(0.2, 0.5, 0.95, 0.9),
		CravingType.SPICE: Color(0.95, 0.15, 0.15, 0.9),
		CravingType.PIZZA: Color(0.8, 0.2, 0.85, 0.9),
	}

	# Use the enemy's own color as a fallback
	var fallback_color := Color(0.6, 0.6, 0.6, 0.9)
	var label_text := "?"

	if craving in colors:
		_craving_indicator.color = colors[craving]
		match craving:
			CravingType.GREASE:
				label_text = "G"
			CravingType.SOUP:
				label_text = "S"
			CravingType.SPICE:
				label_text = "X"
			CravingType.PIZZA:
				label_text = "P"
	else:
		_craving_indicator.color = fallback_color
		label_text = "?"

	_craving_label.text = label_text
