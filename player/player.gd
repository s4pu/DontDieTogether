extends KinematicBody2D
class_name Player

var id
var color: Color setget set_color
var selected_building
const speed = 200
var inventary = {
	'mushroom': 0,
	'wood': 0,
	'stone': 0,
	'food': 0
}

var good_team = true
var last_shot_time = 0

func _ready():
	rset_config("position", MultiplayerAPI.RPC_MODE_REMOTE)
	set_process(true)
	randomize()
	position = Vector2(rand_range(0, get_viewport_rect().size.x), rand_range(0, get_viewport_rect().size.y))
		
	# pick our color, even though this will be called on all clients, everyone
	# else's random picks will be overriden by the first sync_state from the master
	set_color(Color.from_hsv(randf(), 1, 1))
	$Camera2D.current = is_network_master()
	

func get_sync_state():
	# place all synced properties in here
	var properties = ['color']
	
	var state = {}
	for p in properties:
		state[p] = get(p)
	return state

func _process(dt):
	if is_network_master():
		var did_move = false
		var old_position = position
		
		if Input.is_action_pressed("ui_up"):
# warning-ignore:return_value_discarded
			move_and_collide(Vector2(0, -speed * dt))
			did_move = true
		if Input.is_action_pressed("ui_down"):
# warning-ignore:return_value_discarded
			move_and_collide(Vector2(0, speed * dt))
			did_move = true
		if Input.is_action_pressed("ui_left"):
# warning-ignore:return_value_discarded
			move_and_collide(Vector2(-speed * dt, 0))
			did_move = true
		if Input.is_action_pressed("ui_right"):
# warning-ignore:return_value_discarded
			move_and_collide(Vector2(speed * dt, 0))
			did_move = true
		if Input.is_action_just_pressed("ui_accept"):
			rpc("spawn_building", position)
		if Input.is_mouse_button_pressed(BUTTON_LEFT) and can_shoot():
			last_shot_time = OS.get_ticks_msec()
			var direction = -(position - get_global_mouse_position()).normalized()
			rpc("spawn_projectile", position, direction, Uuid.v4())
		if (Input.is_mouse_button_pressed(BUTTON_RIGHT) && selected_building): 
		#&& (selected_building.good_team == good_team)):
			if (selected_building.good_team == good_team):
				selected_building.destroy()
				selected_building = null
		if Input.is_action_just_pressed("ui_changeteam"): # for debugging purpose
			good_team = not good_team
		
		if did_move:
			rset("position", position)
			$particles_steps.rotation = old_position.angle_to_point(position)
		$particles_steps.emitting = did_move

const WEAPON_COOLDOWN = 400 # milliseconds
func can_shoot():
	return OS.get_ticks_msec() - last_shot_time > WEAPON_COOLDOWN

func set_color(_color: Color):
	color = _color
	$sprite.modulate = color

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
	# 1, 1 --> 32, 32
	# 33, 33 --> 32, 32
	# 65, 65 --> 96, 96
	var x = position[0]
	var y = position[1]
	var x_result = round((x-32)/64)*64 + 32
	var y_result = round((y-32)/64)*64 + 32
	return Vector2(x_result, y_result)

remotesync func spawn_building(position):
	var building = preload("res://buildings/building.tscn").instance()
	building.good_team = good_team
	building.position = get_position_on_tilemap(position)
	get_parent().add_child(building)
	building.connect("select_building", self, "select_building")
	building.connect("deselect_building", self, "deselect_building")
	

remotesync func kill():
	hide()

func select_building(building):
	selected_building = building
	
func deselect_building():
	selected_building = null

func collect(collectable):
	if not inventary.has(collectable.item_name):
		inventary[collectable.item_name] = 1
	else:
		inventary[collectable.item_name] += 1
	update_inventary()

func update_inventary():
	if is_network_master():
		$"../../../Inventary".update_inventary(inventary)
	
	
	
