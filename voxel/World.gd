extends Node3D
class_name VoxelWorld

@onready var terrain: VoxelTerrain = $VoxelTerrain
@onready var terrain_material = load("res://voxel/material/VoxelMat.tres")
var current_seed: int = 0

func _ready():
	setup_terrain()
	setup_generator()
	setup_mesher()
	setup_materials()

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
	noise.seed = current_seed
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
	
	# Stone block (ID 1)
	var stone_model = VoxelBlockyModelCube.new()
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
	
	library.add_model(grass_model)

func setup_materials():
	terrain.material_override = terrain_material;

func regenerate_with_seed(new_seed: int):
	current_seed = new_seed
	setup_generator()
	# Force regeneration
	terrain.generator = terrain.generator

func save_world(file_path: String):
	terrain.save_modified_blocks()

func load_world(file_path: String):
	# World loading handled by VoxelStream
	pass
