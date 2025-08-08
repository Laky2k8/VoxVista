@tool
class_name RandomVoxelTerrain
extends VoxelGenerator

# Size of each chunk in voxels (e.g., 16x16x16)
@export var chunk_size := 16
# Maximum terrain height
@export var max_height := 64
# Scale for noise sampling (controls feature size)
@export var noise_scale := 0.1
# Octaves for noise detail
@export var noise_octaves := 4
# Persistence for octaves
@export var noise_persistence := 0.5
# Lacunarity for octaves
@export var noise_lacunarity := 2.0

# The OpenSimplexNoise resource
var noise = FastNoiseLite.new()

func _ready():
	# Configure noise parameters
	noise.seed = randi()
	noise.octaves = noise_octaves
	noise.persistence = noise_persistence
	noise.lacunarity = noise_lacunarity
	noise.period = 1.0 / noise_scale

# This function is called by the VoxelTerrain node for each chunk
func generate_chunk(pos: Vector3i, buffer: VoxelBuffer):
	# pos is the chunk coordinates; convert to world offset
	var world_offset = pos * chunk_size
	# Iterate through every voxel in the chunk
	for x in range(chunk_size):
		for z in range(chunk_size):
			# Compute world x,z
			var world_x = world_offset.x + x
			var world_z = world_offset.z + z
			# Sample noise to get height between -1..1, remap to 0..max_height
			var n = noise.get_noise_2d(world_x, world_z)
			var height = int(((n + 1.0) * 0.5) * max_height)
			# Fill voxels up to the computed height
			for y in range(chunk_size):
				var world_y = world_offset.y + y
				if world_y <= height:
					buffer.set_voxel(x, y, z, 1)  # 1 = solid block
				else:
					buffer.set_voxel(x, y, z, 0)  # 0 = air

# Optional: Implement fallback for unsupported regions
func get_used_channels():
	return PackedStringArray([VoxelBuffer.CHANNEL_TYPE])
