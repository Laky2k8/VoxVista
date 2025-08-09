extends Node3D

@export var camera_speed = 0.1

@onready var camera_3d: Camera3D = $Camera3D


func _physics_process(delta: float) -> void:
	rotation.y -= delta * camera_speed
