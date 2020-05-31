extends Node

const MAP_SIZE = 6000
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
	},
	"cook": {
		true: "cow",
		false: "chicken",
		"hitpoints": 100,
		"speed": 150,
	},
	"fighter": {
		true: "wolf",
		false: "crocodile",
		"hitpoints": 150,
		"speed": 200,
	},
	"healer": {
		true: "bunny",
		false: "snake",
		"hitpoints": 60,
		"speed": 150,
	},
	"siege": {
		true: "ram",
		false: "rhino",
		"hitpoints": 100,
		"speed": 150,
	},
	"collector": {
		true: "pig",
		false: "monkey",
		"hitpoints": 70,
		"speed": 300,
		"behaviour": CollectingBehaviour,
	},
	"builder": {
		true: "beaver",
		false: "mole",
		"hitpoints": 100,
		"speed": 150,
		"behaviour": BuildingBehaviour,
	},
	"ranged": {
		true: "",
		false: "",
		"hitpoints": 100,
		"speed": 150,
	}
}

class AnimalBehaviour:
	func can_build():
		return false
	func can_collect():
		return false
	func can_melee_fight():
		return false
	func can_heal():
		return false
	func can_ranged_right():
		return false
	func can_cook():
		return false
	func can_siege():
		return false

class BuildingBehaviour extends AnimalBehaviour:
	func can_build():
		return true

class CollectingBehaviour extends AnimalBehaviour:
	func can_collect():
		return true
