extends "res://buildings/building.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const fence_hp = 40
const fence_costs = [1]
const fence_material = ["wood"]

# Called when the node enters the scene tree for the first time.
func _ready():
	hp = fence_hp
	costs = fence_costs
	needed_material = fence_material


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
