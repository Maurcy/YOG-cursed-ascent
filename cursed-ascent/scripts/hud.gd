extends CanvasLayer

@onready var levelTimerDisplay: Label = $Control/levelTimerDisplay
@onready var game_start_text: Label = $Control/gameStartText

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	# if there's only less than a minute, starts displaying miliseconds
	if GameManager.remainingLevelTime <= 60:
		levelTimerDisplay.text = "%.1f" % GameManager.remainingLevelTime
	else:
		levelTimerDisplay.text = "%.0f" % GameManager.remainingLevelTime
	
	if GameManager.remainingLevelTime <= 30:
		levelTimerDisplay.add_theme_color_override("font_color", Color(1.0,1.0,0.0,1.0))
	
	if GameManager.remainingLevelTime <= 10:
		levelTimerDisplay.add_theme_color_override("font_color", Color(1.0,0.0,0.0,1.0))
	
	if GameManager.timeUp:
		levelTimerDisplay.text = "Time's up!"
	
	if GameManager.startdisplay == true:
		game_start_text.visible = true
		levelTimerDisplay.visible = false
	else:
		game_start_text.visible = false
		levelTimerDisplay.visible = true
