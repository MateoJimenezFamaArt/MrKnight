extends Node

var score = 0
var level_index = 0  # Keeps track of the current level

@onready var score_label = $CanvasLayer/score_label

@export var required_scores = [9, 13]  # Correct the number of coins needed for each level
@export var levels = [
	"res://Scenes/Levels/level_0.tscn",
	"res://Scenes/Levels/level_1.tscn",
	"res://Scenes/Levels/level_2.tscn"
]

func _ready():
	if level_index < levels.size():
		update_score_label(score)
		print("Game started. Level index at start: ", str(level_index))
		print("You collected " + str(score) + " coins.")

func add_point():
	score += 1
	print("You collected " + str(score) + " coins.")
	print("You have collected a coin. Current score: ", str(score))
	print("Current level index: ", str(level_index))
	update_score_label(score)
	check_for_level_transition()

func check_for_level_transition():
	print("Checking if you are done or not... Current score: ", str(score), " Required: ", str(required_scores[level_index]))
	if score >= required_scores[level_index]:
		print("You have enough coins to proceed.")
		level_index += 1
		if level_index < levels.size():
			print("Your level should be changing to: ", str(levels[level_index]))
			change_level(levels[level_index])
		else:
			print("All levels completed!")

func change_level(level_path):
	print("Changing level to: ", str(level_path))
	var next_level = load(level_path)
	if next_level:
		score = 0
		get_tree().change_scene_to_packed(next_level)
		update_score_label(score)
		print("Level index is now: ", str(level_index))
		if level_index < required_scores.size():
			print("New required score: ", str(required_scores[level_index]))
		print("You collected " + str(score) + " coins.")
	else:
		print("Error loading level: ", str(level_path))
		
func update_score_label(new_score):
	score_label.text = "Coins gathered -> " + str(new_score) + " / " + str(required_scores[level_index])
	
