extends Node3D

@onready var terrain: VoxelTerrain = $VoxelTerrain
@onready var terrain_material = load("res://voxel/material/VoxelMat.tres")

var seed: int = 0
var world_name: String = ""

var blocks_json = "res://blocks.json"

@onready var save_manager = $SaveManager

func _ready():
	world_name = Global.pending_world_name
	seed = Global.pending_seed
	
	setup_terrain()
	setup_mesher()
	setup_materials()
	
	if world_name != "":
		if seed > 0:
			save_manager.create_new_world(world_name, seed)
		else:
			save_manager.load_world(world_name)

	Global.pending_world_name = ""
	Global.pending_seed = 0
	

func setup_terrain():
	# Basic terrain settings
	terrain.max_view_distance = 512
	terrain.collision_layer = 1
	terrain.collision_mask = 1
	terrain.area_edit_notification_enabled = true

func setup_generator():
	# Create noise-based terrain generator
	var generator = VoxelGeneratorNoise2D.new()
	generator.channel = VoxelBuffer.CHANNEL_TYPE
	
	# Create and configure noise
	var noise = FastNoiseLite.new()
	noise.seed = seed
	noise.frequency = 0.02
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_octaves = 4
	noise.fractal_gain = 0.5
	noise.fractal_lacunarity = 2.0
	
	generator.noise = noise
	generator.curve = create_height_curve()
	terrain.generator = generator
	
	
	

func create_height_curve() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0.0, 0.0))  # Sea level
	curve.add_point(Vector2(0.3, 0.1))  # Beach
	curve.add_point(Vector2(0.6, 0.4))  # Hills
	curve.add_point(Vector2(1.0, 1.0))  # Mountains
	return curve

func setup_mesher():
	# Create blocky mesher for cube-style terrain
	var mesher = VoxelMesherBlocky.new()
	var library = VoxelBlockyLibrary.new()
	
	# Create block models
	create_block_library(library)
	mesher.library = library
	terrain.mesher = mesher

func create_block_library(library: VoxelBlockyLibrary):
	# Air block (ID 0) - always first
	var air_model = VoxelBlockyModelEmpty.new()
	library.add_model(air_model)
	
	# Load blocks from blocks.json
	var json = JSON.new()
	var file = FileAccess.open(blocks_json, FileAccess.READ)
	var json_text = file.get_as_text()
	var json_successful = false
	var blocks = null
	
	var error = json.parse(json_text)
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_ARRAY:
			json_successful = true
			blocks = data_received
		else:
			push_warning("Unexpected Data")
	else:
		push_warning("JSON Prase Error: ", json.get_error_message(), " in ", json_text)
	
	if json_successful:
		print("Parsing JSON and filling Block library...")
		
		for i in range(len(blocks)):
			var block = blocks[i]
			print("Name: " + block["name"])
			print("Display name: " + block["display_name"])
			print("Adding block " + block["name"] + " ...")
			
			var block_model = VoxelBlockyModelCube.new()
			block_model.atlas_size_in_tiles = Vector2i(16, 16)
			var textures = block["textures"]
			
			block_model.set_tile(VoxelBlockyModel.SIDE_POSITIVE_X, Vector2i(textures["positive_x"][0], textures["positive_x"][1]))
			block_model.set_tile(VoxelBlockyModel.SIDE_NEGATIVE_X, Vector2i(textures["negative_x"][0], textures["negative_x"][1]))
			
			block_model.set_tile(VoxelBlockyModel.SIDE_POSITIVE_Y, Vector2i(textures["positive_y"][0], textures["positive_y"][1]))
			block_model.set_tile(VoxelBlockyModel.SIDE_NEGATIVE_Y, Vector2i(textures["negative_y"][0], textures["negative_y"][1]))
			
			block_model.set_tile(VoxelBlockyModel.SIDE_POSITIVE_Z, Vector2i(textures["positive_z"][0], textures["positive_z"][1]))
			block_model.set_tile(VoxelBlockyModel.SIDE_NEGATIVE_Z, Vector2i(textures["negative_z"][0], textures["negative_z"][1]))
			
			library.add_model(block_model)
			
			Global.block_types[i] = {"name": block["name"], "display_name": block["display_name"]}
			
			print(block["name"] + " added!")

	else:
		push_warning("Blocks cannot be loaded! Program exiting")
		get_tree().quit(-1)
	
	# Stone block (ID 1)
	'''var stone_model = VoxelBlockyModelCube.new()
	stone_model.atlas_size_in_tiles = Vector2i(16, 16)
	
	stone_model.set_tile(VoxelBlockyModel.SIDE_NEGATIVE_X, Vector2i(0, 1))
	stone_model.set_tile(VoxelBlockyModel.SIDE_POSITIVE_X, Vector2i(0, 1))
	stone_model.set_tile(VoxelBlockyModel.SIDE_NEGATIVE_Y, Vector2i(0, 1))
	stone_model.set_tile(VoxelBlockyModel.SIDE_POSITIVE_Y, Vector2i(0, 1))
	stone_model.set_tile(VoxelBlockyModel.SIDE_NEGATIVE_Z, Vector2i(0, 1))
	stone_model.set_tile(VoxelBlockyModel.SIDE_POSITIVE_Z, Vector2i(0, 1))
	
	library.add_model(stone_model)
	
	# Dirt block (ID 2)
	var dirt_model = VoxelBlockyModelCube.new()
	stone_model.atlas_size_in_tiles = Vector2i(16, 16)
	
	dirt_model.set_tile(VoxelBlockyModel.SIDE_NEGATIVE_X, Vector2i(0, 0))
	dirt_model.set_tile(VoxelBlockyModel.SIDE_POSITIVE_X, Vector2i(0, 0))
	dirt_model.set_tile(VoxelBlockyModel.SIDE_NEGATIVE_Y, Vector2i(0, 0))
	dirt_model.set_tile(VoxelBlockyModel.SIDE_POSITIVE_Y, Vector2i(0, 0))
	dirt_model.set_tile(VoxelBlockyModel.SIDE_NEGATIVE_Z, Vector2i(0, 0))
	dirt_model.set_tile(VoxelBlockyModel.SIDE_POSITIVE_Z, Vector2i(0, 0))
	
	library.add_model(dirt_model)
	
	# Grass block (ID 3)
	var grass_model = VoxelBlockyModelCube.new()
	stone_model.atlas_size_in_tiles = Vector2i(16, 16)
	
	grass_model.set_tile(VoxelBlockyModel.SIDE_NEGATIVE_X, Vector2i(1, 0))
	grass_model.set_tile(VoxelBlockyModel.SIDE_POSITIVE_X, Vector2i(1, 0))
	grass_model.set_tile(VoxelBlockyModel.SIDE_NEGATIVE_Y, Vector2i(0, 0))
	grass_model.set_tile(VoxelBlockyModel.SIDE_POSITIVE_Y, Vector2i(2, 0))
	grass_model.set_tile(VoxelBlockyModel.SIDE_NEGATIVE_Z, Vector2i(1, 0))
	grass_model.set_tile(VoxelBlockyModel.SIDE_POSITIVE_Z, Vector2i(1, 0))
	
	library.add_model(grass_model)'''

func setup_materials():
	terrain.material_override = terrain_material;

func regenerate_with_seed(new_seed: int):
	seed = new_seed
	setup_generator()
	# Force regeneration
	terrain.generator = terrain.generator

func save_world(file_path: String):
	terrain.save_modified_blocks()

func load_world(file_path: String):
	# World loading handled by VoxelStream
	pass
