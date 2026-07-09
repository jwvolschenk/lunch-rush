extends Node
## SoundManager — autoload singleton for all game audio.
## Manages SFX and Music audio buses, provides play_sfx() and play_music().
##
## Usage:
##   SoundManager.play_sfx("grease_fire")
##   SoundManager.play_music("background", loop=true)
##   SoundManager.set_sfx_volume_db(-6.0)
##   SoundManager.set_music_volume_db(-3.0)

## Default bus names
const SFX_BUS := "SFX"
const MUSIC_BUS := "Music"

## Emitted when SFX volume changes
signal sfx_volume_changed(db: float)

## Emitted when music volume changes
signal music_volume_changed(db: float)

## Loaded SFX sound paths, keyed by sound name
var _sfx_streams: Dictionary = {}

## Loaded music track paths, keyed by track name
var _music_streams: Dictionary = {}

## Currently playing music AudioStreamPlayer (for stop_music)
var _current_music_player: AudioStreamPlayer = null

## Track bus mute states locally (since AudioServer.is_bus_muted may not be available in GDScript)
var _sfx_muted: bool = false
var _music_muted: bool = false

## --- Lifecycle ---

func _ready() -> void:
	_setup_audio_buses()
	_load_audio_files()

## --- Audio bus management ---

func _setup_audio_buses() -> void:
	var bus_count: int = AudioServer.get_bus_count()

	# Create SFX bus if it doesn't exist
	if AudioServer.get_bus_index(SFX_BUS) < 0:
		AudioServer.add_bus(bus_count)
		AudioServer.set_bus_name(bus_count, SFX_BUS)
		AudioServer.set_bus_mute(bus_count, false)
		AudioServer.set_bus_volume_db(bus_count, 0.0)

	# Create Music bus if it doesn't exist
	if AudioServer.get_bus_index(MUSIC_BUS) < 0:
		var music_idx: int = bus_count + (1 if AudioServer.get_bus_index(SFX_BUS) >= bus_count else 0)
		AudioServer.add_bus(music_idx)
		AudioServer.set_bus_name(music_idx, MUSIC_BUS)
		AudioServer.set_bus_mute(music_idx, false)
		AudioServer.set_bus_volume_db(music_idx, 0.0)

## --- File loading ---

func _load_audio_files() -> void:
	_load_folder("res://audio/sfx/", _sfx_streams)
	_load_folder("res://audio/music/", _music_streams)

func _load_folder(folder: String, target: Dictionary) -> void:
	var dir := DirAccess.open(folder)
	if dir == null:
		push_warning("[SoundManager] Cannot open folder: " + folder)
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		var lower := file_name.to_lower()
		if lower.ends_with(".wav") or lower.ends_with(".ogg"):
			var key := file_name.trim_suffix(".wav").trim_suffix(".ogg")
			var full_path := folder + file_name
			var stream: Variant = load(full_path)
			if stream != null:
				target[key] = full_path
		file_name = dir.get_next()

## --- SFX playback ---

## Play a sound effect by name.
## If bus_name is provided, plays on that bus; otherwise defaults to SFX bus.
func play_sfx(sound: String, bus_name: String = SFX_BUS) -> void:
	if sound.is_empty():
		return
	if sound in _sfx_streams:
		var stream_path: String = _sfx_streams[sound]
		_play_on_bus(stream_path, bus_name)
	else:
		push_warning("[SoundManager] SFX not found: " + sound)

## --- Music playback ---

## Play a music track by name.
## If loop is true, the track will loop continuously.
func play_music(track: String, loop: bool = true) -> void:
	if track.is_empty():
		return
	if track in _music_streams:
		var stream_path: String = _music_streams[track]
		_play_music_on_bus(stream_path, MUSIC_BUS, loop)
	else:
		push_warning("[SoundManager] Music track not found: " + track)

## Stop any currently playing music track.
func stop_music() -> void:
	if _current_music_player != null and _current_music_player.playing:
		_current_music_player.stop()
		_current_music_player.queue_free()
		_current_music_player = null

## --- Volume controls ---

## Set the SFX bus volume in decibels.
## -inf = mute, 0.0 = unity (default), +6 = boost
func set_sfx_volume_db(db: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index(SFX_BUS)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, db)
		sfx_volume_changed.emit(db)

## Get the SFX bus volume in decibels.
func get_sfx_volume_db() -> float:
	var bus_idx: int = AudioServer.get_bus_index(SFX_BUS)
	if bus_idx >= 0:
		return AudioServer.get_bus_volume_db(bus_idx)
	return 0.0

## Set the music bus volume in decibels.
func set_music_volume_db(db: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index(MUSIC_BUS)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, db)
		music_volume_changed.emit(db)

## Get the music bus volume in decibels.
func get_music_volume_db() -> float:
	var bus_idx: int = AudioServer.get_bus_index(MUSIC_BUS)
	if bus_idx >= 0:
		return AudioServer.get_bus_volume_db(bus_idx)
	return 0.0

## Mute or unmute the SFX bus.
func set_sfx_muted(muted: bool) -> void:
	var bus_idx: int = AudioServer.get_bus_index(SFX_BUS)
	if bus_idx >= 0:
		AudioServer.set_bus_mute(bus_idx, muted)
		_sfx_muted = muted

## Mute or unmute the music bus.
func set_music_muted(muted: bool) -> void:
	var bus_idx: int = AudioServer.get_bus_index(MUSIC_BUS)
	if bus_idx >= 0:
		AudioServer.set_bus_mute(bus_idx, muted)
		_music_muted = muted

## Check if SFX bus is muted.
func is_sfx_muted() -> bool:
	return _sfx_muted

## Check if music bus is muted.
func is_music_muted() -> bool:
	return _music_muted

## --- Internal helpers ---

func _play_on_bus(stream_path: String, bus_name: String) -> void:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx < 0:
		push_warning("[SoundManager] Bus not found: " + bus_name)
		return
	var stream: Variant = load(stream_path)
	if stream == null:
		push_warning("[SoundManager] Failed to load: " + stream_path)
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = bus_name
	player.autoplay = false
	add_child(player)
	player.play()
	player.finished.connect(_on_sfx_finished.bind(player))

func _play_music_on_bus(stream_path: String, bus_name: String, loop: bool) -> void:
	stop_music()
	var stream: Variant = load(stream_path)
	if stream == null:
		push_warning("[SoundManager] Failed to load: " + stream_path)
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = bus_name
	player.loop = loop
	player.autoplay = false
	add_child(player)
	player.play()
	_current_music_player = player

func _on_sfx_finished(player: AudioStreamPlayer) -> void:
	player.queue_free()
