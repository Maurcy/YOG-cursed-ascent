extends CharacterBody2D

@onready var extra_jump_input: TextEdit = $TextEdit

const SPEED = 500.0
const ACCELERATION = 2000.0
const DECELERATION = 1500.0
const BRAKE_ACCELERATION = 4000.0

const GRAVITY = 3000.0
const JUMP_GRAVITY_MULTIPLIER = 0.7
const HANG_GRAVITY_MULTIPLIER = 0.5
const HANG_VELOCITY_THRESHOLD = 40.0
const FALL_GRAVITY_MULTIPLIER = 1.8

const JUMP_VELOCITY = -1000.0
const JUMP_CUT_MULTIPLIER = 0.4
const COYOTE_TIME_WINDOW = 0.1
const JUMP_BUFFER_WINDOW = 0.05

const DOUBLE_TAP_TIME = 0.3
const DASH_SPEED = 1600.0
const DASH_DURATION = 0.05
const DASH_CONTROL_LOCK = 0.03
const DASH_DECEL_RATE = 10000.0

var dash_unlocked := true
var is_dashing := false
var dash_dir := 0
var dash_timer := 0.0
var last_tap_time = {"left": -1.0, "right": -1.0}

var coyote_time_timer := 0.0
var jump_buffer_timer := 0.0
var extra_jumps = 0
var available_extra_jumps := 0


func _ready():
	pass


func _physics_process(delta: float) -> void:
	update_jump_input()
	handle_timers(delta)
	apply_gravity(delta)
	handle_jump_input()
	handle_horizontal_movement(delta)
	handle_dash(delta)
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
	if is_dashing:
		return
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
	if Input.is_action_just_pressed("jump"):
		if (!is_on_floor() and available_extra_jumps > 0):
			if (coyote_time_timer > COYOTE_TIME_WINDOW):
				available_extra_jumps -= 1
			velocity.y = JUMP_VELOCITY * 0.85
		jump_buffer_timer = JUMP_BUFFER_WINDOW
	if (is_on_floor() or coyote_time_timer < COYOTE_TIME_WINDOW) and jump_buffer_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		coyote_time_timer = COYOTE_TIME_WINDOW
		jump_buffer_timer = 0.0 
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER

func handle_horizontal_movement(delta: float):
	if is_dashing and dash_timer < DASH_CONTROL_LOCK:
		return
	var direction := Input.get_axis("moveLeft", "moveRight")
	var target_speed := direction * SPEED
	velocity.x = move_toward(velocity.x, target_speed, get_acceleration(delta, direction))

func get_acceleration(delta: float, direction: float) -> float:
	if direction == 0:
		return DECELERATION * delta
	if sign(direction) != sign(velocity.x):
		return BRAKE_ACCELERATION * delta
	return ACCELERATION * delta

func _input(event):
	if not dash_unlocked:
		return
	if event.is_action_pressed("moveLeft"):
		_check_double_tap("left")
	elif event.is_action_pressed("moveRight"):
		_check_double_tap("right")

func _check_double_tap(dir: String):
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_tap_time[dir] <= DOUBLE_TAP_TIME:
		_start_dash(dir)
	last_tap_time[dir] = current_time

func _start_dash(dir: String):
	if is_dashing:
		return
	is_dashing = true
	dash_dir = -1 if dir == "left" else 1
	dash_timer = 0.0
	velocity.x = dash_dir * DASH_SPEED

func handle_dash(delta: float):
	if not is_dashing:
		return
	dash_timer += delta
	if dash_timer >= DASH_CONTROL_LOCK:
		velocity.x = move_toward(velocity.x, 0, DASH_DECEL_RATE * delta)
	if dash_timer >= DASH_DURATION:
		is_dashing = false
