extends Node

signal show_upgrade_ui(upgrade_options: Array)

var acquired_upgrades := []   # track all taken upgrades
var upgrade_lock := false

# === UPGRADE LIST ===
var all_upgrades = [
	{"name": "wall jump", "desc": "Unlocks wall jumping", "needs": "", "infinite": false},
	{"name": "wall slide", "desc": "Unlocks wall sliding", "needs": "wall jump", "infinite": false},
	{"name": "stickier walls", "desc": "Makes wall sliding even slower", "needs": "wall slide", "infinite": false},
	{"name": "chain wall jumps", "desc": "Unlocks chain wall jumping", "needs": "wall jump", "infinite": false},
	{"name": "dash", "desc": "Unlocks dashing ability", "needs": "",  "infinite": false},
	{"name": "faster dash", "desc": "Decreases cooldown for dashing", "needs": "dash", "infinite": true},
	{"name": "better dash", "desc": "Increases dash distance and speed", "needs": "dash", "infinite": true},
	{"name": "double jump", "desc": "Unlocks double jumping", "needs": "",  "infinite": false},
	{"name": "extra jump", "desc": "Adds another air jump", "needs": "double jump", "infinite": true},
	{"name": "higher jumps", "desc": "Increases jump height", "needs": "",  "infinite": true},
	{"name": "slow falling", "desc": "Allows slow falling when holding jump", "needs": "", "infinite": false},
	{"name": "horizontal speed", "desc": "Increases horizontal movement speed", "needs": "", "infinite": true},
	{"name": "agile start", "desc": "Increase acceleration", "needs": "", "infinite": false},
	{"name": "quick stop", "desc": "Increase braking acceleration", "needs": "", "infinite": false},
	{"name": "floaty jump", "desc": "Jumps have decreased gravity", "needs": "!quick hops", "infinite": false},
	#{"name": "quick hops", "desc": "Shortens jump duration but increases horizontal speed", "needs": "!floaty jump", "infinite": false}
]

func _ready():
	GameManager.offer_upgrades.connect(offer_upgrades)


func offer_upgrades():
	if upgrade_lock:
		return
	
	upgrade_lock = true
	
	var valid_upgrades = _get_valid_upgrades()
	if valid_upgrades.is_empty():
		return
	valid_upgrades.shuffle()
	var chosen = valid_upgrades.slice(0, min(3, valid_upgrades.size()))
	emit_signal("show_upgrade_ui", chosen)


func apply_upgrade(upgrade):
	upgrade_lock = false
	Engine.time_scale = 1.0
	
	var upgrade_name = upgrade["name"]
	if not upgrade["infinite"] and upgrade_name in acquired_upgrades:
		return

	acquired_upgrades.append(upgrade_name)
	var player = get_parent().get_node("CharacterBody2D")

	match upgrade_name:
		"wall jump": # works
			player.wall_jump_unlocked = true
		"wall slide": # works
			player.wall_slide_unlocked = true
		"stickier walls": 
			player.WALL_SLIDE_MULTIPLIER *= 0.5 ##
		"chain wall jumps": # works
			player.chain_wall_jump_unlocked = true
		"dash": # works
			player.dash_unlocked = true
		"faster dash":  # works
			player.dash_cooldown -= 0.2
		"better dash": # works (imperfectly)
			player.dash_speed_multiplier += 0.1
			player.dash_duration -= 0.05 
		"double jump": # works
			player.extra_jumps += 1 
		"extra jump": # works
			player.extra_jumps += 1
		"higher jumps": # works
			player.jump_velocity_multiplier += 0.15
		"slow falling": # works
			player.slow_falling_multiplier = 7.0
		"horizontal speed": # works
			player.horizontal_speed_multiplier += 0.3
		"agile start": # works, NOT FUN
			player.acceleration *= 30
		"quick stop": # works
			player.brake_acceleration *= 2
		"floaty jump": # works
			player.floaty_jump_multiplier *= 0.8
		"quick hops":
			player.JUMP_CUT_MULTIPLIER *= 0.5
			player.horizontal_speed_multiplier += 0.1


func _get_valid_upgrades() -> Array:
	var result := []
	for u in all_upgrades:
		var upgrade_name = u["name"]
		var needs = u["needs"]
		var infinite = u["infinite"]
		
		# Already acquired and not infinite
		if not infinite and upgrade_name in acquired_upgrades:
			continue
		
		# Needs prerequisite
		if needs != "" and not needs.begins_with("!") and needs not in acquired_upgrades:
			continue
		
		# "!" exclusive logic
		if needs.begins_with("!"):
			var target = needs.substr(1, needs.length())
			if target in acquired_upgrades:
				continue
		
		result.append(u)
	return result
