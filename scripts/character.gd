extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@export var CAMERA_MOUNT : Node3D
@export var CAMERA_ROT : Node3D
@export var CAMERA3D : Camera3D
@export var player := 1 :
	set(id):
		player = id
		#Give authority over the player
		$PlayerInput.set_multiplayer_authority(id)
@onready var input = $PlayerInput
@export var spawncolor = ""
signal vote(votecolor)
const CAMERA_MOUSE_ROTATION_SPEED := 0.001
const CAMERA_X_ROT_MIN := deg_to_rad(-89.9)
const CAMERA_X_ROT_MAX := deg_to_rad(70)
const CAMERA_UP_DOWN_MOVEMENT = 1

var paused = false
var already_voted = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Set vote to middle (states are 0,1,2 for left, middle, right)
var vote_direction = 1


#func _enter_tree():
	#set_multiplayer_authority(name.to_int())

func _ready():
	if player == multiplayer.get_unique_id():
		$"Camera Mount/Camera Rot/SpringArm3D/Camera3D".current = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				
func _unhandled_input(event):
	#if event is InputEventMouseMotion:
		#rotate_camera(event.relative * CAMERA_MOUSE_ROTATION_SPEED)
	# Look left when input received, restricted from going off the buttons
	if event.is_action_pressed("look_left"):
		if vote_direction > 0:
			CAMERA_ROT.rotate_y(deg_to_rad(45))
			vote_direction -= 1
	# Look right when input received, restricted from going off the buttons
	if event.is_action_pressed("look_right"):
		if vote_direction < 2:
			CAMERA_ROT.rotate_y(deg_to_rad(-45))
			vote_direction += 1
	# Handle player vote
	if event.is_action_pressed("select"):
		print("Voting, spawncolor: " + spawncolor)
		if already_voted == false:
			if spawncolor == "Red":
				if vote_direction == 0:
					vote.emit("Green")
				elif vote_direction == 1:
					vote.emit("Blue")
				elif vote_direction == 2:
					vote.emit("Yellow")
			if spawncolor == "Blue":
				if vote_direction == 0:
					vote.emit("Yellow")
				elif vote_direction == 1:
					vote.emit("Red")
				elif vote_direction == 2:
					vote.emit("Green")
			if spawncolor == "Yellow":
				if vote_direction == 0:
					vote.emit("Red")
				elif vote_direction == 1:
					print("Emitting Green vote")
					vote.emit("Green")
				elif vote_direction == 2:
					vote.emit("Blue")
			if spawncolor == "Green":
				if vote_direction == 0:
					vote.emit("Blue")
				elif vote_direction == 1:
					print("Emitting Yellow vote")
					vote.emit("Yellow")
				elif vote_direction == 2:
					vote.emit("Red")
		already_voted = true
		
		pass
	# One person quits, everyone quits, pause menu
	if Input.is_action_pressed('escape'):
		get_tree().quit()

func rotate_camera(move):
	CAMERA_MOUNT.rotate_y(-move.x)
	CAMERA_MOUNT.orthonormalize()
	CAMERA_ROT.rotation.x = clamp(CAMERA_ROT.rotation.x + (CAMERA_UP_DOWN_MOVEMENT * -move.y), CAMERA_X_ROT_MIN, CAMERA_X_ROT_MAX)

func get_camera_rotation_basis() -> Basis:
	return CAMERA_ROT.global_transform.basis
