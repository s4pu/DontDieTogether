extends Node2D

func _ready():
	pass

func _process(delta):
	$mole.position.y = -50 + sin(OS.get_system_time_msecs() * 0.003) * 8
