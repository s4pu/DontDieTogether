extends "res://buildings/building.gd"

const spikes_hp = 40
const spikes_costs = 3
const spikes_material = "wood"
const spikes_damage_on_contact = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	hp = spikes_hp
	costs = spikes_costs
	needed_material = spikes_material
	damage_on_contact = spikes_damage_on_contact


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
