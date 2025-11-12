extends Node
var levelTime = 60
var remainingLevelTime
var timeUp = false;
var startdisplay = true;

@onready var levelTimer: Timer = $levelTimer
@onready var gameover: Control = %Gameover
@onready var upgrade_manager: Node = $UpgradeManager

signal offer_upgrades()
signal reset_pos(x, y)

const ROOM_WIDTH := 362
const ROOM_HEIGHT := 362
var level_origin := Vector2(-543, -1843)

var room_variants = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	levelTimer.wait_time = levelTime
	remainingLevelTime = levelTime
	
	preload_rooms()
	var level_layout = LevelGenerator.generate_level(6, 3)
	generate_level(level_layout);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and levelTimer.is_stopped() and timeUp == false:
		levelTimer.start()
		startdisplay = false;
		
	if levelTimer.is_stopped() == false:
		remainingLevelTime = levelTimer.time_left


func _on_level_timer_timeout() -> void:
	timeUp = true
	gameover.gameover()

# Preloads rooms so the level generation knows what rooms to pick from
func preload_rooms():
	var base_path = "res://rooms/"
	var folder_map = {
		LevelGenerator.spawn_room: "spawn_rooms",
		LevelGenerator.normal_room: "normal_rooms",
		LevelGenerator.hard_room: "hard_rooms",
		LevelGenerator.dangerous_room: "dangerous_rooms",
		LevelGenerator.exit_room: "exit_rooms"
	}

	for type in folder_map.keys():
		room_variants[type] = []

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
				instance.position = level_origin + Vector2(x * ROOM_WIDTH, (grid.size() - 1 - y) * ROOM_HEIGHT)
				add_child(instance)
				
	# generates exit
	var exit_scene = get_random_room_scene(4)
	var exit = exit_scene.instantiate()
	# height gets added at the beginning of the level, on top of the top room, with 20 pixels wiggle room
	var exit_height = level_origin.y - ROOM_HEIGHT - 20
	exit.position = Vector2(0 , exit_height)
	add_child(exit)

# test button to show level generation
func _on_button_pressed() -> void:
	print("button pressed")
	var level_layout = LevelGenerator.generate_level(6, 3)
	generate_level(level_layout); 

# pause timer and other stuff for level exit	
func levelexit() -> void:
	Engine.time_scale = 0.0
	emit_signal("offer_upgrades")
	levelTimer.paused = true;
	clear_level()
	var level_layout = LevelGenerator.generate_level(7, 3)
	generate_level(level_layout)
	emit_signal("reset_pos", 4.0, -50.0)

func clear_level():
	for child in get_children():
		# Skip nodes that shouldn't be deleted (like UI, timers, managers)
		if child != levelTimer and child != gameover and child != upgrade_manager:
			child.queue_free()
