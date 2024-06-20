extends CharacterBody2D


const MAX_SPEED = 130.0
const JUMP_VELOCITY = -300.0
const DASH_VELOCITY = 300.0
const ACCELERATION = 1200.0
const DECELERATION = 800.0
const STOP = 20.0
const COYOTE = 0.2
const jump_buffer_timer: float = 0.1

@onready var animated_sprite = $AnimatedSprite2D
@onready var dash_timer = $DashTimer
@onready var coyote_timer = $CoyoteTimer
@onready var boom = $Boom
@onready var audio_stream_player = $AudioStreamPlayer2D

var Velocity = Vector2()
var input_vector = Vector2()

#Jumping Variables
var jump_count = 0
var max_jumps = 2
var can_jump = false #THIS IS FOR COYOTE TIME
var jump_buffer:bool = false

#Dashing Variables
var dash_count = 0
var max_dash = 1
var is_dashing = false

#Bullet Time Variables
var is_bullet_time = true
var bullet_time_scale = 0.4

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor() and not is_dashing:
		velocity.y += gravity * delta
		
	if is_on_floor():
		jump_count = 0
		dash_count = 0
		is_dashing = false
		can_jump = true #RESET FOR COYOTE
		if jump_buffer:
			jump_buffer = false
		Engine.time_scale = 1.0
	
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if (jump_count < max_jumps or can_jump):
			Jump()
		else:
			jump_buffer = true
			get_tree().create_timer(jump_buffer_timer).timeout.connect(on_jump_buffer_timeout)
	
	#Handle Dash
	if Input.is_action_just_pressed("Dash") and dash_count < max_dash and not is_dashing:
		dash_count += 1
		is_dashing = true
		dash_timer.start()
		if not animated_sprite.flip_h:
			velocity.x = DASH_VELOCITY * 1
		if animated_sprite.flip_h:
				velocity.x = DASH_VELOCITY * -1
		animated_sprite.play("Dash")
	
	# Get the input direction 
	var direction = Input.get_axis("move_left", "moeve_right")
	
	#Flip sprite
	if direction > 0 :
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	#Play animations
	if is_on_floor() and not is_dashing:
			if direction == 0:
				animated_sprite.play("Idle")
			else:
				animated_sprite.play("Run")
	
	
	#Apply movement with momentum
	if not is_dashing:
		if direction != 0:
			velocity.x = move_toward(velocity.x,direction * MAX_SPEED, ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
	
	# Snap velocity to zero if it's below the threshold
	if abs(velocity.x) < STOP:
		velocity.x = 0
	

	move_and_slide()

func Jump() -> void:
	boom.emitting = true
	velocity.y = JUMP_VELOCITY
	jump_count += 1
	animated_sprite.play("Jump")
	can_jump = false #DisableCoyote
	audio_stream_player.play()
	if not is_on_floor():
		Engine.time_scale = 0.4

func on_jump_buffer_timeout() -> void:
	jump_buffer = false

func _on_dash_timer_timeout():
	is_dashing = false



