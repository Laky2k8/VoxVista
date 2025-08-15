extends Node3D

@onready var player = $"../IsometricPlayer/Player"
@onready var voxel_terrain = $"../World/VoxelTerrain"
@onready var voxel_tool = voxel_terrain.get_voxel_tool()

@onready var block_selection_label = $"../UILayer/UI/selectedBlock"
@onready var hover_outline = $"../HoverOutline"
var selected_block = 1

'''var voxel = voxel_tool.get_voxel(mouse_3d_pos)

if voxel != null:
	print(voxel)'''
	
func distance_to_block(player_pos, voxel_pos):
	var player_voxel = Vector3i(floor(player_pos.x), floor(player_pos.y), floor(player_pos.z))
	
	var delta = voxel_pos - player_voxel
	
	var chebyshev_distance = max(abs(delta.x), abs(delta.y), abs(delta.z))
	return chebyshev_distance
				
func _input(event: InputEvent):
	
	if Input.is_action_pressed("zoom_in") and (not Input.is_action_pressed("zoom")):
		selected_block += 1
	
	if Input.is_action_pressed("zoom_out") and (not Input.is_action_pressed("zoom")):
		selected_block -= 1
		
	if selected_block > (Global.block_types.size()):
		selected_block = (Global.block_types.size())
	if selected_block < 1:
		selected_block = 1
		
	block_selection_label.text = "Selected Block: " + Global.block_types[selected_block - 1]["display_name"]
		
	if Input.is_action_just_pressed("break") or Input.is_action_just_pressed("place"):
		var ray = MouseSystem.get_mouse_raycast()
		if ray:
			var hit_pos = ray.position        # Vector3
			var hit_normal = ray.normal       # Vector3
			# For breaking: step half a unit opposite the normal
			# For placing: step half a unit along the normal
			var direction = hit_normal if Input.is_action_just_pressed("place") else -hit_normal
			var target_pos = hit_pos + direction * 0.5
			var voxel_pos = Vector3i(
			floor(target_pos.x),
			floor(target_pos.y),
			floor(target_pos.z)
			)
			
			var block_dist = distance_to_block(player.global_transform.origin, voxel_pos)
			
			# Check if block is within reach distance like in MC
			if block_dist <= 10:
				if Input.is_action_just_pressed("break"):
					print("Breaking")
					_break_block(voxel_pos)
				else:
					print("Placing")
					_place_block(voxel_pos, selected_block)
			

				
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
	var ray = MouseSystem.get_mouse_raycast()
	var mouse_3d_pos = MouseSystem.get_mouse_world_position()
	
	if ray:
		var hit_pos = ray.position        # Vector3
		var hit_normal = ray.normal       # Vector3
			
		var target_pos = hit_pos + -hit_normal * 0.5
		var voxel_pos = Vector3i(
			floor(target_pos.x),
			floor(target_pos.y),
			floor(target_pos.z)
		)
		
		DebugDraw3D.draw_gizmo(Transform3D(Basis(), mouse_3d_pos), Color(255, 0, 0, 0))	
		
		var voxel = voxel_tool.get_voxel(voxel_pos)
		
		var block_dist = distance_to_block(player.global_transform.origin, voxel_pos)
		print("Distance to block:" + str(block_dist))
		if voxel and block_dist <= 10:
			hover_outline.global_transform.origin = Vector3(voxel_pos.x + 0.5, voxel_pos.y + 0.5, voxel_pos.z + 0.5)
			hover_outline.visible = true
		else:
			hover_outline.visible = false
			#print(voxel)
			#voxel_tool.set_voxel(voxel_pos, 2)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Byebye!")
		voxel_terrain.save_modified_blocks()
