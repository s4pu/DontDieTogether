extends Node2D

const map_size = 6000

# Called when the node enters the scene tree for the first time.
func _ready():
	set_network_master(1)
#	if is_network_master():0
#		spawn()	

func spawn():
	var num_elem = 500
	var rng = RandomNumberGenerator.new()
	
	var elements = {
		0: 'mushroom',
		1: 'wood',
		2: 'stone',
		3: 'food'
	}
	
	for i in num_elem:
		var pos = Vector2(randi() % map_size, randi() % map_size)
		spawn_collectable(elements[i % len(elements)], pos)
		
		
func spawn_collectable(name, position):
	var collectable = preload("res://collectables/Collectable.tscn").instance()
	collectable.position = position
	collectable.item_name = name
	add_child(collectable)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
