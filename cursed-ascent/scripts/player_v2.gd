extends CharacterBody2D

@onready var extra_jump_input: TextEdit = $TextEdit

var dash_unlocked := false
var wall_jump_unlocked := false
var chain_wall_jump_unlocked := false
var wall_slide_unlocked := false

var jump_velocity_multiplier := 1.0
var wall_jump_velocity_multiplier := 1.0
var horizontal_speed_multiplier := 1.0
var slow_falling_multiplier := 1.0
var floaty_jump_multiplier := 1.0

const SPEED = 500.0
var acceleration = 2000.0
const DECELERATION = 1500.0
var brake_acceleration = 4000.0

const GRAVITY = 3000.0
const JUMP_GRAVITY_MULTIPLIER = 0.7
const HANG_GRAVITY_MULTIPLIER = 0.5
const HANG_VELOCITY_THRESHOLD = 40.0
const FALL_GRAVITY_MULTIPLIER = 1.8

const JUMP_VELOCITY = -1000.0
var JUMP_CUT_MULTIPLIER = 0.4
const COYOTE_TIME_WINDOW = 0.1
const JUMP_BUFFER_WINDOW = 0.1

var coyote_time_timer := 0.0
var jump_buffer_timer := 0.0
var extra_jumps := 0
var available_extra_jumps := 0

const DASH_SPEED = 1400.0
var dash_speed_multiplier := 1.0
var dash_duration = 0.05
const DASH_CONTROL_LOCK = 0.03
const DASH_DECEL_RATE = 10000.0
var dash_cooldown = 1.0

var is_dashing := false
var dash_dir := 0
var dash_timer := 0.0
var dash_cooldown_timer := 0.0

const WALL_JUMP_FORCE = 500.0
const WALL_SLIDE_MULTIPLIER = 0.1 
const MAX_WALL_SLIDE_SPEED = 100.0
const WALL_JUMP_FORGIVENESS_WINDOW = 0.12

var has_wall_jumped = false
var last_wall_dir := 0.0
var was_wall_sliding := false
var wall_jump_forgiveness_timer := 0.0
var tried_wall_jump_but_failed = false



func _ready():
	Engine.time_scale = 1.0
	GameManager.reset_pos.connect(reset_pos)


func reset_pos(x,y):
	position = Vector2(x, y)


func _physics_process(delta: float) -> void:
	handle_timers(delta)
	apply_gravity(delta)
	handle_jump_buffer()
	handle_jump_input()
	handle_horizontal_movement(delta)
	handle_dash(delta)
	handle_wall_slide_transition()
	move_and_slide()


func update_jump_input():
	# temp uit gecomment
	# extra_jumps = extra_jump_input.text.to_int()
	
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
	
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
	
	if wall_jump_forgiveness_timer > 0.0:
		wall_jump_forgiveness_timer -= delta


func apply_gravity(delta: float):
	if is_dashing:
		return
	
	var gravity_force := GRAVITY
	
	if velocity.y < 0:
		if abs(velocity.y) < HANG_VELOCITY_THRESHOLD:
			gravity_force *= HANG_GRAVITY_MULTIPLIER
		else:
			gravity_force *= JUMP_GRAVITY_MULTIPLIER * floaty_jump_multiplier
	else:
		gravity_force *= FALL_GRAVITY_MULTIPLIER
		if Input.is_action_pressed("jump"):
			gravity_force *= 1 / slow_falling_multiplier
		
		if is_wall_sliding() and wall_slide_unlocked:
			gravity_force *= WALL_SLIDE_MULTIPLIER
	
	velocity.y += gravity_force * delta


func handle_jump_buffer():
	if Input.is_action_just_pressed("jump") and not is_on_floor():
		jump_buffer_timer = JUMP_BUFFER_WINDOW


func is_wall_sliding() -> bool:
	var wall_dir := get_wall_normal().x
	var direction := Input.get_axis("moveLeft", "moveRight")
	
	if is_on_wall() and wall_dir == -direction:
		return true
	
	return false


