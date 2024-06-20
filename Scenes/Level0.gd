extends Node

@onready var game_manager = GameManager  # Direct reference to the AutoLoad singleton

func _ready():
	# Ensure we start with the correct console output for the current score and level
	print("Level loaded. Current score: ", str(game_manager.score))
	print("Current level index: ", str(game_manager.level_index))

func _on_Coin_collected():
	game_manager.add_point()
