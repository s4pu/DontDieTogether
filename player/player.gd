extends KinematicBody2D
class_name Player

var id
var color: Color setget set_color
var selected_building
const speed = 200
var inventary = {}
var good_team = true

func _ready():
	rset_config("position", MultiplayerAPI.RPC_MODE_REMOTESYNC)
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
		if Input.is_action_pressed("ui_up"):
# warning-ignore:return_value_discarded
			move_and_collide(Vector2(0, -speed * dt))
		if Input.is_action_pressed("ui_down"):
# warning-ignore:return_value_discarded
			move_and_collide(Vector2(0, speed * dt))
		if Input.is_action_pressed("ui_left"):
# warning-ignore:return_value_discarded
			move_and_collide(Vector2(-speed * dt, 0))
		if Input.is_action_pressed("ui_right"):
# warning-ignore:return_value_discarded
			move_and_collide(Vector2(speed * dt, 0))
		if Input.is_action_just_pressed("ui_buildWall"):
			rpc("spawn_wall", position)
		if Input.is_action_just_pressed("ui_buildFence"):
			rpc("spawn_fence", position)
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			var direction = -(position - get_viewport().get_mouse_position()).normalized()
			rpc("spawn_projectile", position, direction, Uuid.v4())
		if (Input.is_mouse_button_pressed(BUTTON_RIGHT) && selected_building): 
		#&& (selected_building.good_team == good_team)):
			if (selected_building.good_team == good_team):
				selected_building.destroy()
				selected_building = null
		if Input.is_action_just_pressed("ui_changeteam"): # for debugging purpose
			good_team = not good_team
		rset("position", position)


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
	var x = position[0]
	var y = position[1]
	var x_result = round((x-32)/64)*64 + 32
	var y_result = round((y-32)/64)*64 + 32
	return Vector2(x_result, y_result)

func spawn_building(building, position):
	building._ready()
	if inventary.has(building.needed_material) && inventary[building.needed_material] >= building.costs:
		decrease_inventary(building.needed_material, building.costs)
		building.good_team = good_team
		building.position = get_position_on_tilemap(position)
		get_parent().add_child(building)
		building.connect("select_building", self, "select_building")
		building.connect("deselect_building", self, "deselect_building")
	
remotesync func spawn_wall(position):
	var building = preload("res://buildings/wall.tscn").instance()
	spawn_building(building, position)
		
remotesync func spawn_fence(position):
	var building = preload("res://buildings/fence.tscn").instance()
	spawn_building(building, position)

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

func decrease_inventary(material, costs):
	inventary[material] = inventary[material] - costs
	update_inventary()
