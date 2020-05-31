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

var current_manifestation setget set_manifestation
var last_shot_time = 0
remotesync var hitpoints
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
		if Input.is_mouse_button_pressed(BUTTON_LEFT) and can_shoot():
			last_shot_time = OS.get_ticks_msec()
			var direction = -(position - get_global_mouse_position()).normalized()
			rpc("spawn_projectile", position, direction, Uuid.v4())
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
			if collision and collision.get_collider().is_in_group("buildings"):
				take_damage(collision.get_collider().damage_on_contact)
			$particles_steps.rset('rotation', old_position.angle_to_point(position))
		$particles_steps.rset('emitting', did_move)

const WEAPON_COOLDOWN = 400 # milliseconds
func can_shoot():
	return OS.get_ticks_msec() - last_shot_time > WEAPON_COOLDOWN

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

func set_manifestation(name):
	var manifestation = Global.ANIMALS[name]
	var health_percentage = hitpoints / manifestation["hitpoints"] if hitpoints != null else 1
	
	$sprite.texture = load("res://player/" + manifestation[good_team] + ".png")
	hitpoints = ceil(manifestation["hitpoints"] * health_percentage)
	speed = manifestation["speed"]
	current_manifestation = name
	
	emit_signal("manifestation_changed", name)

remotesync func spawn_projectile(position, direction, name):
	var projectile = preload("res://examples/physics_projectile/physics_projectile.tscn").instance()
	projectile.set_network_master(1)
	projectile.name = name
	projectile.position = position
	projectile.direction = direction
	projectile.owned_by = self
	projectile.good_team = good_team
	get_parent().add_child(projectile)
	return projectile
	
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
	hitpoints -= points
	emit_signal("health_changed", hitpoints / Global.ANIMALS[current_manifestation]["hitpoints"])
	
	if hitpoints <= 0:
		hide()
		rset("dead", true)

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
		update_inventory()

func update_inventory():
	if is_network_master() && behaviour().can_collect():
		$"../../../../../Inventory".update_inventory(inventory)

func clear_inventory():
	if is_network_master() && behaviour().can_collect():
		inventory = Global.EMPTY_INVENTORY.duplicate()
		update_inventory()

func get_base():
	return $"../GoodBase" if good_team else $"../EvilBase"

func decrease_base_inventory(materials, costs):
	if is_network_master() && behaviour().can_build():
		for i in range(len(materials)):
			get_base().rpc("increment_item", materials[i], -costs[i])
	
func base_inventory_has_needed_materials(materials, costs):
	var has_enough_material = false
	for i in range(len(materials)):
		if get_base().inventory.has(materials[i]):
			if get_base().inventory[materials[i]] >= costs[i]:
				has_enough_material = true
			else:
				has_enough_material = false
	return has_enough_material
