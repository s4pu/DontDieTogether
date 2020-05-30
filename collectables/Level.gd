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

func spawn():
	var num_elem = 500

	
	for i in num_elem:
		var pos = Vector2(randi() % map_size, randi() % map_size)
		spawn_collectable(elements.keys()[i % len(elements)], pos)
		

func spawn_collectable(name, position):
	var collectable = preload("res://collectables/Collectable.tscn").instance()
	collectable.position = position
	collectable.item_name = name
	collectable.set_texture(elements[name][randi() % elements[name].size()])
	add_child(collectable)

