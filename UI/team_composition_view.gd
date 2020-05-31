extends Control

func _ready():
	pass # Replace with function body.

func update_player_list(good_team: bool):
	$team_color.color = Color.royalblue if good_team else Color.indianred
	$team_color.rect_size = Vector2(40, 40)
	
	for n in $players.get_children():
		$players.remove_child(n)
	
	var players = get_tree().get_nodes_in_group('players')
	for player in players:
		if player.good_team == good_team:
			var tex = TextureRect.new()
			tex.texture = load("res://player/" + Global.ANIMALS[player.current_manifestation][good_team] + '.png')
			$players.add_child(tex)
	
	# fixme wtf?
	yield(get_tree().create_timer(0.01), "timeout")
	$team_color.rect_size = Vector2(32, 32)
	for child in $players.get_children():
		child.rect_scale = Vector2(0.5, 0.5)
