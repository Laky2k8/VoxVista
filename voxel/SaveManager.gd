extends Node
class_name SaveManager

# TO SAVE THE WORLDS, THERE IS ONLY ONE WAY.
# THE SAVEMANAGER CLASS MUST BE ADDED TO THE WORLD NODE.
# ONLY THEN, WILL THE WORLDS BE SAVED.
# - John Deltarune, 2025

@onready var terrain: VoxelTerrain = get_parent().get_node("VoxelTerrain")

var save_directory: String = "user://worlds/"
var current_world_name: String = "default_world"

func _ready():
	ensure_save_directory()
	setup_stream()

func ensure_save_directory():
	print("Ensuring save directory exists...")
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("worlds"):
		dir.make_dir("worlds")

func setup_stream():
	print("Setting up world...")
	var stream = VoxelStreamSQLite.new()
	stream.database_path = save_directory + current_world_name + ".db"
	terrain.stream = stream

func save_world():
	print("Saving world: ", current_world_name)
	terrain.save_modified_blocks()

func load_world(world_name: String):
	current_world_name = world_name
	setup_stream()
	print("Loaded world: ", world_name)

func create_new_world(world_name: String, seed: int):
	current_world_name = world_name
	get_parent().current_seed = seed
	get_parent().regenerate_with_seed(seed)
	setup_stream()
	print("Created new world: ", world_name, " with seed: ", seed)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_world()
