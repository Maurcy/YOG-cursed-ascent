extends CanvasLayer

@onready var levelTimerDisplay: Label = $Control/levelTimerDisplay
@onready var game_start_text: Label = $Control/gameStartText
@onready var gameover: Label = $Control/Gameover

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.timeup.connect(_on_time_up)
	gameover.visible = false;

func _on_time_up() -> void:
	gameover.visible = true;

# time handler.
func _process(delta: float):
	# if there's only less than a minute, starts displaying miliseconds
	if GameManager.remainingLevelTime <= 60:
		levelTimerDisplay.text = "%.1f" % GameManager.remainingLevelTime
	else:
		# minutes is time divided by 60, seconds is the leftover what isnt in a minute
		var minutes = GameManager.remainingLevelTime / 60
		minutes = floor(minutes)
		var seconds = GameManager.remainingLevelTime - (minutes * 60);
		# for some reason it displays 4:60 on 5 minutes, if statement to bruteforce it to be correct
		if seconds > 59:
			minutes += 1
			seconds = "00"
		else:
			seconds = "%.0f" % seconds
		minutes = "%.0f" % minutes
		
		levelTimerDisplay.text = str(minutes) + ":" + str(seconds)
		
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
