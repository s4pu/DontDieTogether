extends StaticBody2D

signal game_over

const MAX_HP = 200
var hp = MAX_HP setget set_hitpoints
var good_team

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_hitpoints(num):
	hp = num
	$Health.value = num / float(MAX_HP)

func destroy():
	queue_free()
	emit_signal("game_over")

remotesync func take_damage(damage):
	set_hitpoints(hp - damage)
	
	if (hp <= 0):
		destroy()
