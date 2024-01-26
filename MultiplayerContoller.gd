extends Control

@export var Address = '127.0.0.1'
@export var PORT = {'tcp': 3074, 'udp': [88, 3074]}
var peer =  ENetMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)	

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
	
# This gets called on ONLY the client
func connection_failed(id):
	print('Could\'t connect')
	

@rpc("any_peer", "call_local")
func StartGame():
	var scene = load('res://Level.tscn').instantiate()
	get_tree().get_root().add_child(scene)
	self.hide()

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
	$MarginContainer/VBoxContainer/Host.visible = false
	
	
	pass


func _on_join_pressed():
	peer.create_client(Address, PORT.tcp)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	pass # Replace with function body.


func _on_options_pressed():
	pass # Replace with function body.


func _on_quit_pressed():
	pass # Replace with function body.
