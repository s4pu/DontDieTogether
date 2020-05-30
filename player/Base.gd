extends Area2D

export (bool) var good_team
var inventary = {
	"wood": 0,
	"food": 0,
	"stone": 0,
	"mushroom": 0
}

func _ready():
	var padding = Vector2(300, 300)
	position = padding if good_team else Vector2(Global.MAP_SIZE, Global.MAP_SIZE) - padding

func _on_Base_body_entered(body):
	if body.is_in_group("players") && \
		  body.is_network_master() && \
		  body.good_team == good_team:
		unload_inventary(body.inventary)
		body.clear_inventory()
		
func unload_inventary(player_inventary):
	for item in ["wood", "stone", "food", "mushroom"]:
		inventary[item] += player_inventary[item]
