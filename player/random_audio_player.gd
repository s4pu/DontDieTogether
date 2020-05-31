extends Node

onready var sounds = get_children()
var rng = RandomNumberGenerator.new()

remotesync func play_random():
	var index = rng.randi_range(0, sounds.size() - 1)
	sounds[index].play()
