extends Node

@export var Address: = '127.0.0.1'
@export var PORT := {'tcp': 3074, 'udp': [88, 3074]}
var peer =  ENetMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

# this get called on the server and clients
func peer_connected(id):
	print('Player Connected: ' + str(id))
	
	
# this gets called on the server and clients
func peer_disconnected(id):
	print('Player Disconnected: ' + str(id))
	
# This gets called on ONLY the client
func connected_to_server():
	print('Connected')
	SendPlayerInformation.rpc_id(1, $Menu/Username.text, multiplayer.get_unique_id())
	
# This gets called on ONLY the client
func connection_failed(id):
	print('Could\'t connect')
	
	
# rpc func for informtion on player
@rpc("any_peer")
func SendPlayerInformation(customName, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			'name': customName,
			'id': id,
			'playerType': 'normie',
		}
	if multiplayer.is_server():
		for i in GameManager.Players:
			SendPlayerInformation.rpc(GameManager.Players[i].name, i)
			

@rpc("any_peer", "call_local")
func StartGame():
	change_level(load('res://scenes/Level.tscn'))
	

	$Menu.hide()

func _on_play_pressed():
	StartGame.rpc()
	pass # Replace with function body.


func _on_host_pressed():
	var error = peer.create_server(PORT.tcp, 4) # TODO: change max players to a var coming from options
	if error != OK: 
		print('connot host: ' + error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	#actually setting multiplayer
	multiplayer.set_multiplayer_peer(peer)
	print('Waiting for Players!')
	#SendPlayerInformation($Username.text, multiplayer.get_unique_id())
	$Menu/MarginContainer/VBoxContainer/Host.visible = false
	$Menu/MarginContainer/VBoxContainer/Join.visible = false

	change_level.rpc(load('res://scenes/Level.tscn'))

	pass


func _on_join_pressed():
	peer.create_client(Address, PORT.tcp)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	$Menu.visible = false	
	
	pass # Replace with function body.


func _on_options_pressed():
	pass # Replace with function body.


func _on_quit_pressed():
	pass # Replace with function body.

@rpc("any_peer", "call_local", "reliable")
func change_level(scene: PackedScene):
	# Remove old level if any.
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	# Add new level.
	level.add_child(scene.instantiate(), true)
