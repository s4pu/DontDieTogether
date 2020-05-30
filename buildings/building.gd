extends StaticBody2D
signal select_building
signal deselect_building

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
	
func destroy():
	queue_free()

func _on_Area2D_mouse_entered():
	emit_signal("select_building", $".")


func _on_Area2D_mouse_exited():
	emit_signal("deselect_building")
