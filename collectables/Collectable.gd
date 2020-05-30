extends Node2D

var item_name
var icon

func _ready():
	set_network_master(1)
	
func configure(item_name, icon):
	item_name = item_name
	icon = icon

func _on_Area2D_body_entered(body):
	if body.is_in_group("players"):
		body.collect(self)
		rpc("die")

remotesync func die():
	queue_free()
