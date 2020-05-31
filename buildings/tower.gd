extends "res://buildings/building.gd"


const tower_hp = 150
const tower_costs = [20, 20]
const tower_material = ["stone", "wood"]
const tower_damage = 30
const WEAPON_COOLDOWN = 1000 # milliseconds

var last_shot_time = 0
var shooting = false
var target_list = []

# Called when the node enters the scene tree for the first time.
func _ready():
	set_network_master(1)
	hp = tower_hp
	costs = tower_costs
	needed_material = tower_material
	
func _process(_dt):
	if can_shoot() and is_network_master():
		target_attk()

func can_shoot():
	return OS.get_ticks_msec() - last_shot_time > WEAPON_COOLDOWN
	
func target_attk():
	if len(target_list) > 0:
		var target = target_list[0]
		var target_dir = (target.global_position - global_position).normalized()
		last_shot_time = OS.get_ticks_msec()
		rpc("spawn_projectile", position, target_dir, Uuid.v4())

remotesync func spawn_projectile(position, direction, name):
	var projectile = preload("res://examples/physics_projectile/physics_projectile.tscn").instance()
	projectile.set_network_master(1)
	projectile.name = name
	projectile.position = position
	projectile.direction = direction
	projectile.owned_by = self
	projectile.good_team = good_team
	projectile.player_damage = tower_damage
	get_parent().add_child(projectile)
	return projectile
	
func _on_Area2D2_body_entered(body):
	if body.is_in_group("players") and body.good_team != good_team:
		target_list.append(body)

func _on_Area2D2_body_exited(body):
	target_list.erase(body)
