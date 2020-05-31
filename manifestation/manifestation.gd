extends Node2D

export (String) var manifestation_name = "default" setget set_manifestation_name
var dropped_by: int

func _ready():
	pass

func _process(delta):
	$sprite.position.y = -20 + sin(OS.get_system_time_msecs() * 0.003) * 8

func _on_manifestation_body_entered(body):
	if body.is_network_master() and body.is_in_group("players") and body.id != dropped_by:
		body.rpc("assume_manifestation", manifestation_name)
		rpc("remove")

remotesync func remove():
	queue_free()

func set_manifestation_name(name):
	manifestation_name = name
	# TODO: always use the team of the client we're runnning on
	$sprite.texture = load("res://player/" + Global.ANIMALS[name][true] + ".png")
