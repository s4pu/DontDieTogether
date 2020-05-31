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

func _process(_delta):
	var color = Color.black if $"../time_of_day".day > 0.5 else Color.white
	$Margin/Row/wood/Count/Label.add_color_override("font_color", color)
	$Margin/Row/stone/Count/Label.add_color_override("font_color", color)
	$Margin/Row/mushrooms/Count/Label.add_color_override("font_color", color)
	$Margin/Row/food/Count/Label.add_color_override("font_color", color)
