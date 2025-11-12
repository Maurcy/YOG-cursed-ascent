extends Node2D

@onready var upgrades_manager: Node = $UpgradesManager

func _on_button_pressed() -> void:
	upgrades_manager.offer_upgrades()
