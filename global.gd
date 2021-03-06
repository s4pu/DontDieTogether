extends Node

# remember what team won before we change to the gameover scene
var winning_team = null

const MAP_SIZE = 3000
const RESOURCES = ["wood", "food", "mushroom", "stone"]
const EMPTY_INVENTORY = {
	"wood": 0,
	"food": 0,
	"stone": 0,
	"mushroom": 0
}

var ANIMALS = {
	"default": {
		true: "koala",
		false: "sloth",
		"hitpoints": 100,
		"speed": 100,
		"behaviour": AnimalBehaviour,
		"building_damage": 0,
		"player_damage": 0,
	},
	#"cook": {
	#	true: "cow",
	#	false: "chicken",
	#	"hitpoints": 100,
	#	"speed": 150,
	#	"behaviour": CookBehaviour,
	#	"building_damage": 0,
	#	"player_damage": 0,
	#},
	"fighter": {
		true: "wolf",
		false: "crocodile",
		"hitpoints": 300,
		"speed": 200,
		"behaviour": FighterBehaviour,
		"building_damage": 5,
		"player_damage": 40,
	},
	"healer": {
		true: "bunny",
		false: "snake",
		"hitpoints": 60,
		"speed": 150,
		"behaviour": HealerBehaviour,
		"building_damage": 0,
		"player_damage": -60,
	},
	"siege": {
		true: "ram",
		false: "rhino",
		"hitpoints": 1000,
		"speed": 80,
		"behaviour": SiegeBehaviour,
		"building_damage": 30,
		"player_damage": 20,
	},
	"collector": {
		true: "pig",
		false: "monkey",
		"hitpoints": 70,
		"speed": 300,
		"behaviour": CollectingBehaviour,
		"building_damage": 0,
		"player_damage": 0,
	},
	"builder": {
		true: "beaver",
		false: "mole",
		"hitpoints": 100,
		"speed": 90,
		"behaviour": BuildingBehaviour,
		"building_damage": 0,
		"player_damage": 0,
	},
	"ranged": {
		true: "giraffe",
		false: "penguin",
		"hitpoints": 60,
		"speed": 150,
		"behaviour": RangedBehaviour,
		"player_damage": 50,
		"building_damage": 3,
	}
}

class AnimalBehaviour:
	var player
	
	func can_build():
		return false
	func can_collect():
		return false
	func can_melee_fight():
		return false
	func can_heal():
		return false
	func can_ranged_fight():
		return false
	func can_cook():
		return false
	func can_siege():
		return false
	func can_shoot():
		return false
	func after_shoot():
		pass
	func weapon_cooldown():
		return 400

class BuildingBehaviour extends AnimalBehaviour:
	func can_build():
		return true

class SiegeBehaviour extends AnimalBehaviour:
	func can_siege():
		return true
	func can_shoot():
		return false
	func weapon_cooldown():
		return 1700

class CollectingBehaviour extends AnimalBehaviour:
	func can_collect():
		return true

class CookBehaviour extends AnimalBehaviour:
	func can_cook():
		return true

class FighterBehaviour extends AnimalBehaviour:
	func can_melee_fight():
		return true
	func weapon_cooldown():
		return 1000

class HealerBehaviour extends AnimalBehaviour:
	func can_heal():
		return true
	func can_shoot():
		return player.get_base().inventory['mushroom'] > 0
	func after_shoot():
		player.decrease_base_inventory(["mushroom"], [1])

class RangedBehaviour extends AnimalBehaviour:
	func can_ranged_fight():
		return true
	func can_shoot():
		return true
