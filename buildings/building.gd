extends StaticBody2D
signal select_building
signal deselect_building

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var good_team
var hp = 50
var costs = 0
var needed_material = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func destroy():
	queue_free()

remotesync func take_damage(damage):
	hp -= damage
	if (hp <= 0):
		destroy()

func _on_Area2D_mouse_entered():
	emit_signal("select_building", $".")


func _on_Area2D_mouse_exited():
	emit_signal("deselect_building")
