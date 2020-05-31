extends StaticBody2D

var hp = 100
var good_team

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func destroy():
	queue_free()

remotesync func take_damage(damage):
	hp -= damage
	if (hp <= 0):
		destroy()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
