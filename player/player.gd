extends KinematicBody2D
class_name Player

var id
var color: Color setget set_color
var selected_building
const speed = 200
var inventary = {}

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
			move_and_collide(Vector2(0, -speed * dt))
		if Input.is_action_pressed("ui_down"):
			move_and_collide(Vector2(0, speed * dt))
		if Input.is_action_pressed("ui_left"):
			move_and_collide(Vector2(-speed * dt, 0))
		if Input.is_action_pressed("ui_right"):
			move_and_collide(Vector2(speed * dt, 0))
		if Input.is_action_just_pressed("ui_accept"):
			rpc("spawn_building", position)
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			var direction = -(position - get_viewport().get_mouse_position()).normalized()
			rpc("spawn_projectile", position, direction, Uuid.v4())
		if Input.is_mouse_button_pressed(BUTTON_RIGHT) && selected_building:
			selected_building.destroy()
			selected_building = null
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
	get_parent().add_child(projectile)
	return projectile

remotesync func spawn_building(position):
	var building = preload("res://buildings/building.tscn").instance()
	building.position = position
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
	$"../Inventary".update_inventary(inventary)
	
	
	
