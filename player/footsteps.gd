extends Node

var last_footstep_timestamp = OS.get_ticks_msec()
onready var footsteps = get_children()
var rng = RandomNumberGenerator.new()

func play_if_necessary():
	var speed = get_parent().speed
	var footstep_interval_msecs = 50000 / speed
	var now = OS.get_ticks_msec()
	var last_footstep_duration = now - last_footstep_timestamp
	if last_footstep_duration >= footstep_interval_msecs:
		last_footstep_timestamp = now
		var index = rng.randi_range(0, footsteps.size() - 1)
		var random_footstep = footsteps[index]
		if not random_footstep.playing:
			random_footstep.play()
