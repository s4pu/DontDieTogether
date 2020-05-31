extends CanvasLayer

func update_inventory(inventory):
	$Margin/Row/wood/Count/Label.text = str(inventory['wood'])
	$Margin/Row/stone/Count/Label.text = str(inventory['stone'])
	$Margin/Row/mushrooms/Count/Label.text = str(inventory['mushroom'])
	$Margin/Row/food/Count/Label.text = str(inventory['food'])
