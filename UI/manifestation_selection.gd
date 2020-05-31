extends Control

signal manifestation_selected(name)

func _ready():
	for key in Global.ANIMALS.keys():
		var button = Button.new()
		button.text = key
		button.connect("pressed", self, "select_manifestation", [key])
		# TODO: adapt to team
		button.icon = load("res://player/" + Global.ANIMALS[key][true] + ".png")
		$row.add_child(button)

func select_manifestation(name):
	emit_signal("manifestation_selected", name)
