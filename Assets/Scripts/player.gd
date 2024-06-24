extends CharacterBody2D


const MAX_SPEED = 130.0
const JUMP_VELOCITY = -300.0
const DASH_VELOCITY = 300.0
const ACCELERATION = 1200.0
const DECELERATION = 800.0
const STOP = 20.0
const COYOTE = 0.2
const JUMP_BUFFER_TIMER: float = 0.1
const MIN_JUMP_VELOCITY = -150.0
const BULLET_TIME_PLAYER_SPEED_SACALE = 0.8
const BULLET_TIME_WORLD_SPEED_SCALE = 0.4

#Onready variables references to other child nodes
@onready var animated_sprite = $AnimatedSprite2D
@onready var dash_timer = $DashTimer
@onready var coyote_timer = $CoyoteTimer
@onready var boom = $Boom
@onready var swash = $Swash
@onready var jump = $Jump
@onready var dash = $Dash



#Jumping Variables
var jump_count = 0
var max_jumps = 2
var can_jump = false #THIS IS FOR COYOTE TIME
var jump_buffer:bool = false
var is_jumping = false

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
		reset_jump_dash_states()
		Engine.time_scale = 1.0
	
	handle_input(delta)
	apply_movement(delta)
	move_and_slide()
	
func handle_input(delta):
	if Input.is_action_just_pressed("jump"):
		if (jump_count < max_jumps or can_jump):
			Jump()
		else:
			jump_buffer = true
			get_tree().create_timer(JUMP_BUFFER_TIMER).timeout.connect(on_jump_buffer_timeout)
	#Handle Variable Jump
	if Input.is_action_just_released("jump") and is_jumping:
		if velocity.y < MIN_JUMP_VELOCITY:
			velocity.y = MIN_JUMP_VELOCITY
	
	#Handle Dash
	if Input.is_action_just_pressed("Dash") and dash_count < max_dash and not is_dashing:
		start_dash()
	
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

func apply_movement(delta):
	if not is_dashing:
		var direction = Input.get_axis("move_left", "moeve_right")
		var speed_scale = 1.0
		if is_bullet_time:
			speed_scale = BULLET_TIME_PLAYER_SPEED_SACALE
		
		var target_speed = direction * MAX_SPEED * speed_scale
		
		velocity.x = move_toward(velocity.x, target_speed, ACCELERATION * delta)

func Jump() -> void:
	boom.emitting = true
	velocity.y = JUMP_VELOCITY
	jump_count += 1
	animated_sprite.play("Jump")
	can_jump = false #DisableCoyote
	jump.play()
	if not is_on_floor():
		Engine.time_scale = 0.4
	is_jumping = true

func start_dash():
	dash.play()
	dash_count += 1
	is_dashing = true
	dash_timer.start()
	velocity.x = DASH_VELOCITY if not animated_sprite.flip_h else -DASH_VELOCITY
	animated_sprite.play("Dash")
	swash.emitting = true

func reset_jump_dash_states():
	jump_count = 0
	dash_count = 0
	is_dashing = false
	can_jump = true
	if jump_buffer:
		jump_buffer = false
		Engine.time_scale = 1.0
		is_jumping = false

func on_jump_buffer_timeout() -> void:
	jump_buffer = false

func _on_dash_timer_timeout():
	is_dashing = false




