extends Node

const MAP_SIZE = 6000
const RESOURCES = ["wood", "food", "mushroom", "stone"]
const EMPTY_INVENTORY = {
	"wood": 0,
	"food": 0,
	"stone": 0,
	"mushroom": 0
}

const ANIMALS = {
	"default": {
		true: "koala",
		false: "sloth",
		"hitpoints": 100,
		"speed": 100,
	},
	"cook": {
		true: "cow",
		false: "chicken",
		"hitpoints": 100,
		"speed": 150,
	},
	"fighter": {
		true: "",
		false: "",
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
	},
	"builder": {
		true: "beaver",
		false: "mole",
		"hitpoints": 100,
		"speed": 150,
	},
	"ranged": {
		true: "",
		false: "",
		"hitpoints": 100,
		"speed": 150,
	}
}
