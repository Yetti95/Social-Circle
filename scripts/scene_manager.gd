extends Node3D

@export var Address: = '127.0.0.1'
@export var PORT := {'tcp': 3074, 'udp': [88, 3074]}
var peer =  ENetMultiplayerPeer.new()
@export var PlayerScene : PackedScene
@export var BuzzerScene : PackedScene

var max_buzzers = 3
var votes = []
var player_count = 2

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
	var initial_x = 0
	var initial_y = 2.5
	var initial_z = 4
	# sets player position to spawn locations
	for spawn in get_tree().get_nodes_in_group('PlayerSpawnPoint'):
			if not spawn.get_meta("spawned"):
				character.position = spawn.position
				character.rotation = spawn.rotation
				character.spawncolor = spawn.name
				character.connect("vote", Callable(self, "_on_character_vote"))
				spawn.set_meta("spawned", true)
				# Spawn in buzzer for each player
				for i in range(max_buzzers):
					var buzzer = preload("res://scenes/buzzer.tscn").instantiate()
					#buzzer.position = spawn.position
					
					# Create transformation for each buzzer
					var new_transform = Transform3D()
					if i%2 == 0:
						# Rotate left and right ones onto walls
						if i == 0:
							new_transform = new_transform.rotated(Vector3(0,0,1), -PI/2)
							#
						if i == 2:
							new_transform = new_transform.rotated(Vector3(0,0,1), PI/2)
					# Create new position based on one buzzer
					var new_x = initial_x + offset + (i * spacing_multiplier)
					var new_y = initial_y + y_offset+ ((i+1)%2 *0.5)
					var new_z = initial_z - distance_from_player + ((i+1)%2 * 0.75)
					var translation = Vector3(new_x, new_y, new_z)
					new_transform = new_transform.translated(translation)
					# Rotate around origin for any other spawns
					new_transform = new_transform.rotated(Vector3(0,1,0), spawn.rotation.y)
					buzzer.transform = new_transform
									
					$Buzzers.add_child(buzzer, true)
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


func _on_character_vote(votecolor):
	print("Vote received: " + votecolor)
	votes.append(votecolor)
	if votes.size() >= player_count:
		print("Processing results")
		process_results()

func tie():
	print("Tie")
	pass

func voted_off(color):
	print(color + " voted off")
	pass

func process_results():
	var red_count = votes.count("Red")
	var blue_count = votes.count("Blue")
	var green_count = votes.count("Green")
	var yellow_count = votes.count("Yellow")
	
	var highest_count = max(red_count, blue_count, green_count, yellow_count)
	if highest_count == red_count:
		if red_count == blue_count or red_count == green_count or red_count == yellow_count:
			tie()
		else:
			voted_off("Red")
	if highest_count == blue_count:
		if blue_count == red_count or blue_count == green_count or blue_count == yellow_count:
			tie()
		else:
			voted_off("Blue")
	if highest_count == yellow_count:
		if yellow_count == blue_count or yellow_count == green_count or yellow_count == red_count:
			tie()
		else:
			voted_off("Yellow")
	if highest_count == green_count:
		if green_count == blue_count or green_count == red_count or green_count == yellow_count:
			tie()
		else:
			voted_off("Green")
