extends CanvasLayer

signal upgrade_selected(upgrade)

var current_upgrades := []

func _ready():
	hide()


func show_upgrades(upgrades: Array):
	print(upgrades)

	current_upgrades = upgrades
	show()

	var buttons = get_node("HBoxContainer").get_children()
	for i in range(buttons.size()):
		var button = buttons[i]
		var upgrade = upgrades[i]
		
		if button.pressed.is_connected(_on_upgrade_pressed):
			button.pressed.disconnect(_on_upgrade_pressed)
		
		button.text = "%s\n%s" % [upgrade["name"], upgrade["description"]]
		button.pressed.connect(_on_upgrade_pressed.bind(upgrade))

func _on_upgrade_pressed(upgrade):
	emit_signal("upgrade_selected", upgrade)
	hide()
