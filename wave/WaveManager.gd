extends Node
## WaveManager — autoload singleton that orchestrates wave flow.
##
## Responsibilities:
##   1. Generate escalating waves with increasing difficulty.
##   2. Spawn enemies via LaneManager at configured intervals.
##   3. Track active enemy count per wave.
##   4. Emit wave_complete when all enemies in the wave are cleared.
##   5. Auto-progression: after card selection, start the next wave.

## --- Wave config ---

## Array of Resource resources defining all waves in a run.
@export var waves: Array[Resource] = []

## Maximum number of waves in a run (0 = infinite/escalating)
@export var max_waves: int = 20

## Base HP growth per wave (10% per wave)
@export var hp_growth: float = 0.10

## Base speed growth per wave (5% per wave)
@export var speed_growth: float = 0.05

## Base enemy count growth per wave (+2 enemies per wave)
@export var count_growth: int = 2

## Base spawn interval reduction per wave (0.1s less per wave)
@export var spawn_interval_reduction: float = 0.1

## Index of the currently playing wave
var _current_wave_index: int = -1
var _current_wave_config: Resource = null

## Enemy spawn queue: list of { enemy_scene, lane_index, hp, speed }
var _spawn_queue: Array = []
var _spawn_timer: float = 0.0
var _spawned_count: int = 0
var _enemies_defeated_count: int = 0

## --- Wave countdown ---
var _countdown_timer: float = 0.0
var _countdown_duration: float = 3.0
var _countdown_active: bool = false
var _countdown_phase: int = 0  # 0=not started, 3=3s, 2=2s, 1=1s

## Active enemy tracking
var _active_enemies: int = 0

## Whether a wave is currently active
var is_wave_active: bool:
	get: return _current_wave_index >= 0

## The next wave index to play after the current one completes
var _next_wave_index: int = 0

## Whether a wave-start has been requested (awaiting card selection)
var _wave_start_requested: bool = false

## --- Signals ---

## Emitted when a wave starts. Args: (wave_config: Resource, wave_index: int)
signal wave_started(wave_config: Resource, wave_index: int)

## Emitted when all enemies in a wave are defeated. Args: (wave_index: int)
signal wave_complete(wave_index: int)

## Emitted when spawning an enemy. Args: (enemy: Node2D, lane_index: int)
signal enemy_spawned(enemy: Node2D, lane_index: int)

## Emitted when an enemy dies. Args: (enemy: Node2D, lane_index: int)
signal enemy_died(enemy: Node2D, lane_index: int)

## Emitted when all waves are completed (endless mode reached max)
signal all_waves_complete()

## Emitted when the player completes all waves (victory)
signal victory(wave_count: int, score: int, gold_earned: int)

## --- Wave state ---

## Returns the wave currently being played, or null if no wave is active.
var active_wave: Resource:
	get: return _current_wave_config

## Returns the current wave index (0-based), or -1 if no wave active.
var active_wave_index: int:
	get: return _current_wave_index

## Returns the number of active (not yet defeated) enemies.
var active_enemy_count: int:
	get: return _active_enemies

## --- Lifecycle ---

func _ready() -> void:
	# Initialize ResourceLoader with editor-configured waves
	if waves.size() > 0:
		WaveConfigLoader.initialize(waves)
	else:
		# No editor waves — load from ResourceLoader (res://waves/*.tres files)
		if WaveConfigLoader.loaded_wave_count > 0:
			waves = WaveConfigLoader._loaded_waves.duplicate()
			WaveConfigLoader.initialize(waves)
			print("[WaveManager] Loaded %d waves from resource files." % waves.size())
		else:
			_generate_default_waves()
	# Listen for LaneManager's wave_complete signal (all lanes cleared)
	LaneManager.wave_complete.connect(_on_wave_complete)
	print("[WaveManager] Initialized with %d waves." % waves.size())

func _process(delta: float) -> void:
	# During an active wave, spawn enemies at the configured interval
	if _current_wave_index < 0:
		return
	
	# Handle countdown phase — block spawning while counting down
	if _countdown_active:
		_countdown_timer -= delta
		if HUD and HUD.has_method("show_wave_countdown"):
			var phase := ceili(_countdown_timer)
			if phase < 1:
				phase = 0
			elif phase > 3:
				phase = 3
			
			if phase > 0:
				HUD.show_wave_countdown("%d" % phase)
			else:
				if HUD.has_method("hide_wave_countdown"):
					HUD.hide_wave_countdown()
		
		if _countdown_timer <= 0:
			_countdown_active = false
			_countdown_phase = 0
		return
	
	if _spawn_queue.is_empty():
		return
	
	_spawn_timer += delta
	if _spawn_timer >= _current_wave_config.spawn_interval:
		_spawn_timer = 0.0
		spawn_next()

## --- Wave generation ---

