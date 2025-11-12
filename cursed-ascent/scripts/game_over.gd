extends ColorRect

@onready var animation_player: AnimationPlayer = $GameOverScreen/AnimationPlayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func gameover() -> void:
	animation_player.play("fadeblack")
