extends RigidBody2D

var direction: Vector2
var owned_by: Node2D
const speed = 500
const damage = 1
var good_team: bool

#puppet var override_position: Vector2
#puppet var override_rotation: float
#puppet var override_angular_velocity: float
#puppet var override_linear_velocity: Vector2
#puppet var has_overrides = false

func _ready():
	# spawn outside our owner
	position = position + direction * 50
	
	# accelerate in direction of shooting
	rotation = direction.angle()
	apply_central_impulse(direction * speed)
	
	# wait for a bit then kill the projectile
	if is_network_master():
		yield(get_tree().create_timer(2), "timeout")
		rpc("kill")

remotesync func kill():
	queue_free()

func _integrate_forces(state: Physics2DDirectBodyState):
	if is_network_master():
		#rset_unreliable("override_position", state.transform.get_origin())
		#rset_unreliable("override_rotation", state.transform.get_rotation())
		#rset_unreliable("override_angular_velocity", state.angular_velocity)
		#rset_unreliable("override_linear_velocity", state.linear_velocity)
		#rset_unreliable("has_overrides", true)
		
		for i in range(state.get_contact_count()):
			var body = state.get_contact_collider_object(i)
			if body and body != owned_by:				
				if body.is_in_group("players"):
					body.rpc("take_damage", 80)
					rpc("explode")
				if body.is_in_group("buildings"):
					if body.good_team != good_team:
						body.rpc("take_damage", damage)
					rpc("explode")
				
	#elif has_overrides:
	#	has_overrides = false
	#	state.transform = Transform2D(override_rotation, override_position)
	#	state.angular_velocity = override_angular_velocity
	#	state.linear_velocity = override_linear_velocity

remotesync func explode():
	var particles = preload("res://projectile/Hit_Particle.tscn").instance()
	particles.position = position
	particles.get_node("Particles2D").emitting = true
	get_parent().add_child(particles)
	queue_free()