## Generate default waves with escalating difficulty if none provided.
func _generate_default_waves() -> void:
	if waves.size() > 0:
		return
	
	waves = []
	
	# Define the base enemy pool for waves
	var goblin_data: Resource = preload("res://enemy/EnemyData_HungryGoblin.tres")
	
	for i in range(max_waves):
		var wave := Resource.new()
		
		# Escalating difficulty
		var hp_scale = 1.0 + (i * hp_growth)
		var speed_scale = 1.0 + (i * speed_growth)
		var enemy_count = 3 + (i * 2) + count_growth
		var spawn_interval = max(0.3, 2.0 - (i * spawn_interval_reduction))
		
		wave.hp_scale = hp_scale
		wave.speed_scale = speed_scale
		wave.spawn_interval = spawn_interval
		wave.enemies = [
			{ "enemy_data": goblin_data, "count": enemy_count }
		]
		wave.description = "Wave %d — %d Hungry Goblins" % [i + 1, enemy_count]
		
		waves.append(wave)
	
	print("[WaveManager] Generated %d default waves." % waves.size())
	
	# Sync generated waves back to ResourceLoader
	WaveConfigLoader.reload_with(waves)

## --- Wave management ---

## Start a wave by index. Loads the config, runs countdown, then prepares spawns.
## Call this when GameState enters PLAYING state.
func start_wave(wave_index: int) -> void:
	if wave_index < 0:
		push_warning("[WaveManager] Cannot start wave with negative index.")
		return
	
	# If we have predefined waves, use them; otherwise delegate to ResourceLoader
	if wave_index < waves.size():
		_current_wave_config = waves[wave_index].duplicate(true)
	else:
		_current_wave_config = WaveConfigLoader.get_wave(wave_index)
	
	# Apply room modifiers from current room (modifies the copied Resource)
	var room = GameState.current_room
	if room:
		WaveConfigLoader.apply_room_modifiers(_current_wave_config, room)
	
	# Then build spawn queue with modified scales
	_spawn_queue = _build_spawn_queue()
	_spawn_timer = 0.0
	_spawned_count = 0
	
	# Count active enemies from current game state
	_active_enemies = _current_wave_config.get_total_enemies()
	
	# Track wave gold reward (increases with wave number, apply room gold bonus)
	var gold_reward: float = 25 + (wave_index * 5)
	if room and "gold_bonus" in room:
		gold_reward *= (1.0 + room.gold_bonus * 0.01)
	GameState.wave_gold_reward = int(gold_reward)
	
	_current_wave_index = wave_index
	_wave_start_requested = false
	
	# Start countdown before enemies appear
	_countdown_timer = _countdown_duration
	_countdown_active = true
	_countdown_phase = 3
	
	# Show countdown overlay
	if HUD and HUD.has_method("show_wave_countdown"):
		HUD.show_wave_countdown("Wave %d incoming!" % (wave_index + 1))
	
	wave_started.emit(_current_wave_config, _current_wave_index)
	GameState.wave = wave_index + 1
	print("[WaveManager] Started wave %d (%d enemies, HP x%.1f, speed x%.1f)." % [
		_current_wave_index + 1,
		_current_wave_config.get_total_enemies(),
		_current_wave_config.hp_scale,
		_current_wave_config.speed_scale
	])

## Build the spawn queue from the current wave config.
## Returns array of { enemy_scene, lane_index, hp, speed } entries.
func _build_spawn_queue() -> Array:
	var queue: Array = []
	
	var goblin_data: Resource = preload("res://enemy/EnemyData_HungryGoblin.tres")
	var default_scene = "res://enemy/HungryGoblin.tscn"
	
	for entry in _current_wave_config.enemies:
		var enemy_data: Resource = entry.get("enemy_data", null)
		var count: int = entry.get("count", 0)
		
		if not enemy_data:
			enemy_data = goblin_data
		
		# Load the enemy scene (custom_scene or default)
		var scene_path: String = ""
		if enemy_data:
			if "custom_scene" in enemy_data and enemy_data.custom_scene != "":
				scene_path = enemy_data.custom_scene
		if not scene_path:
			scene_path = default_scene
		var enemy_scene: PackedScene = load(scene_path)
		# Graceful fallback: if the scene is missing/corrupted, fall back to the default enemy scene
		if not enemy_scene and scene_path != default_scene:
			push_warning("[WaveManager] Failed to load enemy scene '%s', falling back to default (%s)." % [scene_path, default_scene])
			enemy_scene = load(default_scene)
		if not enemy_scene:
			push_error("[WaveManager] Critical: could not load default enemy scene '%s'. Wave spawn queue will be empty." % default_scene)
			return []
		
		var base_hp: float = 40.0
		var base_speed: float = 60.0
		if enemy_data:
			if "max_hp" in enemy_data:
				base_hp = enemy_data.max_hp
			if "speed" in enemy_data:
				base_speed = enemy_data.speed
		
		for i in range(count):
			var lane_index: int = randi() % LaneManager.lane_count
			queue.append({
				"enemy_scene": enemy_scene,
				"lane_index": lane_index,
				"hp": base_hp * _current_wave_config.hp_scale,
				"speed": base_speed * _current_wave_config.speed_scale,
				"gold_reward": enemy_data.gold_reward if enemy_data else 10,
				"score_reward": enemy_data.score_reward if enemy_data else 10,
			})
	
	# Shuffle the queue for randomness
	queue.shuffle()
	return queue

