extends CanvasLayer

@onready var levelTimerDisplay: Label = $Control/levelTimerDisplay
@onready var game_manager: Node = %gameManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	# if there's only less than a minute, starts displaying miliseconds
	if game_manager.remainingLevelTime <= 60:
		levelTimerDisplay.text = "%.1f" % game_manager.remainingLevelTime
	else:
		levelTimerDisplay.text = "%.0f" % game_manager.remainingLevelTime
	
	if game_manager.remainingLevelTime <= 30:
		levelTimerDisplay.add_theme_color_override("font_color", Color(1.0,1.0,0.0,1.0))
	
	if game_manager.remainingLevelTime <= 10:
		levelTimerDisplay.add_theme_color_override("font_color", Color(1.0,0.0,0.0,1.0))
	
	if game_manager.timeUp:
		levelTimerDisplay.text = "Time's up!"
