extends Node

@onready var animation_player: AnimationPlayer = $GameOverScreen/AnimationPlayer

func _ready() -> void:
	GameManager.timeup.connect(_on_time_up)

func _on_time_up() -> void:
	gameover()

func gameover() -> void:
	animation_player.play("fadeblack")
