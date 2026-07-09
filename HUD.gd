extends Control
## HUD — displays gold, score, wave, health, and wave progress from GameState/WaveManager.
## Connects to GameState signals for reactive updates; periodically updates wave progress.

var _progress_update_timer: float = 0.0
var _progress_update_interval: float = 0.25
var _wave_progress_value: float = 0.0

## --- Hand display ---
var _hand_enabled: bool = false
var _hand_update_timer: float = 0.0
var _hand_update_interval: float = 0.3

var _hand_panel: Control = null
var _card_slots: Array[PanelContainer] = []
var _card_icons: Array[ColorRect] = []
var _card_names: Array[Label] = []
var _card_costs: Array[Label] = []

## --- Damage flash ---
var _damage_flash_overlay: ColorRect = null
var _damage_flash_timer: float = 0.0

@onready var _gold_label: Label = $Panel/GoldLabel
@onready var _score_label: Label = $Panel/ScoreLabel
@onready var _wave_label: Label = $Panel/WaveLabel
@onready var _health_label: Label = $Panel/HealthLabel
@onready var _enemy_count_label: Label = $Panel/EnemyCountLabel
@onready var _next_spawn_label: Label = $Panel/NextSpawnLabel
@onready var _wave_countdown_label: Label = $WaveCountdownLabel
@onready var _wave_progress_panel: Container = $Panel/WaveProgressPanel
@onready var _wave_progress_title: Label = $Panel/WaveProgressPanel/WaveProgressTitle
@onready var _wave_progress_bar: ProgressBar = $Panel/WaveProgressPanel/WaveProgressBar
@onready var _hand_panel_node: Control = $HandPanel
@onready var _card1: PanelContainer = $HandPanel/Card1
@onready var _card1_icon: ColorRect = $HandPanel/Card1/Card1Icon
@onready var _card1_name: Label = $HandPanel/Card1/Card1Name
@onready var _card1_cost: Label = $HandPanel/Card1/Card1Cost
@onready var _card2: PanelContainer = $HandPanel/Card2
@onready var _card2_icon: ColorRect = $HandPanel/Card2/Card2Icon
@onready var _card2_name: Label = $HandPanel/Card2/Card2Name
@onready var _card2_cost: Label = $HandPanel/Card2/Card2Cost
@onready var _card3: PanelContainer = $HandPanel/Card3
@onready var _card3_icon: ColorRect = $HandPanel/Card3/Card3Icon
@onready var _card3_name: Label = $HandPanel/Card3/Card3Name
@onready var _card3_cost: Label = $HandPanel/Card3/Card3Cost
@onready var _wave_complete_label: Label = $WaveCompleteLabel

func _ready() -> void:
	_wave_progress_panel.visible = false
	_setup_damage_flash()
	GameState.gold_changed.connect(_on_gold_changed)
	GameState.score_changed.connect(_on_score_changed)
	GameState.wave_changed.connect(_on_wave_changed)
	GameState.health_changed.connect(_on_health_changed)
	GameState.damage_flashed.connect(_on_damage_flashed)
	_update_labels()
	# Hand display initialization
	_hand_panel = _hand_panel_node
	if _hand_panel:
		_card_slots = [_card1, _card2, _card3]
		_card_icons = [_card1_icon, _card2_icon, _card3_icon]
		_card_names = [_card1_name, _card2_name, _card3_name]
		_card_costs = [_card1_cost, _card2_cost, _card3_cost]
		DeckManager.hand_changed.connect(_on_hand_changed)
		show_hand()

func _process(delta: float) -> void:
	if GameState.state != GameState.GameMode.PLAYING:
		return
	if _damage_flash_timer > 0:
		_damage_flash_timer -= delta
		var alpha = clamp(1.0 - (_damage_flash_timer / 0.05), 0.0, 1.0)
		if _damage_flash_overlay:
			_damage_flash_overlay.visible = true
			_damage_flash_overlay.color = Color(1.0, 1.0, 0.0, alpha * 0.3)
		if _damage_flash_timer <= 0:
			_damage_flash_overlay.visible = false
			_damage_flash_timer = 0.0
	_progress_update_timer += delta
	if _progress_update_timer >= _progress_update_interval:
		_progress_update_timer = 0.0
		_update_wave_progress()
	_update_wave_complete(delta)

func _update_wave_progress() -> void:
	if not _enemy_count_label or not _next_spawn_label:
		return
	if not WaveManager.is_wave_active:
		_enemy_count_label.text = "Enemies: -"
		_next_spawn_label.text = "Next: -s"
		return
	
	var remaining = WaveManager.active_enemy_count + WaveManager.remaining_to_spawn()
	_enemy_count_label.text = "Enemies: %d" % remaining
	
	var time_remaining = _get_time_to_next_spawn()
	if time_remaining > 0:
		_next_spawn_label.text = "Next: %.1fs" % time_remaining
	else:
		_next_spawn_label.text = "Next: done"
	
	_update_wave_progress_bar()

