extends CharacterBody3D

@onready var head = $CameraPivot

const SPEED = 5.0
const JUMP_VELOCITY = 10
const DECELERATION = 20.0
const SENSITIVITY = 0.003
const ROTATION_SPEED = 5.0

# Use a float for player rotation instead of Basis
var player_rotation_y = 0.0
var paused = false

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func _input(event: InputEvent):
	if event is InputEventMouseMotion and not paused:
		# Mouse rotation code would go here if needed
		pass
		
	if Input.is_action_just_pressed("pause"):
		paused = not paused
		'''if paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			print("Mouse mode set to VISIBLE")
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			print("Mouse mode set to CAPTURED")'''

func _physics_process(delta: float) -> void:
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor() && !paused:
		velocity.y = JUMP_VELOCITY

	# Handle rotation with keys (for top-down)
	var rotation_input = 0.0
	if Input.is_action_pressed("left"):
		rotation_input += 1.0
	if Input.is_action_pressed("right"):
		rotation_input -= 1.0
	
	# Apply rotation to player
	if rotation_input != 0.0 && !paused:
		player_rotation_y += rotation_input * ROTATION_SPEED * delta
		rotation.y = player_rotation_y

	# Get input direction and handle movement
	var input_dir := Input.get_vector("strafe_left", "strafe_right", "forward", "backward")
	
	# Calculate movement direction based on player's current rotation
	var forward = -transform.basis.z  # Player's forward direction
	var right = transform.basis.x     # Player's right direction
	
	var movement_direction = (forward * input_dir.y + right * input_dir.x).normalized()

	if movement_direction != Vector3.ZERO && !paused:
		velocity.x = movement_direction.x * SPEED
		velocity.z = movement_direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
		velocity.z = move_toward(velocity.z, 0.0, DECELERATION * delta)

	move_and_slide()
	
	#print("My pos:" + str(position))