func handle_wall_slide_transition():
	var wall_sliding_now = is_wall_sliding()
	if wall_sliding_now and not was_wall_sliding:
		if velocity.y > MAX_WALL_SLIDE_SPEED:
			velocity.y = MAX_WALL_SLIDE_SPEED
	was_wall_sliding = wall_sliding_now


func handle_jump_input():
	if is_on_floor():
		if jump_buffer_timer > 0.0:
			do_ground_jump()
		last_wall_dir = 0.0
		has_wall_jumped = false
		wall_jump_forgiveness_timer = 0.0
		tried_wall_jump_but_failed = false
	
	if is_on_wall() and not is_on_floor():
		wall_jump_forgiveness_timer = WALL_JUMP_FORGIVENESS_WINDOW
	
	if Input.is_action_just_pressed("jump"):
		if (is_on_wall() and not is_on_floor() and wall_jump_unlocked) or wall_jump_forgiveness_timer > 0.0:
			do_wall_jump()
		elif is_on_floor() or coyote_time_timer < COYOTE_TIME_WINDOW:
			do_ground_jump()
		elif available_extra_jumps > 0:
			do_extra_jump()
		
		if tried_wall_jump_but_failed and available_extra_jumps > 0:
			do_extra_jump()
	
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER


func do_ground_jump():
	velocity.y = JUMP_VELOCITY * jump_velocity_multiplier
	coyote_time_timer = COYOTE_TIME_WINDOW
	jump_buffer_timer = 0.0


func do_extra_jump():
	available_extra_jumps -= 1
	velocity.y = JUMP_VELOCITY * jump_velocity_multiplier * pow(0.9, (extra_jumps - available_extra_jumps))


func do_wall_jump():
	if not wall_jump_unlocked:
		return
	
	var wall_dir = get_wall_normal().x
	
	if not chain_wall_jump_unlocked and has_wall_jumped:
		tried_wall_jump_but_failed = true
		return
	
	if wall_dir == last_wall_dir:
		tried_wall_jump_but_failed = true
		return
	
	velocity.x = WALL_JUMP_FORCE * wall_dir * wall_jump_velocity_multiplier
	velocity.y = JUMP_VELOCITY * wall_jump_velocity_multiplier
	last_wall_dir = wall_dir
	has_wall_jumped = true
	wall_jump_forgiveness_timer = 0.0
	tried_wall_jump_but_failed = false


func handle_horizontal_movement(delta: float):
	if is_dashing and dash_timer < DASH_CONTROL_LOCK:
		return
	
	var direction := Input.get_axis("moveLeft", "moveRight")
	var target_speed := direction * SPEED * horizontal_speed_multiplier
	velocity.x = move_toward(velocity.x, target_speed, get_acceleration(delta, direction))


func get_acceleration(delta: float, direction: float) -> float:
	if direction == 0:
		return DECELERATION * delta * horizontal_speed_multiplier
	
	if sign(direction) != sign(velocity.x):
		return brake_acceleration * delta * (horizontal_speed_multiplier * 2)
	
	return acceleration * delta * horizontal_speed_multiplier


func _input(_event):
	if not dash_unlocked:
		return
	
	if Input.is_action_just_pressed("dash"):
		_start_dash()


func _start_dash():	
	if is_dashing:
		return
	
	if dash_cooldown_timer > 0.0:
		return
	
	dash_cooldown_timer = dash_cooldown
	
	var direction := Input.get_axis("moveLeft", "moveRight")
	
	if direction == 0:
		dash_dir = sign(velocity.x)
	else:
		dash_dir = sign(direction)
	
	is_dashing = true
	dash_timer = 0.0
	velocity.x = dash_dir * DASH_SPEED * dash_speed_multiplier


func handle_dash(delta: float):
	if not is_dashing:
		return
	
	dash_timer += delta
	
	if dash_timer >= DASH_CONTROL_LOCK:
		velocity.x = move_toward(velocity.x, 0, DASH_DECEL_RATE * dash_speed_multiplier * delta)
	
	if dash_timer >= dash_duration:
		is_dashing = false
		
func _process(delta: float):
	if GameManager.timeUp:
		set_physics_process(false)
