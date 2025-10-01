extends Area2D

var playerAtExit = false

func _on_body_entered(body: Node2D) -> void:
	playerAtExit = true


func _on_body_exited(body: Node2D) -> void:
	playerAtExit = false
	
func _process(delta: float):
	if Input.is_action_just_pressed("jump") and playerAtExit:
		get_tree().reload_current_scene()
