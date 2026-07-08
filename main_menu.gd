extends Control
## MainMenu — title screen with instructions and high score display.
## Shows the game title, instructions, the persistent high score (from SaveLoad),
## and a "Play" button to start the game.

## --- UI References ---
var title_label: Label
var high_score_label: Label
var instructions_label: Label
var play_button: Button

## --- Lifecycle ---
func _ready() -> void:
	# Grab UI references
	title_label = $VBox/Title
	high_score_label = $VBox/HighScore
	instructions_label = $VBox/Instructions
	play_button = $VBox/PlayButton
	
	# Connect button
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	
	# Display the current high score
	_update_high_score()

## --- High Score ---
func _update_high_score() -> void:
	var high_score := SaveLoad.get_high_score()
	var best_waves := SaveLoad.get_best_waves()
	var best_gold := SaveLoad.get_best_gold()
	
	if high_score > 0:
		high_score_label.text = "High Score: %d  |  Best Waves: %d  |  Best Gold: %d" % [
			high_score, best_waves, best_gold
		]
	else:
		high_score_label.text = "High Score: No runs yet — be the first!"

## --- Play ---
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Main.tscn")
