extends Node3D

@export var Address: = '127.0.0.1'
@export var PORT := {'tcp': 3074, 'udp': [88, 3074]}
var peer =  ENetMultiplayerPeer.new()
@export var PlayerScene : PackedScene
@export var BuzzerScene : PackedScene
var max_buzzers = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer.hide()
	# We only need to spawn players on the server.
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	
	# Spawn already connected players
	for id in multiplayer.get_peers():
		add_player(id)
	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		add_player(1)

func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#@rpc('any_peer', "call_local", "reliable")
func add_player(id = 1):
	var character = PlayerScene.instantiate()
	
	# set Player id.
	character.player = id
	character.name = str(id)
	#character.set_multiplayer_authority(id)
	$Players.add_child(character,true)
	
	var offset = -1
	var spacing_multiplier = 1
	var distance_from_player = 2
	var y_offset = -0.25
	# sets player position to spawn locations
	for spawn in get_tree().get_nodes_in_group('PlayerSpawnPoint'):
			if not spawn.get_meta("spawned"):
				character.position = spawn.position
				character.rotation = spawn.rotation
				spawn.set_meta("spawned", true)
				# Spawn in buzzer for each player
				for i in range(max_buzzers):
					var buzzer = preload("res://scenes/buzzer.tscn").instantiate()
					buzzer.position = spawn.position
					#var new_transform = Transform3D()
					#if i%2 == 0:
						#if i == 0:
							#new_transform = new_transform.rotated(Vector3(0,0,1), -PI/2)
							##
						#if i == 2:
							#new_transform = new_transform.rotated(Vector3(0,0,1), PI/2)
					#var new_x = spawn.position.x + offset + (i * spacing_multiplier)
					#var new_y = spawn.position.y + y_offset+ ((i+1)%2 *0.5)
					#var new_z = spawn.position.z - distance_from_player + ((i+1)%2 * 0.75)
					#var translation = Vector3(new_x, new_y, new_z)
					#new_transform = new_transform.translated(translation)
					#
					#new_transform = new_transform.rotated(Vector3(0,1,0), deg_to_rad(spawn.rotation.y))
					#buzzer.transform = new_transform
					if spawn.position.x < 0:
						buzzer.position.z += offset + (i * spacing_multiplier)
						buzzer.position.x += distance_from_player - ((i+1)%2 * 0.75)
						buzzer.position.y += y_offset + ((i+1)%2 *0.5)
					elif spawn.position.z < 0:
						buzzer.position.x += offset + (i * spacing_multiplier)
						buzzer.position.z += distance_from_player - ((i+1)%2 * 0.75)
						buzzer.position.y += y_offset + ((i+1)%2 *0.5)
					elif spawn.position.x > 0:
						buzzer.position.z += offset + (i * spacing_multiplier)
						buzzer.position.x -= distance_from_player - ((i+1)%2 * 0.75)
						buzzer.position.y += y_offset+ ((i+1)%2 *0.5)
					elif spawn.position.z > 0:
						buzzer.position.x += offset + (i * spacing_multiplier)
						buzzer.position.z -= distance_from_player - ((i+1)%2 * 0.75)
						buzzer.position.y += y_offset+ ((i+1)%2 *0.5)
					if i%2 == 0:
						if i == 0:
							buzzer.rotation.z += deg_to_rad(90)
							
						if i == 2:
							buzzer.rotation.z -= deg_to_rad(90)
					buzzer.rotate_y(PI)
					$Players/Buzzers.add_child(buzzer)
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
	#
	#if multiplayer.is_server():
		#change_level.call_deferred(load("res://level.tscn"))
