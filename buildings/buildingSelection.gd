extends CanvasLayer

func set_visibility(visible):
	$MarginContainer.visible = visible

func _process(_delta):
	var color = Color.black if $"../time_of_day".day > 0.5 else Color.white
	$MarginContainer/wall/Label.add_color_override("font_color", color)
	$MarginContainer/fence/Label.add_color_override("font_color", color)
	$MarginContainer/spikes/Label.add_color_override("font_color", color)
	$MarginContainer/tower/wood/Label.add_color_override("font_color", color)
	$MarginContainer/tower/stone/Label.add_color_override("font_color", color)
