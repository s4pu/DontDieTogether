extends Area2D

export (bool) var good_team
var inventary = Global.EMPTY_INVENTORY.duplicate()

signal base_entered
signal base_exited

func _ready():
	var padding = Vector2(300, 300)
	position = padding if good_team else Vector2(Global.MAP_SIZE, Global.MAP_SIZE) - padding

func _on_Base_body_entered(body):
	if body.is_in_group("players") && \
		  body.is_network_master() && \
		  body.good_team == good_team:
		unload_inventary(body.inventory)
		body.clear_inventory()
		
		emit_signal("base_entered")

func unload_inventary(player_inventary):
	for item in Global.RESOURCES:
		inventary[item] += player_inventary[item]


func _on_Base_body_exited(body):
	if body.is_in_group("players") && \
		  body.is_network_master() && \
		  body.good_team == good_team:
		emit_signal("base_exited")
