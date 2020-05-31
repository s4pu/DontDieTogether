extends Area2D

export (bool) var good_team
var inventory = {
	"wood": 20,
	"stone": 20,
	"food": 20,
	"mushroom": 20,
}

signal base_entered
signal base_exited

func _ready():
	var padding = Vector2(300, 300)
	position = padding if good_team else Vector2(Global.MAP_SIZE, Global.MAP_SIZE) - padding

func _on_Base_body_entered(body):
	if body.is_in_group("players") && \
		  body.is_network_master() && \
		  body.good_team == good_team:
		unload_inventory(body.inventory)
		body.clear_player_inventory()
		body.update_base_inventory()

func unload_inventory(player_inventory):
	for item in Global.RESOURCES:
		rpc("increment_item", item, player_inventory[item])
		emit_signal("base_entered")

remotesync func increment_item(name, amount):
	inventory[name] += amount

func _on_Base_body_exited(body):
	if body.is_in_group("players") && \
		  body.is_network_master() && \
		  body.good_team == good_team:
		emit_signal("base_exited")
