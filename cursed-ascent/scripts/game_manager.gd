extends Node
var levelTime = 20
var remainingLevelTime
var timeUp = false;
@onready var levelTimer: Timer = $levelTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	levelTimer.wait_time = levelTime
	remainingLevelTime = levelTime

# Called every frame. 'delta' is the e6lapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and levelTimer.is_stopped() and timeUp == false:
		levelTimer.start()
		
	if levelTimer.is_stopped() == false:	
		remainingLevelTime = levelTimer.time_left


func _on_level_timer_timeout() -> void:
	timeUp = true
