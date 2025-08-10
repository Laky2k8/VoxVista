@tool
extends VoxelGenerator

var seed_value: int = 0
var _initialized: bool = false

const SEA_LEVEL = 64
const MOUNTAIN_THRESHOLD = 0.6
const DIRT_DEPTH = 4
const STONE_HEIGHT = 80

const BLOCK_AIR = 0
const BLOCK_STONE = 1
const BLOCK_DIRT = 2
const BLOCK_GRASS = 3

var height_noise: FastNoiseLite
var mountain_noise: FastNoiseLite
var cave_noise: FastNoiseLite

func _init():
	pass

func ensure_initialized():
	if not _initialized or not height_noise or not mountain_noise or not cave_noise:
		setup_noise()
		_initialized = true

func setup_noise():
	if height_noise:
		height_noise = null
	if mountain_noise:
		mountain_noise = null
	if cave_noise:
		cave_noise = null
	
	height_noise = FastNoiseLite.new()
	height_noise.seed = seed_value
	height_noise.frequency = 0.008
	height_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	height_noise.fractal_octaves = 3
	# height_noise.fractal_gain = 0.4
	height_noise.fractal_lacunarity = 2.0
	
	# Mountain noise 
	mountain_noise = FastNoiseLite.new()
	mountain_noise.seed = seed_value + 1000
	mountain_noise.frequency = 0.003 
	mountain_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	mountain_noise.fractal_octaves = 4
	# mountain_noise.fractal_gain = 0.6
	mountain_noise.fractal_lacunarity = 2.0
	
	# Underground cave noise
	cave_noise = FastNoiseLite.new()
	cave_noise.seed = seed_value + 2000
	cave_noise.frequency = 0.02
	cave_noise.noise_type = FastNoiseLite.TYPE_PERLIN

func _generate_block(buffer: VoxelBuffer, origin: Vector3i, lod: int):
	ensure_initialized()
	
	var size = buffer.get_size()
	
	for x in range(size.x):
		for z in range(size.z):
			var world_x = origin.x + x
			var world_z = origin.z + z
			
			# Get terrain height at this position
			var terrain_height = get_terrain_height(world_x, world_z)
			
			for y in range(size.y):
				var world_y = origin.y + y
				var block_type = get_block_type(world_x, world_y, world_z, terrain_height)
				buffer.set_voxel(block_type, x, y, z, VoxelBuffer.CHANNEL_TYPE)

func get_terrain_height(world_x: int, world_z: int) -> int:
	var base_height_noise = height_noise.get_noise_2d(world_x, world_z)
	
	var mountain_height_noise = mountain_noise.get_noise_2d(world_x, world_z)
	
	var base_height = SEA_LEVEL + (base_height_noise * 20)
	
	# Add mountains only where mountain noise is high
	var mountain_factor = 0.0
	if mountain_height_noise > MOUNTAIN_THRESHOLD:
		# Smooth transition into mountain areas
		mountain_factor = (mountain_height_noise - MOUNTAIN_THRESHOLD) / (1.0 - MOUNTAIN_THRESHOLD)
		mountain_factor = smoothstep(0.0, 1.0, mountain_factor)  # Smooth the transition
	
	# Add mountain height
	var mountain_height = mountain_factor * 60  
	
	return int(base_height + mountain_height)

func get_block_type(world_x: int, world_y: int, world_z: int, terrain_height: int) -> int:
	# Air above terrain
	if world_y > terrain_height:
		return BLOCK_AIR
	
	# Underground caves
	if cave_noise:
		var cave_value = cave_noise.get_noise_3d(world_x, world_y, world_z)
		if world_y < terrain_height - 5 and cave_value > 0.6:
			return BLOCK_AIR
	
	# Surface block (grass on top)
	if world_y == terrain_height:
		# Grass only grows at reasonable heights and not on steep slopes
		if terrain_height < STONE_HEIGHT and terrain_height > SEA_LEVEL - 5:
			# Check if surface is flat enough for grass
			var nearby_height1 = get_terrain_height(world_x + 1, world_z)
			var nearby_height2 = get_terrain_height(world_x, world_z + 1)
			var slope = abs(terrain_height - nearby_height1) + abs(terrain_height - nearby_height2)
			
			if slope <= 2:  # Relatively flat surface
				return BLOCK_GRASS
			else:
				return BLOCK_STONE  # Rocky slopes
		else:
			return BLOCK_STONE  # High altitude or underwater
	
	# Subsurface layers
	var depth_from_surface = terrain_height - world_y
	
	# Stone layer (mountains and deep underground)
	if terrain_height > STONE_HEIGHT or depth_from_surface > DIRT_DEPTH:
		return BLOCK_STONE
	
	# Dirt layer (shallow subsurface)
	return BLOCK_DIRT

# Required override - defines which channels this generator affects
func _get_used_channels_mask() -> int:
	return 1 << VoxelBuffer.CHANNEL_TYPE
