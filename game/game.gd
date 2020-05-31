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

func _ready():
	var peer = NetworkedMultiplayerENet.new()
	var is_client = "--client" in OS.get_cmdline_args()
	var is_dedicated = "--dedicated" in OS.get_cmdline_args()
	
	if is_client:
		peer.create_client(ip, port)
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
	
	var players = get_tree().get_nodes_in_group("players")
	if not is_dedicated and not is_client:
		register_player(1, null, {})

func client_note_disconnected():
	print("Server disconnected from player, exiting ...")
	get_tree().quit()

func server_player_connected(player_id: int):
	if player_id != 1:
		print("Connected ", player_id)
		# get our new player informed about all the old players and objects
		for old_player in get_tree().get_nodes_in_group("players"):
			rpc_id(player_id, "register_player", old_player.id, old_player.position, old_player.get_sync_state())
		for node in get_tree().get_nodes_in_group("synced"):
			rpc_id(player_id, "spawn_object", node.name, node.filename, node.get_path(), node.position, node.get_node("sync").get_sync_state())
		
		# inform all our players (including himself) about the new player
		var new_player = register_player(player_id, null, {})
		rpc("register_player", player_id, new_player.position, new_player.get_sync_state())

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

remote func register_player(player_id: int, position, state: Dictionary):
	var player: Node2D = preload("res://player/player.tscn").instance()
	player.id = player_id
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
