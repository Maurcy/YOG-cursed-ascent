extends CharacterBody2D

const GRAVITY = 3000.0
const SPEED = 460.0
const JUMP_VELOCITY = -1000.0

const ACCELERATION = 2000.0
const DECELERATION = 1500.0
const BRAKE_ACCELERATION = 4000.0

const JUMP_GRAVITY_MULTIPLIER = 0.7
const HANG_GRAVITY_MULTIPLIER = 0.5  
const HANG_VELOCITY_TRESHOLD = 40
const FALL_GRAVITY_MULTIPLIER = 1.8
const JUMP_CUT_MULTIPLIER = 0.4


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		var gravity_force = GRAVITY
		
		if velocity.y < 0: 
			if abs(velocity.y) < HANG_VELOCITY_TRESHOLD:
				gravity_force *= HANG_GRAVITY_MULTIPLIER
			else:
				gravity_force *= JUMP_GRAVITY_MULTIPLIER
		else: 
			gravity_force *= FALL_GRAVITY_MULTIPLIER
		
		velocity.y += gravity_force * delta
	
	# Jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER
	
	# Moving on ground
	var direction := Input.get_axis("moveLeft", "moveRight")
	if direction != 0:
		if sign(direction) != sign(velocity.x) and velocity.x != 0:
			velocity.x = move_toward(velocity.x, direction * SPEED, BRAKE_ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
	
	move_and_slide()
