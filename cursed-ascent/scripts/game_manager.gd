extends Node
var levelTime = 20
var remainingLevelTime
var timeUp = false;
@onready var levelTimer: Timer = $levelTimer

#
const ROOM_WIDTH := 160
const ROOM_HEIGHT := 160

var room_variants = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	levelTimer.wait_time = levelTime
	remainingLevelTime = levelTime
	
	preload_rooms()
	var level_layout = LevelGenerator.generate_level()
	generate_level(level_layout);

# Called every frame. 'delta' is the e6lapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and levelTimer.is_stopped() and timeUp == false:
		levelTimer.start()
		
	if levelTimer.is_stopped() == false:	
		remainingLevelTime = levelTimer.time_left


func _on_level_timer_timeout() -> void:
	timeUp = true


func preload_rooms():
	var base_path = "res://rooms/"
	var folder_map = {
		LevelGenerator.normal_room: "normal_rooms",
		LevelGenerator.hard_room: "hard_rooms",
		LevelGenerator.dangerous_room: "dangerous_rooms",
		LevelGenerator.treasure_room: "treasure_rooms"
	}

	for type in folder_map.keys():
		var path = base_path + folder_map[type]
		var dir = DirAccess.open(path)
		if dir:
			dir.list_dir_begin()
			var file = dir.get_next()
			while file != "":
				if file.ends_with(".tscn"):
					room_variants[type].append(load(path + "/" + file))
				file = dir.get_next()
			dir.list_dir_end()


func get_random_room_scene(room_type: int) -> PackedScene:
	var list = room_variants.get(room_type, [])
	if list.size() == 0:
		push_error("No scenes found for room type: %d" % room_type)
		return null
	return list[randi() % list.size()]

func generate_level(grid: Array):
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			var room_type = grid[y][x]
			if room_type == null:
				continue
				
			var room_scene = get_random_room_scene(room_type)
			
			if room_scene:
				var instance = room_scene.instantiate()
				instance.position = Vector2(x * ROOM_WIDTH, y * ROOM_HEIGHT)
				add_child(instance)
