extends Node2D

onready var sounds = get_children()
var rng = RandomNumberGenerator.new()

remotesync func play_random():
	var players = get_tree().get_nodes_in_group("players")
	var success = false
	var cam_pos
	for player in players:
		if player.is_network_master():
			success = true
			cam_pos = player.global_position
			
	if not success:
		print(":(")
		return
	
	#var cam_pos = get_viewport().get_camera().get_global_pos()
	if global_position.distance_to(cam_pos) > 600:
		return
	var index = rng.randi_range(0, sounds.size() - 1)
	sounds[index].play()
