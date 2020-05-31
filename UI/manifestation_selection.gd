extends Control

func _ready():
	for key in Global.ANIMALS.keys():
		var button = Button.new()
		button.text = key
		# TODO: adapt to team
		button.icon = load("res://player/" + Global.ANIMALS[key][true] + ".png")
		$row.add_child(button)
