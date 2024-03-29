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
const CAMERA_MOUSE_ROTATION_SPEED := 0.001
const CAMERA_X_ROT_MIN := deg_to_rad(-89.9)
const CAMERA_X_ROT_MAX := deg_to_rad(70)
const CAMERA_UP_DOWN_MOVEMENT = 1

var paused = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#func _enter_tree():
	#set_multiplayer_authority(name.to_int())

func _ready():
	if player == multiplayer.get_unique_id():
		$"Camera Mount/Camera Rot/SpringArm3D/Camera3D".current = true
		
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_camera(event.relative * CAMERA_MOUSE_ROTATION_SPEED)

func rotate_camera(move):
	CAMERA_MOUNT.rotate_y(-move.x)
	CAMERA_MOUNT.orthonormalize()
	CAMERA_ROT.rotation.x = clamp(CAMERA_ROT.rotation.x + (CAMERA_UP_DOWN_MOVEMENT * move.y), CAMERA_X_ROT_MIN, CAMERA_X_ROT_MAX)

func get_camera_rotation_basis() -> Basis:
	return CAMERA_ROT.global_transform.basis
