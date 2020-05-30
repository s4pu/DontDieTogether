extends Node2D

const map_size = 6000

const elements = {
	'mushroom': ['mushrooms_corner.png'],
	'wood': ['pine.png', 'tree.png'],
	'stone': ['rock.png'],
	'food': ['bush.png']
}
	
# Called when the node enters the scene tree for the first time.
func _ready():
	set_network_master(1)
#	if is_network_master():0
#		spawn()	

func get_position_on_tilemap(position):
	# 1, 1 --> 32, 32
	# 33, 33 --> 32, 32
	# 65, 65 --> 96, 96
	var x = position[0]
	var y = position[1]
	var x_result = round((x-32)/64)*64 + 32
	var y_result = round((y-32)/64)*64 + 32
	return Vector2(x_result, y_result)

func spawn():
	var num_elem = 500
	
	for i in num_elem:
		var pos = Vector2(randi() % map_size, randi() % map_size)
		pos = get_position_on_tilemap(pos)
		spawn_collectable(elements.keys()[i % len(elements)], pos)
		

func spawn_collectable(name, position):
	var collectable = preload("res://collectables/Collectable.tscn").instance()
	collectable.position = position
	collectable.item_name = name
	collectable.set_texture(elements[name][randi() % elements[name].size()])
	add_child(collectable)

