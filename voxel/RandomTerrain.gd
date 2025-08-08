extends Node3D

@export var use_random_seed: bool = true
@export var terrain_frequency: float = 0.01
@export var terrain_height_variation: float = 30.0

@onready var voxel_terrain: VoxelTerrain = $VoxelTerrain

func _ready():
	setup_procedural_terrain()

func setup_procedural_terrain():
	# Get the existing generator and noise
	var generator = voxel_terrain.generator as VoxelGeneratorNoise2D
	if not generator:
		print("Error: No VoxelGeneratorNoise2D found!")
		return
	
	var noise = generator.noise as FastNoiseLite
	if not noise:
		print("Error: No FastNoiseLite found!")
		return
	
	# Set random seed for each game launch
	if use_random_seed:
		var random_seed = randi()
		noise.seed = random_seed
		print("Generated terrain with seed: ", random_seed)
	
	# Configure noise for good terrain
	noise.frequency = terrain_frequency
	noise.fractal_octaves = 4
	noise.fractal_gain = 0.5
	
	var curve = Curve.new()
	curve.clear_points()
	
	# Create a curve to control terrain generationvar curve = Curve.new()
	curve.clear_points()
	
	# Define how noise values map to blocks:
	curve.add_point(Vector2(-1.0, 0.0))  # Low noise = air
	curve.add_point(Vector2(-0.3, 0.0))  # Still air
	curve.add_point(Vector2(-0.1, 1.0))  # Start grass blocks
	curve.add_point(Vector2(0.0, 1.0))   # Grass continues
	curve.add_point(Vector2(0.3, 2.0))   # Switch to stone
	curve.add_point(Vector2(1.0, 2.0))   # High noise = stone
	
	generator.height_range = 100
	generator.height_start = -50
	
	# Force regeneration
	generator.emit_changed()
	
	print("Procedural terrain configured!")

# Optional: Regenerate with space bar
func _input(event):
	if event.is_action_pressed("ui_accept"):
		setup_procedural_terrain()