## Spawn the next enemy from the queue.
## Called automatically by _process each frame.
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
				if "gold_reward" in next:
					enemy.gold_reward = next.gold_reward
				if "score_reward" in next:
					enemy.score_reward = next.score_reward
				
				enemy_spawned.emit(enemy, next.lane_index)
				print("[WaveManager] Spawned enemy #%d (lane %d, HP: %.0f)." % [
					_spawned_count, next.lane_index, next.hp
				])
				return true
	
	return false

## Called when an enemy dies. Decrements the active counter.
## Connect this to GameState's enemy_died signal or LaneManager's signal.
func _on_enemy_died(enemy: Node2D, lane_index: int) -> void:
	if not enemy:
		return
	
	_active_enemies -= 1
	_enemies_defeated_count += 1
	enemy_died.emit(enemy, lane_index)
	
	if _enemies_defeated_count >= _spawned_count:
		_on_wave_complete()

## Called when all enemies in a wave are defeated.
## Transitions GameState to WAVE_COMPLETE and shows card selection.
func _on_wave_complete() -> void:
	# Verify the wave is truly complete: all spawned enemies must be defeated
	if _enemies_defeated_count < _spawned_count:
		return
	
	# Check for victory: completed the final wave
	var is_final_wave = max_waves > 0 and _current_wave_index >= max_waves - 1
	if is_final_wave:
		print("[WaveManager] All %d waves complete! VICTORY!" % max_waves)
		var score = GameState.score
		var gold = GameState.gold
		SaveLoad.save_run(score, max_waves, gold)
		var unlocks = SaveLoad.check_unlocks(max_waves)
		GameState.trigger_victory()
		victory.emit(max_waves, score, gold)
		return
	
	# Emit LaneManager wave_complete signal so Main knows to show card UI
	LaneManager.wave_complete.emit()
	
	print("[WaveManager] Wave %d complete! (%d enemies defeated)" % [
		_current_wave_index + 1,
		_spawned_count
	])
	
	# Award gold reward
	GameState.add_gold(GameState.wave_gold_reward)
	
	# Emit signal
	wave_complete.emit(_current_wave_index)
	
	# Play wave complete SFX and show HUD notification
	if SoundManager:
		SoundManager.play_sfx("wave_complete")
	if HUD and HUD.has_method("show_wave_complete"):
		HUD.show_wave_complete()
	
	# Advance to card selection
	advance_to_card_selection()

## Advance GameState to WAVE_COMPLETE and prepare card selection UI.
func advance_to_card_selection() -> void:
	GameState.state = GameState.GameMode.WAVE_COMPLETE
	_wave_start_requested = false
	
	# Generate card choices
	var card_pool = preload("res://card_pool/CardPool.gd").new()
	var cards := card_pool.get_card_pool(3)
	
	# Pass card data to the card selection UI via GameState
	if cards.size() > 0:
		GameState.set("pending_cards", cards)

## Called after card selection to start the next wave.
## This is the auto-progression hook that bridges card selection → next wave.
func start_next_wave() -> void:
	if not _wave_start_requested:
		return
	
	_next_wave_index += 1
	
	# Check if we've exceeded max waves
	if max_waves > 0 and _next_wave_index >= waves.size():
		# Generate an escalated wave beyond predefined waves
		print("[WaveManager] All predefined waves complete. Continuing with escalating waves.")
	
	# If we've gone past predefined waves and hitting max, end the run
	if max_waves > 0 and _next_wave_index >= max_waves:
		print("[WaveManager] All %d waves complete. Game over." % max_waves)
		return
	
	# Check if we need to generate a new dynamic wave
	if _next_wave_index >= waves.size():
		var dynamic_wave = WaveConfigLoader.get_wave(_next_wave_index)
		waves.append(dynamic_wave)
	
	start_wave(_next_wave_index)
	_wave_start_requested = false

## Called when a room is selected to prepare for the next wave.
## Stores the request so start_next_wave() knows to proceed.
func on_room_selected() -> void:
	_wave_start_requested = true
	print("[WaveManager] Room selected. Awaiting card selection to start next wave.")

## Called when a card is selected to trigger next wave start.
## Returns true if a wave was started immediately (room was already selected).
func on_card_selected() -> bool:
	_wave_start_requested = true
	# Always transition to ROOM_SELECTING — the room selector is the bridge
	# between card selection and the next wave. Never auto-start here.
	return false

## Check if the current wave is fully spawned (no more enemies to spawn).
func is_spawning_done() -> bool:
	if not _current_wave_config:
		return true
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
	_enemies_defeated_count = 0
	_active_enemies = 0
	_next_wave_index = 0
	_wave_start_requested = false
	_countdown_timer = 0.0
	_countdown_active = false
	_countdown_phase = 0
	if HUD and HUD.has_method("hide_wave_countdown"):
		HUD.hide_wave_countdown()
