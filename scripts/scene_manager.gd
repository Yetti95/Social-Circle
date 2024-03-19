extends Node3D

@export var Address: = '127.0.0.1'
@export var PORT := {'tcp': 3074, 'udp': [88, 3074]}
var peer =  ENetMultiplayerPeer.new()
@export var PlayerScene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	# We only need to spawn players on the server.
	if not multiplayer.is_server():
		return

	multiplayer.peer_disconnected.connect(del_player)


func _exit_tree():
	if not multiplayer.is_server():
		return
	#multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@rpc('any_peer', "call_local", "reliable")
func add_player(id = 1):
	var character = PlayerScene.instantiate()
	# set Player id.
	character.player = id
	character.name = str(id)
	character.set_multiplayer_authority(id)
	$Players.call_deferred("add_child", character)
	# sets player position to spawn locations
	for spawn in get_tree().get_nodes_in_group('PlayerSpawnPoint'):
			if not spawn.get_meta("spawned"):
				character.position = spawn.position
				spawn.set_meta("spawned", true)
				break

func del_player(id: int):
	if not 	$Players.has_node(str(id)):
		return
	$Players.get_node(str(id)).queue_free()


func _on_join_pressed():
	peer.create_client(Address, PORT.tcp)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	start_game()
	pass # Replace with function body.


func _on_host_pressed():
	var error = peer.create_server(PORT.tcp, 4) # TODO: change max players to a var coming from options
	if error != OK: 
		print('connot host: ' + error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	#actually setting multiplayer
	multiplayer.set_multiplayer_peer(peer)
	multiplayer.peer_connected.connect(add_player)
	add_player()
	#$CanvasLayer.hide()
	start_game()
	pass # Replace with function body.


func start_game():
	$CanvasLayer.hide();
	get_tree().paused = false
