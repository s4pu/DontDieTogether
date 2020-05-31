extends "res://buildings/building.gd"

const fence_hp = 40
const fence_costs = [1]
const fence_material = ["wood"]

func _ready():
	max_hp = fence_hp
	hp = fence_hp
	costs = fence_costs
	needed_material = fence_material
