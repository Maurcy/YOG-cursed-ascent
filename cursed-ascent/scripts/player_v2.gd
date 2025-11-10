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

const DASH_SPEED = 1400.0
const DASH_DURATION = 0.05
const DASH_CONTROL_LOCK = 0.03
const DASH_DECEL_RATE = 10000.0
const DASH_COOLDOWN = 1.0

var dash_unlocked := true
var is_dashing := false
var dash_dir := 0
var dash_timer := 0.0
var dash_cooldown_timer := 0.0

const WALL_JUMP_FORCE = 500.0

var can_wall_jump = false
var last_wall_dir = 0


var coyote_time_timer := 0.0
var jump_buffer_timer := 0.0
var extra_jumps = 0
var available_extra_jumps := 0


func _ready():
	Engine.time_scale = 1.0
	pass


func _physics_process(delta: float) -> void:
	update_jump_input()
	handle_timers(delta)
	apply_gravity(delta)
	handle_jump_input()
	handle_wall_jump_input()
	handle_horizontal_movement(delta)
	handle_dash(delta)
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


func handle_wall_jump_input():
	if is_on_floor():
		can_wall_jump = true
		last_wall_dir = 0 
	
	if Input.is_action_just_pressed("jump") and can_wall_jump:
		if is_on_wall() and not is_on_floor():
			var wall_dir = get_wall_normal().x
			
			if wall_dir == last_wall_dir:
				return
			
			velocity.x = WALL_JUMP_FORCE * wall_dir
			velocity.y = JUMP_VELOCITY
			last_wall_dir = wall_dir


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
	
	dash_cooldown_timer = DASH_COOLDOWN
	
	var direction := Input.get_axis("moveLeft", "moveRight")
	
	if direction == 0:
		dash_dir = sign(velocity.x)
	else:
		dash_dir = sign(direction)
	
	is_dashing = true
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
		
func _process(delta: float):
		if GameManager.timeUp:
			set_physics_process(false)
