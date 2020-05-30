extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_inventary(inventary):
	$Margin/Row/wood/Count/Label.text = str(inventary['wood'])
	$Margin/Row/stone/Count/Label.text = str(inventary['stone'])
	$Margin/Row/mushrooms/Count/Label.text = str(inventary['mushroom'])
	$Margin/Row/food/Count/Label.text = str(inventary['food'])

