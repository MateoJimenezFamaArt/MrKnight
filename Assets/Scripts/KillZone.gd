extends Area2D

@onready var game_manager = GameManager
@onready var timer = $Timer

func _on_body_entered(body):
	print("U died Bro")
	Engine.time_scale = 0.5
	game_manager.score = 0
	body.get_node("AnimatedSprite2D").play("Die")
	body.get_node("CollisionShape2D").queue_free()
	timer.start()


func _on_timer_timeout():
	get_tree().reload_current_scene()
	Engine.time_scale = 1
