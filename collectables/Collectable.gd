extends Node2D

var item_name
var texture setget set_texture

func _ready():
	set_network_master(1)

func _on_Area2D_body_entered(body):
	if body.is_in_group("players") \
	  and body.is_network_master() \
	  and body.behaviour().can_collect():
		body.collect(self)
		rpc("die")
	
	if body.is_in_group("projectiles"):
		body.rpc("explode")

func set_texture(path):
	texture = path
	$Area2D/Sprite.texture = load("collectables/" + path)

remotesync func die():
	queue_free()
