extends Node
## WaveManager — autoload singleton that orchestrates wave flow.
##
## Responsibilities:
##   1. Load WaveConfig waves (from a resource array or inline config).
##   2. Spawn enemies via LaneManager at configured intervals.
##   3. Track active enemy count per wave.
##   4. Emit wave_complete when all enemies in the wave are cleared.
##   5. Bridge GameState from WAVE_COMPLETE to card selection state.
##
## Usage:
##   WaveManager.start_wave(wave_config)  — begin a new wave
##   WaveManager.spawn_next()             — spawn one enemy from the queue
##   WaveManager._on_enemy_died()         — internal: decrement active count
##   WaveManager.advance_to_card_selection() — transition to card UI

## --- Wave config ---

## Array of WaveConfig resources defining all waves in a run.
@export var waves: Array[WaveConfig] = []

## Index of the currently playing wave
var _current_wave_index: int = -1
var _current_wave_config: WaveConfig = null

## Enemy spawn queue: list of { enemy_scene, lane_index }
var _spawn_queue: Array = []
var _spawn_timer: float = 0.0
var _spawned_count: int = 0

## Active enemy tracking
var _active_enemies: int = 0

## --- Signals ---

## Emitted when a wave starts. Args: (wave_config: WaveConfig, wave_index: int)
signal wave_started(wave_config: WaveConfig, wave_index: int)

## Emitted when all enemies in a wave are defeated. Args: (wave_index: int)
signal wave_complete(wave_index: int)

## Emitted when spawning an enemy. Args: (enemy: Node2D, lane_index: int)
signal enemy_spawned(enemy: Node2D, lane_index: int)

## Emitted when an enemy dies. Args: (enemy: Node2D, lane_index: int)
signal enemy_died(enemy: Node2D, lane_index: int)

## --- Wave state ---

## Returns the wave currently being played, or null if no wave is active.
var active_wave: WaveConfig:
	get: return _current_wave_config

## Returns the current wave index (0-based), or -1 if no wave active.
var active_wave_index: int:
	get: return _current_wave_index

## Returns the number of active (not yet defeated) enemies.
var active_enemy_count: int:
	get: return _active_enemies

## --- Lifecycle ---

func _ready() -> void:
	print("[WaveManager] Initialized with %d waves." % waves.size())

## --- Wave management ---

## Start a wave by index. Loads the config and prepares the spawn queue.
## Call this when GameState enters PLAYING state.
func start_wave(wave_index: int) -> void:
	if wave_index < 0 or wave_index >= waves.size():
		push_warning("[WaveManager] Invalid wave index: %d" % wave_index)
		return
	
	_current_wave_index = wave_index
	_current_wave_config = waves[wave_index]
	
	# Apply room modifiers first (modifies hp_scale/speed_scale in place)
	var room = GameState.current_room
	if room:
		_apply_modifiers(_current_wave_config, room)
	
	# Then build spawn queue with modified scales
	_spawn_queue = _build_spawn_queue()
	_spawn_timer = 0.0
	_spawned_count = 0
	
	# Count active enemies from current game state
	_active_enemies = _current_wave_config.get_total_enemies()
	
	# Track wave gold reward
	GameState.wave_gold_reward = 25
	
	wave_started.emit(_current_wave_config, _current_wave_index)
	print("[WaveManager] Started wave %d: %d enemies." % [
		_current_wave_index + 1, _current_wave_config.get_total_enemies()
	])

## Build the spawn queue from the current wave config.
## Returns array of { enemy_data, lane_index } entries.
func _build_spawn_queue() -> Array:
	var queue: Array = []
	
	for entry in _current_wave_config.enemies:
		var enemy_data: Resource = entry.get("enemy_data", null)
		var count: int = entry.get("count", 0)
		
		if not enemy_data:
			continue
		
		# Load the enemy scene (custom_scene or default)
		var scene_path: String = enemy_data.get("custom_scene", "")
		if not scene_path:
			scene_path = "res://enemy/HungryGoblin.tscn"
		var enemy_scene: PackedScene = load(scene_path)
		
		for i in range(count):
			# Assign to a random lane
			var lane_index: int = randi() % LaneManager.lane_count
			queue.append({
				"enemy_scene": enemy_scene,
				"lane_index": lane_index,
				"hp": enemy_data.get("max_hp", 40.0) * _current_wave_config.hp_scale,
				"speed": enemy_data.get("speed", 60.0) * _current_wave_config.speed_scale,
			})
	
	# Shuffle the queue for randomness
	queue.shuffle()
	return queue

