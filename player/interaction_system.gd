extends Node3D

@onready var player = $"../IsometricPlayer"
@onready var voxel_terrain = $"../World/VoxelTerrain"
@onready var voxel_tool = voxel_terrain.get_voxel_tool()

'''var voxel = voxel_tool.get_voxel(mouse_3d_pos)

if voxel != null:
	print(voxel)'''
				
func _input(event: InputEvent):
	if Input.is_action_just_pressed("break"):
		print("Breaking")
		var mouse_3d_pos = MouseSystem.get_mouse_world_position()
		if mouse_3d_pos != null:
			#var voxel_pos = Vector3i(floor(mouse_3d_pos.x), floor(mouse_3d_pos.y), floor(mouse_3d_pos.z))
			_break_block(mouse_3d_pos)
			
	elif Input.is_action_just_pressed("place"):
		print("Placing")
		var mouse_3d_pos = MouseSystem.get_mouse_world_position()
		if mouse_3d_pos != null:
			#var voxel_pos = Vector3i(floor(mouse_3d_pos.x), floor(mouse_3d_pos.y), floor(mouse_3d_pos.z))
			_place_block(mouse_3d_pos, 1)
			

				
func _break_block(pos):
	voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE
	voxel_tool.mode = VoxelTool.MODE_REMOVE
	voxel_tool.value = 0
	
	voxel_tool.do_point(pos)
	
func _place_block(pos, block_type):
	voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE
	voxel_tool.mode = VoxelTool.MODE_ADD
	voxel_tool.value = block_type
	
	voxel_tool.do_point(pos)

	

func _physics_process(delta: float) -> void:
	pass
