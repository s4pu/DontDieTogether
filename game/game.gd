extends Node2D

var port = 8899
var ip = '127.0.0.1'
var max_players = 200
var manifestations_menu

# put game-specific (non network) init things here
func game_ready():

	var viewport = $color_tint_container/viewport/shadow_casters_container/viewport
# warning-ignore:return_value_discarded
	viewport.get_node("GoodBase").connect("base_entered", self, "show_manifestations")
# warning-ignore:return_value_discarded
	viewport.get_node("GoodBase").connect("base_exited", self, "hide_manifestations")
# warning-ignore:return_value_discarded
	viewport.get_node("EvilBase").connect("base_entered", self, "show_manifestations")
# warning-ignore:return_value_discarded
	viewport.get_node("EvilBase").connect("base_exited", self, "hide_manifestations")
	
	viewport.get_node("GoodBase").get_node("Artefact").connect("game_over", self, "show_game_over", ["evil"])
	viewport.get_node("EvilBase").get_node("Artefact").connect("game_over", self, "show_game_over", ["good"])
	
	set_color_of_base(viewport.get_node("GoodBase"))
	set_color_of_base(viewport.get_node("EvilBase"))
	
func set_color_of_base(base):
	var color = Color.royalblue if base.get_node("Artefact").good_team else Color.indianred
	base.get_node("Sprite").material = base.get_node("Sprite").material.duplicate()
	base.get_node("Sprite").material.set_shader_param("outline_color", color)
	base.get_node("Artefact").get_node("Sprite").material = base.get_node("Artefact").get_node("Sprite").material.duplicate()
	base.get_node("Artefact").get_node("Sprite").material.set_shader_param("outline_color", color)

func show_game_over(team):
	Global.winning_team = team
	get_tree().change_scene("res://game/gameOver.tscn")
	
func show_manifestations():
	if not manifestations_menu:
		manifestations_menu = preload("res://UI/manifestation_selection.tscn").instance()
		manifestations_menu.name = 'manifestation_selection'
		manifestations_menu.connect("manifestation_selected", self, "manifestation_selected")
		add_child(manifestations_menu)
func manifestation_selected(name):
	my_player().rpc("assume_manifestation", name)
func hide_manifestations():
	if manifestations_menu:
		manifestations_menu.queue_free()
		manifestations_menu = null

func my_player():
	for player in get_tree().get_nodes_in_group("players"):
		if player.is_network_master():
			return player
	return null

func next_player_team():
	var players = get_tree().get_nodes_in_group("players")
	var count_good = 0
	var count_evil = 0
	for player in players:
		if player.good_team:
			count_good += 1
		else:
			count_evil += 1
	return count_good <= count_evil

func _ready():
	var peer = NetworkedMultiplayerENet.new()
	var is_client = "--client" in OS.get_cmdline_args()
	var is_dedicated = "--dedicated" in OS.get_cmdline_args()
	var host = 'g.tmbe.me' if '--tmbe' in OS.get_cmdline_args() else ip
	
	if is_client:
		print('Connecting to ' + str(host) + ':' + str(port))
		peer.create_client(host, port)
		if get_tree().connect("server_disconnected", self, "client_note_disconnected") != OK:
			print("An eror occured while trying to connect the server disconnected signal")
	else:
		print("Listening for connections on " + String(port) + " ...")
		var err = peer.create_server(port, max_players)
		if err != OK:
			print('Network failed to initialize: ' + str(err))
			get_tree().quit()
		if get_tree().connect("network_peer_connected", self, "server_player_connected") != OK:
			print("An error occured while trying to connect the network peer connected signal")
		if get_tree().connect("network_peer_disconnected", self, "server_player_disconnected") != OK:
			print("An error occured while trying to connec the network peer disconnected signal")
		
		$color_tint_container/viewport/shadow_casters_container/viewport/Level.spawn()
	
	get_tree().set_network_peer(peer)
	
	game_ready()
	
	if not is_dedicated and not is_client:
		register_player(1, null, {}, next_player_team())

func client_note_disconnected():
	print("Server disconnected from player, exiting ...")
	get_tree().quit()

func server_player_connected(player_id: int):
	if player_id != 1:
		print("Connected ", player_id)
		rpc_id(player_id, "loading_started")
		
		# get our new player informed about all the old players and objects
		for old_player in get_tree().get_nodes_in_group("players"):
			rpc_id(player_id, "register_player", old_player.id, old_player.position, old_player.get_sync_state(), old_player.good_team)
		for node in get_tree().get_nodes_in_group("synced"):
			rpc_id(player_id, "spawn_object", node.name, node.filename, node.get_path(), node.position, node.get_node("sync").get_sync_state())
		
		# inform all our players (including himself) about the new player
		var new_player = register_player(player_id, null, {}, next_player_team())
		rpc("register_player", player_id, new_player.position, new_player.get_sync_state(), new_player.good_team)
		rpc_id(player_id, "loading_finished")

remotesync func loading_started():
	$loading_screen.show()
remotesync func loading_finished():
	remove_child($loading_screen)

func server_player_disconnected(player_id: int):
	print("Disconnected ", player_id)
	rpc("unregister_player", player_id)

remote func spawn_object(name: String, filename: String, path: NodePath, position: Vector2, state: Dictionary):
	# either create the object or just find the existing one
	var object: Node2D = get_node_or_null(path)
	if not object:
		var fullPath = Array(str(path).split('/'))
		fullPath.pop_back()
		object = load(filename).instance()
		object.name = name
		get_node(PoolStringArray(fullPath).join('/')).add_child(object)
		#$shadow_casters_container/viewport.add_child(object)
	
	# rigid bodys need to be our syncable_rigid_body because you can't set the
	# position or any other physics property outside of its own _integrate_forces
	if object is RigidBody2D:
		object.use_update(position, state)
	else:
		object.position = position
		for property in state:
			object.set(property, state[property])
	
	return object

remote func register_player(player_id: int, position, state: Dictionary, good_team: bool):
	var player: Node2D = preload("res://player/player.tscn").instance()
	player.id = player_id
	player.good_team = good_team
	player.set_network_master(player.id)
	player.name = String(player.id)
	player.add_to_group("players")
	
	$color_tint_container/viewport/shadow_casters_container/viewport.add_child(player)
	
	if position:
		player.position = position
	for property in state:
		player.set(property, state[property])
	return player

remotesync func unregister_player(player_id: int):
	remove_child(get_node(String(player_id)))
