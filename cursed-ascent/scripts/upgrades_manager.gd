extends Node

signal update_jumps(new_amount)
signal update_wall_jump()
signal show_upgrade_ui(upgrade_options: Array)

var extra_jumps := 0

var all_upgrades = [
	{"name": "Extra Jump", "description": "Gain +1 extra jump.", "type": "jump"},
	{"name": "Wall Jump", "description": "Unlock wall jumping.", "type": "wall_jump"},
	{"name": "Dash", "description": "Unlock dashing ability.", "type": "dash"},
	{"name": "Move Speed", "description": "Increase horizontal movement speed.", "type": "speed"},
]

func add_jump(amount):
	extra_jumps += amount
	emit_signal("update_jumps", extra_jumps)

func add_wall_jump():
	emit_signal("update_wall_jump")

func offer_upgrades():
	print('test')
	var shuffled = all_upgrades.duplicate()
	shuffled.shuffle()
	var chosen = shuffled.slice(0, 3)
	emit_signal("show_upgrade_ui", chosen)

func apply_upgrade(upgrade):
	var player = get_parent().get_node("Player")
	
	match upgrade["type"]:
		"jump":
			player.extra_jumps += 1
		"wall_jump":
			player.wall_jump_unlocked = true
		"dash":
			player.dash_unlocked = true
		"speed":
			player.horizontal_speed_multiplier += 0.2
