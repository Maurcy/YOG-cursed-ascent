extends CharacterBody2D

@onready var extra_jump_input: TextEdit = $TextEdit

# Movement
const SPEED = 500.0
const ACCELERATION = 2000.0
const DECELERATION = 1500.0
const BRAKE_ACCELERATION = 4000.0

# Gravity 
const GRAVITY = 3000.0
const JUMP_GRAVITY_MULTIPLIER = 0.7
const HANG_GRAVITY_MULTIPLIER = 0.5
const HANG_VELOCITY_THRESHOLD = 40.0
const FALL_GRAVITY_MULTIPLIER = 1.8

# Jumping
const JUMP_VELOCITY = -1000.0
const JUMP_CUT_MULTIPLIER = 0.4
const COYOTE_TIME_WINDOW = 0.1
const JUMP_BUFFER_WINDOW = 0.05

# Runtime state
var coyote_time_timer := 0.0
var jump_buffer_timer := 0.0
var extra_jumps = 0
var available_extra_jumps := 0


func _ready():
	# Engine.time_scale = 0.2
	pass


func _physics_process(delta: float) -> void:
	update_jump_input()
	handle_timers(delta)
	apply_gravity(delta)
	handle_jump_input()
	handle_horizontal_movement(delta)
	move_and_slide()


func update_jump_input():
	extra_jumps = extra_jump_input.text.to_int()
	if Input.is_key_pressed(KEY_TAB):
		extra_jump_input.release_focus()

func handle_timers(delta: float):
	if not is_on_floor():
		coyote_time_timer += delta
	else:
		available_extra_jumps = extra_jumps
		coyote_time_timer = 0.0
	
	if jump_buffer_timer > 0.0:
		jump_buffer_timer -= delta

func apply_gravity(delta: float):
	var gravity_force := GRAVITY
	if velocity.y < 0:
		if abs(velocity.y) < HANG_VELOCITY_THRESHOLD:
			gravity_force *= HANG_GRAVITY_MULTIPLIER
		else:
			gravity_force *= JUMP_GRAVITY_MULTIPLIER
	else:
		gravity_force *= FALL_GRAVITY_MULTIPLIER
	
	velocity.y += gravity_force * delta

func handle_jump_input():
	# Mid Air Jumps
	if Input.is_action_just_pressed("jump"):
		if (!is_on_floor() and available_extra_jumps > 0):
			if (coyote_time_timer > COYOTE_TIME_WINDOW):
				available_extra_jumps -= 1
			velocity.y = JUMP_VELOCITY * 0.85
		
		jump_buffer_timer = JUMP_BUFFER_WINDOW
	
	# Grounded Jumps
	if (is_on_floor() or coyote_time_timer < COYOTE_TIME_WINDOW) and jump_buffer_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		coyote_time_timer = COYOTE_TIME_WINDOW
		jump_buffer_timer = 0.0 
	
	# Variable Jump Height
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER

func handle_horizontal_movement(delta: float):
	var direction := Input.get_axis("moveLeft", "moveRight")
	var target_speed := direction * SPEED
	velocity.x = move_toward(velocity.x, target_speed, get_acceleration(delta, direction))

func get_acceleration(delta: float, direction: float) -> float:
	if direction == 0:
		return DECELERATION * delta
	if sign(direction) != sign(velocity.x):
		return BRAKE_ACCELERATION * delta
	return ACCELERATION * delta
