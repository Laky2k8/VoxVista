extends CharacterBody3D

@onready var head = $Head
@onready var camera = $Head/Camera3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const DECELERATION = 20.0
const SENSITIVITY = 0.003

var paused = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent):
	
	if event is InputEventMouseMotion and not paused:
		#print("Mouse motion detected: ", event.relative)
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		#print("Camera rotation: ", camera.rotation_degrees)
		
	if Input.is_action_just_pressed("pause"):
		paused = not paused
		
		if paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			print("Mouse mode set to VISIBLE")
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			print("Mouse mode set to CAPTURED")


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor()  && !paused:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	if direction && !paused:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
		velocity.z = move_toward(velocity.z, 0.0, DECELERATION * delta)

	move_and_slide()
