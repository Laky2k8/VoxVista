extends Node3D

@export var cameraSens = 0.004
@export var cameraSpeed = 1.0
@export var maxZoom = 40
@export var minZoom = 8

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
	if Input.is_action_pressed("zoom_in"):
		zoomChange -= 1
	elif Input.is_action_pressed("zoom_out"):
		zoomChange += 1
	
	camera_3d.size += zoomChange
	camera_3d.size = clamp(camera_3d.size, minZoom, maxZoom)

func _physics_process(delta: float) -> void:
	position = player.position
	pass

'''func _camera_movement():
	var direction = Vector2.ZERO
	direction.y = Input.get_axis("forward", "backward")
	direction.x = Input.get_axis("left", "right")
	
	global_position += (global_basis * Vector3(direction.x, 0, direction.y)).normalized() * cameraSpeed'''
