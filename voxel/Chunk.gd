@tool
extends StaticBody3D

const vertices = [
	Vector3(0, 0, 0), #0
	Vector3(1, 0, 0), #1
	Vector3(0, 1, 0), #2
	Vector3(1, 1, 0), #3
	Vector3(0, 0, 1), #4
	Vector3(1, 0, 1), #5
	Vector3(0, 1, 1), #6
	Vector3(1, 1, 1)  #7
]

const TOP = [2, 3, 7, 6]
const BOTTOM = [0, 4, 5, 1]
const LEFT = [6, 4, 0, 2]
const RIGHT = [3, 1, 5, 7]
const FRONT = [7, 5, 4, 6]
const BACK = [2, 0, 1, 3]

var blocks = []

var st = SurfaceTool.new()
var mesh = null
var mesh_instance = null

var material = preload("res://voxel/material/BlockMaterial.tres")

var _chunk_position = Vector2()

var chunk_position = Vector2() :
	get:
		return _chunk_position  # Return the private variable
	set(value):
		set_chunk_position(value)

func _ready():
	generate()
	update()
	#pass
	
func generate():
	# Only generate if blocks array is empty (avoid duplicate work)
	if blocks.size() > 0:
		return
		
	blocks = []
	
	# Resize blocks array to be big enough for our chunk and generate world
	blocks.resize(Global.DIMENSION.x)
	for i in range(0, Global.DIMENSION.x):
		blocks[i] = []
		blocks[i].resize(Global.DIMENSION.y)
		for j in range(0, Global.DIMENSION.y):
			blocks[i][j] = []
			blocks[i][j].resize(Global.DIMENSION.z)
			for k in range(Global.DIMENSION.z):
				# Set the value of the blocks
				var block = Global.AIR
				
				if j < 16:
					block = Global.STONE
				elif j < 32:
					block = Global.DIRT
				elif j == 32:
					block = Global.GRASS
					
				blocks[i][j][k] = block

func update():

			
	# Unload if already loaded in
	if mesh_instance != null:
		mesh_instance.call_deferred("queue_free")
		mesh_instance = null
		
	# Create new mesh
	mesh = ArrayMesh.new()
	mesh_instance = MeshInstance3D.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(-1)
	
	for x in range(Global.DIMENSION.x):
		for y in range(Global.DIMENSION.y):
			for z in range(Global.DIMENSION.z):
				create_block(x, y, z)

				
	# Add to mesh
	st.generate_normals(false)
	st.set_material(material)
	st.commit(mesh)
	
	mesh_instance.set_mesh(mesh)
	add_child(mesh_instance)
	mesh_instance.create_trimesh_collision()
	
	self.visible = true
	
func check_transparent(x, y, z):
	# Check if block is in bounds
	if x >= 0 and x < Global.DIMENSION.x and \
		y >= 0 and y < Global.DIMENSION.y and \
		z >= 0 and z < Global.DIMENSION.z:
			# Check if block is transparent
			var is_solid = Global.types[blocks[x][y][z]][Global.SOLID]	
			return not is_solid
	return true
			
func create_block(x, y, z):
	# Skip if air
	var block = blocks[x][y][z]
	if block == Global.AIR:
		return
		
	var block_info = Global.types[block]
	
	# Only render faces if neighbour is transparent
	if check_transparent(x, y + 1, z):
		create_face(TOP, x, y, z, block_info[Global.TOP])
	
	if check_transparent(x, y - 1, z):
		create_face(BOTTOM, x, y, z, block_info[Global.BOTTOM])
	
	if check_transparent(x - 1, y, z):
		create_face(LEFT, x, y, z, block_info[Global.LEFT])
		
	if check_transparent(x + 1, y, z):
		create_face(RIGHT, x, y, z, block_info[Global.RIGHT])
		
	if check_transparent(x, y, z - 1):
		create_face(BACK, x, y, z, block_info[Global.BACK])
		
	if check_transparent(x, y, z + 1):
		create_face(FRONT, x, y, z, block_info[Global.FRONT])
	
func create_face(indices, x, y, z, texture_atlas_offset):
	
	for i in indices:
		if i < 0 or i >= vertices.size():
			print("ERROR: Invalid vertex index ", i, " for face at position (", x, ",", y, ",", z, ")")
			return
			
	# Get position of all vertices in global coordinates
	var offset = Vector3(x, y, z)
	var vert1 = vertices[indices[0]] + offset
	var vert2 = vertices[indices[1]] + offset
	var vert3 = vertices[indices[2]] + offset
	var vert4 = vertices[indices[3]] + offset
	
	# UV for textures
	var uv_offset = texture_atlas_offset / Global.TEXTURE_ATLAS_SIZE
	var height = 1.0 / Global.TEXTURE_ATLAS_SIZE.y
	var width = 1.0 / Global.TEXTURE_ATLAS_SIZE.x
	
	var uv_v1 = uv_offset + Vector2(0, 0)
	var uv_v2 = uv_offset + Vector2(0, height)
	var uv_v3 = uv_offset + Vector2(width, height)
	var uv_v4 = uv_offset + Vector2(width, 0)
	
	# Create square (from two triangles, duh)
	st.add_triangle_fan(([vert1, vert2, vert3]), ([uv_v1, uv_v2, uv_v3]))
	st.add_triangle_fan(([vert1, vert3, vert4]), ([uv_v1, uv_v3, uv_v4]))

func set_chunk_position(pos):
	_chunk_position = pos
	position = Vector3(pos.x, 0, pos.y) * Global.DIMENSION
	
	self.visible = false
	