## Apply room modifiers to the wave config.
func _apply_modifiers(wave: WaveConfig, modifier: Resource) -> WaveConfig:
	if not modifier:
		return wave
	
	var hp_mult = modifier.get("enemy_hp_modifier", 1.0)
	var speed_mult = modifier.get("enemy_speed_modifier", 1.0)
	var count_add = modifier.get("enemy_count_modifier", 0)
	
	# Scale existing HP and speed
	wave.hp_scale *= hp_mult
	wave.speed_scale *= speed_mult
	
	# Add extra enemies of the first type (simplified)
	if count_add > 0 and wave.enemies.size() > 0:
		var first_entry = wave.enemies[0]
		var extra_scene = first_entry.get("enemy_data", null)
		if extra_scene:
			for i in range(count_add):
				wave.enemies.append({
					"enemy_data": extra_scene,
					"count": 1,
				})
	
	return wave

## Spawn the next enemy from the queue.
## Call this each tick via _process.
func spawn_next() -> bool:
	if _spawn_queue.is_empty():
		return false
	
	_spawn_timer += 1.0 / 60.0
	
	if _spawn_timer >= _current_wave_config.spawn_interval:
		_spawn_timer = 0.0
		var next = _spawn_queue.pop_front()
		
		if next and next.get("enemy_scene"):
			var enemy = LaneManager.spawn_enemy_on_lane(
				next.enemy_scene, next.lane_index
			)
			
			if enemy:
				_spawned_count += 1
				_active_enemies += 1
				
				# Apply scaled stats from wave config
				enemy.max_hp = next.hp
				enemy.current_hp = next.hp
				enemy.speed = next.speed
				
				enemy_spawned.emit(enemy, next.lane_index)
				print("[WaveManager] Spawned enemy #%d (lane %d)." % [
					_spawned_count, next.lane_index
				])
				return true
	
	return false

## Called when an enemy dies. Decrements the active counter.
## Connect this to GameState's enemy_died signal or LaneManager's signal.
func _on_enemy_died(enemy: Node2D, lane_index: int) -> void:
	if not enemy:
		return
	
	_active_enemies -= 1
	enemy_died.emit(enemy, lane_index)
	
	if _active_enemies <= 0:
		_on_wave_complete()

## Called when all enemies in a wave are defeated.
## Transitions GameState to WAVE_COMPLETE and shows card selection.
func _on_wave_complete() -> void:
	print("[WaveManager] Wave %d complete!" % (_current_wave_index + 1))
	
	# Award gold reward
	GameState.add_gold(GameState.wave_gold_reward)
	
	# Emit signal
	wave_complete.emit(_current_wave_index)
	
	# Transition to card selection
	advance_to_card_selection()

## Advance GameState to WAVE_COMPLETE and prepare card selection UI.
func advance_to_card_selection() -> void:
	GameState.state = GameState.GameState.WAVE_COMPLETE
	
	# Generate card choices
	var card_pool := CardPool
	var cards := card_pool.get_card_pool(3)
	
	# Pass card data to the card selection UI via GameState
	if cards.size() > 0:
		# Store card data on GameState for Main to pick up
		GameState.set("pending_cards", cards)

## Check if the current wave is fully spawned (no more enemies to spawn).
func is_spawning_done() -> bool:
	return _spawn_queue.is_empty() && _spawned_count >= _current_wave_config.get_total_enemies()

## Check if the current wave is complete (all enemies defeated).
func is_wave_complete() -> bool:
	return _active_enemies <= 0

## Get the remaining enemies to spawn this wave.
func remaining_to_spawn() -> int:
	return _spawn_queue.size()

## Get the number of enemies already spawned this wave.
func enemies_spawned() -> int:
	return _spawned_count

## Reset wave state for a fresh run.
func reset() -> void:
	_current_wave_index = -1
	_current_wave_config = null
	_spawn_queue = []
	_spawn_timer = 0.0
	_spawned_count = 0
	_active_enemies = 0
