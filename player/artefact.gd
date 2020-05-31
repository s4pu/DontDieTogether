extends StaticBody2D

signal game_over

var hp = 200
var good_team

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func destroy():
	queue_free()
	emit_signal("game_over")

remotesync func take_damage(damage):
	hp -= damage
	if (hp <= 0):
		destroy()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
