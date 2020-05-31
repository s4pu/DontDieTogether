extends KinematicBody2D
class_name Player

signal health_changed(percentage)
signal manifestation_changed(name)

var id
var selected_building
var previous_buildings_position = Vector2(0,0)
var speed = 200
var good_team setget set_team
var inventory = Global.EMPTY_INVENTORY.duplicate()

const charge_back_speed = 150
const charge_forward_speed = 1500
const charge_back_duration = 400	# milliseconds
const charge_forward_duration = 100	# milliseconds
const charging_damage = 50
var charge_start_time
var charge_direction: Vector2
var charging_status = 0 	#  0) no charge  1) back   2) forward

var current_manifestation setget set_manifestation
var last_shot_time = 0
var last_hit_time = 0
remotesync var hitpoints setget set_hitpoints
remotesync var dead = false

func _ready():
	rset_config("position", MultiplayerAPI.RPC_MODE_REMOTE)
	set_process(true)
	randomize()
	
	assume_manifestation("default")
	
	position = $"../GoodBase".position if good_team else $"../EvilBase".position
	#position = Vector2(rand_range(0, get_viewport_rect().size.x), rand_range(0, get_viewport_rect().size.y))
	
	$Camera2D.current = is_network_master()
	
	$particles_steps.rset_config("emitting", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	$particles_steps.rset_config("rotation", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	
	#get_tree().get_root().get_node("game/Player_Inventory").connect("update_inventory", self, update_player_inventory())

func get_sync_state():
	# place all synced properties in here
	var properties = ['color', "hitpoints", "current_manifestation"]
	
	var state = {}
	for p in properties:
		state[p] = get(p)
	return state

func _process(dt):
	if is_network_master() and not dead:
		var did_move = false
		var old_position = position
		var collision
		
		if charging_status == 1:
			collision = move_and_collide(- charge_direction * charge_back_speed * dt)
			did_move = true
			if OS.get_ticks_msec() - charge_start_time > charge_back_duration:
				charging_status = 2
		elif charging_status == 2:
			collision = move_and_collide(charge_direction * charge_forward_speed * dt)
			did_move = true
			if OS.get_ticks_msec() - charge_start_time > charge_forward_duration + charge_back_duration:
				charging_status = 0
		else:
			if Input.is_action_pressed("ui_up"):
	# warning-ignore:return_value_discarded
				collision = move_and_collide(Vector2(0, -speed * dt))
				did_move = true
			if Input.is_action_pressed("ui_down"):
	# warning-ignore:return_value_discarded
				collision = move_and_collide(Vector2(0, speed * dt))
				did_move = true
			if Input.is_action_pressed("ui_left"):
	# warning-ignore:return_value_discarded
				collision = move_and_collide(Vector2(-speed * dt, 0))
				did_move = true
			if Input.is_action_pressed("ui_right"):
	# warning-ignore:return_value_discarded
				collision = move_and_collide(Vector2(speed * dt, 0))
				did_move = true
			if Input.is_action_just_pressed("ui_buildWall"):
				rpc("spawn_wall", position)
			if Input.is_action_just_pressed("ui_buildFence"):
				rpc("spawn_fence", position)
			if Input.is_action_just_pressed("ui_buildTower"):
				rpc("spawn_tower", position)
			if Input.is_action_just_pressed("ui_buildSpikes"):
				rpc("spawn_spikes", position)
			if Input.is_mouse_button_pressed(BUTTON_LEFT) \
			  and (behaviour().can_ranged_fight() or behaviour().can_heal() or behaviour().can_siege())\
			  and can_shoot():
				last_shot_time = OS.get_ticks_msec()
				var direction = -(position - get_global_mouse_position()).normalized()
				if behaviour().can_siege():
					charging_status = 1
					charge_start_time = OS.get_ticks_msec()
					charge_direction = direction
					collision = move_and_collide(- direction * charge_back_speed * dt)
					did_move = true
				else:
					rpc("spawn_projectile", position, direction, Uuid.v4())
			if Input.is_mouse_button_pressed(BUTTON_LEFT) and can_hit() and behaviour().can_melee_fight():
				last_hit_time = OS.get_ticks_msec()
				var direction = -(position - get_global_mouse_position()).normalized()
				rpc("hit", position, direction, Uuid.v4())
			if (Input.is_mouse_button_pressed(BUTTON_RIGHT) && selected_building):
				if (selected_building.good_team == good_team):
					selected_building.destroy()
					selected_building = null
			if Input.is_action_just_pressed("ui_changeteam"): # for debugging purpose
				set_team(not good_team)
			if Input.is_action_just_pressed("free_manifestation"):
				rpc("drop_manifestation", position)
		
		if did_move:
			rset("position", position)
			if collision:
				var collider = collision.get_collider()
				if collider.is_in_group("buildings"):
					if charging_status == 2:
						building_collide(collision)
						charging_status = 0
					else:
						rpc("take_damage", collision.get_collider().damage_on_contact)
			$particles_steps.rset('rotation', old_position.angle_to_point(position))
		$particles_steps.rset('emitting', did_move)

const WEAPON_COOLDOWN = 400 # milliseconds
func can_shoot():
	return OS.get_ticks_msec() - last_shot_time > WEAPON_COOLDOWN

const MELEE_WEAPON_COOLDOWN = 1000 # milliseconds
func can_hit():
	return OS.get_ticks_msec() - last_hit_time > MELEE_WEAPON_COOLDOWN

remotesync func drop_manifestation(position):
	var pickup = preload("res://manifestation/manifestation.tscn").instance()
	pickup.position = position
	pickup.manifestation_name = current_manifestation
	pickup.dropped_by = id
	get_parent().add_child(pickup)
	
	assume_manifestation("default")

func set_team(team):
	good_team = team
	var color = Color.royalblue if good_team else Color.indianred
	$sprite.material = $sprite.material.duplicate()
	$sprite.material.set_shader_param("outline_color", color)

remotesync func assume_manifestation(manifestation_name):
	# TODO: spawn effect showing the change
	set_manifestation(manifestation_name)

func set_hitpoints(num):
	hitpoints = num
	$Health.value = 1 if num == null or current_manifestation == null else num / Global.ANIMALS[current_manifestation]['hitpoints']

func set_manifestation(name):
	var manifestation = Global.ANIMALS[name]
	var health_percentage = hitpoints / manifestation["hitpoints"] if hitpoints != null else 1
	
	$sprite.texture = load("res://player/" + manifestation[good_team] + ".png")
	set_hitpoints(ceil(manifestation["hitpoints"] * health_percentage))
	speed = manifestation["speed"]
	current_manifestation = name
	set_inventory_visibility()
	get_building_menu().set_visibility(behaviour().can_build())
	
	emit_signal("manifestation_changed", name)

func set_inventory_visibility():
	var collector = behaviour().can_collect()
	var builder = behaviour().can_build()
	var healer = behaviour().can_heal()
	var cook = behaviour().can_cook()
	get_player_inventory().set_visibility(collector, collector, collector)
	get_base_inventory().set_visibility(builder, healer, cook)

func get_player_inventory():
	return $"../../../../../Player_Inventory"
	
func get_base_inventory():
	return $"../../../../../Base_Inventory"

func get_building_menu():
	return $"../../../../../buildingSelection"

remotesync func spawn_projectile(position, direction, name):
	var projectile = preload("res://examples/physics_projectile/physics_projectile.tscn").instance()
	projectile.set_network_master(1)
	projectile.name = name
	projectile.position = position
	projectile.player_damage = Global.ANIMALS[current_manifestation]["player_damage"]
	projectile.building_damage = Global.ANIMALS[current_manifestation]["building_damage"]
	projectile.direction = direction
	projectile.owned_by = self
	projectile.good_team = good_team
	get_parent().add_child(projectile)
	return projectile
	
remotesync func hit(position, direction, name):
	var weapon = preload("res://melee_weapon/melee_weapon.tscn").instance()
	weapon.set_network_master(1)
	weapon.name = name
	weapon.position = position
	weapon.owned_by = self
	weapon.good_team = good_team
	get_parent().add_child(weapon)
	#weapon.swing()
	
func get_position_on_tilemap(position):
	var x = position[0]
	var y = position[1]
	var x_result = round((x-32)/64)*64 + 32
	var y_result = round((y-32)/64)*64 + 32
	return Vector2(x_result, y_result)

func get_position_after_building(me, building):
	var direction = me - building
	if direction.length() == 0:
		direction = previous_buildings_position - building
	var further = direction.normalized() * 95
	return get_position_on_tilemap(me - further)

func spawn_building(building, position):
	building._ready()
	if behaviour().can_build() &&\
	  base_inventory_has_needed_materials(building.needed_material, building.costs):
		decrease_base_inventory(building.needed_material, building.costs)
		building.good_team = good_team
		building.position = get_position_on_tilemap(position)
		self.position = get_position_after_building(position, building.position)
		previous_buildings_position = building.position
		var color = Color.royalblue if building.good_team else Color.indianred
		building.get_node("Sprite").material = building.get_node("Sprite").material.duplicate()
		building.get_node("Sprite").material.set_shader_param("outline_color", color)
		get_parent().add_child(building)
		building.connect("select_building", self, "select_building")
		building.connect("deselect_building", self, "deselect_building")
	
remotesync func spawn_wall(position):
	if behaviour().can_build():
		var building = preload("res://buildings/wall.tscn").instance()
		spawn_building(building, position)

remotesync func spawn_fence(position):
	if behaviour().can_build():
		var building = preload("res://buildings/fence.tscn").instance()
		spawn_building(building, position)

remotesync func spawn_tower(position):
	if behaviour().can_build():
		var building = preload("res://buildings/tower.tscn").instance()
		spawn_building(building, position)

remotesync func spawn_spikes(position):
	if behaviour().can_build():
		var building = preload("res://buildings/spikes.tscn").instance()
		spawn_building(building, position)

remotesync func take_damage(points):
	var max_hitpoints = Global.ANIMALS[current_manifestation]["hitpoints"]
	set_hitpoints(hitpoints - points)
	if hitpoints > max_hitpoints:
		set_hitpoints(max_hitpoints)
	
	var percentage = hitpoints / max_hitpoints
	emit_signal("health_changed", percentage)
	
	if hitpoints <= 0:
		die()

func die():
	var particles = preload("res://player/Dying_Particle.tscn").instance()
	particles.position = position
	particles.get_node("Particles2D").emitting = true
	get_parent().add_child(particles)
	hide()
	
	dead = true
	yield(get_tree().create_timer(1), "timeout")
	position = Vector2(-8000, -8000)
	set_hitpoints(null)
	$Health.value = 1
	assume_manifestation("default")
	
	if is_network_master():
		yield(get_tree().create_timer(6), "timeout")
		rpc("respawn")

remotesync func respawn():
	position = get_base().position
	dead = false
	show()

func behaviour():
	return Global.ANIMALS[current_manifestation]["behaviour"].new()

func select_building(building):
	if behaviour().can_build():
		selected_building = building
	
func deselect_building():
	if behaviour().can_build():
		selected_building = null

func collect(collectable):
	if behaviour().can_collect():
		inventory[collectable.item_name] += 1
		update_player_inventory()

func update_player_inventory():
	if is_network_master() && behaviour().can_collect():
		get_player_inventory().update_inventory(inventory)

func update_base_inventory():
	if is_network_master():
		get_base_inventory().update_inventory(get_base().inventory)

func clear_player_inventory():
	if is_network_master() && behaviour().can_collect():
		inventory = Global.EMPTY_INVENTORY.duplicate()
		update_player_inventory()

func get_base():
	return $"../GoodBase" if good_team else $"../EvilBase"

func decrease_base_inventory(materials, costs):
	if is_network_master() && behaviour().can_build():
		for i in range(len(materials)):
			get_base().rpc("increment_item", materials[i], -costs[i])
		update_base_inventory()
	
func base_inventory_has_needed_materials(materials, costs):
	var has_enough_material = false
	for i in range(len(materials)):
		if get_base().inventory.has(materials[i]):
			if get_base().inventory[materials[i]] >= costs[i]:
				has_enough_material = true
			else:
				has_enough_material = false
	return has_enough_material
	
func building_collide(collision: KinematicCollision2D):
	var building = collision.get_collider()
	if building.good_team != good_team:
		building.rpc("take_damage", charging_damage)
	var particles = preload("res://buildings/Collision_Particle.tscn").instance()
	particles.position = collision.position
	particles.get_node("Particles2D").emitting = true
	get_parent().add_child(particles)
