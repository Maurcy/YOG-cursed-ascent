extends Node
var left_border = 30
var right_border = 1120
var size = 0;
var height = 6;
var grid := []

const spawn_room = 0
const normal_room = 1
const hard_room = 2
const dangerous_room = 3
const treasure_room = 4

func _ready() -> void:
	size =  (right_border - left_border) / 3

func generate_level() -> void:
	grid.clear()
	
	for y in range(height):
		grid.append([null, null, null])	
		if y == 0:
			var room = randi_range(1,2)
			pass
		else:
			pass
	pass
