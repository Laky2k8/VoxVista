extends Node3D

@export var cameraSens = 0.004
@export var cameraSpeed = 1.0
@export var maxZoom = 40
@export var minZoom = 8
@export var joystick_deadzone = 0.2

@onready var camera_3d: Camera3D = $Camera3D
@onready var player: CharacterBody3D = $"../Player"


func _ready() -> void:
	pass

func _input(event):

	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		rotation.y -= event.relative.x * cameraSens

	_camera_zoom()

func _camera_zoom():
	var zoomChange = 0
	if Input.is_action_pressed("zoom_in") and Input.is_action_pressed("zoom"):
		zoomChange -= 1
	elif Input.is_action_pressed("zoom_out") and Input.is_action_pressed("zoom"):
		zoomChange += 1
	
	camera_3d.size += zoomChange
	camera_3d.size = clamp(camera_3d.size, minZoom, maxZoom)

func _physics_process(delta: float) -> void:
	position = player.position
	
	# JOYSTICK SUPPORT
	_joystick_rotate(delta)
	_joystick_zoom(delta)

# JOYSTICK SUPPORT 
func _joystick_rotate(delta: float) -> void:
	# Read horizontal right-stick axis (Joypad 1, axis 2)
	var axis_value = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	# Apply deadzone
	if abs(axis_value) > joystick_deadzone:
		rotation.y -= axis_value * delta

func _joystick_zoom(delta: float) -> void:
	# Read vertical right-stick axis (Joypad 1, axis 3)
	var zoom_axis = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	if abs(zoom_axis) > joystick_deadzone:
		# Positive axis_zoom pulls the stick down
		camera_3d.size += zoom_axis * 20 * delta
		camera_3d.size = clamp(camera_3d.size, minZoom, maxZoom)

'''func _camera_movement():
	var direction = Vector2.ZERO
	direction.y = Input.get_axis("forward", "backward")
	direction.x = Input.get_axis("left", "right")
	
	global_position += (global_basis * Vector3(direction.x, 0, direction.y)).normalized() * cameraSpeed'''
