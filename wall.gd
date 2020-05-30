extends "res://buildings/building.gd"


const wall_hp = 60
const wall_costs = 1
const wall_material = 'stone'

# Called when the node enters the scene tree for the first time.
func _ready():
	hp = wall_hp
	costs = wall_costs
	needed_material = wall_material


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
