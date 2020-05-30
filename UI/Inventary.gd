extends CanvasLayer

func update_inventary(inventary):
	$Margin/Row/wood/Count/Label.text = str(inventary['wood'])
	$Margin/Row/stone/Count/Label.text = str(inventary['stone'])
	$Margin/Row/mushrooms/Count/Label.text = str(inventary['mushroom'])
	$Margin/Row/food/Count/Label.text = str(inventary['food'])