func _update_wave_progress_bar() -> void:
	var total = WaveManager.active_wave.get_total_enemies()
	if total <= 0:
		return
	
	var remaining = WaveManager.active_enemy_count + WaveManager.remaining_to_spawn()
	var defeated = total - remaining
	_wave_progress_value = float(defeated) / float(total)
	_wave_progress_title.text = "Wave %d/%d" % [GameState.wave, WaveManager.max_waves]
	_wave_progress_bar.value = _wave_progress_value
	_wave_progress_panel.visible = true

func _get_time_to_next_spawn() -> float:
	if not WaveManager._current_wave_config or WaveManager._spawn_queue.is_empty():
		return 0.0
	var interval = WaveManager._current_wave_config.spawn_interval
	var elapsed = WaveManager._spawn_timer
	return max(0.0, interval - elapsed)

func _update_labels() -> void:
	if _gold_label:
		_gold_label.text = "Gold: %d" % GameState.gold
	if _score_label:
		_score_label.text = "Score: %d" % GameState.score
	if _wave_label:
		_wave_label.text = "Wave: %d" % GameState.wave
	if _health_label:
		_health_label.text = "Health: %d" % GameState.health

func _on_gold_changed(new_gold: int) -> void:
	if _gold_label:
		_gold_label.text = "Gold: %d" % new_gold

func _on_score_changed(new_score: int) -> void:
	if _score_label:
		_score_label.text = "Score: %d" % new_score

func _on_wave_changed(new_wave: int) -> void:
	if _wave_label:
		_wave_label.text = "Wave: %d" % new_wave

func _on_health_changed(new_health: int) -> void:
	if _health_label:
		_health_label.text = "Health: %d" % new_health

## --- Wave countdown display ---

func show_wave_countdown(text: String) -> void:
	if not _wave_countdown_label:
		return
	_wave_countdown_label.text = text
	_wave_countdown_label.visible = true

func hide_wave_countdown() -> void:
	if not _wave_countdown_label:
		_wave_countdown_label.visible = false

## --- Wave complete notification ---

var _wave_complete_timer: float = 0.0
var _wave_complete_duration: float = 2.0
var _wave_complete_fade_out: float = 0.8
var _wave_complete_visible: bool = false

func show_wave_complete() -> void:
	if not _wave_complete_label:
		return
	_wave_complete_label.visible = true
	_wave_complete_label.modulate = Color(1, 1, 0.6, 1)
	_wave_complete_label.scale = Vector2(1.0, 1.0)
	_wave_complete_timer = _wave_complete_duration + _wave_complete_fade_out
	_wave_complete_visible = true

func hide_wave_complete() -> void:
	if not _wave_complete_label:
		return
	_wave_complete_label.visible = false
	_wave_complete_visible = false

func _update_wave_complete(delta: float) -> void:
	if not _wave_complete_visible or not _wave_complete_label:
		return
	_wave_complete_timer -= delta
	if _wave_complete_timer <= _wave_complete_fade_out:
		# Fade out phase
		var t = _wave_complete_timer / _wave_complete_fade_out
		_wave_complete_label.modulate = Color(1, 1, 0.6, t)
		var scale = 1.0 + (1.0 - t) * 0.15
		_wave_complete_label.scale = Vector2(scale, scale)
		if _wave_complete_timer <= 0:
			_wave_complete_label.visible = false
			_wave_complete_visible = false
			_wave_complete_timer = 0.0

## --- Damage flash ---

func _setup_damage_flash() -> void:
	_damage_flash_overlay = ColorRect.new()
	_damage_flash_overlay.anchor_left = 0.0
	_damage_flash_overlay.anchor_top = 0.0
	_damage_flash_overlay.anchor_right = 1.0
	_damage_flash_overlay.anchor_bottom = 1.0
	_damage_flash_overlay.color = Color(1.0, 1.0, 0.0, 0.0)
	_damage_flash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_damage_flash_overlay.visible = false
	add_child(_damage_flash_overlay)

func _on_damage_flashed() -> void:
	_damage_flash_timer = 0.05

## --- Hand display ---

func show_hand() -> void:
	_hand_enabled = true
	_hand_panel.visible = true
	_update_hand_display()

func hide_hand() -> void:
	_hand_enabled = false
	_hand_panel.visible = false

func _update_hand_display() -> void:
	if not _hand_enabled or not _hand_panel:
		return
	var hand = DeckManager.get_hand()
	var count = min(hand.size(), 3)
	for i in range(count):
		if i < _card_slots.size():
			_card_slots[i].visible = true
			_update_card_slot(i, hand[i])
	for i in range(count, _card_slots.size()):
		_card_slots[i].visible = false

func _update_card_slot(index: int, card: Dictionary) -> void:
	if index >= _card_icons.size():
		return
	_card_icons[index].color = card.get("icon_color", Color.WHITE)
	_card_names[index].text = card.get("name", "Unknown")
	var cost = card.get("cost", 0)
	_card_costs[index].text = "$%d" % cost

func _on_hand_changed() -> void:
	if _hand_enabled:
		_update_hand_display()
