extends Node2D

const elements = {
	'mushroom': ['mushrooms_corner.png'],
	'wood': ['pine.png', 'tree.png'],
	'stone': ['rock.png'],
	'food': ['bush.png']
}
var positions = {}

func _ready():
	set_network_master(1)

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
		var position = Vector2(0, 0)
		
		while (position.x < 640 and position.y < 640)\
		  or (position.x > Global.MAP_SIZE - 640 and position.y > Global.MAP_SIZE - 640)\
		  or positions.has(position)\
		  or $tiles.get_cellv($tiles.world_to_map(position)) != -1:
			position = Vector2(randi() % Global.MAP_SIZE, randi() % Global.MAP_SIZE)
			position = get_position_on_tilemap(position)
		
		positions[position] = true
		spawn_collectable(elements.keys()[i % len(elements)], position)

func spawn_collectable(name, position):
	var collectable = preload("res://collectables/Collectable.tscn").instance()
	collectable.position = position
	collectable.item_name = name
	collectable.set_texture(elements[name][randi() % elements[name].size()])
	if name == "wood":
		# trees should get a bit more shadow
		var sprite = collectable.get_node("Area2D/Sprite")
		sprite.material = sprite.material.duplicate()
		sprite.material.set_shader_param("height", 2)
	add_child(collectable)
