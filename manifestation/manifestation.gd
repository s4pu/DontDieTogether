extends Node2D

export (String) var manifestation_name = "default"

func _ready():
	pass

func _process(delta):
	$mole.position.y = -20 + sin(OS.get_system_time_msecs() * 0.003) * 8

func _on_manifestation_body_entered(body):
	if body.is_network_master() and body.is_in_group("players"):
		body.rpc("assume_manifestation", manifestation_name)
		rpc("remove")

remotesync func remove():
	queue_free()
