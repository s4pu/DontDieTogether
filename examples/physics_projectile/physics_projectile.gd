extends RigidBody2D

var direction: Vector2
var owned_by: Node2D
const speed = 500
var player_damage: int
var building_damage: int
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

remotesync func kill():
	queue_free()

func _integrate_forces(state: Physics2DDirectBodyState):
	if is_network_master():
		for i in range(state.get_contact_count()):
			var body = state.get_contact_collider_object(i)
			if body and body != owned_by:
				if body.is_in_group("players"):
					if (body.good_team != good_team and player_damage > 0)\
					  or (body.good_team == good_team and player_damage < 0):
						body.rpc("take_damage", player_damage)
					rpc("explode")
				if body.is_in_group("buildings"):
					if body.good_team != good_team:
						body.rpc("take_damage", building_damage)
					rpc("explode")
				if body.is_in_group("artefact"):
					if body.good_team != good_team:
						body.rpc("take_damage", building_damage)
					rpc("explode")

remotesync func explode():
	var particles = preload("res://projectile/Hit_Particle.tscn").instance()
	particles.position = position
	particles.get_node("Particles2D").emitting = true
	get_parent().add_child(particles)
	queue_free()

func _on_Timer_timeout():
	rpc("kill")
