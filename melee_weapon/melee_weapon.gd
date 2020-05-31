extends KinematicBody2D


var owned_by: Node2D
const speed = 0
const damage = 5
var good_team: bool
var direction = 0
var angle = 0
var relative_position = Vector2(20,0)
var radius = 50
var rotate_speed = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

remotesync func kill():
	queue_free()

#func _integrate_forces(state: Physics2DDirectBodyState):
#	var xform = state.get_transform().rotated(angle)
#	#var offset = Vector2(sin(angle), cos(angle)) * radius
#	position = owned_by.position + relative_position
	
#	state.set_transform(xform)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#angle += 0.001
	#relative_position[0] -= 10
	#relative_position[1] = abs(20 - relative_position[0])
	angle += rotate_speed * delta
	var offset = Vector2(sin(angle), cos(angle)) * radius
	position = owned_by.position + offset
	look_at(owned_by.position)

func _on_Timer_timeout():
	rpc("kill")

func _on_Area2D_body_entered(body):
	if body.good_team != good_team:
		body.rpc("take_damage", 5)
