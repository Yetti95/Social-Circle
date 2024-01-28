extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@export var CAMERA_MOUNT : Node3D
@export var CAMERA_ROT : Node3D
@export var CAMERA3D : Camera3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Disables camera on non-host server setups, or dedicated server builds
	if OS.has_feature("dedicated_server"):
		CAMERA3D.current = false
		
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		CAMERA3D.make_current()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	else: 
		set_process(false)
		set_process_input(false)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
