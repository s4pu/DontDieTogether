extends CanvasLayer

func set_visibility(materials_visible, heal_visible, food_visible):
	$Margin/Row/wood.visible = materials_visible
	$Margin/Row/stone.visible = materials_visible
	$Margin/Row/mushrooms.visible = heal_visible
	$Margin/Row/food.visible = food_visible

func update_inventory(inventory):
	$Margin/Row/wood/Count/Label.text = str(inventory['wood'])
	$Margin/Row/stone/Count/Label.text = str(inventory['stone'])
	$Margin/Row/mushrooms/Count/Label.text = str(inventory['mushroom'])
	$Margin/Row/food/Count/Label.text = str(inventory['food'])
