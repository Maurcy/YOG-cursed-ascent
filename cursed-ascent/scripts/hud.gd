extends CanvasLayer

@onready var levelTimerDisplay: Label = $Control/levelTimerDisplay
@onready var game_manager: Node = %gameManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	levelTimerDisplay.text = "Remaining time: " + str(snapped(game_manager.remainingLevelTime, 0.01))
	if game_manager.timeUp:
		levelTimerDisplay.text = "Time's up!"
