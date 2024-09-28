extends Button

@onready var game_manager = get_node("/root/GameManager")

func _on_pressed() -> void:
	# Check if GameManager and the level array are valid
	if game_manager and game_manager.level_index < game_manager.levels.size():
		# Load the first playable level (adjust index if needed)
		game_manager.change_level(game_manager.levels[game_manager.level_index])
	else:
		print("Error: GameManager not found or levels are exhausted.")
	
	
	# Change to the new scene
	#get_tree().change_scene_to(new_scene)
