extends RigidBody3D

var mouse_sensitivity := 0.001
var twist_input := 0.0
var pitch_input := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Input of player keys, WASD
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_backward")
	
	#  Move player based on the direction they are looking
	apply_central_force($Twist.basis * input * 1200.0 * delta)
	
	# Escape key allows for closing the window
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	# Capture camera rotation based on mouse movement
	$Twist.rotate_y(twist_input)
	$Twist/Pitch.rotate_x(pitch_input)
	
	# move camera based on movement, restrict camera movement from going vertical
	$Twist/Pitch.rotation.x = clamp($Twist/Pitch.rotation.x,deg_to_rad(-30),deg_to_rad(30))
	
	# Reset mouse movement effect on camera, (stops camera when not moving mouse)
	twist_input = 0.0
	pitch_input = 0.0

func _unhandled_input(event: InputEvent) -> void:
	# Captures mouse movement to affect camera
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity
			pitch_input = - event.relative.y * mouse_sensitivity
